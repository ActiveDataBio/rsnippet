# Title: Fisher's exact test
#
# Uses: Fisher's exact test is used when both variables being tested
# are categorical. Fisher's exact t-test assumes that each observation
# only fits into one cell and that the row and column totals are fixed
# and not random. It is used to test for independence between the two 
# variables, when sample sizes are small. The null hypothesis is that
# the proportions of one variable are independent of the other variable,
# while the alternative hypothesis is that the proportions of one
# variable are not independent of the other variable.
#
# Data format: character or numeric
#
# Author: Kaitlin Cornwell
#
# Date: July 27, 2016
#
# Notes: 


Snippet <- setRefClass("Snippet", contains = "Data", fields = "datatable",
                       methods = list(
                         ## Missing value handler function
                         cleaning = function(null_string) {
                           tryCatch({
                             ## initial read in
                             read_check(meta1)
                             read_check(meta2)
                             meta1 <<- as.character(meta1)
                             meta2 <<- as.character(meta2)
                             
                             ## remove missing values
                             remove_missing(meta1, meta2)
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
                         
                         assumptions = function() {
                           tryCatch ({
                             
                             ## Check expected values
                             datatable <<- table(meta1, meta2)
                             value_check(meta1, meta2)
                             
                             if (!is.null(freq_check(datatable, length(meta1)))) {
                               errors <<- c(errors, 
                                            list("At least 80% of the expected counts are >5", 1))
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
                             test = fisher.test(meta1, meta2, workspace = 1e+7)
                             rows = rownames(datatable)
                             
                             data = list()
                             for (i in 1:dim(datatable)[2]) {
                               data = c(data, list(datatable[!rows %in% null_string, i]))
                             }
                             
                             return(result(test, 
                                           c("column", "stacked-column", "percent-column"),
                                           rows[!rows %in% null_string],
                                           data,
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
                         }
                       ))


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
      if (((row_sums[i] * col_sums[j])/length) > 5)
        count = count + 1
    }
  }
  
  ## return percentage of expected frequences >5
  if ((count/(dim(datatable)[1] * dim(datatable)[2])) > .8)
    return("chisq")
  return(NULL)
}