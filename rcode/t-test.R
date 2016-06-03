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


test <- function(meta, group, null_string) {
  if (!is.character(meta)) {
    meta = as.character(meta)
  }
  
  ## Remove missing values
  mvidx = !(meta %in% null_string)
  rmgroup = group[mvidx]
  rmmeta = meta[mvidx]
  rmmeta = as.numeric(rmmeta)
  
  ## Separate into "in" and "out" groups
  group_index = (rmgroup %in% "IN")
  meta_in = rmmeta[group_index]
  meta_out = rmmeta[!group_index]
  
  ## test variance and conduct t-test
  var = var.test(meta_in, meta_out, alternative = "two.sided")
  if (var$p.value < .05) {
    test = t.test(meta_in, meta_out, alternative = "two.sided", var.equal = FALSE)
  }
  else {
    test = t.test(meta_in, meta_out, atlernative = "two.sided", var.equal = TRUE)
  }
  
  return((c(testMethods = gsub("\\'", "\\\\'", test$method),
            pvalues = test$p.value,
            charts = "box plot",
            labels = '',
            gin = paste(meta_in, collapse = ','),
            gout = paste(meta_out, collapse = ','))))
}