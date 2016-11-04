# Title: Chi-squared test
#
# Uses: The chi-squared test is used when both variables being tested
# are categorical. The test assumes that observations are not correlated
# and at least 80% of the expected cell counts of the contingency table
# are greater than 5. It is used to test for independence between the 
# two variables when sample sizes are large. The null hypothesis is
# that the proportions of one variable are independent of the other
# variable, while the alternative hypothesis is that the proportions
# of one variable are not independent of the other variable.
#
# Data format: 
#
# Author: Kaitlin Cornwell
#
# Date: June 1, 2016
#
# Notes: The chi-squared test of homogeneity is performed using 
# the same method as the chi-squared test of independence. The null
# hypothesis for the chi-squared test of homogeneity is that the
# proportions between the two groups are the same, while the 
# alternative is that they are different. The chi-squared test of 
# independence is used when two samples are chosen, then measurements
# are taken. The chi-squared test of homogeneity is used when random subsets
# of particular groups are chosen (where groups are defined by a measure
# that has already been taken) and then another measurement is taken of 
# a different variable.

Snippet <- setRefClass("Snippet", contains = "Data", fields = "datatable",
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
                             group_check(group)
                           },
                           
                           error = function(e) {
                             e$message = gsub("\n", " ", e$message)
                             errors <<- list(e$message, 2)     
                           },
                           
                           finally = {
                             return(result(error = errors))
                           })},
                         
                         ## Assumptions checking
                         assumptions = function() {
                           tryCatch({
                             
                             ## check expected values
                             datatable <<- table(meta, group)
                             value_check(meta, group)
                             # if (!is.null(freq_check(datatable, length(meta)))) {
                             #   errors <<- c(errors, list("At least 20% of the expected counts are <5",
                             #                             1))
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
                             test = chisq.test(meta, group)
                             rows = rownames(datatable)
                             return(result(test, 
                                           c("column", "stacked-column", "percent-column"),
                                           rows[!rows %in% null_string],
                                           datatable[!rows %in% null_string, "IN"],
                                           datatable[!rows %in% null_string, "OUT"],
                                           errors))
                           },
                           
                           error = function(e) {
                             e$message = gsub("\n", " ", e$message)
                             return(result(error = list(e$message, 2)))
                           })
                         }
                       ))


## Check expected frequency assumption
freq_check <- function(datatable, length) {
  ## find row and column sums
  row_sums = vector(mode = "numeric", length = 0)
  for (i in 1:dim(datatable)[1]) {
    row_sums = c(row_sums, sum(datatable[i,]))
  }
  col_sums = vector(mode = "numeric", length = 0)
  for (j in 1:dim(datatable)[2]) {
    col_sums = c(col_sums, sum(datatable[,j]))
  }
  
  ## find expected frequencies to test assumptions and count number of 
  ## expected frequences <5
  count = 0
  
  for (i in 1:dim(datatable)[1]) {
    for (j in 1:dim(datatable)[2]) {
      if (((row_sums[i] * col_sums[j])/length) < 5)
        count = count + 1
    }
  }
  
  ## return percentage of expected frequences <5
  if ((count/(dim(datatable)[1] * dim(datatable)[2])) > .2)
    return("fisher")
  return(NULL)
}
