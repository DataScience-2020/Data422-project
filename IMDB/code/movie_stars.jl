# coded by Jian ZHOU
# Jian ZHOU 51404140 jzh210@uclive.ac.nz
# This Julia code extract movie and characters / cast members from IMDB, and save the data incrementally to csv files.
# By the nature of this design, we could run this code in multiple instances at the same time / multitasking for each year's web scraping.
using Pkg 
#Pkg.add("HTTP")
#Pkg.add("Gumbo")
#Pkg.add("Cascadia")
using HTTP, Gumbo, Cascadia

#define website host address
host = "https://www.imdb.com"

using Query, CSV, DataFrames, StringEncodings

#Here I define some functions to facilitate information extraction from html nodes.

#The first one is called node_text and it takes two parameters, namely the css selector matching string and the parent node. With the help of this function, we don't have to write so much code again to deal with array index out of bounds / mismatching exceptions. In such cases, it returns an empty string.

#The second one is called get_match and it takes two parameters, namely the regex group result and the index number. Before we use this function, we want to match some string / digital patterns in groups, and pass it to get_match function to get the matched string.

function node_text(match, node, tidy = true, index = 1)
    text = ""
    try
        text = nodeText(eachmatch(Selector(match), node)[index])
        if tidy
            text = replace(text, r"\W+" => " ")
        end
        return strip(text)
    catch
        return text
    end
end

function get_match(result, index = 1)
    match = ""
    #for m in result.captures
        #match = m
    #end
    if result != nothing
        match = result[index]
    end
    return match
end

#write dataframe to a file in a incremental way
function write_csv(file, df)
	file = "data/"*file
    try
        CSV.write(file, df, header = !isfile(file), append = true)
    catch
        return
    end
end

#write text to a file in a incremental way
function write_txt(file, txt)
	file = "data/"*file
    try
        io = open(file,"a")
        write(io, txt)
        close(io)
    catch
        return
    end
end

#The following functions are defined to deal with numerous of data type conversions. Practically we don't want to see exceptions when null / empty values are passed to the standard parse funciton.
function to_Int16(value)
    try
        return parse(Int16, value)
    catch
        return 0
    end
end

function to_Float16(value)
    try
        return parse(Float16, value)
    catch
        return 0
    end
end

function to_Int(value)
    try
        return parse(Int, value)
    catch
        return 0
    end
end


#get imdb movie cast list
function page_cast(id, year, link)
    #sleep(2)
    #println(id, title, year, link)
    imdb_page = HTTP.get(link)
    parsed_page = imdb_page.body |>
        String |>
        parsehtml
    
    # we create a selector to get the thing we want
    sel_for_content = Selector(".cast_list tr")
    # and we extract each matching node in the XML document
    imdb_html_contents = eachmatch(sel_for_content, parsed_page.root)
    
    # data frames of cast are defined for characters.
    df_cast = DataFrame(ID = String[], Year = String[], Actor = String[], Character = String[])
    characters = ""
    for imdb_character in imdb_html_contents
        #println(imdb_character)
        node = eachmatch(Selector("td"), imdb_character) #[1].attributes["href"]
        if length(node) > 1
            name = node_text("a", node[2])
            character = node_text("a", node[4])
            if character == ""
                character = node_text(".character", imdb_character)
            end
            
            #add data to cast dataframe
            push!(df_cast, (id, year, name, character))
            #println(name, ":",character)
            characters = characters*" "*character
        end
    end
    
    return df_cast, characters
end


#get imdb movie list

