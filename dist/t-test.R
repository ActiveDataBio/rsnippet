# Title: Two-sample t-test
#
# Uses: The two-sample t-test is used when one variable is continuous and one
# variable is categorical with two groups. This test assumes that samples have
# been drawn from normally distributed populations and that the populations have
# equal variances. The two-sample t-test is used to test for differences in mean
# between the groups defined by the categorical variable. The null hypothesis is
# that the means are equal, while the alternative hypothesis is that the means
# are not equal. Since this test uses the mean, the two-sample t-test should not 
# be chosen when the data has a large range or is significantly skewed.
#
# Data format: numeric
#
# Author: Kaitlin Cornwell
# 
# Date: June 3, 2016
#
# Notes: 

Snippet <- setRefClass("Snippet", contains = "Data",
                       fields = c("meta_in", "meta_out"),
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
                             group_check(group)
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
                           try = tryCatch ({
                            
                            value_check(meta, group)
                             
                            ## split data into in and out groups
                            group_index = (group %in% "IN")
                            meta_in <<- meta[group_index]
                            meta_out <<- meta[!group_index]
                         
                            ## normality test
                            # if (!is.null(norm_check(meta_in, meta_out))) {
                            #   errors <<- c(errors, 
                            #                 list("At least one group is not normally distributed", 1))
                            # }
                           }, 
                           
                           error = function(e) {
                             e$message = gsub("\n", " ", e$message)
                             errors <<- list(e$message, 2)
                           },
                           
                           finally = {
                             return(result(error = errors))
                           })
                        },
                         
                         ## Statistical test
                         test = function() {
                           tryCatch({
                            var = var.test(meta_in, meta_out, alternative = "two.sided")
                            if (var$p.value < .05) {
                              test = t.test(meta_in, meta_out,
                                            alternative= "two.sided", var.equal = FALSE)
                            } else {
                              test = t.test(meta_in, meta_out,
                                            alterantive = "two.sided", var.equal = TRUE)
                            }
                           
                            return(result(test, c("box"), "", meta_in, meta_out, errors))
                           },
                           
                           error = function(e) {
                             e$message = gsub("\n", " ", e$message)
                             return(result(error = list(e$message, 2)))
                           })
                       }))


## Check normality assumption
norm_check <- function(meta_in, meta_out) {
  if ((shapiro.test(meta_in)$p.value < .05) ||
    (shapiro.test(meta_out)$p.value < .05)) {
    return("non-normal")
  }
  return(NULL)
}