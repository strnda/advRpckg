library(sf); library(curl); library(data.table); library(ggplot2); library(terra)

url <- "https://hydrology.nws.noaa.gov/pub/gcip/mopex/US_Data/Basin_Boundaries/bdy.zip"

dir.create(path = "./data/raw/",
           recursive = TRUE,
           showWarnings = FALSE)

curl_download(url = url,
              destfile = "./data/raw/mopex_shapes.zip")

file.info("./data/raw/mopex_shapes.zip")

unzip(zipfile = "./data/raw/mopex_shapes.zip",
      exdir = "./data/")

fls <- list.files(path = "./data/",
                  pattern = ".bdy",
                  full.names = TRUE,
                  ignore.case = TRUE,
                  all.files = TRUE)

scan(file = fls[42])

dta <- fread(input = fls[42],
             header = TRUE)
dta

plot(x = dta,
     type = "l")

dta_st <- st_polygon(x = list(as.matrix(x = dta)))

plot(x = dta_st)
head(x = dta_st)
class(x = dta_st)

dta_df <- data.frame(ID = "A",
                     val_1 = 5,
                     val_2 = "G")

dta_df$geometry <- st_sfc(x = dta_st,
                          crs = 4326)
dta_df

dta_sf <- st_as_sf(x = dta_df)

plot(x = dta_sf)

#####
dta_bdy <- lapply(
  X = fls,
  FUN = function(x) {

    out <- fread(input = x,
                 header = TRUE)
    out <- st_polygon(x = list(as.matrix(x = out)))
    out
  }
)

ID <- strsplit(x = fls,
               split = "/")

dta_all <- data.frame(
  ID = gsub(pattern = ".bdy",
            replacement = "",
            x = sapply(X = ID,
                       FUN = "[[",
                       index = length(x = ID[[1]])),
            ignore.case = TRUE)
)
dta_all$geometry <- st_sfc(x = dta_bdy,
                           crs = 4326)
dta_all <- st_as_sf(x = dta_all)

plot(x = dta_all)

st_write(obj = dta_all,
         dsn = "./data/mopex_shapes.shp")

test <- read_sf("./data/mopex_shapes.shp")
plot(x = test)

st_crs(x = test)

ggplot() +
  geom_sf(data = test,
          mapping = aes(fill = ID),
          show.legend = FALSE) +
  theme_bw()

ggplot() +
  geom_sf(data = test,
          fill = NA,
          show.legend = FALSE) +
  theme_bw() +
  coord_sf(crs = 3995)

aoi <- dta_all[sample(x = 1:dim(x = dta_all)[1],
                      size = 20),]

plot(x = aoi)

buff <- st_buffer(x = aoi,
                  dist = 100000)

ggplot() +
  geom_sf(data = buff,
          fill = "grey95") +
  geom_sf(data = aoi,
          colour = "red4",
          fill = "darkolivegreen") +
  theme_bw()

int <- st_intersection(x = buff,
                       y = dta_all)

ggplot() +
  geom_sf(data = buff,
          fill = "grey95") +
  geom_sf(data = int,
          colour = "grey50",
          fill = NA) +
  geom_sf(data = aoi,
          colour = "red4",
          fill = "darkolivegreen") +
  theme_bw()
