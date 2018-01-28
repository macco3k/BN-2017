# require(gRain);
library(pcalg)
library(bnlearn)
library(Rgraphviz)

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
    c('g1>g2', dim(v1)[1] - dim(v)[1])
  else
    c('g2>g1', dim(v2)[1] - dim(v)[1])
}

# compute difference in arcs between g1 and g2
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
         'roi')]#,
         #'revenue')]
         # 'popularity_binned')]

nlev <- c(2,4,3,2,3,3,3,3,3,4)#,3)
names(t) = c('major','genre','budget','us','cast_popularity','community_vote', 'community_count', 'critics_vote', 'critics_count', 'roi')#,'revenue')

t_pc <- data.frame(t)
for(name in names(t_pc)){
  f <- as.factor(t_pc[[name]])
  levels(f) <- 1:length(levels(f))
  f <- as.numeric(f)-1
  t_pc[name] <- f
}

graph.par(list(nodes=list(fontsize=36)))

hiton_net = si.hiton.pc(t, undirected = FALSE, test="x2", debug = TRUE, alpha=0.01)
graphviz.plot(hiton_net)

hc_net = hc(t, restart = 10, optimized = TRUE)
graphviz.plot(hill_climbing_net)

