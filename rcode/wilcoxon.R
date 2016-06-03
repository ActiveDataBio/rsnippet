# Title: Two sample Wilcoxon rank sum Test
#
# Uses: The two sample Wilcoxon rank sum test is used as an
# alterantive to the two-sample t-test when the data is not
# normally distributed, the sample size is small, or when one 
# variable is ordinal. This test assumes that that one variable
# is either continuous or ordinal and one variable is categorical
# with two groups, that the groups within the categorical
# varaible are independent, and that observations are independent.
# The null hypothesis is that the groups are identically
# distributed while the alternative hypothesis is that the groups
# are not identically distributed. If the distributions of the
# two groups are not similar then the Wilcoxon rank sum test
# determines if the distributions are significantly different. If
# the two distributions are similar then the test determines if
# the medians of the two groups are significantly different.
#
# Data format: Values except for null/missing characters are numeric (may be
# encoded as strings).
# 
# Author: Kaitlin Cornwell
#
# Date: June 3, 2016
#
# Notes: The two-sample Wilcoxon rank sum test is also known as the Mann-
# Whitney U test.

test <- function(meta, group, null_string) {
  meta = as.character(meta)
  ## Remove missing values
  mvidx = !(meta %in% null_string)
  rmgroup = group[mvidx]
  rmmeta = meta[mvidx]
  rmmeta = as.numeric(rmmeta)
  
  ## Separate into "in" and "out" groups
  group_index = (rmgroup %in% "IN")
  meta_in = rmmeta[group_index]
  meta_out = rmmeta[!group_index]
  
  test = wilcox.test(meta_in, meta_out, alternative = "two.sided")
  
  return((c(testMethods = gsub("\\'", "\\\\'", test$method),
            pvalues = test$p.value,
            charts = paste(c("box plot", "scatter plot"), collapse = ','),
            labels = '',
            gin = paste(meta_in, collapse = ','),
            gout = paste(meta_out, collapse = ','))))
}
