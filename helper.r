cv.test = function(x, y, chisq) {
  CV = sqrt(chisq / (length(x) * (min(length(unique(x)), length(unique(y))) - 1)))
  print.noquote("Cramér V / Phi:")
  
  return(as.numeric(CV))
}

rmsea.test = function(chisq, df, n) {
  rmsea = sqrt((chisq-df)/(df*(n-1)))
  
  return(as.numeric(rmsea))
}