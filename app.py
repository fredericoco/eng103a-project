# install flask with pip install flask
from config_manager import itjobswatch_home_page_url
from src.itjobswatch_html_readers.itjobswatch_home_page_top_30 import ItJobsWatchHomePageTop30
from src.csv_generators.top_30_csv_generator import Top30CSVGenerator
from flask import Flask, render_template, request, redirect, send_file
import os
import pandas as pd
import time
import shutil

categories = {
  'All':0,
  'Application Platforms': 1400,
  'Applications': 100,
  'Business Applications': 2200,
  'Cloud Services': 4000,
  'Communications & Networking': 1000,
  'Database & Business Intelligence': 500,
  'Development Applications': 1500,
  'General': 3000,
  'Job Titles': 2400,
  'Libraries, Frameworks & Software Standards': 1300,
  'Miscellaneous': 2000,
  'Operating Systems': 800,
  'Processes & Methodologies': 700,
  'Programming Languages': 900,
  'Qualifications': 1100,
  'Quality Assurance & Compliance': 1200,
  'System Software': 2300,
  'System Management': 2500,
  'Vendors': 300
}

app = Flask(__name__)
# creating an app instance
# use a decorator @ to define the route for our web page
@app.route("/", methods=['GET', 'POST'])
# setting up a default page
def index():
    for root, dirs, files in os.walk('recentcsv/'):
        for file in files:
            os.remove(os.path.join(root, file))
    top_30 = ItJobsWatchHomePageTop30(itjobswatch_home_page_url())
    timestr = time.strftime("%Y%m%d-%H%M%S")
    if request.method == "POST":
        Top30CSVGenerator().generate_top_30_csv(ItJobsWatchHomePageTop30(itjobswatch_home_page_url() + "/default.aspx?q=&ql=&l=&ll=&id=" + str(categories[request.form['category']]) + "&p=6&e=5&sortby=&orderby=").get_top_30_table_elements_into_array(), os.path.expanduser('csvfiles/'), timestr + ".csv") #, top_30.get_table_headers_array())
        data = pd.read_csv('csvfiles/' + timestr + '.csv', header=None, encoding='ISO-8859-1')
        data.columns=["", "Ranking Over Last 6 Months (up to 8 March 2022)", "YoY (Year-over-Year) Change","Median Salary","Median Salary YoY (Year-over-Year) Change","Total Unique Permanent Jobs During 6 Month Period","Current Live Jobs"]
        shutil.copy('csvfiles/' + timestr + '.csv', 'recentcsv/recentcsv.csv')
        # return render_template('index.html', myData=[data.values], columns=data.columns)
        return render_template('index.html', myData=[data.values], columns=data.columns)
    else: 
        Top30CSVGenerator().generate_top_30_csv(ItJobsWatchHomePageTop30(itjobswatch_home_page_url()).get_top_30_table_elements_into_array(), os.path.expanduser('csvfiles/'), timestr + ".csv") #, top_30.get_table_headers_array())
        data = pd.read_csv('csvfiles/' + timestr + '.csv', header=None, encoding='ISO-8859-1')
        data.columns=["", "Job Ranking Over Last 6 Months (up to 8 March 2022)", "YoY (Year-over-Year) Change","Median Salary","Median Salary YoY (Year-over-Year) Change","Total Unique Permanent Jobs During 6 Month Period","Current Live Jobs"]
        shutil.copy('csvfiles/' + timestr + '.csv', 'recentcsv/recentcsv.csv')
        return render_template('index.html', myData=[data.values], columns=data.columns)

@app.route("/download/", methods=['GET', 'POST'])
def download():
    if request.method == 'GET':
        return send_file('recentcsv/recentcsv.csv',
                        mimetype='text/csv',
                        attachment_filename='top30jobs.csv',
                        as_attachment=True)


@app.route("/team/")
def team():
    return render_template('team.html')
    
@app.route("/test/")
def team2():
    return render_template('test.html')

@app.route("/tools/")
def tools():
    return render_template("tools.html")


if __name__ == "__main__":
    app.run(host="0.0.0.0")


