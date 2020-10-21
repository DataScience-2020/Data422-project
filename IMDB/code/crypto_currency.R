# coded by Jian ZHOU
# Jian ZHOU 51404140 jzh210@uclive.ac.nz
# This code is tested to get data from cryptocurrency web page by using xpath from XML package
# Linda decided to use API methods later on because she didn't get variance of changes at a short time period
library(XML)

url <- "https://coinmarketcap.com/all/views/all/"
source <- readLines(url, encoding = "UTF-8", warn=FALSE)
parsed_doc <- htmlParse(source, encoding = "UTF-8")

#strip off non numeric characters but keep sign symbols
num_strip <- function(x)
{
	gsub("[^0-9.-]", "", x)
}

#main function to parse web page
parse_page <- function()
{
	df <- data.frame()
	#//*[@id="__next"]/div[1]/div[2]/div[1]/div[2]/div/div[2]/div[3]/div/table/thead/tr/th[2]
	path <- '//*[@id="__next"]/div[1]/div[2]/div[1]/div[2]/div/div[2]/div[3]/div/table/thead/tr/th['
	header <- c()
	for(i in 1:10)
	{
		path_cell <- paste(path, i, ']')
		cell <- xpathSApply(parsed_doc, path = path_cell, xmlValue)
		header <-c(header, cell)
		
	}
	print(header)
	#colnames(df) <- header
	if(length(header) != 10)
		return
	
	for(i in 1:200)
	{
		
		
		path <- paste('//*[@id="__next"]/div[1]/div[2]/div[1]/div[2]/div/div[2]/div[3]/div/table/tbody/tr[', i, ']/td[')
		#print(path)
		#page <- xpathSApply(parsed_doc, path = path, xmlValue)
		#print(page)
		for(j in 1:10)
		{
			path_cell <- paste(path, j, ']')
			#print(path_cell)
			cell <- xpathSApply(parsed_doc, path = path_cell, xmlValue)
			#print(cell)
			if(j == 2 || j == 3)
				df[i, j] <- cell
			else
				df[i, j] <- num_strip(cell)
		}
	}
	colnames(df) <- header
	df
}
#save data incrementally to csv file
save_data <- function()
{
	data <- parse_page()
	write.table(data, "crypto_currency.csv", sep = ",", col.names = !file.exists('crypto_currency.csv'),row.names = F, append = T)
}
#loop function to get data at a given time interval
for(n in 1:1000)
{
	#format(Sys.time())
	Sys.sleep(10)
	save_data()
	Sys.sleep(60*30)
}


#//*[@id="__next"]/div[1]/div[2]/div[1]/div[2]/div/div[2]/div[3]/div/table/thead/tr
#//*[@id="__next"]/div[1]/div[2]/div[1]/div[2]/div/div[2]/div[3]/div/table/tbody/tr[1]

#//*[@id="__next"]/div[1]/div[2]/div[1]/div[2]/div/div[2]/div[3]/div/table/tbody/tr[1]/td[1]
#//*[@id="__next"]/div[1]/div[2]/div[1]/div[2]/div/div[2]/div[3]/div/table/tbody/tr[1]/td[10]