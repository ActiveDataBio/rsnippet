# Title: Two-sample t-test
#
# Uses: The two-sample t-test is used when one variable is continuous and one
# variable is categorical with two groups. This test assumes that samples have
# been drawn from normally distributed popluations and that the popluations have
# equal variances. The two-sample t-test is used to test for diffrences in mean
# between teh groups defined by the categorical variable. The null hypothesis is
# that the means are equal, while the alternative hypothesis is that the means
# are not equal. Since this test uses the mean, the two-sample t-test should be 
# chosen when the data does not have a large range or is signifcanly skewed.
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
  return = tryCatch({
    ## check data input
    if (is.null(meta)) {
      stop("null")
    }
    if(!is.character(meta)) {
      meta = as.character(meta)
    }
    
    ## remove missing values
    mvidx = !(meta %in% null_string)
    if (length(which(mvidx)) == 0) {
      stop("null")
    }
    rmgroup = group[mvidx]
    rmmeta = meta[mvidx]
    
    ## Change data to numeric form
    rmmeta = as.numeric(rmmeta)
    
    ## check "in" and "out" groups
    levels = sort(unique(rmgroup))
    if(length(levels) != 2) {
      stop("Warning:level")
    }
    if(levels[1] != "IN") {
      stop("category")
    }
    if(levels[2] != "OUT") {
      stop("category")
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
    
    return(c(testMethods = gsub("\\'", "\\\\'", test$method),
             pvalues = test$p.value,
             charts = "box plot",
             labels = '',
             gin = paste(meta_in, collapse = ','),
             gout = paste(meta_out, collapse = ',')))
    
  }, error = function (e) {
    if (grepl("null", e)) {
      return(c("No meta data", 2))
    }
    if (grepl("level", e)) {
      return(c("Incorrect number of groups", 4))
    }
    if (grepl("category", e)) {
      return(c("Incorrect group names", 4))
    }
    print(e)
    return(c("Unknown error", 1))
  })
  
  return(return)
}
