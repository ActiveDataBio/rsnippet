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
# Date: July 28, 2016
#
# Notes: The two-sample Wilcoxon rank sum test is also known as the Mann-
# Whitney U test.

## meta1 is numeric
## meta2 is categorical
Snippet <- setRefClass("Snippet", contains = "Data", fields = "groups",
                       methods = list(
                         
                         ## Missing values handler function
                         cleaning = function(null_string) {
                           tryCatch({
                             
                             ## initial read in
                             read_check(meta1)
                             read_check(meta2)
                             meta1 <<- as.character(meta1)
                             meta2 <<- as.character(meta2)
                             
                             ## remove missing values
                             remove_missing(meta1, meta2)
                             
                             ## change to numeric form
                             meta1 <<- as.numeric(meta1)
                             index = !(is.na(meta1))
                             missing_check(index)
                             meta1 <<- meta1[index]
                             meta2 <<- meta2[index]
                             group_check(meta2)
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
                             value_check(meta1, meta2)
                             
                             names = levels(as.factor(meta2))
                             
                             for (i in 1:length(names)) {
                               groups <<- c(groups, list(meta1[meta2 == names[i]]))
                             }

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
                             
                             if (dim(table(meta2)) == 2) {
                              test = wilcox.test(meta1 ~ meta2, 
                                                  alternative = "two.sided")
                             } else {
                               test = kruskal.test(meta1 ~ as.factor(meta2))
                             }
                             
                             return(result(test, 
                                           c("box"),
                                           "",
                                           groups[2:length(groups)],
                                           errors))
                             
                           },
                           
                           ## Statistical test
                           error = function(e) {
                             e$message = gsub("\n", " ", e$message)
                             return(result(error = list(e$message, 2)))
                           })
                         },
                         
                         ## removes missing values
                         remove_missing = function(meta1, meta2) {
                           index = !(meta1 %in% null_string)
                           missing_check(index)
                           meta1 <<- meta1[index]
                           meta2 <<- meta2[index]
                           
                           index = !(meta2 %in% null_string)
                           missing_check(index)
                           meta1 <<- meta1[index]
                           meta2 <<- meta2[index]
                           
                           return(NULL)
                         }
                       ))
