#!/usr/bin/env python
import tweepy
from tweepy import OAuthHandler
import json
from credentials import *
import time
import os
import sys
import argparse
import datetime
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument("username",type=str, help="Insert Twitter username")
parser.add_argument("--limit", nargs='?', const=200, type= int, help="Number\
        of returned tweets. Max 2500.")
args = parser.parse_args()
args.username=str(args.username)
if args.limit > 2500:
    args.limit = 2500

auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_secret)
api = tweepy.API(auth)

def giveme_tweets(screen_name):
    tweets = []
    new_tweets = api.user_timeline(screen_name = screen_name,count=199)
    tweets.extend(new_tweets)
    oldest = tweets[-1].id - 1
    if args.limit < 2500:
        while len(tweets) < args.limit:
            try:
                #all subsiquent requests use the max_id param to prevent duplicates
                new_tweets = api.user_timeline(screen_name = screen_name,count=199,max_id=oldest)
                tweets.extend(new_tweets)
                oldest = tweets[-1].id - 1
            except:
                time.sleep(60)
                continue
        tweets = tweets[0:args.limit]
        with open('%s.json' % args.username,'a') as f:
            for tweet in tweets:
                f.write(str(tweet._json)+'\n')
    else:
        while len(new_tweets) > 0:
            try:
                #all subsiquent requests use the max_id param to prevent duplicates
                new_tweets = api.user_timeline(screen_name = screen_name,count=199,max_id=oldest)
                tweets.extend(new_tweets)
                oldest = tweets[-1].id - 1
            except:
                time.sleep(60)
                continue
        with open('%s.json' % args.username,'a') as f:
            for tweet in tweets:
                f.write(str(tweet._json)+'\n')

giveme_tweets(args.username)
