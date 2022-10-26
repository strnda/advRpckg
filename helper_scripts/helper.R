# install.packages("devtools")

library(usethis)
library(devtools)

use_gpl3_license()

use_git()
use_github()
gh_token_help()
create_github_token()
gitcreds::gitcreds_set()

use_github()

use_build_ignore(files = "helper_scripts/")

build()
check()

?hello

library(testthat)

use_test(name = "hello")

# edit_r_environ()

# methods(generic.function = plot)
#
# methods(class = "character")

rm(list = ls())
dev.off()

library(advRpckg)

obj <- hello()

obj

class(obj)

attributes(x = obj)

plot(x = obj)

# use_readme_rmd()
