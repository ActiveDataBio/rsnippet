# Title: Two sample Wilcoxon rank sum Test
#
# Uses: The two sample Wilcoxon rank sum test is used as an
# alternative to the two-sample t-test when the data is not
# normally distributed, the sample size is small, or when one 
# variable is ordinal. This test assumes that that one variable
# is either continuous or ordinal and one variable is categorical
# with two groups, that the groups within the categorical
# variable are independent, and that observations are independent.
# The null hypothesis is that the groups are identically
# distributed while the alternative hypothesis is that the groups
# are not identically distributed. If the distributions of the
# two groups are not similar then the Wilcoxon rank sum test
# determines if the distributions are significantly different. If
# the two distributions are similar then the test determines if
# the medians of the two groups are significantly different.
#
# Data format: Values except for null/missing characters are numeric (may be
# encoded as strings).
# 
# Author: Kaitlin Cornwell
#
# Date: June 3, 2016
#
# Notes: The two-sample Wilcoxon rank sum test is also known as the Mann-
# Whitney U test.

Snippet <- setRefClass("Snippet", contains = "Data", fields = c("meta_in", "meta_out"),
                       methods = list(
                         
                         ## Missing values handler function
                         cleaning = function(null_string) {
                           tryCatch({
                             
                             ## initial read in
                             read_check(meta)
                             meta <<- as.character(meta)
                             
                             ## remove missing values
                             index = !(meta %in% null_string)
                             missing_check(index)
                             group <<- group[index]
                             meta <<- meta[index]
                             
                             ## change to numeric form
                             meta <<- as.numeric(meta)
                             index = !(is.na(meta))
                             group <<- group[index]
                             meta <<- meta[index]
                             group_check(meta, group)
                          },
                          
                          error = function(e) {
                            e$message = gsub("\n", " ", e$message)
                            errors <<- list(e$message, 2)
                          },
                          
                          finally = {
                            return(result(error = errors))
                          })
                         },
                         
                         ## Assumption checking
                         assumptions = function() {
                           
                           tryCatch({
                            value_check(meta)
                           
                            ## split the data across "in" and "out" groups
                            group_index = (group %in% "IN")
                            meta_in <<- meta[group_index]
                            meta_out <<- meta[!group_index]
                           },   
                           
                           error = function(e) {
                             e$message = gsub("\n", " ", e$message)
                             errors <<- list(e$message, 2)
                           }, 
                           
                           finally = {
                             return(result(error = errors))
                           })   
                          },
                         
                         test = function() {
                           tryCatch({
                             test = wilcox.test(meta_in, meta_out, 
                                                alternative = "two.sided")
                             
                             return(result(test, c("box"),
                                           "", meta_in, meta_out, errors))
                             
                           },
                           
                           ## Statistical test
                           error = function(e) {
                             e$message = gsub("\n", " ", e$message)
                             return(result(error = list(e$message, 2)))
                           })
                         }
                       ))



## Check if data was read in correctly
read_check <- function(meta) {
  if(is.null(meta)) {
    stop("No meta data")
  }
  return(NULL)
}

## Check if data still availabe after removal of missing values
missing_check <- function(index) {
  if (length(which(index)) == 0) {
    stop("No meta data")
  }
  return(NULL)
}

## Check if there are observations in each group
group_check <- function(meta, group) {
  if (length(meta) == 0) {
    stop("Incorrect data type: need numeric data")
  }
  if (length(which(group %in% "IN")) == 0 || 
      length(which(group %in% "OUT")) == 0) {
    stop("No data in one group")
  }
  return("NULL")
}

## Check data is not constant
value_check <- function(meta) {
  datatable = table(meta)
  if (dim(datatable) == 1)
    stop("Data is constant")
  return(NULL)
}