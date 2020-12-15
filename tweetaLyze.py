#add long BEARER_TOKEN from https://developer.twitter.com/en/portal/register/welcome as environment variable
#https://github.com/twitterdev/Twitter-API-v2-sample-code/blob/master/Sampled-Stream/sampled-stream.py
import requests
import os
import json
print(os.environ.get("BEARER_TOKEN"))
#https://towardsdatascience.com/sentiment-analysis-for-stock-price-prediction-in-python-bed40c65d178
requests.get(
    'https://api.twitter.com/1.1/search/tweets.json?q=tesla',
    headers={
        'authorization': 'Bearer '+BEARER_TOKEN
})
params = {'q': 'tesla'
          'tweet_mode': 'extended'}
requests.get(
    'https://api.twitter.com/1.1/search/tweets.json',
    params=params,
    headers={'authorization': 'Bearer '+BEARER_TOKEN}
})
params = {
    'q': 'tesla',
    'tweet_mode': 'extended',
    'lang': 'en',
    'count': '100'
}
def get_data(tweet):
    data = {
        'id': tweet['id_str'],
        'created_at': tweet['created_at'],
        'text': tweet['full_text']
    }
    return data
df = pd.DataFrame()
for tweet in response.json()['statuses']:
    row = get_data(tweet)
    df = df.append(row, ignore_index=True)
#!pip install flair
import flair
sentiment_model = flair.models.TextClassifier.load('en-sentiment')
sentence = flair.data.Sentence(TEXT)
sentiment_model.predict(sentence)
whitespace = re.compile(r"\s+")
web_address = re.compile(r"(?i)http(s):\/\/[a-z0-9.~_\-\/]+")
tesla = re.compile(r"(?i)@Tesla(?=\b)")
user = re.compile(r"(?i)@[a-z0-9_]+")
#https://gist.githubusercontent.com/jamescalam/ea9f6acfaddee86b4e5b092eba8c3052/raw/08227fce29870a869cdff4962fa7b12c37aa9386/pull_week_tweets.py
from datetime import datetime, timedelta
import requests
import pandas as pd

# read bearer token for authentication
with open('bearer_token.txt') as fp:
    BEARER_TOKEN = fp.read()

# setup the API request
endpoint = 'https://api.twitter.com/2/tweets/search/recent'
headers = {'authorization': f'Bearer {BEARER_TOKEN}'}
params = {
    'query': '(tesla OR tsla OR elon musk) (lang:en)',
    'max_results': '100',
    'tweet.fields': 'created_at,lang'
}

dtformat = '%Y-%m-%dT%H:%M:%SZ'  # the date format string required by twitter

# we use this function to subtract 60 mins from our datetime string
def time_travel(now, mins):
    now = datetime.strptime(now, dtformat)
    back_in_time = now - timedelta(minutes=mins)
    return back_in_time.strftime(dtformat)

now = datetime.now()  # get the current datetime, this is our starting point
last_week = now - timedelta(days=7)  # datetime one week ago = the finish line
now = now.strftime(dtformat)  # convert now datetime to format for API

df = pd.DataFrame()  # initialize dataframe to store tweets

df = pd.DataFrame()  # initialize dataframe to store tweets
while True:
    if datetime.strptime(now, dtformat) < last_week:
        # if we have reached 7 days ago, break the loop
        break
    pre60 = time_travel(now, 60)  # get 60 minutes before 'now'
    # assign from and to datetime parameters for the API
    params['start_time'] = pre60
    params['end_time'] = now
    response = requests.get(endpoint,
                            params=params,
                            headers=headers)  # send the request
    now = pre60  # move the window 60 minutes earlier
    # iteratively append our tweet data to our dataframe
    for tweet in response.json()['data']:
        row = get_data(tweet)  # we defined this function earlier
        df = df.append(row, ignore_index=True)
tsla = yf.Ticker("TSLA")
tsla_stock = tsla.history(
    start=(data['created_at'].min()).strftime('%Y-%m-%d'),
    end=data['created_at'].max().strftime('%Y-%m-%d'),
    interval='60m'
).reset_index()
#!pip install yfinance
tsla = yf.Ticker("TSLA")
tsla_stock = tsla.history(
    start=(data['created_at'].min()).strftime('%Y-%m-%d'),
    end=data['created_at'].max().strftime('%Y-%m-%d'),
    interval='60m'
).reset_index()
#https://www.youtube.com/watch?v=DFtP1THE8fE&t=9s

# we then use the sub method to replace anything matching
tweet = whitespace.sub(' ', tweet)
tweet = web_address.sub('', tweet)
tweet = tesla.sub('Tesla', tweet)
tweet = user.sub('', tweet)
sentence = flair.data.Sentence(tweet)
sentiment_model.predict(sentence)
probability = sentence.labels[0].score  # numerical value 0-1
sentiment = sentence.labels[0].value  # 'POSITIVE' or 'NEGATIVE'
# we will append probability and sentiment preds later
probs = []
sentiments = []

# use regex expressions (in clean function) to clean tweets
tweets['text'] = tweets['text'].apply(clean)

for tweet in tweets['text'].to_list():
    # make prediction
    sentence = flair.data.Sentence(tweet)
    sentiment_model.predict(sentence)
    # extract sentiment prediction
    probs.append(sentence.labels[0].score)  # numerical score 0-1
    sentiments.append(sentence.labels[0].value)  # 'POSITIVE' or 'NEGATIVE'

# add probability and sentiment predictions to tweets dataframe
tweets['probability'] = probs
tweets['sentiment'] = sentiments

def auth():
    return os.environ.get("BEARER_TOKEN")
def create_url():
    return "https://api.twitter.com/2/tweets/sample/stream"
def create_headers(bearer_token):
    headers = {"Authorization": "Bearer {}".format(bearer_token)}
    return headers
def connect_to_endpoint(url, headers):
    response = requests.request("GET", url, headers=headers, stream=True)
    print(response.status_code)
    for response_line in response.iter_lines():
        if response_line:
            json_response = json.loads(response_line)
            print(json.dumps(json_response, indent=4, sort_keys=True))
    if response.status_code != 200:
        raise Exception(
            "Request returned an error: {} {}".format(
                response.status_code, response.text
            )
        )
bearer_token = auth()
url = create_url()
headers = create_headers(bearer_token)
timeout = 0
res=connect_to_endpoint(url, headers)
while True:
    connect_to_endpoint(url, headers)
    timeout += 1

#https://github.com/twitterdev/Twitter-API-v2-sample-code/blob/master/Recent-Search/recent_search.py
def auth():
    return os.environ.get("BEARER_TOKEN")

def create_url():
    query = "from:twitterdev -is:retweet"
    tweet_fields = "tweet.fields=author_id"
    url = "https://api.twitter.com/2/tweets/search/recent?query={}&{}".format(
        query, tweet_fields
    )
    return url

def create_headers(bearer_token):
    headers = {"Authorization": "Bearer {}".format(bearer_token)}
    return headers

def connect_to_endpoint(url, headers):
    response = requests.request("GET", url, headers=headers)
    print(response.status_code)
    if response.status_code != 200:
        raise Exception(response.status_code, response.text)
    return response.json()

def main():
    bearer_token = auth()
    url = create_url()
    headers = create_headers(bearer_token)
    json_response = connect_to_endpoint(url, headers)
    print(json.dumps(json_response, indent=4, sort_keys=True))
