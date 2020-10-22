# Data422-project
First repository on Github

# Project Name
>  Video Game Miners

## Table of contents
* [General info](#general-info)
* [Technologies](#technologies)
* [Setup](#setup)
* [Features](#features)
* [Status](#status)
* [Inspiration](#inspiration)
* [Contact](#contact)

## Sequence_of_Files_to-Run
The idea is to provide a platform to the game publisher to find the relevant characters & the countries to publish the new game. 
We have gathered the data from multiple sources, wrangle it, join it and made a meaningful information which can then be used for game publication. 

1. Run the IGDB Notebook under IGDB\Codes\IGDB_games_infor_scrap_main.ipynb
2. Run the IGDB Company_ID Notebook under IGDB\Codes\(unfinished)IGDB_company_id_underwork.ipynb
   2.1. Copy the data files 'game_ageRating', 'games_genres' & 'game_companies' from IGDB\Docs to IMDB\data
3. RUn the movie_stars.ipynb from \IMDB\code
4. This extract the movie data incuding actor, companies, games genres and their id. 
5. We have merged the data from IMDB with IGDB but the second step where the company id is suppose to be extracted from the keywords was not finished yet. 


## Technologies
* R
* Julia

## Setup
We have extensively used both R & Julia to scrape, wrangle and visualize the data. 
All the notebooks are in the Source directory along with the downloaded/extracted data. 
The notebooks does have the information about the installed packages. 

## Code Examples
The code snippets can be found in the /Source

## Features
List of features ready and TODOs for future development
* Game mined data
* Movies semantics data (extracted keywords/feature from the movie plots)
* GeoMapping to list countries on the map
* CyptoAnalyzer to list top authentics currencies being used

To-do list:
* Classify the game publisher w.r.t. regions and themes
* Enhance data visualization

## Status (_finished_)
_in progress_,
==> _finished_,
_no longer continue_,
_paused_,
_blocked 
 
The initial defined scope has been achieved and the project is finished; but we will keep it open for future reference.
This will give us an opportunity to be in touch with other group members and implement the new learnings down the road. 


## Inspiration
We all came up with different and unique ideas at the start and they all were so compelling that we end up adding them together. 


## Contact
* Christine: Shi Chen sch405@uclive.ac.nz
* Waqas: waqas.naveed@uclive.ac.nz
* Jay: Jian ZHOU
* Linda: Jiaying Zhu jzh209@uclive.ac.nz
* Sarah: Xiaohong Chen xch121@uclive.ac.nz
