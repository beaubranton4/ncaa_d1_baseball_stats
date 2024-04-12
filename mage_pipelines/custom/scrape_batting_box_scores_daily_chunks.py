from bs4 import BeautifulSoup
import requests
import time
from datetime import datetime
import pandas as pd
import re
from requests import Session
from datetime import datetime, timedelta
from google.cloud import storage
from os import path
from mage_ai.settings.repo import get_repo_path
import urllib.parse
import os

if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


# GET request options
_HEADERS = {'User-Agent': 'Mozilla/5.0'}

# Define variables for ingestion script
sport_code = "MBA"
academic_year = "2024"
division = "1"

#Open webpage and locate home and away tables to scrape boxstats
def get_stats(url):
    with Session() as s:
        r = s.get('https://stats.ncaa.org'+url, headers=_HEADERS)
    if r.status_code == 403:
        print('An error occurred with the GET Request')
        print('403 Error: NCAA blocked request')
    soup = BeautifulSoup(r.text, features='lxml')
    tables = soup.find_all("table")

    away_table = tables[5]
    home_table = tables[6]

    away_df = scrape_box_stats(away_table)
    home_df = scrape_box_stats(home_table)

    return away_df, home_df

def scrape_box_stats(table):
    headers = [header.text for header in table.find('tr', {'class': 'grey_heading'}).find_all('th')]        
    data = []
    for row in table.find_all('tr', {'class': 'smtext'}):
        data.append([cell.text.strip().split('/')[0] for cell in row.find_all('td')])  # Split at '/' for dirty data and take the first part
    df = pd.DataFrame(data, columns=headers)
    df = df.replace('', 0)
    return df

def get_team_names(table_html):
    # Parse the HTML content
    soup = BeautifulSoup(table_html, 'html.parser')

    # Find the table rows
    rows = soup.find_all('tr')

    # Get the team names and remove the record in parentheses
    away_team_name = rows[1].find('a').text.rsplit(' (', 1)[0].strip()
    home_team_name = rows[2].find('a').text.rsplit(' (', 1)[0].strip()

    return {"Away Team": away_team_name, "Home Team": home_team_name}

def get_game_info(table_html):
    # Parse the HTML content
    soup = BeautifulSoup(table_html, 'html.parser')

    # Find the table rows
    rows = soup.find_all('tr')
    # Get the game date, location, and attendance (if the data is available)
    if len(rows)>=3:     
        game_date = rows[0].find_all('td')[1].text.strip()
        location = rows[1].find_all('td')[1].text.strip()
        attendance = rows[2].find_all('td')[1].text.strip()
    elif len(rows) == 2:
        # Case: len(rows) = 2
        game_date = rows[0].find_all('td')[1].text.strip()
        location = rows[1].find_all('td')[1].text.strip()
        attendance = None
    elif len(rows) == 1:
        # Case: len(rows) = 1
        game_date = rows[0].find_all('td')[1].text.strip()
        location = None
        attendance = None
    else:
        # Case: len(rows) = 0
        game_date, location, attendance = None, None, None

    return {"Game Date": game_date, "Location": location, "Attendance": attendance}

def get_box_score_links(html):
    # Parse the HTML content
    soup = BeautifulSoup(html, 'html.parser')
    # Find all the 'a' tags
    a_tags = soup.find_all('a')
    # Get the links that contain "box_score"
    links = [a['href'] for a in a_tags if "box_score" in a['href']]
    return links


@custom
def load_data(game_date, *args, **kwargs):
    # Start the timer
    start_time = time.time()

    print(f"Scraping all games on {game_date}. It may take a few minutes to scrape all games on given day...")
    base_url = "https://stats.ncaa.org/contests/livestream_scoreboards"       
    params = {
        "utf8": "✓",
        "sport_code": sport_code,
        "academic_year": academic_year,
        "division": division,
        "game_date": game_date,
    }
    
    with Session() as s:
        r = s.get(base_url, params=params, headers=_HEADERS)
    if r.status_code == 403:
        print('An error occurred with the GET Request')
        print('403 Error: NCAA blocked request')    
    
    num_games = 0 
    final_batting_df = pd.DataFrame()
    #Retrieve all links to game box score webpages
    game_links = get_box_score_links(r.text) 
    for game in game_links:
        num_games+=1
        url = 'https://stats.ncaa.org'+game
        # print(f"Getting stats from: {url}")      
        #------------------------GET URLS FOR BATTING,PITCHING,FIELDING
        with Session() as s:
            r = s.get(url, headers=_HEADERS)
        if r.status_code == 403:
            print('An error occurred with the GET Request')
            print('403 Error: NCAA blocked request')
  
        soup = BeautifulSoup(r.text, features='lxml')
        
        # Find the table element that contains the player data
        tables = soup.find_all("table")
        
        team_names = get_team_names(tables[0].prettify())
        game_info = get_game_info(tables[2].prettify())
        stat_type = tables[4].find_all('a')
        
        #Store URLs for batting
        url = stat_type[0]['href']

        # Get the home and away stats for each stat type  
        away_df, home_df = get_stats(url)  
  
        #Add additional fields
        away_df['game_id'] =  int(re.search(r'\d+', game).group())
        home_df['game_id'] = int(re.search(r'\d+', game).group())
        away_df['team'] = team_names["Away Team"]
        home_df['team'] = team_names["Home Team"]
        away_df['date'] = game_date
        home_df['date'] = game_date
        away_df['location'] = game_info["Location"]
        home_df['location'] = game_info["Location"]
        away_df['attendance'] = game_info["Attendance"]
        home_df['attendance'] = game_info["Attendance"]
        away_df['side'] = 'Visitor'
        home_df['side'] = 'Home'
        
        # Append away and home stats to the final dataframe
        final_batting_df = pd.concat([final_batting_df, away_df, home_df])
    print(f"Finished scraping data from {num_games} games on {game_date}")
    
    # End the timer and print the elapsed time
    end_time = time.time()
    print(f"Time taken: {end_time - start_time} seconds")

    return final_batting_df

# @test
# def test_output(output, *args) -> None:
#     """
#     Template code for testing the output of the block.
#     """
#     assert output is not None, 'The output is undefined'
