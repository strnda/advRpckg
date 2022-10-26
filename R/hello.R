#' hello world example
#'
#' @param x main argument
#'
#' @export
#' @import data.table
#'
#' @examples
#'
#' hello()
#'
hello <- function(x = "Hello, world!") {

  # library(data.table)

  dta <- data.table(hello = x)

  structure(.Data = dta,
            class = c("hello", "data.frame"),
            whatever = "whatever")
}

#' plot method for hello class
#'
#' @param x hello thingy
#' @param ... other arguments
#'
#' @export
#' @import ggplot2
#'
#' @method plot hello
#'
#' @examples
#'
#' plot(x = hello())
#'
plot.hello <- function(x, ...) {

  temp <- as.data.frame(x = x)

  p <- ggplot(data = temp) +
    geom_label(mapping = aes(x = 1,
                             y = 1,
                             label = hello))

  p
}
