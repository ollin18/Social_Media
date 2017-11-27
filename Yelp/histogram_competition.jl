using OhMyREPL
using Plots
pyplot()

competition = readdlm("competition.txt",'\t')
cafe_21 = readdlm("../scraper/cafe_21_reviews_user.csv",'|')
chevrolet = readdlm("../scraper/chevrolet.csv",'|')
competition = readdlm("chevrolet.txt",'\t')
dentist = readdlm("../scraper/cynthia-cheung-dds-los-angeles.csv",'|')
competition = readdlm("dentist.txt",'\t')

stars = dentist[2:end,7]
mean_stars = mean(stars)
length(stars)
avg_stars = competition[1]
histogram(stars,bins=5,alpha=0.6,title="Star histogram for dentist LA",lab="Star count",xticks=((1:5)+0.5,1:5),normalize=true,ylims=(0,1))
vline!([avg_stars],line=(4,0.6,:dash,:red),lab="Mean competition")
vline!([mean_stars],line=(4,0.6,:dash,:green),lab="Mean self")
xaxis!("Stars")
yaxis!("Count")
savefig("dentist.png")
