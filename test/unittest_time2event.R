### Unit Testing for Time to Event snippets

### Use this Rscript to test any customized Rscripts. This file can be 
### modified to customize any tests, but the server will run this
### original script to check for the correct output of the customized
### Rsnippet.
### Note: These tests only check that the return value from the tests
### follow the correct foramt and only checks for correct error handling
### if any test is guarenteed to produce an error. Otherwise, it is up to
### the writer to test for correct results.

###############################################################################
## Do not edit following section before line 71
###############################################################################

setwd("~/GitHub/rsnippet");

library(survival)
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

snippet <- "rcode/kaplan_meier.R"
source(snippet)

## Testing when meta == NULL
## Should return an error message, status code = 2
meta = NULL
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
return_test(vec$doTest(null_string), "test of meta = NULL", 1)

## Testing correct coding with random times between 0 and 100 and random events
meta_time = sample(0:100, size = 50, replace = TRUE)
meta_event = sample(c('a','b'), length(meta_time), replace = TRUE)
group = sample(c('IN','OUT'), length(meta_time), replace = TRUE)
vec = Snippet$new(paste(meta_time, meta_event, sep = ""), group)
return_test(vec$doTest(null_string), "test of random times and events")

## Testing all events are censored
meta_time = sample(0:100, size = 50, replace = TRUE)
meta_event = rep('a', times = length(meta_time))
group = sample(c('IN','OUT'), length(meta_time), replace = TRUE)
vec = Snippet$new(paste(meta_time, meta_event, sep = ""), group)
return_test(vec$doTest(null_string), "test of all events are censored")

## Testing all events in 'OUT' group are censored
meta_time = sample(0:100, size = 50, replace = TRUE)
meta_event = c(sample(c('a','b'), size = length(meta_time)/2, replace = TRUE), 
               rep('a', times = length(meta_time)/2))
group = c(rep('IN', times = length(meta_time)/2), rep('OUT', times = length(meta_time)/2))
vec = Snippet$new(paste(meta_time, meta_event, sep = ""), group)
return_test(vec$doTest(null_string), "test all events in 'OUT' group are censored")

## Testing all events in 'OUT' occured after the events in group 'IN'
meta_time = c(sample(1:50, size = 25, replace = TRUE), 
              sample(51:100, size = 25, replace = TRUE))
meta_event = sample(c('a','b'), size = length(meta_time), replace = TRUE)
group = c(rep('IN', times = length(meta_time)/2),
          rep('OUT', times = length(meta_time)/2))
vec = Snippet$new(paste(meta_time, meta_event, sep = ""), group)
return_test(vec$doTest(null_string), "test all events in 'OUT' occur after all events in 'IN'")

## Testing with missing values
meta_time = c(sample(1:100, size = 40, replace = TRUE), 
              sample(null_string, size = 10, replace = TRUE))
meta_event = sample(c('a','b'), size = length(meta_time), replace = TRUE)
group = sample(c('IN','OUT'), size = length(meta_time), replace = TRUE)
vec = Snippet$new(paste(meta_time, meta_event, sep = ""), group)
return_test(vec$doTest(null_string), "test with missing values")

## Testing with negative values for time
meta_time = sample(-20:75, size = 50, replace = TRUE)
meta_event = sample(c('a','b'), size = length(meta_time), replace = TRUE)
group = sample(c('IN','OUT'), size = length(meta_time), replace = TRUE)
vec = Snippet$new(paste(meta_time, meta_event, sep = ""), group)
return_test(vec$doTest(null_string), "test with negative time values")

## Testing with all missing values
## Should return an error message, status code = 2
meta_time = sample(null_string, size = 50, replace = TRUE)
group = sample(c('IN','OUT'), size = length(meta_time), replace = TRUE)
vec = Snippet$new(meta_time, group)
return_test(vec$doTest(null_string), "test with all values missing", 1)

## Testing with one group missing
## Should return an error message, status code = 2
meta_time = c(sample(null_string, size = 25, replace = TRUE), sample(1:100, size = 25, replace = TRUE))
meta_event = sample(c('a','b'), size = length(meta_time), replace = TRUE)
group = c(rep('IN', times = length(meta_time)/2), rep('OUT', times = length(meta)/2))
vec = Snippet$new(paste(meta_time, meta_event, sep = ""), group)
return_test(vec$doTest(null_string), "test with 'IN' group missing")

## Testing with one observation in 'OUT' and many in 'IN' group
meta_time = sample(1:100, size = 50, replace = TRUE)
meta_event = c(sample(c('a','b'), size = (length(meta_time) - 1), replace = TRUE), 'b')
group = c(rep('IN', times = (length(meta_time) - 1)), 'OUT')
vec = Snippet$new(paste(meta_time, meta_event, sep = ""), group)
return_test(vec$doTest(null_string), "test with one 'OUT' event but many 'IN' events", 1)

## Testing with one event per group
meta_time = sample(1:100, size = 2, replace = TRUE)
meta_event = c('b','b')
group = c('IN','OUT')
vec = Snippet$new(paste(meta_time, meta_event, sep = ""), group)
return_test(vec$doTest(null_string), "test with one event per group")

## Testing with three events per group
meta_time = sample(1:100, size = 6, replace = TRUE)
meta_event = rep('b', times = length(meta_time))
group = rep(c('IN','OUT'), times = length(meta_time)/2)
vec = Snippet$new(paste(meta_time, meta_event, sep = ""), group)
return_test(vec$doTest(null_string), "test wiht three events per group")

## Testing with incorrect event coding
## Should return an error message, status code = 2
meta_time = sample(1:100, size = 50, replace = TRUE)
meta_event = sample(c('c','d'), size = length(meta_time), replace = TRUE)
group = sample(c('IN','OUT'), size = length(meta_time), replace = TRUE)
vec = Snippet$new(paste(meta_time, meta_event, sep = ""), group)
return_test(vec$doTest(null_string), "test with incorrect event coding", 1)

## Testing with categorical data
## Should return an error message, status code = 2
meta = sample(c('YES','NO'), size = 50, replace = TRUE)
group = sample(c('IN','OUT'), size = length(meta_time), replace = TRUE)
vec = Snippet$new(meta_time, group)
return_test(vec$doTest(null_string), "test with categorical data", 1)