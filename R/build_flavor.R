build_flavor <- function(...){
  
  flavor_els <- c(...)
  
  flavor_els <- flavor_els[!is.na(flavor_els)]
  
  paste0(flavor_els,collapse = '-')
  
}
