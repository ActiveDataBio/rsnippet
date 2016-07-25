### Unit Testing for Continuous Snippets

### Use this Rscript to test any customized Rscripts. This file can be 
### modified to customize any tests, but the server will run this
### original script to check for the correct output of the customized
### Rsnippet.
### Note: These tests only check that the return value from the tests
### follow the correct foramt and only checks for correct error handling
### if any test is guarenteed to produce an error. Otherwise, it is up to
### the writer to test for correct results.

###############################################################################
## Do not edit following section before line 70
###############################################################################

setwd("~/GitHub/rsnippet");

source("test/baseClass.r")

return_test = function(result, test, code = 0) {
  if (!is.list(result))
    stop("return value is not a list in ", test)
  
  if (length(result) != 8)
    stop("returned list does not have a length of 8 in ", test)
  
  if (is.null(result$status))
    stop("no status code returned in ", test)
  
  if (result$status != 0 & result$status != 1 & 
      result$status != 2 & result$status != 3)
    stop("improper status code returned in ", test)
  
  if (result$status == 3)
    stop(result$msg, "in ", test)
  
  if (code == 1)
    if (result$status != 2)
      stop("test did not return an error in ", test)
  
  if (is.null(result$msg))
    stop("no error message returned, should be an empty string if no error occurred in ", test)
  
  if (is.null(result$method))
    stop("no test method returned in ", test)
  
  if (is.null(result$pvalue))
    stop("no p-value returned in ", test)
  
  if (is.null(result$charts) || length(result$charts) == 0)
    stop("no chart types returned in ", test)
  
  if (is.null(result$labels))
    stop("no labels returned, should be an empty string if lables are not needed in ", test)
  
  if (is.null(result$group_in))
    stop("no data returned for \"IN\" group, should be an empty array if an error occurred in ", test)
  
  if (is.null(result$group_out))
    stop("no data returned for \"OUT\" group, should be an empty array if an error occurred in ", test)
  
  print(paste(test, "returned correct results format", sep = " "))
}

###############################################################################
## Edit beneath here to customize unit tests
## Must edit the null_string to match missing values and must edit snippet name
###############################################################################

# define 'null' strings
null_string <- c("","[Not Applicable]","[Not Available]","[Pending]","[]")

snippet <- "rcode/t-test.R"
source(snippet)

## Testing when meta == NULL
## Should return an error message, status code = 2
meta = NULL
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of meta = NULL", 1)

## Testing when meta comes from a N(0,1) population
meta = rnorm(n = 50, mean = 0, sd = 1)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of meta sampled from a N(0,1) population")

## Testing when meta comes from a N(10,5) population (all positive values)
meta = rnorm(n = 50, mean = 10, sd = 5)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of meta sampled from a N(10, 5) population")

## Testing when meta comes from an exp(2)
meta = rexp(n = 50, rate = 2)
group = sample(c('IN','OUT'), length(meta), replace = TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of meta sampled from a exp(2) population")

## Testing when meta comes from an exp(2)*-1 population (all negative values)
meta = rexp(n = 50, rate = 2)
meta = meta * -1
group = sample(c('IN','OUT'), length(meta), replace = TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of meta sampled from exp(2) * -1 population")

## Testing when meta contains missing values
meta = sample(c(rnorm(n = 50, mean = 0, sd = 1), null_string), size = 50, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace = TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of meta containing missing values")

## Testing when all data is missing
## Should return an error, status code = 2
meta = sample(null_string, size = 20, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test when all data is missing", 1)

## Testing when there is one observation in one group, many observations in other group
meta = runif(n = 50, min = -5, max = 5)
group = c('IN', rep('OUT', times = (length(meta) - 1)))
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test when there in one observation in group 'IN'")

## Testing when one group has all missing values
## Should return an error, status code = 2
meta = rgamma(n = 25, shape = 1)
meta = c(meta, sample(null_string, size = 25, replace = TRUE))
group = rep('IN', times = 25)
group = c(group, rep('OUT'), times = 25)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test when one group has all missing values", 1)

## Testing when the observations belong to one group
## Should return an error, status code = 2
meta = rf(n = 50, df1 = 2, df2 = 1)
group = sample(c('IN'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test when all observations belong to one group", 1)

## Testing when there is only one observation per group
meta = runif(n = 2, min = 0, max = 1)
group = c('IN','OUT')
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test with one observation per group")

## Testing when there are three observations per group
meta = runif(n = 6, min = 0, max = 5)
group = rep(c('IN','OUT'), times = 3)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test with three observations per group")

## Testing when meta is categorical and categories are encoded as numbers
meta = sample(c(20, 10, 0, -10), size = 50, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of numerical categorical data")

## Testing when meta is categorical and categories are encoded as strings
## Should return an error, status code = 2
meta = sample(c('YES','NO','MAYBE','UNKNOWN'), size = 50, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of character categorical data", 1)