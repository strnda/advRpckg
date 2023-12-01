# install.packages(c("ncdf4", "ncdf4.helpers"))
# install.packages(c("terra", "data.table"))

## data available @ "https://owncloud.cesnet.cz/index.php/s/HyKD3KXSOontoKX/download"

library(ncdf4); library(ncdf4.helpers)
library(terra); library(data.table)

fls <- list.files(path = "../Downloads/nc/", 
                  recursive = TRUE, 
                  pattern = ".nc", 
                  full.names = TRUE)

ids <- c(296, 263, 264, 265, 295, 297, 327, 328, 329)

dta_all <- lapply(
  X = fls,
  FUN = function(i) {
    
    e <- try(
      expr = {
        
        nc <- nc_open(filename = i)
        
        lon <- ncvar_get(nc = nc, 
                         varid = "lon")
        lat <- ncvar_get(nc = nc,
                         varid = "lat")
        pr <- ncvar_get(nc = nc,
                        varid = "pr")
        time <- nc.get.time.series(f = nc)
        
        nc_close(nc = nc)
        
        r <- rast(x = pr)
        ext(x = r) <- c(range(lon),
                        range(lat))
        crs(x = r) <- "epsg:4326"
        
        xy <- xyFromCell(object = r,
                         cell = ids)
        val <- t(x = extract(x = r,
                             y = xy))
        
        dta <- data.table(time = time, val)
      }, 
      silent = TRUE
    )
    
    if (inherits(x = e, 
                 what = "try-error")) {
      return(NULL)
    } else {
      
      return(dta)
    }
  }
)

dta_all <- rbindlist(l = dta_all)
dta_all_m <- melt(data = dta_all,
                  id.vars = "time",
                  variable.name = "cell_id")
mx <- dta_all_m[, .(mx = max(value)),
                    by = .(cell_id, year(x = time))]

mx

spl_dta <- split(x = dta_all_m,
                 f = dta_all_m$cell_id)

idf <- function(x, 
                rp = c(2, 5, 10, 25, 50, 100),
                dur = c(1, 2, 5, 10, 24, 48),
                aggfun = "mean",
                dist = "gev", ...) {
  
  agg <- lapply(
    X = dur, 
    FUN = function(d) {
      
      out <- x[, .(time = time,
                   val = do.call(what = paste0("froll", aggfun),
                                 args = list(x = value, 
                                             n = d, 
                                             align = "center",
                                             fill = 0)))]
      out
    }
  )
  
  quant <- lapply(
    X = agg, 
    FUN = function(a) {
      
      mx <- a[, .(mx = max(x = val, 
                           na.rm = TRUE)),
              by = year(x = time)]
      
      para <- fitDist(data = mx$mx,
                      dist = dist,
                      n.points = 10,
                      norm = "N4",
                      constrain = FALSE)
      
      prob <- 1 - 1/rp
      
      q <- qgev(p = prob,
                loc = para$loc,
                scale = para$scale,
                shape = para$shape)
      
      names(x = q) <- rp
      
      as.list(x = q)
    }
  )
  
  names(x = quant) <- dur
  
  quant_all <- rbindlist(l = quant, 
                         idcol = "dur")
  quant_idf <- melt(data = quant_all,
                    id.vars = "dur",
                    variable.name = "rp")
  
  return(quant_idf)
}

idf_dta <- lapply(X = spl_dta, 
                  FUN = idf)

idf_dta <- rbindlist(l = idf_dta,
                     idcol = "cell_id")

ggplot(data = idf_dta,
       mapping = aes(x = as.numeric(x = dur),
                     y = value, 
                     colour = rp)) +
  geom_line() +
  geom_point() +
  scale_colour_manual(name = "Return\nperion",
                      values = c("yellow4", "steelblue", "red4", 
                                 "darkgreen", "pink", "magenta4")) +
  labs(x = "Duration (hours)",
       y = "Intensity (mm/h)",
       title = "IDF curve") +
  theme_bw() +
  facet_wrap(facets = ~cell_id)
