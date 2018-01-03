# require(gRain);
library(bnlearn)
library(Rgraphviz)

# Change this to yours!
# root_path = 'D:\\Documents\\Github\\BN-2017'
root_path = '~/Documents/RU/BN/BN-2017'
data_path = file.path(root_path, 'data')

# source(file.path(root_path, 'helper.r'))


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


hiton_net = si.hiton.pc(t, undirected = FALSE, test="x2")
graphviz.plot(net)

tabu_net = tabu(t)
graphviz.plot(tabu_net)

hill_climbing_net = hc(t, restart = 1000, optimized = TRUE)
graphviz.plot(hill_climbing_net)

