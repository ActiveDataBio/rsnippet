# Title: Fisher's exact test
#
# Uses: Fisher's exact test is used when both variables being tested
# are categorical. Fisher's exact t-test assumes that each observation
# only fits into one cell and that the row and column totals are fixed
# and not random. It is used to test for independence between the two 
# variables, when sample sizes are small. The null hypothesis is that
# that the proportions of one varaible are independent of the other
# variable, while the alternative hypothesis is that the proportions
# of one variable are not independent of the other variable.
#
# Data format: character or numeric
#
# Author: Kaitlin Cornwell
#
# Date: June 1, 2016
#
# Notes: 

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
      fisher.test(rmmeta, rmgroup)
    } else {
      stop("Custom: cellcount")
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
      if(grepl("cellcount", e)) {
        return(list("80% of cell counts are >5, use Chi-squared test instead", 3))
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
  
  test = fisher.test(rmmeta, rmgroup)
  
  return (list(method = test$method,#gsub("\\'","\\\\'", test$method),
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