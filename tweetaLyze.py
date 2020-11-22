#add long BEARER_TOKEN from https://developer.twitter.com/en/portal/register/welcome as environment variable
#https://github.com/twitterdev/Twitter-API-v2-sample-code/blob/master/Sampled-Stream/sampled-stream.py
import requests
import os
import json
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
