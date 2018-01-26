# require(gRain);
library(pcalg)
library(bnlearn)
library(Rgraphviz)
library(foreach)

count_vstructs <- function(g1, g2){
  v1 <- vstructs(g1)
  v2 <- vstructs(g2)
  
  # compute the intersection
  v <- rbind(v1,v2)
  v <- v[duplicated(v), , drop=FALSE]
  
  if(dim(v1)[1] > dim(v2)[1])
    dim(v1)[1] - dim(v)[1]
  else
    dim(v2)[1] - dim(v)[1]
}

intersection <- function(m1,m2){
  # compute the intersection
  m <- rbind(m1,m2)
  m <- m[duplicated(m), , drop=FALSE]
}

count_vstructs <- function(g1, g2){
  v1 <- vstructs(g1)
  v2 <- vstructs(g2)
  
  v <- intersection(v1,v2)
  
  if(dim(v1)[1] > dim(v2)[1])
    dim(v1)[1] - dim(v)[1]
  else
    dim(v2)[1] - dim(v)[1]
}

count_arcs <- function(g1, g2){
  a1 <- g1$arcs
  a2 <- g2$arcs
  
  a <- intersection(a1,a2)
  
  if(dim(a1)[1] > dim(a2)[1])
    dim(a1)[1] - dim(a)[1]
  else
    dim(a2)[1] - dim(a)[1]
}

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

t_pc <- data.frame(t)
for(name in names(t_pc)){
  f <- as.factor(t_pc[[name]])
  levels(f) <- 1:length(levels(f))
  f <- as.numeric(f)-1
  t_pc[name] <- f
}

graph.par(list(nodes=list(fontsize=36)))

suffStat = list(dm=t_pc, nlev=nlev, adaptDF=FALSE, labels=names)
pc_net = pc(suffStat, indepTest = chisq.test, alpha=0.05, labels=colnames(t), verbose=TRUE)
plot(pc_net, main = "")

hiton_net = si.hiton.pc(t, undirected = FALSE, test="mi", debug = TRUE, alpha=0.05)
graphviz.plot(hiton_net)

hiton_hc_net = hc(t, restart = 1000, optimized = TRUE, whitelist = hiton_net$arcs)
graphviz.plot(hiton_net)

tabu_net = tabu(t)
graphviz.plot(tabu_net)

hill_climbing_net = hc(t, restart = 1000, optimized = TRUE)
graphviz.plot(hill_climbing_net)

