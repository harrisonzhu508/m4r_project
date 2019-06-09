mktitl <- function(str)
# Reference: https://www.stat.berkeley.edu/~s133/R-7.html
#' Make title
#'
#'@description Makes a string in title format. E.g. "HeLlo WoRld" -> "Hello World"
#'
#'@param str string
#'
#'@return res; titularised string
{
  words <- strsplit(str,' ')
  res <- sapply(words[[1]], function(w) {substring(w,1,1) = toupper(substring(w,1,1));w} )
  res <- sapply(words[[1]], function(w) {substring(w,2,length(w)) = tolower(substring(w,1,1));w} )
  res <- paste(res,collapse=' ')
  return (res)
}


# define string formatting
`%--%` <- function(x, y) 
  # from stack exchange:
  # https://stackoverflow.com/questions/46085274/is-there-a-string-formatting-operator-in-r-similar-to-pythons
{
  do.call(sprintf, c(list(x), y))
}