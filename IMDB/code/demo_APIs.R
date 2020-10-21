# This code is modified from Sarah's code to test API request
# https://data.linz.govt.nz/layer/53353-nz-street-address/webservices/
# https://help.koordinates.com/query-api-and-web-services/vector-query/
# https://data.linz.govt.nz/services/query/v1/vector.json?&d8f0a0e7e3be4827875c7938b79f17a3&layer=53353&x=172.6332999999969&y=-43.53330000000021&max_results=3&radius=10000&geometry=true&with_field_names=true

library(httr)
library(jsonlite)
library(httr)
library(rvest)

#API_Key <- "d8f0a0e7e3be4827875c7938b79f17a3"
API_Key <- "e696bb728443441c98ebf397e19cafdf"
layer <- "layer=53353"  
x <- "x=172.6332999999969"
y <- "y=-43.53330000000021"
max_results <- "max_results=3"
radius <- "radius=10000"
geometry <- "geometry=true"
with_field_names <- "with_field_names=true"

url <- paste("https://data.linz.govt.nz/services/query/v1/vector.json?",
             key,
             layer,
             x,
             y,
             max_results,
             radius,
             geometry,
             with_field_names,
             sep = "&")

response <- GET(url)
print(url)
#response <- GET(url, user_agent("httr"))
response


# Install RSelenium if required. You will need phantomjs in your path or follow instructions
# in package vignettes
# devtools::install_github("ropensci/RSelenium")
# login first
appURL <- 'http://subscribers.footballguys.com/amember/login.php'
library(RSelenium)
pJS <- phantom() # start phantomjs
remDr <- remoteDriver(browserName = "phantomjs")
remDr$open()
remDr$navigate(appURL)
remDr$findElement("id", "login")$sendKeysToElement(list("myusername"))
remDr$findElement("id", "pass")$sendKeysToElement(list("mypass"))
remDr$findElement("css", ".am-login-form input[type='submit']")$clickElement()

appURL <- 'http://subscribers.footballguys.com/myfbg/myviewprojections.php?projector=2'
remDr$navigate(appURL)
tableElem<- remDr$findElement("css", "table.datamedium")
res <- readHTMLTable(header = TRUE, tableElem$getElementAttribute("outerHTML")[[1]])

