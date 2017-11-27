#!/usr/bin/env julia

using Gumbo
using Cascadia
using Requests
using ArgParse

parser = ArgParseSettings(description = "Scrap the reviews from a Yelp account.")

@add_arg_table parser begin
    "--output", "-o"
    "yelpid"
end

args = parse_args(parser)

output_file = get(args, "output", STDOUT)
if ===(output_file, nothing)
    output_file = STDOUT
else
    output_file = args["output"]
end

function debug(msg)
    write(STDERR, msg)
end

debug("Output File: $(output_file)\n")

function properties(s,n)
    try
        parse(Int64,nodeText(matchall(Selector(s),h.root)[n]))
    catch
        0
    end
end

function iselite(n)
    try
        nodeText(matchall(Selector(elite),h.root)[n])
        return 1
    catch
        0
    end
end

friends = "li [class^='friend-count responsive-small-display-inline-block'] b"
many_reviews = "li [class^='review-count responsive-small-display-inline-block'] b"
photos = "li [class^='photo-count responsive-small-display-inline-block'] b"
elite = "li [class^='is-elite responsive-small-display-inline-block'] a"

k = args["yelpid"]

r = get("https://www.yelp.com/biz/"*k)
h = parsehtml(String(copy(r.data)))
number = matchall(Selector("span[itemprop^='reviewCount']"),h.root)
number = parse(Int64,nodeText(number[1]))
pages = collect(20:20:number);
reviews = matchall(Selector("div[itemprop^='review']"),h.root)
the_good_ones = collect(1:2:39);
names = Array{String}(number)
location = Array{String}(number)
friend_count = Array{Int64}(number)
review_count = Array{Int64}(number)
photo_count = Array{Int64}(number)
is_elite = Array{Int64}(number)
stars = Array{Float64}(number)
dates = Array{String}(number)
the_review = Array{Any}(number)
n = 1
m = 1
for each ∈ the_good_ones
    try
        names[n]=reviews[each][1].attributes["content"]
        location[n] = nodeText(matchall(Selector("li[class^='user-location responsive-hidden-small']"),h.root)[m])
        friend_count[n] = properties(friends,m)
        review_count[n] = properties(many_reviews,m)
        photo_count[n] = properties(photos,m)
        is_elite[n] = iselite(m)
        stars[n]=parse(Float64,reviews[each][2][1].attributes["content"])
        dates[n]=reviews[each][3].attributes["content"]
        the_review[n]=replace(nodeText(reviews[each][4]),r"\n","")
        n+=1
        m+=1
    end
end
for page ∈ pages
    r = get("https://www.yelp.com/biz/"*k*"?start=$page")
    h = parsehtml(String(copy(r.data)))
    reviews = matchall(Selector("div[itemprop^='review']"),h.root)
    m = 1
    for each ∈ the_good_ones
        try
            names[n]=reviews[each][1].attributes["content"]
            location[n] = nodeText(matchall(Selector("li[class^='user-location responsive-hidden-small']"),h.root)[m])
            friend_count[n] = properties(friends,m)
            review_count[n] = properties(many_reviews,m)
            photo_count[n] = properties(photos,m)
            is_elite[n] = iselite(m)
            stars[n]=parse(Float64,reviews[each][2][1].attributes["content"])
            dates[n]=reviews[each][3].attributes["content"]
            the_review[n]=replace(nodeText(reviews[each][4]),r"\n","")
            n+=1
            m+=1
        end
    end
end

data = hcat(names,location,friend_count,review_count,photo_count,is_elite,stars,dates,the_review)
headers = ["names","location","friend_count","review_count","photo_count","is_elite","stars","date","the_review"]
headers = reshape(headers,1,9)
the_data = vcat(headers,data)
writedlm(output_file, the_data,'|')
