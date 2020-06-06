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
#' @rdname checkinfo
#' @export 
#' @importFrom sessioninfo session_info
#' @importFrom cchecks cch_pkgs
checkinfo <- function(cran_type = 'release', platform = get_os(), machine = R.version$arch, linux_type = ifelse(platform=='linux','debian-clang',NA_character_)){
  
  si <- sessioninfo::package_info()
  sip <- as.data.frame(si)
  
  sip_check_raw <- cchecks::cch_pkgs(sip$package)
  
  this_flavor <- build_flavor(cran_type,platform,machine,linux_type)
  
  sip_check_list <- lapply(sip_check_raw,function(y){
    
    idx <- grepl(this_flavor,y$data$checks$flavor)
    
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
  
  sip_check_wide <- Reduce(f = function(x,y) merge(x,y,by=c('package','version')),sip_check_split)
  
  sip_check <- merge(sip[c('package','source','date','loadedversion')],sip_check_wide,by = 'package',all.x = TRUE)
  
  names(sip_check)[grepl('loadedversion',names(sip_check))] <- 'loaded'
  
  names(sip_check)[grepl(this_flavor,names(sip_check))] <- cran_type
  
  note_lvls <- c('OK','NOTE','WARN','ERROR','FAIL')
  
  these_lvls <- intersect(note_lvls,unique(sip_check[[cran_type]]))
  
  sip_check[[cran_type]] <- factor(sip_check[[cran_type]],levels = these_lvls)
  
  sip_check <- sip_check[order(sip_check[[cran_type]],decreasing = c(TRUE)),]
  
  rownames(sip_check) <- NULL
  
  sip_check$version_diff <- ifelse((sip_check$loaded!=sip_check$cran_version)%in%c(TRUE,NA),'*','')
  
  class(sip_check) <- c('checkinfo','data.frame')
  
  sip_check
}
