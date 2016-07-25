### Unit Testing for Categorical Snippets

### Use this Rscript to test any customized Rscripts. This file can be 
### modified to customize any tests, but the server will run this
### original script to check for the correct output of the customized
### Rsnippet.

###############################################################################
## Do not edit following section before line 171
###############################################################################

# setwd("~/GitHub/rsnippet");

Data <- setRefClass("Data", fields = c("meta", "group", "errors"),
                    methods = list(
                      ## initializer function
                      initialize = function(meta, group) {
                        initFields(meta = meta, group = group, errors = list("", 0))
                      },
                      
                      ## update Data varaible to new meta and group and reset errors
                      update = function(meta, group) {
                        meta <<- meta
                        group <<- group
                        errors <<- list("", 0)
                      },
                      
                      ## function to run the snippet tests and return the output
                      snippet_test = function(null_string) {
                        tryCatch({
                          result = vec$cleaning(null_string)
                          if (result$status != 2) {
                            result = vec$assumptions()
                          }
                          if (result$status != 2) {
                            result = vec$test()
                          }
                          return(result)
                        },
                        
                        error = function(e) {
                          return(result(error = list(e$message, 3)))
                        }
                        )},
                      
                      ## results formatting function
                      result = function(test = list(method = "", p.value = ""), chart = "", 
                                        label = "", g_in = "", g_out = "", error) {
                        
                        code = error[[2]]
                        if ((code == 2) || (length(error) == 2)) {
                          messages = error[[1]]
                        } else {
                          messages = list()
                          i = 3
                          while (i <= (length(error) - 1)) {
                            messages = c(messages, list(error[[i]]))
                            i = i + 2
                          }
                          code = 1
                        }
                        
                        names(messages) = NULL
                        
                        return(list(method = test$method,#gsub("\\'", "\\\\'", test$method),
                                    pvalue = test$p.value,
                                    charts = chart,
                                    labels = label,
                                    group_in = g_in,
                                    group_out = g_out,
                                    msg = unlist(messages),
                                    status = code))
                      },
                      
                      ## data cleaning and missing value handler function
                      cleaning = function(null_string) {
                        errors[[1]] <<- "Cleaning function not found"
                        errors[[2]] <<- 3
                        return(result(error = errors))
                      },
                      
                      ## testing assumptions/requirements
                      assumptions = function() {
                        errors[[1]] <<- "Assumption testing function not found"
                        errors[[2]] <<- 3
                        return(result(error = errors))
                      },
                      
                      ## statistical testing function
                      test = function() {
                        errors[[1]] <<- "Test function not found"
                        errors[[2]] <<- 3
                        return(result(error = errors))
                      },
                      
                      ## Check if data was read in correctly
                      read_check = function(meta) {
                        if (is.null(meta))
                          stop("No meta data")
                        return(NULL)
                      },
                      
                      ## Check if data still available after removal of missing values
                      missing_check = function(index) {
                        if (length(which(index)) == 0)
                          stop("No meta data")
                        return(NULL)
                      },
                      
                      ## Check if there are observations in each group
                      group_check = function(group) {
                        if(length(which(group %in% "IN")) == 0 ||
                           length(which(group %in% "OUT")) == 0) {
                          stop("No data in one group")
                        }
                        return(NULL)
                      },
                      
                      ## Check data is not constant
                      value_check = function(meta, group) {
                        datatable = table(meta, group)
                        if (dim(datatable)[1] == 1)
                          stop("Same value for each observation")
                        return(NULL)
                      }
                    ))

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
    stop("no data returned fro \"OUT\" group, should be an empty array if an error occurred in ", test)
  
  print(paste(test, "success", sep = " "))
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
result = vec$snippet_test(null_string)
return_test(result, "test of meta = NULL", 1)

## Testing correct coding with random times between 0 and 100 and random events
meta_time = sample(0:100, size = 50, replace = TRUE)
meta_event = sample(c('a','b'), length(meta_time), replace = TRUE)
group = sample(c('IN','OUT'), length(meta_time), replace = TRUE)
vec$update(paste(meta_time, meta_event, sep = ""), group)
result = vec$snippet_test(null_string)
return_test(result, "test of random times and events")

## Testing all events are censored
meta_time = sample(0:100, size = 50, replace = TRUE)
meta_event = rep('a', times = length(meta_time))
group = sample(c('IN','OUT'), length(meta_time), replace = TRUE)
vec$update(paste(meta_time, meta_event, sep = ""), group)
result = vec$snippet_test(null_string)
return_test(result, "test of all events are censored")

