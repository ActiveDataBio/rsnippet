# Title: Two-sample t-test
#
# Uses: The two-sample t-test is used when one variable is continuous and one
# variable is categorical with two groups. This test assumes that samples have
# been drawn from normally distributed popluations and that the popluations have
# equal variances. The two-sample t-test is used to test for differences in mean
# between the groups defined by the categorical variable. The null hypothesis is
# that the means are equal, while the alternative hypothesis is that the means
# are not equal. Since this test uses the mean, the two-sample t-test should not 
# be chosen when the data has a large range or is signifcanly skewed.
#
# Data format: Values except for null/missing characters are numeric (may be
# encoded as strings).
#
# Author: Kaitlin Cornwell
# 
# Date: June 3, 2016
#
# Notes: 


test = function(meta, group, null_string) {
  ret = tryCatch({
    ## check data input
    if (is.null(meta)) {
      stop("Custom: null")
    }
    if(!is.character(meta)) {
      meta = as.character(meta)
    }
    
    ## remove missing values
    mvidx = !(meta %in% null_string)
    if (length(which(mvidx)) == 0) {
      stop("Custom: null")
    }
    rmgroup = group[mvidx]
    rmmeta = meta[mvidx]
    
    ## Change data to numeric form
    rmmeta = as.numeric(rmmeta)
    
    ## Remove NAs
    mvidx = (!is.na(rmmeta))
    rmgroup = rmgroup[mvidx]
    rmmeta = rmmeta[mvidx]
    
    ## Check data
    if (length(rmmeta) == 0) {
      stop("Custom: type")
    }
    if (length(which(rmgroup %in% "IN")) == 0 ||
        length(which(rmgroup %in% "OUT")) == 0) {
      stop("Custom: nullgroup")
    }
    
    ## Check data type
    table = table(rmmeta)
    if (dim(table) == 1) {
      stop("Custom: oneval")
    }
    for (i in 1:dim(table)) {
      if (table[[i]] > (.2 * length(rmmeta))) {
        stop("Custom: type")
      }
    }
    
    ## Split data into "IN" and "OUT" groups
    group_index = (rmgroup %in% "IN")
    meta_in = rmmeta[group_index]
    meta_out = rmmeta[!group_index]
    
    ## Test varaince and perform t-test
    var = var.test(meta_in, meta_out, alternative = "two.sided")
    if (var$p.value < .05) {
      test = t.test(meta_in, meta_out,
                    alternative = "two.sided", var.equal = FALSE)
    }
    else {
      test = t.test(meta_in, meta_out,
                    alternative = "two.sided", var.equal = TRUE)
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
        return(c("Incorrect data type: received categorical instead of continuous", 3))
      }
    }
    return(c(e, 1))
  })
  
  ## if length of return statement is 2 then an error occurred
  ## return the error message and code
  if (length(ret) == 2) {
    return(c(msg = ret[1], status = ret[2]))
  }

  return(c(testMethods = gsub("\\'", "\\\\'", ret$method),
    pvalues = ret$p.value,
    charts = "box plot",
    labels = '',
    gin = paste(meta_in, collapse = ','),
    gout = paste(meta_out, collapse = ','),
    msg = '',
    status = 0))
}
