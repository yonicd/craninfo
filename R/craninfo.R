#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param cran_type PARAM_DESCRIPTION, Default: 'release'
#' @param platform PARAM_DESCRIPTION, Default: get_os()
#' @param machine PARAM_DESCRIPTION, Default: R.version$arch
#' @param linux_type PARAM_DESCRIPTION, Default: ifelse(platform == "linux", "debian-clang", NA_character_)
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples 
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
# @seealso [sessioninfo][sessioninfo::sessioninfo],[cch_pkgs][cchecks::cch_pkgs]
#' @rdname craninfo
#' @export 
#' @importFrom sessioninfo session_info
#' @importFrom cchecks cch_pkgs
craninfo <- function(cran_type = 'release', platform = get_os(), machine = R.version$arch, linux_type = ifelse(platform=='linux'&cran_type=='devel','debian-clang',NA_character_)){
  
  si <- sessioninfo::package_info()
  sip <- as.data.frame(si)
  
  sip_check_raw <- cchecks::cch_pkgs(sip$package)
  
  this_flavor <- sapply(cran_type,build_flavor,
         platform = platform,
         machine = machine,
         linux_type = linux_type,
         USE.NAMES = FALSE)
  
  grep_flavor <- paste0(sprintf("(%s)",this_flavor),collapse = '|')
  
  sip_check_list <- lapply(sip_check_raw,function(y){
    
    idx <- grepl(grep_flavor,y$data$checks$flavor)
    
    ret <- y$data$checks[idx,c('flavor','version','status')]
    ret$package <- y$data$package
    if(!is.null(ret))
      names(ret)[grepl('version',names(ret))] <- 'cran_version'
    ret
  })
  
  sip_check_df <- do.call('rbind',sip_check_list)
  
  sip_check_split <- lapply(split(sip_check_df,sip_check_df$flavor),function(x){
    names(x)[3] <- x$flavor[1]
    x$flavor <- NULL
    x
  })
  
  sip_check_wide <- Reduce(f = function(x,y) merge(x,y,by=c('package','cran_version')),sip_check_split)
  
  sip_check <- merge(sip[c('package','source','date','loadedversion')],sip_check_wide,by = 'package',all.x = TRUE)
  
  names(sip_check)[grepl('loadedversion',names(sip_check))] <- 'loaded'
  
  adj_names <- names(sip_check)[grepl(grep_flavor,names(sip_check))]
  
  names(sip_check)[grepl(grep_flavor,names(sip_check))] <- sapply(strsplit(adj_names,'-'),'[[',2)
  
  status_lvls <- c('OK','NOTE','WARN','ERROR','FAIL')
  
  this_status <- unique(unlist(c(sip_check[,cran_type])))
  
  these_lvls <- intersect(status_lvls,this_status)
  
  sip_check[[cran_type[1]]] <- factor(sip_check[[cran_type[1]]],levels = these_lvls)
  
  sip_check <- sip_check[order(sip_check[[cran_type[1]]],decreasing = c(TRUE)),]
  
  rownames(sip_check) <- NULL
  
  sip_check$version_diff <- ifelse((sip_check$loaded!=sip_check$cran_version)%in%c(TRUE,NA),'*','')
  
  class(sip_check) <- c('craninfo','data.frame')
  
  attr(sip_check,'flavor') <- this_flavor
  
  sip_check
}
