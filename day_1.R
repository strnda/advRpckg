class("1L")

a <- sample(x = letters,
            size = 1E7, 
            replace = TRUE)

object.size(x = a)

b <- sample(x = 1:15,
            size = 1E7,
            replace = TRUE)

object.size(x = b)

f <- as.factor(x = a)

class(x = f)
object.size(x = f)

head(x = a)
head(x = f)

class(Sys.Date())

date <- as.Date(x = "1988-12-01",
                format = "%Y-%m-%d")

date + 100

?strptime

format(x = date,
       format = "%A")

seq(from = 1,
    to = 2,
    length.out = 42)

methods(generic.function = seq)

seq(from = date,
    by = "day",
    length.out = 100)

methods(class = "Date")

# install.packages("CoSMoS")
# library(CoSMoS)
# 
# ?fitDist
# 
# x <- fitDist(data = rnorm(n = 1000), 
#              dist = 'norm', 
#              n.points = 30, 
#              norm = 'N1', 
#              constrain = FALSE)
# plot(x = x)

## fails
dta <- read.table(file = "https://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/Us_438_Daily/01445000.dly",
                  sep = "")

## close but not close enough
dta <- read.table(file = "https://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/Us_438_Daily/01445000.dly",
                  sep = ",")
dta[1,]

test <- substring(text = dta[1,],
                  first = c(1, 9, 19),
                  last = c(8, 18, 28))
as.numeric(x = test)

## another way
dta <- read.fwf(file = "https://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/Us_438_Daily/01445000.dly",
                widths = c(8, rep(x = 10, 
                                  times = 5)), 
                col.names = c("date", "p", "e", "r", "tmax", "tmin"))
head(x = dta)
str(dta)

## almost there -> date is still a char...

as.Date(x = dta$date[1], 
        format = "%Y%m%d")
as.Date(x = dta$date, 
        format = "%Y%m%d")

dta$date <- as.Date(x = gsub(pattern = " ",
                             replacement = "0", 
                             x = dta$date), 
                    format = "%Y%m%d")

str(dta)

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
