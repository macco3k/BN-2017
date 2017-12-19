# require(gRain);
library(bnlearn)
library(Rgraphviz)

root_path = 'D:\\Documents\\Github\\BN-2017'
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
         'macro_genre', 
         'budget_binned',
         'us', 
         'cast_popularity_binned', 
         'vote_average_binned', 
         'vote_count_binned',
         'critics_vote_binned',
         'critics_count_binned',
         'roi_binned')]
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

for (i in implications)
{
    print(i)
    test <- ci.test(x = i[1] , y = i[2], z = c(i[-1:-2]), data = t, test="x2")
    citest_list[count] <- test
    citest.p.value[count] <- test$p.value
    citest.names[count] = test$data.name
    count <- count+1
}

df <- data.frame(names=citest.names, p.value=citest.p.value)
# todo plot this with points and maybe prettier labels
plot(df, las=2, xlab='')

# TODO inference
# - predict a movie's popularity
#   - see https://sujitpal.blogspot.nl/2013/07/bayesian-network-inference-with-r-and.html
#   - see http://www.bnlearn.com/documentation/man/cpquery.html for inference given evidence (or not)
#   - see http://www.bnlearn.com/documentation/man/rbn.html for generating data from the network
# - predict the prior for popularity
#   - cpquery(fitted, event=(movie_popularity=='high'), evidence=TRUE) #no evidence
# - ask the network to get the cpt for popularity (assuming we don't have the movie_popularity column)
#   - see http://www.bnlearn.com/documentation/man/impute.html