# Title: The name of the test that will be run
#
# Uses: Should include when the test should be run (ie: variable types
# sample sizes, etc), assumptions, and the hypothesis.
#
# Data format: how the data should be encoded (numeric, binary,
# any special formatting, etc).
#
# Author: your name
#
# Date: the date the test was created
#
# Notes: any additional notes needed for the test (additional names, 
# or uses, etc).

Snippet <- setRefClass("Snippet", contains = "Data", 
                       fields = c( ## insert the name of any additional
                                   ## fields as a string 
                                  ),
                       methods = list(
                         
                         ## Include any methods (functions) here
                         
                         ## A cleaning, assumptions, and test method
                         ## must be implemented. Additional methods may be
                         ## added as needed.
                         
                         ## Missing values handler function
                         cleaning = function(null_string) {
                           tryCatch({
                             
                             ## Used to clean the data by changing types
                             ## (i.e. character to numeric) and to handle
                             ## missing data.
                             
                             ## Additionally, checks can be included here.
                             ## Checks that have already been implemented 
                             ## include read_check(meta) to check if the
                             ## data was read in correctly, missing_check(index)
                             ## to check if there is still data available after
                             ## removal of missing values, and group_check(group)
                             ## to ensure there is at least one observation per
                             ## group.
            
                           },
                           
                           error = function(e) {
                             
                             ## Error handler function for the cleaning method
                             ## Can simply return an error or may be customized
                             ## to handle the error in another way.
                             
                             ## to return the error, uncomment 
                             ## the following two lines.
                             
                             #e$message = gsub("\n", " ", e$message)
                             #errors <<- list(e$message, 2)
                           },
                           
                           finally = {
                             
                            ## This section is optional
                            ## The finally section of the tryCatch within the
                            ## cleaning function can be used to return the
                            ## list of errors. The list of errors must be
                            ## returned in order for the program to continue
                            ## to the assumptions method.
                             
                            ## example of the return statement: 
                            ## return(result(error = errors))
                           })
                         },
                         
                         ## Assumption checking
                         assumptions = function() {
                           
                           tryCatch({
                            
                             ## To be used to check any assumptions that the test
                             ## has. Can also be used to set any additional fields.
                             ## One check that has been previously implemented
                             ## and can be used here is the value_check(meta, group)
                             ## to ensure that the data is not constant.
                             
                           },   
                           
                           error = function(e) {
                             
                             ## Error handler function for the assumptions method
                             ## Can simply return an error or may be customized
                             ## to handle the error in another way.
                             
                             ## to return the error, implement the uncomment 
                             ## the following two lines.
                             
                             #e$message = gsub("\n", " ", e$message)
                             #errors <<- list(e$message, 2) 
                             
                           }, 
                           
                           finally = {
                             
                             ## This section is optional
                             ## The finally section of the tryCatch within the
                             ## assumptions function can be used to return the
                             ## list of errors. The list of errors must be
                             ## returned in order for the program to continue
                             ## to the test method.
                             
                             ## example of the return statement: 
                             ## return(result(error = errors))
                           
                            })   
                         },
                         
                         test = function() {
                           tryCatch({
                             
                             ## To be used to carry out the statistical test
                             ## and return the output.
                             ## Each parameter to the "result" function should
                             ## be returned at this step if the test ran
                             ## without any errors
                             
                           },
                           
                           ## Statistical test
                           error = function(e) {
                             
                             ## Error handler function for the test method.
                             ## Can simply return an error or may be customized
                             ## to handle the error in another way.
                             
                             ## to return the error, implement the uncomment 
                             ## the following two lines.
                             
                             #e$message = gsub("\n", " ", e$message)
                             #errors <<- list(e$message, 2)
                             
                           })
                         }
                       ))

## Add any additional functions needed here (e.g. any functions for additional checks)
