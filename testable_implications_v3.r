getImplications <- function(){
  implications <- implications <- list(c("budget","community_vote","community_count"),
                                       c("budget","critics_vote","critics_count"),
                                       c("budget","roi","cast_popularity","critics_vote","community_vote"),
                                       c("budget","roi","community_vote","cast_popularity","critics_count"),
                                       c("budget","roi","cast_popularity","critics_vote","community_count"),
                                       c("budget","roi","cast_popularity","community_count","critics_count"),
                                       c("cast_popularity","community_count","budget"),
                                       c("cast_popularity","community_vote","community_count"),
                                       c("cast_popularity","community_vote","budget"),
                                       c("cast_popularity","critics_count","budget"),
                                       c("cast_popularity","critics_vote","critics_count"),
                                       c("cast_popularity","critics_vote","budget"),
                                       c("cast_popularity","genre","budget"),
                                       c("cast_popularity","major","budget"),
                                       c("cast_popularity","us","budget"),
                                       c("community_count","critics_count","genre","budget","us"),
                                       c("community_count","critics_vote","critics_count"),
                                       c("community_count","critics_vote","genre","budget","us"),
                                       c("community_count","major","us","genre","budget"),
                                       c("community_count","roi","cast_popularity","critics_vote","community_vote"),
                                       c("community_count","roi","community_vote","cast_popularity","critics_count"),
                                       c("community_count","roi","critics_vote","community_vote","budget"),
                                       c("community_count","roi","community_vote","critics_count","budget"),
                                       c("community_count","roi","genre","budget","us","community_vote"),
                                       c("community_vote","critics_count","genre","budget","us"),
                                       c("community_vote","critics_count","community_count"),
                                       c("community_vote","critics_vote","critics_count"),
                                       c("community_vote","critics_vote","genre","budget","us"),
                                       c("community_vote","critics_vote","community_count"),
                                       c("community_vote","genre","community_count"),
                                       c("community_vote","major","us","genre","budget"),
                                       c("community_vote","major","community_count"),
                                       c("community_vote","us","community_count"),
                                       c("critics_count","major","us","genre","budget"),
                                       c("critics_count","roi","cast_popularity","critics_vote","community_vote"),
                                       c("critics_count","roi","cast_popularity","critics_vote","community_count"),
                                       c("critics_count","roi","critics_vote","community_vote","budget"),
                                       c("critics_count","roi","critics_vote","community_count","budget"),
                                       c("critics_count","roi","genre","us","budget","critics_vote"),
                                       c("critics_vote","genre","critics_count"),
                                       c("critics_vote","major","us","genre","budget"),
                                       c("critics_vote","major","critics_count"),
                                       c("critics_vote","us","critics_count"),
                                       c("genre","us","major"),
                                       c("genre","roi","cast_popularity","critics_vote","community_vote"),
                                       c("genre","roi","community_vote","cast_popularity","critics_count"),
                                       c("genre","roi","cast_popularity","critics_vote","community_count"),
                                       c("genre","roi","cast_popularity","community_count","critics_count"),
                                       c("genre","roi","critics_vote","community_vote","budget"),
                                       c("genre","roi","community_vote","critics_count","budget"),
                                       c("genre","roi","critics_vote","community_count","budget"),
                                       c("genre","roi","community_count","critics_count","budget"),
                                       c("major","roi","cast_popularity","critics_vote","community_vote"),
                                       c("major","roi","community_vote","cast_popularity","critics_count"),
                                       c("major","roi","cast_popularity","critics_vote","community_count"),
                                       c("major","roi","cast_popularity","community_count","critics_count"),
                                       c("major","roi","critics_vote","community_vote","budget"),
                                       c("major","roi","community_vote","critics_count","budget"),
                                       c("major","roi","critics_vote","community_count","budget"),
                                       c("major","roi","community_count","critics_count","budget"),
                                       c("major","roi","genre","budget","us"),
                                       c("us","roi","cast_popularity","critics_vote","community_vote"),
                                       c("us","roi","community_vote","cast_popularity","critics_count"),
                                       c("us","roi","cast_popularity","critics_vote","community_count"),
                                       c("us","roi","cast_popularity","community_count","critics_count"),
                                       c("us","roi","critics_vote","community_vote","budget"),
                                       c("us","roi","community_vote","critics_count","budget"),
                                       c("us","roi","critics_vote","community_count","budget"),
                                       c("us","roi","community_count","critics_count","budget"))
  # implications <-  list( c("budget","genre","major"),
  #                                       c("budget","us","major"),
  #                                       c("budget","roi","cast_popularity","critics_vote","community_vote"),
  #                                        c("cast_popularity","community_count","budget"),
  #                                        c("cast_popularity","community_vote","budget"),
  #                                        c("cast_popularity","critics_count","budget"),
  #                                        c("cast_popularity","critics_vote","budget"),
  #                                        c("cast_popularity","genre","major"),
  #                                        c("cast_popularity","genre","budget"),
  #                                        c("cast_popularity","major","budget"),
  #                                        c("cast_popularity","us","major"),
  #                                        c("cast_popularity","us","budget"),
  #                                        c("community_count","critics_count","genre","us","budget"),
  #                                        c("community_count","critics_vote","critics_count","budget"),
  #                                        c("community_count","critics_vote","budget","genre","us"),
  #                                        c("community_count","major","budget","us","genre"),
  #                                        c("community_count","roi","cast_popularity","critics_vote","community_vote"),
  #                                        c("community_count","roi","critics_vote","community_vote","budget"),
  #                                        c("community_count","roi","community_vote","critics_count","budget"),
  #                                        c("community_count","roi","budget","genre","us","community_vote"),
  #                                        c("community_vote","critics_count","genre","us","budget"),
  #                                        c("community_vote","critics_count","budget","community_count"),
  #                                        c("community_vote","critics_vote","critics_count","budget"),
  #                                        c("community_vote","critics_vote","budget","genre","us"),
  #                                        c("community_vote","critics_vote","budget","community_count"),
  #                                        c("community_vote","genre","budget","community_count"),
  #                                        c("community_vote","major","budget","us","genre"),
  #                                        c("community_vote","major","budget","community_count"),
  #                                        c("community_vote","us","budget","community_count"),
  #                                        c("critics_count","major","budget","us","genre"),
  #                                        c("critics_count","roi","cast_popularity","critics_vote","community_vote"),
  #                                        c("critics_count","roi","critics_vote","community_vote","budget"),
  #                                        c("critics_count","roi","critics_vote","community_count","budget"),
  #                                        c("critics_count","roi","budget","genre","us","critics_vote"),
  #                                        c("critics_vote","genre","budget","critics_count"),
  #                                        c("critics_vote","major","budget","us","genre"),
  #                                        c("critics_vote","major","budget","critics_count"),
  #                                        c("critics_vote","us","budget","critics_count"),
  #                                        c("genre","us","major"),
  #                                        c("genre","roi","cast_popularity","critics_vote","community_vote"),
  #                                        c("genre","roi","critics_vote","community_vote","budget"),
  #                                        c("genre","roi","community_vote","critics_count","budget"),
  #                                        c("genre","roi","critics_vote","community_count","budget"),
  #                                        c("genre","roi","community_count","budget","critics_count"),
  #                                        c("major","roi","cast_popularity","critics_vote","community_vote"),
  #                                        c("major","roi","critics_vote","community_vote","budget"),
  #                                        c("major","roi","community_vote","critics_count","budget"),
  #                                        c("major","roi","critics_vote","community_count","budget"),
  #                                        c("major","roi","community_count","budget","critics_count"),
  #                                        c("major","roi","budget","genre","us"),
  #                                        c("us","roi","cast_popularity","critics_vote","community_vote"),
  #                                        c("us","roi","critics_vote","community_vote","budget"),
  #                                        c("us","roi","community_vote","critics_count","budget"),
  #                                        c("us","roi","critics_vote","community_count","budget"),
  #                                        c("us","roi","community_count","budget","critics_count"))
  implications
}