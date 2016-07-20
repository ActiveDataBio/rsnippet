### Unit Testing for Categorical Snippets
setwd("~/GitHub/rsnippet");

Data <- setRefClass("Data", fields = c("meta", "group", "errors"),
                    methods = list(
                      ## initializer function
                      initialize = function(meta, group) {
                        initFields(meta = meta, group = group, errors = list("", 0))
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

return_test = function(result, code = 0) {
  if (!is.list(result))
    stop("return value is not a list")
  
  if (length(result) != 8)
    stop("returned list does not have a length of 8")
  
  if (is.null(result$status))
    stop("no status code returned")
  
  if (result$status != 0 | result$status != 1 | 
      result$status != 2 | result$status != 3)
    stop("improper status code returned")
  
  if (result$status == 3)
    stop(result$msg)
  
  if (code == 0)
    if (result$status != 2)
      stop("test did not return an error")
  
  if (is.null(result$msg))
    stop("no error message returned, should be an empty string if no error occurred")
  
  if (is.null(result$method))
    stop("no test method returned")
  
  if (is.null(result$pvalue))
    stop("no p-value returned")
  
  if (is.null(result$charts) || length(result$charts) == 0)
    stop("no chart types returned")
  
  if (is.null(result$lables))
    stop("no labels returned, should be an empty string if lables are not needed")
  
  if (is.null(result$group_in))
    stop("no data returned for \"IN\" group, should be an empty array if an error occurred")
  
  if (is.null(result$group_out))
    stop("no data returned fro \"OUT\" group, should be an empty array if an error occurred")
}

get_randomval = function(x) {
  if (length(x) == 1)
    return(x)
  else 
    return(sample(x, 1))
}


fixFactor <- function(x) {
  if(is.factor(x)) factor(x) else x
}

# define 'null' strings
null_string <- c("","[Not Applicable]","[Not Available]","[Pending]","[]")

snippet <- "rcode/wilcoxon.R"
source(snippet)

## Testing when meta == NULL
## Should return an error message, status code = 2
meta = NULL
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
result = vec$snippet_test(null_string)
return_test(result, 1)

## Testing when meta has two categories
meta = sample(c('YES','NO'), length = 50, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
result = vec$snippet_test(null_string)
return_test(result)

## Testing when meta has four categories
meta = sample(c('YES','NO','MAYBE','UNKNOWN'), length = 50, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
result = vec$snippet_test(null_string)
return_test(result)

## Testing when the meta categories are encoded as numbers
meta = sample(c(20, 10, 0, -10), length = 50, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
result = vec$snippet_test(null_string)
return_test(result)

## Testing when all data is missing
## Should return an error, status code = 2
meta = sample(null_string, length = 20, replace = TRUE)
group = sample(c('IN','OUT'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
result = vec$snippet_test(null_string)
return_test(result, 1)

## Testing when there is one observation in one group, many observations in other group
meta = sample(c('YES','NO'), length = 50, replace = TRUE)
group = c('IN', rep('OUT', times = (length(meta) - 1)))
vec = Snippet$new(meta, group)
result = vec$snippet_test(null_string)
return_test(result)

## Testing when one group has all missing values
## Should return an error, status code = 2
meta = rep(c('YES', get_randomval(null_string)), times = 50)
group = rep(c('IN','OUT'), length(meta), replace = TRUE)
vec = Snippet$new(meta, group)
result = vec$snippet_test(null_string)
return_test(result, 1)

## Testing when the observations belong to one group
## Should return an error, status code = 2
meta = sample(c('YES','NO'), length = 50, replace = TRUE)
group = sample(c('IN'), length(meta), replace=TRUE)
vec = Snippet$new(meta, group)
result = vec$snippet_test(null_string)
return_test(result, 1)

## Testing when there is only one observation per group
meta = c('YES','NO')
group = c('IN','OUT')
vec = Snippet$new(meta, group)
result = vec$snippet_test(null_string)
return_test(result)

## Testing when there are three observations per group
meta = sample(c('YES','NO'), length = 6, replace = TRUE)
group = rep(c('IN','OUT'), times = 3)
vec = Snippet$new(meta, group)
result = vec$snippet_test(null_string)
return_test(result)

## Testing a continuous variable
meta = rexp(50)
group = rep(c('IN','OUT'), length(meta), replace = TRUE)
vec = Snippet$new(meta, group)
result = vec$snippet_test(null_string)
return_test(result)