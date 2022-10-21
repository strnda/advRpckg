# install.packages("devtools")

library(usethis)

use_gpl3_license()

use_git()
use_github()
gh_token_help()
create_github_token()
gitcreds::gitcreds_set()

use_github()

use_build_ignore(files = "helper.R")

# use_namespace()

?hello

library(testthat)

use_test(name = "hello")

# edit_r_environ()

methods(generic.function = plot)

methods(class = "character")

rm(list = ls())
dev.off()

library(advRpckg)

obj <- hello()

obj

class(obj)

attributes(x = obj)

plot(x = obj)



