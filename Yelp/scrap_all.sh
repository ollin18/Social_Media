#!/usr/bin/env bash
while read p;do
./yelpscraper.jl $p -o $p.csv
sleep $[ ( $RANDOM % 360 )  + 1 ]s
cp $p.csv /data_scrap
done <followthis.txt
