#' Get IDs from mopex database
#'
#' @param url database url
#'
#' @export
#'
#' @examples
#' 
#' get_id()
#' 
get_id <- function(url = "https://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/Us_438_Daily/") {
  
  ids <- readLines(con = url)
  ids <- substr(x = ids,
                start = 82,
                stop = 93)
  ids <- ids[grep(pattern = ".dly",
                  x = ids)]
  ids <- gsub(pattern = ".dly",
              replacement = "",
              x = ids)
  
  ids
}

#' data dowload from mopex dataset
#'
#' @param id catchment id
#' @param url database url
#' @param save logical - save file to local disk
#' @param path path of the file
#' @param file_name filename
#'
#' @export
#'
#' @examples
#' 
#' 
data_download <- function(id, 
                          url = "https://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/Us_438_Daily/",
                          save = FALSE, 
                          path = NULL, 
                          file_name = NULL) {
  
  dta <- lapply(
    X = id, 
    FUN = function(x) {
      
      message(paste("downloading", x))
      
      e <- try(
        expr = {
          
          dl <- read.fwf(file = paste0(url, 
                                       x,
                                       ".dly"),
                         widths = c(8, rep(x = 10,
                                           times = 5)),
                         col.names = c("DTM", "P", "E", "Q", "Tmax", "Tmin"))
          
          dl$DTM <- as.Date(x = gsub(pattern = " ",
                                     replacement = "0",
                                     x = dl$DTM),
                            format = "%Y%m%d")
          dl$ID <- x
          
        },
        silent = TRUE
      )
      
      if (inherits(x = e,
                   what = "try-error")) {
        
        message(paste(x, "was not downloaded correctly"))
      } else {
        
        return(dl)
      }
    } 
  )
  
  dta_bind <- do.call(what = rbind,
                      args = dta)
  dta_bind$ID <- as.factor(x = dta_bind$ID)

  if (save) {
    
    if (any(is.null(x = path), 
            is.null(x = file_name))) {
      
      ## this part can be handled in multiple various ways 
      ## like assigning getwd() to path object etc... 
      
      stop("path or filename was not supplied")
    }
    
    write.csv(x = dta_bind,
              file = file.path(path, file_name))
    
    if (file.exists(file.path(path, file_name))) {
      
      message("file created succesfully")
    }
  }
  
  dta_bind
}
