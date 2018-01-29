# require(gRain);
library(pcalg)
library(bnlearn)
library(Rgraphviz)

intersection <- function(m1,m2){
  m <- rbind(m1,m2)
  m <- m[duplicated(m), , drop=FALSE]
}

count_vstructs <- function(g1, g2){
  v1 <- vstructs(g1)
  v2 <- vstructs(g2)
  
  v <- intersection(v1,v2)
  
  if(dim(v1)[1] > dim(v2)[1])
    c('g1>g2', dim(v1)[1] - dim(v)[1])
  else
    c('g2>g1', dim(v2)[1] - dim(v)[1])
}

# compute difference in arcs between g1 and g2 (not working)
count_arcs <- function(g1, g2){
  a1 <- g1$arcs
  a2 <- g2$arcs
  
  a <- intersection(a1,a2)
  
  if(dim(a1)[1] > dim(a2)[1])
    c('g1>g2', dim(a1)[1] - dim(a)[1])
  else
    c('g2>g1', dim(a2)[1] - dim(a)[1])
}

# return the set of independencies for a graph

# Change this to yours!
root_path = 'D:\\Documents\\Github\\BN-2017'
# root_path = '~/Documents/RU/BN/BN-2017'
data_path = file.path(root_path, 'data')

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
         'roi')]#,
         #'revenue')]
         # 'popularity_binned')]

nlev <- c(2,4,3,2,3,3,3,3,3,4)
names(t) = c('major','genre','budget','us','cast_popularity','community_vote', 'community_count', 'critics_vote', 'critics_count', 'roi')

graph.par(list(nodes=list(fontsize=36)))

# pc algorithm
# t_pc <- data.frame(t)
# for(name in names(t_pc)){
#   f <- as.factor(t_pc[[name]])
#   levels(f) <- 1:length(levels(f))
#   f <- as.numeric(f)-1
#   t_pc[name] <- f
# }
# 
# suffStat = list(dm=t_pc, nlev=nlev, adaptDF=FALSE, labels=names)
# pc_net = pc(suffStat, indepTest = disCItest, alpha=0.05, labels=colnames(t), verbose=TRUE)
# plot(pc_net, main = "")

hiton_net = si.hiton.pc(t, undirected = FALSE, optimized=FALSE,test="x2", debug = TRUE, alpha=0.05)
graphviz.plot(hiton_net)

hiton_opt_net = si.hiton.pc(t, undirected = FALSE, optimized=TRUE,test="x2", debug = TRUE, alpha=0.05)
graphviz.plot(hiton_opt_net)

# tabu_net = tabu(t)
# graphviz.plot(tabu_net)

hc_net = hc(t, restart = 1, optimized = TRUE)
graphviz.plot(hc_net)

defined_net_string = "[major][genre|major][budget|major:genre:us][us|major][cast_popularity|budget:us][community_count|us:genre:budget:cast_popularity][community_vote|community_count:critics_vote][critics_count|us:genre:budget][critics_vote|critics_count:budget][roi|cast_popularity:community_vote:critics_vote]"
defined_net = model2network(defined_net_string)

graphviz.compare(cpdag(hc_net), cpdag(defined_net))
graphviz.compare(cpdag(hiton_opt), cpdag(defined_net))

hamming(cpdag(hc_net),cpdag(defined_net))
hamming(cpdag(hiton_opt_net),cpdag(defined_net))
