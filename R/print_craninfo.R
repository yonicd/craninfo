#' @export 
#' @importFrom cli cat_rule
print.craninfo <- function(x,...){
  names(x)[ncol(x)] <- ''
  cli::cat_rule(sprintf('Check Info (Sys.time: %s)',Sys.time()))
  cli::cat_rule(sprintf('Flavor: %s',attr(x,'flavor')))
  print(as.data.frame(x))
}
