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
# Date: July 28, 2016
#
# Notes: 

Snippet <- setRefClass("Snippet", contains = "Data",
                       fields = "groups",
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
                           try = tryCatch ({
                             
                             value_check(meta1, meta2)
                             
                             names = levels(as.factor(meta2))
                             
                             for (i in 1:length(names)) {
                               groups <<- c(groups, list(meta1[meta2 == names[i]]))
                             }
                             
                             ## normality test
                             if (!is.null(norm_check(groups))) {
                               errors <<- c(errors, 
                                            list("At least one group is not normally distributed", 1))
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
                         
                         ## Statistical test
                         test = function() {
                           tryCatch({
                             if ((length(groups) - 1) == 2) {
                              var = var.test(meta1 ~ meta2, alternative = "two.sided")
                              if (var$p.value < .05) {
                                test = t.test(meta1 ~ meta2,
                                              alternative= "two.sided", var.equal = FALSE)
                              } else {
                                test = t.test(meta1 ~ meta2,
                                              alterantive = "two.sided", var.equal = TRUE)
                              }
                             } else {
                               output = anova(aov(meta1 ~ meta2))
                               test = list(method = "Analysis of Variance", 
                                           p.value = output$'Pr(>F)'[1])
                               
                             }
                             
                             return(result(test, 
                                           c("box"), 
                                           "", 
                                           groups[2:length(groups)], 
                                           errors))
                           },
                           
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
                         }))


## Check normality assumption
norm_check <- function(groups) {
  for (i in 2:length(groups)) {
    if (shapiro.test(groups[[i]])$p.value < .05)
      return("non-normal")
  }

  return(NULL)
}