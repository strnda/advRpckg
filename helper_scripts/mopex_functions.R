#######################

mopex_id <- function(url = "https://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/Us_438_Daily/") {

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
data_download <- function(id,
                          url = "https://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/Us_438_Daily/") {

  dta <- lapply(
    X = id,
    FUN = function(x) {

      message(paste("downloading", x))

      e <- try(
        expr = {

          dl <- read.fwf(file =  paste0(url,
                                        x,
                                        ".dly"),
                         widths = c(8, rep(x = 10,
                                           times = 5)),
                         col.names = c("date", "p", "e", "r", "tmax", "tmin"))

          dl$date <- as.Date(x = gsub(pattern = " ",
                                      replacement = "0",
                                      x = dl$date),
                             format = "%Y%m%d")
          dl$id <- x

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
  dta_bind$id <- as.factor(x = dta_bind$id)

  dta_bind
}

test <- data_download(id = mopex_id()[1:5])

head(x = test)
str(object = test)
summary(object = test)
