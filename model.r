# require(gRain);
library(bnlearn)
library(Rgraphviz)

root_path = 'D:\\Documents\\Github\\BN-2017'
root_path = '~/Documents/RU/BN/BN-2017'
data_path = file.path(root_path, 'data')

source(file.path(root_path, 'testable_implications_v3a.r'))
source(file.path(root_path, 'helper.r'))

# defining the network arcs from the picture
# v2
# defined_net_string = "[major][genre|major][budget|major:genre][us|major][cast_popularity|budget][community_count|movie_popularity][community_vote][critics_vote|critics_count][critics_count][movie_popularity|critics_vote:community_count:community_vote:cast_popularity:genre:us][roi|movie_popularity]"

# v3
defined_net_string = "[major][genre|major][budget|major][us|major][cast_popularity|budget][community_count|us:genre:budget][community_vote|community_count][critics_count|us:genre:budget][critics_vote|critics_count][roi|cast_popularity:community_vote:critics_vote]"

defined_net = model2network(defined_net_string)
graphviz.plot(defined_net)

t <- read.csv(file.path(data_path, 'train.csv'))

t <- t[c('major', 
         'genre', 
         'budget',
         'us', 
         'cast_popularity', 
         'community_vote', 
         'community_count',
         'critics_vote',
         'critics_count',
         'roi')]
         # 'revenue_binned',
         # 'popularity_binned')]

names(t) = c('major','genre','budget','us','cast_popularity','community_vote', 'community_count', 'critics_vote', 'critics_count', 'roi')
fitted <- bn.fit(defined_net, data=t)

# TODO test independences
# Look into bnlearn::ci.test or chisq.test
implications <- getImplications()
count <- 1
citest_list <- c()
citest.p.value <- c()
citest.names <- c()
citest.rmsea <- c()

for (i in implications)
{
    # print(i)
    test <- ci.test(x = i[1] , y = i[2], z = c(i[-1:-2]), data = t, test="x2")
    citest_list[count] <- test
    citest.p.value[count] <- test$p.value
    
    # not that some numbers will be NaN, this is, according to some webstie overfit of the data
    # so we can safely ignore it
    
    citest.rmsea[count] <- max(sqrt( ((test$statistic/test$parameter) - 1 )/(3000 - 1)),0)
    citest.names[count] = test$data.name

    
    
    count <- count+1
}

rmsea = function(test) {
  max(sqrt( ((test$statistic/test$parameter) - 1 )/(3000 - 1)),0)
}

df <- data.frame(names=citest.names, p.value=citest.p.value)
df <- data.frame(names=citest.names, RMSEA=citest.rmsea)

# todo plot this with points and maybe prettier labels
op <- par(mar=c(11,4,4,2)) # the 10 allows the names.arg below the barplot

plot(df, las=2, xlab='')
rm(op)

# run the following code: to calculate the rmseas with higher dan 0.05
df[df["RMSEA"] > 0.05,]

# TODO inference
# - predict a movie's popularity
#   - see https://sujitpal.blogspot.nl/2013/07/bayesian-network-inference-with-r-and.html
#   - see http://www.bnlearn.com/documentation/man/cpquery.html for inference given evidence (or not)
#   - see http://www.bnlearn.com/documentation/man/rbn.html for generating data from the network
# - predict the prior for popularity
#   - cpquery(fitted, event=(movie_popularity=='high'), evidence=TRUE) #no evidence
# - ask the network to get the cpt for popularity (assuming we don't have the movie_popularity column)
#   - see http://www.bnlearn.com/documentation/man/impute.html


#What makes for a highly profitable movie?
# Pr(roi=high | genre=action) vs. Pr(roi=high | genre=light)
cpquery(fitted, (roi=='high'), (genre=='action'))
cpquery(fitted, (roi=='high'), (genre=='dark'))
cpquery(fitted, (roi=='high'), (genre=='light'))
cpquery(fitted, (roi=='high'), (genre=='other'))

#-----------------------------------------------------------------------------------------------------------

#What are the odds of making a high profit for a non-major company? What if we want to go for a niche movie?
#e.g. Pr(roi=high | major=no) vs. Pr(roi=~high | major=no)
cpquery(fitted, (roi=='high'), (major=='yes'))
cpquery(fitted, (roi!='high'), (major=='yes'))
cpquery(fitted, (roi=='high'), (major=='no'))
cpquery(fitted, (roi!='high'), (major=='no'))

