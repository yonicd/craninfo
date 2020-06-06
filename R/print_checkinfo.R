#' @export 
#' @importFrom cli cat_rule
print.checkinfo <- function(x,...){
  names(x)[ncol(x)] <- ''
  cli::cat_rule('Check Info')
  print(as.data.frame(x))
}
