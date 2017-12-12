# require(gRain);
library(bnlearn)
library(Rgraphviz)

root_path = 'D:\\PyCharm\\BayesNet_Movies\\Bayesian_github\\BN-2017'
data_path = file.path(root_path, 'data')

# Read CSV into R
# major,
# vote_avg,
# genre|major,
# us|major,
# cast_popularity|budget,
# budget|major,genre
# vote_count_community|movie_popularity
# vote_count_critics|movie_popularity
# revenue|movie_popularity
  
# ny <- c("no", "yes")
# g <- c("action","dark","light","other")
# bog <- c("bad", "ok", "great")
# lah <- c("low", "avg", "high")
# 
# d <- read.csv(file.path(data_path, 'major.csv'))
# cptMajor <- matrix(d$X0, ncol=2, dimnames=list(NULL, ny))
# 
# d <- read.csv(file.path(data_path, 'macro_genre-major.csv'))
# cptGenre <- data.matrix(d$X0)
# dim(cptGenre) = c(4,2)
# dimnames(cptGenre)=list("genre"=g, "major"=ny)
# 
# # d <- read.csv(file.path(data_path, 'cast_popularity_binned.csv'))
# # cptCast <- matrix(d$X0, ncol=3, dimnames=list(NULL, c("1st","2nd","3rd")))
# # 
# # data <- read.csv(file.path(data_path, 'vote_average_binned.csv'))
# # vote_avg <- cptable(~vote_avg, values=data$X0)
# 
# d <- read.csv(file.path(data_path, 'budget_binned-major,macro_genre.csv'))
# cptBudget <- data.matrix(d$X0)
# 
# dim(cptBudget) = c(3,4,2)
# dimnames(cptBudget) = list("budget"=lah,"genre"=g, "major"=ny)

# net = model2network("[major][genre][budget|major:genre]")
# dfit = custom.fit(net, dist=list(major=cptMajor, genre=cptGenre, budget=cptBudget))
# dfit

# defining the network arcs from the picture

defined_net_string = "[major][genre|major][budget|major:genre][us|major][cast_popularity|budget][community_vote][critics_vote][movie_popularity|cast_popularity:critics_vote:community_vote:genre:us][community_count|movie_popularity][critics_count|movie_popularity][revenue|movie_popularity]"
defined_net = model2network(defined_net_string)
# graphviz.plot(defined_net)

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
         'revenue_binned',
         'popularity_binned')]

names(t) = c('major','genre','budget','us','cast_popularity','community_vote', 'community_count', 'critics_vote', 'critics_count', 'revenue', 'movie_popularity')
fitted <- bn.fit(defined_net, data=t)

# TODO test independences
# Look into bnlearn::ci.test or chisq.test
implications <- list(c("revenue","budget","major","genre","cast_popularity"),
                     c("revenue","budget","genre","us","cast_popularity"),
                     c("revenue","budget","movie_popularity"),
                     c("revenue","genre","movie_popularity"),
                     c("revenue","major","us","genre","budget"),
                     c("revenue","major","cast_popularity","genre","us"),
                     c("revenue","major","movie_popularity"),
                     c("revenue","us","movie_popularity"),
                     c("revenue","cast_popularity","movie_popularity"),
                     c("revenue","community_vote","movie_popularity"),
                     c("revenue","critics_vote","movie_popularity"),
                     c("revenue","community_count","movie_popularity"),
                     c("revenue","critics_count","movie_popularity"),
                     c("budget","us","major"),
                     c("budget","movie_popularity","genre","cast_popularity","us"),
                     c("budget","movie_popularity","genre","cast_popularity","major"),
                     c("budget","community_vote"),
                     c("budget","critics_vote"),
                     c("budget","community_count","movie_popularity"),
                     c("budget","community_count","genre","cast_popularity","us"),
                     c("budget","community_count","genre","cast_popularity","major"),
                     c("budget","critics_count","movie_popularity"),
                     c("budget","critics_count","genre","cast_popularity","us"),
                     c("budget","critics_count","genre","cast_popularity","major"),
                     c("genre","us","major"),
                     c("genre","cast_popularity","budget"),
                     c("genre","community_vote"),
                     c("genre","critics_vote"),
                     c("genre","community_count","movie_popularity"),
                     c("genre","critics_count","movie_popularity"),
                     c("major","movie_popularity","genre","cast_popularity","us"),
                     c("major","movie_popularity","genre","us","budget"),
                     c("major","cast_popularity","budget"),
                     c("major","community_vote"),
                     c("major","critics_vote"),
                     c("major","community_count","movie_popularity"),
                     c("major","community_count","genre","cast_popularity","us"),
                     c("major","community_count","genre","us","budget"),
                     c("major","critics_count","movie_popularity"),
                     c("major","critics_count","genre","cast_popularity","us"),
                     c("major","critics_count","genre","us","budget"),
                     c("us","cast_popularity","budget"),
                     c("us","cast_popularity","major"),
                     c("us","community_vote"),
                     c("us","critics_vote"),
                     c("us","community_count","movie_popularity"),
                     c("us","critics_count","movie_popularity"),
                     c("cast_popularity","community_vote"),
                     c("cast_popularity","critics_vote"),
                     c("cast_popularity","community_count","movie_popularity"),
                     c("cast_popularity","critics_count","movie_popularity"),
                     c("community_vote","critics_vote"),
                     c("community_vote","community_count","movie_popularity"),
                     c("community_vote","critics_count","movie_popularity"),
                     c("critics_vote","community_count","movie_popularity"),
                     c("critics_vote","critics_count","movie_popularity"),
                     c("community_count","critics_count","movie_popularity"))
count <- 1
citest_list <- list()
for (line in implications)
{
  citest_list[[paste(count)]] <- ci.test(x = line[1] , y = line[2], z = c(line[-1:-2]), data = t)
  count <- count+1
}

for (i in 1:length(citest_list))
{
  cat ("\nnumber ",i," : ",citest_list[[i]]$p.value, " --- ", citest_list[[i]]$data.name)
}

# TODO inference
# - predict a movie's popularity
#   - see http://www.bnlearn.com/documentation/man/cpquery.html for inference given evidence (or not)
#   - see http://www.bnlearn.com/documentation/man/rbn.html for generating data from the network
# - predict the prior for popularity
#   - cpquery(fitted, event=(movie_popularity=='high'), evidence=TRUE) #no evidence
# - ask the network to get the cpt for popularity (assuming we don't have the movie_popularity column)
#   - see http://www.bnlearn.com/documentation/man/impute.html
# - predict arc strength
#   - look into bnlearn::coefficients and bnlearn::arc.strength