## Testing all events in 'OUT' group are censored
meta_time = sample(0:100, size = 50, replace = TRUE)
meta_event = c(sample(c('a','b'), size = length(meta_time)/2, replace = TRUE), 
               rep('a', times = length(meta_time)/2))
group = c(rep('IN', times = length(meta_time)/2), rep('OUT', times = length(meta_time)/2))
vec$update(paste(meta_time, meta_event, sep = ""), group)
result = vec$snippet_test(null_string)
return_test(result, "test all events in 'OUT' group are censored")

## Testing all events in 'OUT' occured after the events in group 'IN'
meta_time = c(sample(1:50, size = 25, replace = TRUE), 
              sample(51:100, size = 25, replace = TRUE))
meta_event = sample(c('a','b'), size = length(meta_time), replace = TRUE)
group = c(rep('IN', times = length(meta_time)/2),
          rep('OUT', times = length(meta_time)/2))
vec$update(paste(meta_time, meta_event, sep = ""), group)
result = vec$snippet_test(null_string)
return_test(result, "test all events in 'OUT' occur after all events in 'IN'")

## Testing with missing values
meta_time = c(sample(1:100, size = 40, replace = TRUE), 
              sample(null_string, size = 10, replace = TRUE))
meta_event = sample(c('a','b'), size = length(meta_time), replace = TRUE)
group = sample(c('IN','OUT'), size = length(meta_time), replace = TRUE)
vec$update(paste(meta_time, meta_event, sep = ""), group)
result = vec$snippet_test(null_string)
return_test(result, "test with missing values")

## Testing with negative values for time
meta_time = sample(-20:75, size = 50, replace = TRUE)
meta_event = sample(c('a','b'), size = length(meta), replace = TRUE)
group = sample(c('IN','OUT'), size = length(meta), replace = TRUE)
vec$update(paste(meta_time, meta_event, sep = ""), group)
result = vec$snippet_test(null_string)
return_test(result, "test with negative time values")

## Testing with all missing values
## Should return an error message, status code = 2
meta_time = sample(null_string, size = 50, replace = TRUE)
group = sample(c('IN','OUT'), size = length(meta), replace = TRUE)
vec$update(meta_time, group)
result = vec$snippet_test(null_string)
return_test(result, "test with all values missing", 1)

## Testing with one group missing
## Should return an error message, status code = 2
meta_time = c(sample(null_string, size = 25, replace = TRUE), sample(1:100, size = 25, replace = TRUE))
meta_event = sample(c('a','b'), size = length(meta), replace = TRUE)
group = c(rep('IN', times = length(meta)/2), rep('OUT', times = length(meta)/2))
vec$update(paste(meta_time, meta_event, sep = ""), group)
result = vec$snippet_test(null_string)
return_test(result, "test with 'IN' group missing")

## Testing with one observation in 'OUT' and many in 'IN' group
meta_time = sample(1:100, size = 50, replace = TRUE)
meta_event = c(sample(c('a','b'), size = (length(meta) - 1), replace = TRUE), 'b')
group = c(rep('IN', times = (length(meta) - 1)), 'OUT')
vec$update(paste(meta_time, meta_event, sep = ""), group)
result = vec$snippet_test(null_string)
return_test(result, "test with one 'OUT' event but many 'IN' events", 1)

## Testing with one event per group
meta_time = sample(1:100, size = 2, replace = TRUE)
meta_event = c('b','b')
group = c('IN','OUT')
vec$update(paste(meta_time, meta_event, sep = ""), group)
result = vec$snippet_test(null_string)
return_test(result, "test with one event per group")

## Testing with three events per group
meta_time = sample(1:100, size = 6, replace = TRUE)
meta_event = rep('b', times = length(meta))
group = rep(c('IN','OUT'), times = length(meta)/2)
vec$update(paste(meta_time, meta_event, sep = ""), group)
result = vec$snippet_test(null_string)
return_test(result, "test wiht three events per group")

## Testing with incorrect event coding
## Should return an error message, status code = 2
meta_time = sample(1:100, size = 50, replace = TRUE)
meta_event = sample(c('c','d'), size = length(meta), replace = TRUE)
group = sample(c('IN','OUT'), size = length(meta), replace = TRUE)
vec$update(paste(meta_time, meta_event, sep = ""), group)
result = vec$snippet_test(null_string)
return_test(result, "test with incorrect event coding", 1)

## Testing with categorical data
## Should return an error message, status code = 2
meta = sample(c('YES','NO'), size = 50, replace = TRUE)
group = sample(c('IN','OUT'), size = length(meta), replace = TRUE)
vec$update(meta, group)
result = vec$snippet_test(null_string)
return_test(result, "test with categorical data", 1)