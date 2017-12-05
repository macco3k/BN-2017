require(gRain);

data_path = 'D:\\OneDrive\\Documenti\\Radboud\\2017\\Bayesian Networks\\Assignment 1\\data\\cpt'
file.path(data_path, 'major.csv')

# Read CSV into R
# major,
# genre,
# cast_popularity,
# vote_avg,
# us|major,
# cast_popularity|genre
# budget|major, genre, cast_popularity
# movie_popularity|genre, us, cast_popularity, vote_avg_community, vote_avg_critics
# vote_count_community|movie_popularity
# vote_count_critics|movie_popularity
# revenue|movie_popularity
  
data <- read.csv(file.path(data_path, 'major.csv'))
major <- cptable(~major, values=data$X0)
data <- read.csv(file.path(data_path, 'us-major.csv'))
us.major <- cptable(~us|major, values=data$X0)
data <- read.csv(file.path(data_path, 'macro_genre-major.csv'))
major.macro_genre <- cptable(~genre|major, values=data$X0)
data <- read.csv(file.path(data_path, 'cast_popularity_binned-major.csv'))
major.cast_pop <- cptable(~cast_pop|major, values=data$X0)

data <- read.csv(file.path(data_path, 'macro_genre.csv'))
genre <- cptable(~genre, values=data$X0)
data <- read.csv(file.path(data_path, 'cast_popularity_binned-macro_genre.csv'))
cast_pop.genre <- cptable(~cast_pop|genre, values=data$X0, levels=unique(data$cast_pop))

data <- read.csv(file.path(data_path, 'cast_popularity_binned.csv'))
cast_pop <- cptable(~cast_pop, values=data$X0)

data <- read.csv(file.path(data_path, 'vote_average_binned.csv'))
vote_avg <- cptable(~vote_avg, values=data$X0)

data <- read.csv(file.path(data_path, 'budget_binned-major,macro_genre,cast_popularity_binned.csv'))
budget.major.genre.cast_pop <- cptable(~us|major, values=data$X0)


plist <- compileCPT(list(major, 
                         us.major, 
                         major.macro_genre, 
                         major.cast_pop, 
                         genre, 
                         cast_pop, 
                         cast_pop.genre, 
                         budget.major.genre.cast_pop,
                         vote_avg))

