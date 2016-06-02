test <- function(meta, group, null_string) {
  
  # change meta from factors to strings
  meta = as.character(meta)
  
  # remove missing values
  mvidx = !(meta %in% null_string)
  rmgroup = group[mvidx]
  rmmeta = meta[mvidx]
  
  # if >20% of expected frequences are <5 then use Fisher's exact test
  if (test_freq(rmmeta, tempTable) > .2) {
    test = fisher.test(rmmeta, rmgroup)
  } else {
    test = chisq.test(rmmeta, rmgroup)
  }
  
  return ((c(testMethods = gsub("\\'", "\\\\'", test$method),
             pvalues = test$p.value,
             types = 'categorical',
             labels = paste(tempRows[!tempRows %in% null_string], collapse = ','),
             gin = paste(tempTable[!tempRows %in% null_string,"IN"], collapse = ','),
             gout = paste(tempTable[!tempRows %in% null_string,"OUT"], collapse = ','))))
}

test_freq <- function(rmmeta, tempTable) {
  # find row and column sums
  row_sums = vector(mode = "numeric", length = 0)
  for (i in 1:dim(tempTable)[1]) {
    row_sums = c(row_sums, sum(tempTable[i,]))
  }
  col_sums = vector(mode = "numeric", length = 0)
  for (j in 1:dim(tempTable)[2]) {
    col_sums = c(col_sums, sum(tempTable[,j]))
  }
  
  # find expected frequencies to test assumptions and count number of 
  # expected frequences <5
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
  
  # return percentage of expected frequences <5
  return (count/(dim(tempTable)[1] * dim(tempTable)[2]))
}
