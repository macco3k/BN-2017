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


##############################################################################
##############################################################################
##############################################################################

graph.par(list(nodes=list(fontsize=56)))

suffStat = list(dm=t, nlev=nlev, adaptDF=FALSE)
pc_net = pc(suffStat, indepTest = disCItest, alpha=0.05, labels=colnames(t), verbose=TRUE)

hiton_net = si.hiton.pc(t, undirected = FALSE, test="mi", debug = TRUE)
graphviz.plot(hiton_net)

tabu_net = tabu(t)
graphviz.plot(tabu_net)



##############################################################################
##############################################################################
##############################################################################
defined_net_string = "[major][genre|major][budget|major:genre:us][us|major][cast_popularity|budget:us][community_count|us:genre:budget:cast_popularity][community_vote|community_count:critics_vote][critics_count|us:genre:budget][critics_vote|critics_count:budget][roi|cast_popularity:community_vote:critics_vote]"
defined_net = model2network(defined_net_string)
graphviz.plot(defined_net)

graph.par(list(nodes=list(fontsize=56)))
hill_climbing_net = hc(t, restart = 50, optimized = TRUE, perturb = 5)
graphviz.plot(hill_climbing_net)

graph.par(list(nodes=list(fontsize=26)))
hiton_net = si.hiton.pc(t, undirected = FALSE, test="mi", debug = TRUE)
graphviz.plot(hiton_net)

ham = hamming(defined_net, hill_climbing_net, debug = TRUE)
ham

ham = hamming(hiton_net, hill_climbing_net, debug = TRUE)
ham


ham = hamming(defined_net, hiton_net, debug = TRUE)
ham

##############################################################################
##############################################################################
##############################################################################

graph.par(list(nodes=list(fontsize=56)))
hc_net_log = hc(t, restart = 50, optimized = TRUE, perturb = 5, score = 'loglik')
graphviz.plot(hc_net_log)

graph.par(list(nodes=list(fontsize=56)))
hc_net_bic = hc(t, restart = 50, optimized = TRUE, perturb = 5, score = 'bic')
graphviz.plot(hc_net_bic)

graph.par(list(nodes=list(fontsize=56)))
hc_net_aic = hc(t, restart = 50, optimized = TRUE, perturb = 5, score = 'aic')
graphviz.plot(hc_net_aic)

ham = hamming(hc_net_log, hc_net_bic, debug = TRUE)
ham
graph.par(list(nodes=list(fontsize=56)))
graphviz.compare(hc_net_bic, hc_net_log)


ham = hamming(hc_net_log, hc_net_aic, debug = TRUE)
ham
graphviz.compare(hc_net_aic, hc_net_log)


ham = hamming(hc_net_bic, hc_net_aic, debug = TRUE)
ham
graphviz.compare(hc_net_bic, hc_net_aic)




