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
# Data format: The group labels are encoded as strings.
#
# Author: Kaitlin Cornwell
#
# Date: June 1, 2016

test <- function(meta, group, null_string) {
  
  # change meta from factors to strings
  meta = as.character(meta)
  
  ## remove missing values
  mvidx = !(meta %in% null_string)
  rmgroup = group[mvidx]
  rmmeta = meta[mvidx]
  tempTable = table(rmmeta, rmgroup)
  tempRows = rownames(tempTable)
  
  ## if >20% of expected frequences are <5 then use Fisher's exact test
  if (test_freq(rmmeta, tempTable) > .2) {
    test = fisher.test(rmmeta, rmgroup)
  } else {
    test = chisq.test(rmmeta, rmgroup)
  }
  
  return ((c(testMethods = gsub("\\'", "\\\\'", test$method),
             pvalues = test$p.value,
             charts = paste(c("stacked percentage column", "basic column",
                              "stacked column chart"), collapse = ','),
             labels = paste(tempRows[!tempRows %in% null_string], collapse = ','),
             gin = paste(tempTable[!tempRows %in% null_string,"IN"], collapse = ','),
             gout = paste(tempTable[!tempRows %in% null_string,"OUT"], collapse = ','))))
}

test_freq <- function(rmmeta, tempTable) {
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
      ex_freq[i,j] = (row_sums[i] * col_sums[j])/length(rmmeta)
      if (ex_freq[i,j] < 5) {
        count = count + 1
      }
    }
  }
  
  ## return percentage of expected frequences <5
  return (count/(dim(tempTable)[1] * dim(tempTable)[2]))
}