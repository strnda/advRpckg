install.packages(c("CoSMoS", "data.table"))

library(CoSMoS); library(data.table) 

?distribution

n <- 200000

prec <- rbinom(n = n, 
               size = 1,
               prob = .1) *
  rgamma(n = n,
         shape = 5.2,
         scale = .1)

dta <- data.table(date = seq.POSIXt(from = Sys.time(),
                                    by = "hour",
                                    length.out = n), 
                  val = prec)
dta

#### create an IDF curve for 
#### 2, 5, 10, 25, 50, 100 year periods and 
#### 1, 2, 5, 10, 24, 48 hour duration

idf <- function(x, 
                rp = c(2, 5, 10, 25, 50, 100),
                dur = c(1, 2, 5, 10, 24, 48),
                aggfun = "mean",
                dist = "gev", ...) {
  
  agg <- lapply(
    X = dur, 
    FUN = function(d) {
      
      out <- x[, .(date = date,
                   val = do.call(what = paste0("froll", aggfun),
                                 args = list(x = prec, 
                                             n = d, 
                                             align = "center",
                                             fill = 0)))]
      out
    }
  )
  
  agg <- c(list(x), agg)
  
  quant <- lapply(
    X = agg, 
    FUN = function(a) {
      
      mx <- a[, .(mx = max(x = val, 
                           na.rm = TRUE)),
              by = year(x = date)]
      
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
  
  names(x = quant) <- c(1, dur)
  
  quant_all <- rbindlist(l = quant, 
                         idcol = "dur")
  quant_idf <- melt(data = quant_all,
                    id.vars = "dur",
                    variable.name = "rp")
  
  return(quant_idf)
}

test <- idf(x = dta)

ggplot(data = test,
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
  theme_bw()