function page_movie(root, year_str)
    # we create a selector to get the thing we want
    sel_for_content = Selector(".lister-item-content")
    # and we extract each matching node in the XML document
    imdb_html_contents = eachmatch(sel_for_content, root) #parsed_page.root)
    #imdb_html_contents
	next_page = ""
	pager_nodes = eachmatch(Selector(".lister-page-next"), root) #[1].attributes["href"]
	#println(pager_nodes)
	if length(pager_nodes) > 0 
		next_page = pager_nodes[1].attributes["href"]
	end
	#println("next page:", next_page)

    # data frames of movies and stars are defined respectively.
    df_movies = DataFrame(ID = String[], Title = String[], Year = String[], Certificate = String[], 
        Runtime = Int16[], Genre = String[], Rating = String[], Score = Int16[], Vote = Int[])

    df_stars = DataFrame(ID = String[], Director1 = String[], Director2 = String[], Star1 = String[], 
        Star2 = String[], Star3 = String[], Star4 = String[])

    movie_desc = ""
    for imdb_movie in imdb_html_contents
        href = eachmatch(Selector(".lister-item-header a"), imdb_movie)[1].attributes["href"]
        #println(href)
        m1 = match(r"\/(title)\/(.*)\/" , href)
        #get name of the movie
        title = node_text(".lister-item-header a", imdb_movie) 
        #get year of the movie
        year = node_text(".lister-item-header .lister-item-year", imdb_movie, false)
        m2 = match(r"(\d+)" , year)
        #println(m1[2], title, m2[1])

        #get movie description
        description = node_text("p", imdb_movie, true, 2)
        movie_desc = movie_desc*"\n"*description
        #get certificate of the movie
        certificate = node_text(".text-muted .certificate", imdb_movie, false)
        #get runtime of the movie
        runtime = node_text(".text-muted .runtime", imdb_movie, false)
        m3 = match(r"(\d+)", runtime)
        #get genre of the movie
        genre = node_text(".text-muted .genre", imdb_movie)
        #println(certificate, genre, get_match(m3))

        #get rating of the movie
        rating = node_text(".ratings-bar .ratings-imdb-rating", imdb_movie, false)
        #get score of the movie
        score = node_text(".ratings-bar .ratings-metascore .metascore", imdb_movie, false)
        #println(rating, score)

        #get vote of the movie
        vote = node_text(".sort-num_votes-visible [name = 'nv']", imdb_movie, false)
        #println(replace(vote, "," => ""))

        #add data to the movie dataframe
        push!(df_movies, (get_match(m1,2), title, get_match(m2), certificate, to_Int16(get_match(m3)), 
                genre, rating, to_Int16(score), to_Int(replace(vote, "," => ""))))


        #dir_dict dictionary is defined for directors
        dir_dict = Dict([(1, ""), (2, "")])
        #star_dict dictionary is defined for stars
        star_dict = Dict([(1, ""), (2, ""), (3, ""), (4, "")])
        stars = eachmatch(Selector("p"), imdb_movie)
        #println(stars[3])
        #parse the node that has the mixed information of directors and stars 
        director = true
        index = 0
        for star in eachmatch(Selector("a, span"), stars[3])
            if nodeText(star) == "|"
                director = false
                index = 0
            else
                index += 1
                if director
                    dir_dict[index] = nodeText(star)
                else
                    star_dict[index] = nodeText(star)
                end
            end
            #println(director, nodeText(star))

        end

        #add data to star dataframe
        push!(df_stars, (get_match(m1,2), dir_dict[1], dir_dict[2], star_dict[1], 
                star_dict[2], star_dict[3], star_dict[4]))
        
        #df_cast, character = page_cast(get_match(m1,2), title, get_match(m2), host*href)
        #write_csv("cast.csv", df_cast)
        #write_txt("character.txt", character*"\n")
        
        #println(size(df_cast)[1], size(df_cast)[2])

    end
    
    write_csv("movie.csv", df_movies)
    write_csv("stars.csv", df_stars)
    write_txt("descr_"*year_str*".txt", movie_desc)
    #df_movies
    return df_movies, df_stars, next_page
end

#This is the main function to be called to scrape movies
function scrape_movie(year_begin = 2010, year_end = 2020, list_num = 200)
	#year_begin = 2010
	#year_end = 2020
	#list_num = 200

	#host = "https://www.imdb.com/"
	#get html content and parse it into html content for each year and page
	for year in year_begin:year_end
		next = true
		next_page = ""
        param = string(year)*"-01-01,"*string(year)*"-12-31&count="*string(list_num)*
                "&start=1&ref_=adv_nxt"
		link = host*"/search/title/?title_type=feature&release_date="*param
	    while next
	        if next_page != ""
				link = host*next_page
			end
	        println(link)
	        #sleep(3)
	        imdb_page = HTTP.get(link)
	        parsed_page = imdb_page.body |>
	            String |>
	            parsehtml
        
	        df_movie, df_star, next_page = page_movie(parsed_page.root, string(year))
			if next_page == ""
				next = false
			end
	        #if size(df_movie)[1] < 200
	            #break
				#end
	    end
	end
end

#scrape_movie(2017)

#This is the main function to be called to scrape cast members
function scrape_cast(years)
	movie_df = CSV.File(open(read, "data/movie.csv", enc"ISO-8859-1")) |> DataFrame
	#https://www.imdb.com/title/tt10682266/
	for row in eachrow(movie_df)
		if !ismissing(row[3]) && row[3] in years
	    	println(row[3], " : ", host*"/title/"*row[1])
	        df_cast, character = page_cast(row[1], string(row[3]), host*"/title/"*row[1])
	        write_csv("cast.csv", df_cast)
	        write_txt("character"*string(row[3])*".txt", character*"\n")
		end
	end
end

years = [2020] #, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020]
scrape_cast(years)
