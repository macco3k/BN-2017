# require(gRain);
library(bnlearn)

data_path = 'D:\\OneDrive\\Documenti\\Radboud\\2017\\Bayesian Networks\\Assignment 1\\data\\cpt'
data_path = 'data/cpt'

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
  
ny <- c("no", "yes")
g <- c("action","dark","light","other")
bog <- c("bad", "ok", "great")
lah <- c("low", "avg", "high")

d <- read.csv(file.path(data_path, 'major.csv'))
cptMajor <- matrix(d$X0, ncol=2, dimnames=list(NULL, ny))

d <- read.csv(file.path(data_path, 'macro_genre-major.csv'))
cptGenre <- data.matrix(d$X0)
dim(cptGenre) = c(4,2)
dimnames(cptGenre)=list("genre"=g, "major"=ny)

# d <- read.csv(file.path(data_path, 'cast_popularity_binned.csv'))
# cptCast <- matrix(d$X0, ncol=3, dimnames=list(NULL, c("1st","2nd","3rd")))
# 
# data <- read.csv(file.path(data_path, 'vote_average_binned.csv'))
# vote_avg <- cptable(~vote_avg, values=data$X0)

d <- read.csv(file.path(data_path, 'budget_binned-major,macro_genre.csv'))
cptBudget <- data.matrix(d$X0)

dim(cptBudget) = c(3,4,2)
dimnames(cptBudget) = list("budget"=lah,"genre"=g, "major"=ny)

net = model2network("[major][genre][budget|major:genre]")
dfit = custom.fit(net, dist=list(major=cptMajor, genre=cptGenre, budget=cptBudget))
dfit

# defining the network arcs from the picture

defined_net_string = "[major][genre|major][budget|major:genre][us|major][cast_popularity|budget][vote_avg_community][vote_avg_critics][movie_popularity|vote_avg_critics:vote_avg_community:cast_popularity:genre:us][vote_count_community|movie_popularity][vote_count_critics|movie_popularity][revenue|movie_popularity]"
defined_net = model2network(defined_net_string)
graphviz.plot(defined_net)

fitted = custom.fit(defined_net, list(
  major = cptMajor,
  genre = cptGenre,
  budget = cptBudget
))
















