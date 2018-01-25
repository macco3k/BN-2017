# require(gRain);
library(pcalg)
library(bnlearn)
library(Rgraphviz)

# Change this to yours!
root_path = 'D:\\Documents\\Github\\BN-2017'
# root_path = '~/Documents/RU/BN/BN-2017'
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

nlev <- c(2,4,3,2,3,3,3,3,3,4)
names(t) = c('major','genre','budget','us','cast_popularity','community_vote', 'community_count', 'critics_vote', 'critics_count', 'roi')

graph.par(list(nodes=list(fontsize=36)))

suffStat = list(dm=t, nlev=nlev, adaptDF=FALSE)
pc_net = pc(suffStat, indepTest = disCItest, alpha=0.05, labels=colnames(t), verbose=TRUE)

hiton_net = si.hiton.pc(t, undirected = FALSE, test="mi", debug = TRUE)
graphviz.plot(hiton_net)

tabu_net = tabu(t)
graphviz.plot(tabu_net)

hill_climbing_net = hc(t, restart = 1000, optimized = TRUE)
graphviz.plot(hill_climbing_net)

