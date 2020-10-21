# coded by Jian ZHOU
# Jian ZHOU 51404140 jzh210@uclive.ac.nz
# This code is to deal with NLP analysis, by reading text data from files
#https://www.displayr.com/sentiment-word-clouds-r/
#https://github.com/PoLabs/flipTextAnalysis
#library(flipTextAnalysis)
library(readr)
#library(rtweet)
library(tidyverse)

#term <- "Trump" #Trump"
#search.term <- paste("#", term, " ", term, sep = '')
#tweet_df <- search_tweets(search.term, n = 2000, include_rts = TRUE)
# I added search term and other user defined words to stop words
term <- "voice"
stop_list <-c(term, "https", "http", "null", "add", "plot", "full", "summary")
stop_words <- ""
for(n in 1:length(stop_list))
{
	if(n != 1)
		stop_words = paste(stop_words, "|", stop_list[n], sep = '')
	else
		stop_words = stop_list[n]
}
# I assemble the word list to regex string
stop_words <- paste("(?i)(", stop_words, ")", sep = '')

text <- read_file("data/character2020.txt") #character.txt")

text.to.analyze <- ""
#for(n in 1:nrow(tweet_df['text']))
#{
	#text.to.analyze = paste(text.to.analyze, str_remove_all(tweet_df[n,'text'], stop_words))
#}
# now we can remove stopwords
text.to.analyze = str_remove_all(text, stop_words)
 
# Converting the text to a vector
text.to.analyze <- as.character(text.to.analyze)

# Extracting the words from the text
library(flipTextAnalysis)
options = GetTextAnalysisOptions(phrases = '', 
                                 extra.stopwords.text = 'amp',
                                 replacements.text = '',
                                 do.stem = TRUE,
                                 do.spell = TRUE)
text.analysis.setup = InitializeWordBag(text.to.analyze, min.frequency = 5.0, operations = options$operations, manual.replacements = options$replacement.matrix, stoplist = options$stopwords, alphabetical.sort = FALSE, phrases = options$phrases, print.type = switch("Word Frequencies", "Word Frequencies" = "frequencies", "Transformed Text" = "transformations")) 
 
# Sentiment analysis of the phrases 
phrase.sentiment = SaveNetSentimentScores(text.to.analyze, check.simple.suffixes = TRUE, blanks.as.missing = TRUE) 
phrase.sentiment[phrase.sentiment >= 1] = 1
phrase.sentiment[phrase.sentiment <= -1] = -1
 
# Sentiment analysis of the words
final.tokens <- text.analysis.setup$final.tokens
td <- t(vapply(text.analysis.setup$transformed.tokenized, function(x) {
    as.integer(final.tokens %in% x)
}, integer(length(final.tokens))))
counts <- text.analysis.setup$final.counts 
phrase.word.sentiment <- sweep(td, 1, phrase.sentiment, "*")
phrase.word.sentiment[td == 0] <- NA # Setting missing values to Missing
word.mean <- apply(phrase.word.sentiment,2, FUN = mean, na.rm = TRUE)
word.sd <- apply(phrase.word.sentiment,2, FUN = sd, na.rm = TRUE)
word.n <- apply(!is.na(phrase.word.sentiment),2, FUN = sum, na.rm = TRUE)
word.se <- word.sd / sqrt(word.n)
word.z <- word.mean / word.se
word.z[word.n <= 3 || is.na(word.se)] <- 0        
words <- text.analysis.setup$final.tokens
x <- data.frame(word = words, 
      freq = counts, 
      "Sentiment" = word.mean,
      "Z-Score" = word.z,
      Length = nchar(words))
word.data <- x[order(counts, decreasing = TRUE), ]
 
# Working out the colors
n = nrow(word.data)
colors = rep("grey", n)
colors[word.data$Z.Score < -.06] = "Red"
colors[word.data$Z.Score > .06] =  "Green"
 
# Creating the word cloud
library(wordcloud2)
wordcloud2(data = word.data[, -3], color = colors, size = 0.4)