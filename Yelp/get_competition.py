#!/usr/bin/env python
from __future__ import print_function
import sys
from yelpapi import YelpAPI
from credentials import *
import argparse
import json
import numpy as np
import math
from geopy.distance import vincenty

parser = argparse.ArgumentParser()
parser.add_argument("--id", help="Insert Yelp's id")
parser.add_argument("--rad", nargs='?', const=100, type=int, help="Insert query\
        radius. Maximum value is 40000 meters")
parser.add_argument("--limit", nargs='?', const=20, type= int, help="A limit of result per type of business\
        in id's description. Maximum value is 50")
args = parser.parse_args()

def eprint(*args,**kwargs):
    print(*args, file=sys.stderr,**kwargs)

if args.limit > 50:
    eprint("Max value for limit is 50, will continue with that")
    args.limit = 50
if args.rad > 40000:
    eprint("Max value for rad is 40000, will continue with that")
    args.limit = 40000

yelp_api = YelpAPI(CLIENT_ID, CLIENT_SECRET)
business = yelp_api.business_query(id=args.id)
business = yelp_api.business_query(id="saporé-san-diego")
city = business['location']['city']
lat = business['coordinates']['latitude']
lon = business['coordinates']['longitude']
categories = business['categories']
bus_type = list(map(lambda x: x['alias'],categories))
seen = set()
ratings = []
review_count = []
tot = 1
for different in range(len(bus_type)):
    similar = yelp_api.search_query(location=city,term=bus_type[different],limit=args.limit)
    competition = similar['businesses']
    for i in range(len(competition)):
        if competition[i]['id'] not in seen:
            seen.add(competition[i]['id'])
            lati = competition[i]['coordinates']['latitude']
            longi = competition[i]['coordinates']['longitude']
            if vincenty((lat,lon),(lati,longi)).meters <= args.rad:
                ratings.append(competition[i]['rating'])
                review_count.append(competition[i]['review_count'])
                tot += 1
if not math.isnan(np.mean(ratings)):
    eprint("Mean ratings", "Mean review counts", "Total business",sep='\t')
    print(np.mean(ratings), np.mean(review_count),tot,sep='\t')
else:
    eprint("No competition was found")
