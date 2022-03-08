# install flask with pip install flask
from config_manager import itjobswatch_home_page_url
from src.itjobswatch_html_readers.itjobswatch_home_page_top_30 import ItJobsWatchHomePageTop30
from src.csv_generators.top_30_csv_generator import Top30CSVGenerator
import os
from flask import Flask, render_template
import pandas as pd

app = Flask(__name__)
# creating an app instance

# use a decorator @ to define the route for our web page
@app.route("/")
# setting up a default page
def index():
    top_30 = ItJobsWatchHomePageTop30(itjobswatch_home_page_url())
    Top30CSVGenerator().generate_top_30_csv(ItJobsWatchHomePageTop30(itjobswatch_home_page_url()).get_top_30_table_elements_into_array(), os.path.expanduser('top30/'), 'ItJobsWatchTop30.csv') #, top_30.get_table_headers_array())
    data = pd.read_csv('top30/ItJobsWatchTop30.csv', header=None, encoding= 'unicode_escape')
    data.columns=["", "Job Ranking Over Last 6 Months (up to 8 March 2022)", "YoY (Year-over-Year) Change","Median Salary","Median Salary YoY (Year-over-Year) Change","Total Unique Permanent Jobs During 6 Month Period","Current Live Jobs"]
    return render_template('index.html', myData=[data.values], columns=data.columns)
    



@app.route("/team/")
def team():
    return render_template('team.html')

@app.route("/tools/")
def tools():
    return render_template("tools.html")

# @app.route("/tables")
# def table():
#     top_30 = ItJobsWatchHomePageTop30(itjobswatch_home_page_url())
#     Top30CSVGenerator().generate_top_30_csv(ItJobsWatchHomePageTop30(itjobswatch_home_page_url()).get_top_30_table_elements_into_array(), os.path.expanduser('top30/'), 'ItJobsWatchTop30.csv') #, top_30.get_table_headers_array())
#     data = pd.read_csv('top30/ItJobsWatchTop30.csv', header=None)
#     data.columns=["", "Job Ranking Over Last 6 Months (up to 8 March 2022)", "YoY (Year-over-Year) Change","Median Salary","Median Salary YoY (Year-over-Year) Change","Total Unique Permanent Jobs During 6 Month Period","Current Live Jobs"]
#     return render_template('tables.html', myData=[data.values], columns=data.columns)
    