#e.g. Pr(roi=high | major=no, genre=other) vs. Pr(roi=~high | major=no, genre=other)
cpquery(fitted, (roi=='high' & major=='no'), (genre=='action'))
cpquery(fitted, (roi=='high' & major=='no'), (genre=='dark'))
cpquery(fitted, (roi=='high' & major=='no'), (genre=='light'))
cpquery(fitted, (roi=='high' & major=='no'), (genre=='other'))
cpquery(fitted, (roi!='high'& major=='no'), (genre=='action'))

#-----------------------------------------------------------------------------------------------------------

#Does a highly popular cast get us higher votes? 
#e.g. Pr(critics_vote=great & community_vote=great | cast=high)
cpquery(fitted, (critics_vote=='great' & community_vote=='great'), (cast_popularity=='high'))
cpquery(fitted, (critics_vote=='great' | community_vote=='great'), (cast_popularity=='high'))

cpquery(fitted, (critics_vote=='great'), (cast_popularity=='high'))
cpquery(fitted, (community_vote=='great'), (cast_popularity=='high'))
cpquery(fitted, (critics_vote=='great'), (cast_popularity!='high'))
cpquery(fitted, (community_vote=='great'), (cast_popularity!='high'))

#e.g. Pr(critics_vote=great & community_vote=great | cast=~high)
cpquery(fitted, (critics_vote=='great' & community_vote=='great'), (cast_popularity!='high'))
cpquery(fitted, (critics_vote=='great' | community_vote=='great'), (cast_popularity!='high'))

cpquery(fitted, (critics_vote=='great' & community_vote=='great'), (cast_popularity=='high'))
cpquery(fitted, (critics_vote=='great' | community_vote=='great'), (cast_popularity=='high'))

#-----------------------------------------------------------------------------------------------------------
#How can we prevent our movie from being a flop?
#e.g. Pr(roi=~flop | genre=? & cast_popularity=?)
cpquery(fitted, (roi!='flop'), (genre=='action' & cast_popularity=='high'))
cpquery(fitted, (roi!='flop'), (genre=='dark' & cast_popularity=='high'))
cpquery(fitted, (roi!='flop'), (genre=='light' & cast_popularity=='high'))
cpquery(fitted, (roi!='flop'), (genre=='other' & cast_popularity=='high'))

cpquery(fitted, (roi!='flop'), (genre=='action' & cast_popularity!='high'))
cpquery(fitted, (roi!='flop'), (genre=='dark' & cast_popularity!='high'))
cpquery(fitted, (roi!='flop'), (genre=='light' & cast_popularity!='high'))
cpquery(fitted, (roi!='flop'), (genre=='other' & cast_popularity!='high'))

cpquery(fitted, (roi!='flop'), (genre=='action' ))
cpquery(fitted, (roi!='flop'), (genre=='dark' ))
cpquery(fitted, (roi!='flop'), (genre=='light' ))
cpquery(fitted, (roi!='flop'), (genre=='other' ))

#-----------------------------------------------------------------------------------------------------------
#Are highly popular actors worth it if we want a "great" review?
#e.g. Pr(critics_vote=great | cast=avg) vs. Pr(critics_vote=great | cast=high)

cpquery(fitted, (critics_vote=='great'), (cast_popularity=='high'))
cpquery(fitted, (critics_vote=='great'), (cast_popularity=='avg'))
cpquery(fitted, (critics_vote=='great'), (cast_popularity=='low'))

cpquery(fitted, (community_vote=='great'), (cast_popularity=='high'))
cpquery(fitted, (community_vote=='great'), (cast_popularity=='avg'))
cpquery(fitted, (community_vote=='great'), (cast_popularity=='low'))

cpquery(fitted, (community_vote=='great'& critics_vote=='great'), (cast_popularity=='high'))
cpquery(fitted, (community_vote=='great'& critics_vote=='great'), (cast_popularity=='avg'))
cpquery(fitted, (community_vote=='great'& critics_vote=='great'), (cast_popularity=='low'))

cpquery(fitted, (community_vote=='great' | critics_vote=='great'), (cast_popularity=='high'))
cpquery(fitted, (community_vote=='great' | critics_vote=='great'), (cast_popularity=='avg'))
cpquery(fitted, (community_vote=='great' | critics_vote=='great'), (cast_popularity=='low'))

#-----------------------------------------------------------------------------------------------------------








