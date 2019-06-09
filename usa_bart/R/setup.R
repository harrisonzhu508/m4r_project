list.of.packages <- c(
              "bartMachine",
              "matrixStats",
              "dplyr",
              "doParallel",
              "logging",
              "data.tree"
              )

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]

if (length(new.packages) > 0 ) {
  install.packages(new.packages)
}
