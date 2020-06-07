#' @export 
#' @importFrom cli cat_rule
print.craninfo <- function(x,...){
  names(x)[ncol(x)] <- ''
  cli::cat_rule(sprintf('Check Info (Sys.time: %s)',Sys.time()))
  title_flavor <- paste0(sprintf('r-%s',attr(x,'flavor')),collapse = ', ')
  cli::cat_rule(sprintf('Flavor: %s',title_flavor))
  print(as.data.frame(x))
}
