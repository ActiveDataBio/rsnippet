### Unit Testing for Categorical Snippets

### Use this Rscript to test any customized Rscripts. This file can be 
### modified to customize any tests, but the server will run this
### original script to check for the correct output of the customized
### Rsnippet.
### Note: These tests only check that the return value from the tests
### follow the correct foramt and only checks for correct error handling
### if any test is guarenteed to produce an error. Otherwise, it is up to
### the writer to test for correct results.

###############################################################################
## Do not edit the following section before line 70
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

snippet <- "rcode/chisq.R"
source(snippet)

## Testing when meta == NULL
## Should return an error message, status code = 2
meta = NULL
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of meta = NULL", 1)

## Testing when meta has two categories
meta = sample(c('YES','NO'), size = 50, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of two categories")

## Testing when meta has four categories
meta = sample(c('YES','NO','MAYBE','UNKNOWN'), size = 50, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of four categories")

## Testing when the meta categories are encoded as numbers
meta = sample(c(20, 10, 0, -10), size = 50, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of numeric names of categories")

## Testing when meta contains missing values
meta = sample(c('YES','NO',null_string), size = 50, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace = TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of meta + missing values")

## Testing when all data is missing
## Should return an error, status code = 2
meta = sample(null_string, size = 20, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of complete missing data", 1)

## Testing when there are 10 groups with 5 categories in meta
meta = sample(c('1', '2', '3', '4', '5', '6', '7', '8', '9', '10'), size = 50, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace = TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of 10 categories")

## Testing when there is one observation in one group, many observations in other group
meta = sample(c('YES','NO'), size = 50, replace = TRUE)
group = c('IN', rep('OUT', times = (length(meta) - 1)))
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of one observation in 'IN' group")

## Testing when one group has all missing values
## Should return an error, status code = 2
meta = rep('YES', times = 25)
meta = c(meta, sample(null_string, size = 25, replace = TRUE))
group = rep('IN', length(meta)/2, replace = TRUE)
group = c(group, rep('OUT', length(meta)/2, replace = TRUE))
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of all missing values in 'OUT' group", 1)

## Testing when the observations belong to one group
## Should return an error, status code = 2
meta = sample(c('YES','NO'), size = 50, replace = TRUE)
group = sample(c('IN'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of all observations in 'IN' group", 1)

## Testing when there is only one observation per group
meta = c('YES','NO')
group = c('IN','OUT')
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of only one observation per group")

## Testing when there are three observations per group
meta = sample(c('YES','NO'), size = 6, replace = TRUE)
group = rep(c('IN','OUT'), times = 3)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of three observations per group")

## Testing a continuous variable
meta = rexp(50)
group = rep(c('IN','OUT'), length(meta), replace = TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of continuous variable")