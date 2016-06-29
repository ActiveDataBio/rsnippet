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

error <- function(meta, group, null_string) {
  
  ret = tryCatch({
    
    ## check data type
    if (is.null(meta)) {
      stop("Custom: null")
    }
    
    ## change meta from factors to strings
    meta = as.character(meta)
    
    ## remove missing values
    mvidx = !(meta %in% null_string)
    if (length(which(mvidx)) == 0) {
      stop("Custom: null")
    }
    rmgroup = group[mvidx]
    rmmeta = meta[mvidx]
    if (length(which(rmgroup %in% "IN")) == 0 ||
        length(which(rmgroup %in% "OUT")) == 0) {
      stop("Custom: nullgroup")
    }
    tempTable = table(rmmeta, rmgroup)
    
    ## Check data type
    if (dim(tempTable)[1] == 1) {
      stop("Custom: oneval")
    }
    if (dim(tempTable)[1] > ceiling(.75 * length(rmmeta))) {
      stop("Custom: type")
    }
    
    ## if >20% of expected frequences are <5 then use Fisher's exact test
    if (test_freq(length(rmmeta), tempTable) > .2) {
      stop("Custom: cellcount")
    } else {
      test = chisq.test(rmmeta, rmgroup)
    }
  },
  ## error handler function
  error = function (e) {
    if (grepl("Custom:", e)) {
      if (grepl("nullgroup", e)) {
        return(list("No data in a group", 2))
      }
      if (grepl("null", e)) {
        return(list("No meta data", 2))
      }
      if (grepl("oneval", e)) {
        return(list("Same value for each observation", 3))
      }
      if (grepl("type", e)) {
        return(list("Incorrect data type: received continuous instead of categorical", 3))
      }
      if (grepl("cellcount", e)) {
        return(list("20% of cell counts are <5, use Fisher's test instead", 3))
      }
    }
    return(list(e$message, 1))
  })
  
  ## if length of return statement is 2 then an error occurred
  ## return the error message and code
  if (length(ret) == 2) {
    return(list(msg = ret[[1]], status = ret[[2]]))
  } else {
    return(list(msg = '', status = 0))
  }
}

test = function(meta, group, null_string) {
  
  ## change meta from factors to strings
  meta = as.character(meta)
  
  ## remove missing values
  mvidx = !(meta %in% null_string)
  rmgroup = group[mvidx]
  rmmeta = meta[mvidx]
  tempTable = table(rmmeta, rmgroup)
  tempRows = rownames(tempTable)
  
  test = chisq.test(rmmeta, rmgroup)
  
  return (list(method = test$method,#gsub("\\'", "\\\\'", test$method),
               pvalue = test$p.value,
               charts = c('column','stacked-column','percent-column'),
               labels = tempRows[!tempRows %in% null_string],
               group_in = tempTable[!tempRows %in% null_string,"IN"],
               group_out = tempTable[!tempRows %in% null_string,"OUT"],
               msg = '',
               status = 0))
}

test_freq <- function(length, tempTable) {
  ## find row and column sums
  row_sums = vector(mode = "numeric", length = 0)
  for (i in 1:dim(tempTable)[1]) {
    row_sums = c(row_sums, sum(tempTable[i,]))
  }
  col_sums = vector(mode = "numeric", length = 0)
  for (j in 1:dim(tempTable)[2]) {
    col_sums = c(col_sums, sum(tempTable[,j]))
  }
  
  ## find expected frequencies to test assumptions and count number of 
  ## expected frequences <5
  ex_freq = matrix(data = NA, nrow = dim(row(tempTable))[1], ncol = 2)
  count = 0
  
  for (i in 1:dim(tempTable)[1]) {
    for (j in 1:dim(tempTable)[2]) {
      ex_freq[i,j] = (row_sums[i] * col_sums[j])/length
      if (ex_freq[i,j] < 5) {
        count = count + 1
      }
    }
  }
  
  ## return percentage of expected frequences <5
  return (count/(dim(tempTable)[1] * dim(tempTable)[2]))
}
