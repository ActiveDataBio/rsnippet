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

snippet <- "rcode/t-test.R"
source(snippet)

## Testing when meta == NULL
## Should return an error message, status code = 2
meta = NULL
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
result = vec$snippet_test(null_string)
return_test(result, "test of meta = NULL", 1)

## Testing when meta comes from a N(0,1) population
meta = rnorm(n = 50, mean = 0, sd = 1)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec$update(meta, group)
result = vec$snippet_test(null_string)
return_test(result, "test of meta sampled from a N(0,1) population")

## Testing when meta comes from a N(10,5) population (all positive values)
meta = rnorm(n = 50, mean = 10, sd = 5)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec$update(meta, group)
result = vec$snippet_test(null_string)
return_test(result, "test of meta sampled from a N(10, 5) population")

## Testing when meta comes from an exp(2)
meta = rexp(n = 50, rate = 2)
group = sample(c('IN','OUT'), length(meta), replace = TRUE)
vec$update(meta, group)
result = vec$snippet_test(null_string)
return_test(result, "test of meta sampled from a exp(2) population")

## Testing when meta comes from an exp(2)*-1 population (all negative values)
meta = rexp(n = 50, rate = 2)
meta = meta * -1
group = sample(c('IN','OUT'), length(meta), replace = TRUE)
vec$update(meta, group)
result = vec$snippet_test(null_string)
return_test(result, "test of meta sampled from exp(2) * -1 population")

## Testing when meta contains missing values
meta = sample(c(rnorm(n = 50, mean = 0, sd = 1), null_string), size = 50, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace = TRUE)
vec$update(meta, group)
result = vec$snippet_test(null_string)
return_test(result, "test of meta containing missing values")

## Testing when all data is missing
## Should return an error, status code = 2
meta = sample(null_string, size = 20, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec$update(meta, group)
result = vec$snippet_test(null_string)
return_test(result, "test when all data is missing", 1)

## Testing when there is one observation in one group, many observations in other group
meta = runif(n = 50, min = -5, max = 5)
group = c('IN', rep('OUT', times = (length(meta) - 1)))
vec$update(meta, group)
result = vec$snippet_test(null_string)
return_test(result, "test when there in one observation in group 'IN'")

## Testing when one group has all missing values
## Should return an error, status code = 2
meta = rgamma(n = 25, shape = 1)
meta = c(meta, sample(null_string, size = 25, replace = TRUE))
group = rep('IN', times = 25)
group = c(group, rep('OUT'), times = 25)
vec$update(meta, group)
result = vec$snippet_test(null_string)
return_test(result, "test when one group has all missing values", 1)

## Testing when the observations belong to one group
## Should return an error, status code = 2
meta = rf(n = 50, df1 = 2, df2 = 1)
group = sample(c('IN'), length(meta), replace=TRUE)
vec$update(meta, group)
result = vec$snippet_test(null_string)
return_test(result, "test when all observations belong to one group", 1)

## Testing when there is only one observation per group
meta = runif(n = 2, min = 0, max = 1)
group = c('IN','OUT')
vec$update(meta, group)
result = vec$snippet_test(null_string)
return_test(result, "test with one observation per group")

## Testing when there are three observations per group
meta = runif(n = 6, min = 0, max = 5)
group = rep(c('IN','OUT'), times = 3)
vec$update(meta, group)
result = vec$snippet_test(null_string)
return_test(result, "test with three observations per group")

## Testing when meta is categorical and categories are encoded as numbers
meta = sample(c(20, 10, 0, -10), size = 50, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec$update(meta, group)
result = vec$snippet_test(null_string)
return_test(result, "test of numerical categorical data")

## Testing when meta is categorical and categories are encoded as strings
## Should return an error, status code = 2
meta = sample(c('YES','NO','MAYBE','UNKNOWN'), size = 50, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec$update(meta, group)
result = vec$snippet_test(null_string)
return_test(result, "test of character categorical data", 1)