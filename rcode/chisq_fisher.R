# Title: Chi-squared test or Fisher's exact test
#
# Uses: The chi-squared test and Fisher's exact test are used when
# both variables being tested are categorical. The chi-squared test
# assumes that observations are not correlated and at least 20% of 
# the expected cell counts of the contingency table are greater than
# 5. Fisher's exact t-test assumes that each observation only fits
# into one cell and that the row and column totals are fixed and not
# random. Both tests are used to test for independence between the 
# two variables, but Fisher's exact t-test is used when sample sizes
# are small. The null hypothesis is that the proportions of one
# variable are independent of the other variable, while the
# alternative hypothesis is that the proportions of one variable are
# not independent of the other variable.
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
# a different variable. Lastly, this Rsnippet will calculate the expected
# cell frequencies of the contingency table and choose the appropriate test
# (chi-squared or Fisher's exact) for the data.

test <- function(meta, group, null_string) {
  
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
    
    tempRows = rownames(tempTable)
    
    ## Check data type
    if (dim(tempTable)[1] == 1) {
      stop("Custom: oneval")
    }
    if (dim(tempTable)[1] > ceiling(.75 * length(rmmeta))) {
      stop("Custom: type")
    }
    
    ## if >20% of expected frequences are <5 then use Fisher's exact test
    if (test_freq(length(rmmeta), tempTable) > .2) {
      test = fisher.test(rmmeta, rmgroup)
    } else {
      test = chisq.test(rmmeta, rmgroup)
    }
  },
  ## error handler function
  error = function (e) {
    if (grepl("Custom:", e)) {
      if (grepl("nullgroup", e)) {
        return(c("No data in a group", 2))
      }
      if (grepl("null", e)) {
        return(c("No meta data", 2))
      }
      if (grepl("oneval", e)) {
        return(c("Same value for each observation", 3))
      }
      if (grepl("type", e)) {
        return(c("Incorrect data type: received continuous instead of categorical", 3))
      }
    }
    return(c(e, 1))
  })
  
  ## if length of return statement is 2 then an error occurred
  ## return the error message and code
  if (length(ret) == 2) {
    return(c(msg = ret[1], status = ret[2]))
  }
  
  return (c(testMethods = gsub("\\'", "\\\\'", test$method),
             pvalues = test$p.value,
             charts = paste(c("stacked percentage column", "basic column",
                              "stacked column chart"), collapse = ','),
             labels = paste(tempRows[!tempRows %in% null_string], collapse = ','),
             gin = paste(tempTable[!tempRows %in% null_string,"IN"], collapse = ','),
             gout = paste(tempTable[!tempRows %in% null_string,"OUT"], collapse = ','),
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