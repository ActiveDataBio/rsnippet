library('methods')

Data <- setRefClass("Data", fields = c("meta1", "meta2", "meta3", "errors"),
                    methods = list(
                      ## initializer function
                      initialize = function(meta1, meta2, meta3 = NULL) {
                        initFields(meta1 = meta1, meta2 = meta2,
                                   meta3 = meta3, errors = list("", 0))
                      },
                      
                      doTest = function(null_string) {
                        tryCatch({
                          result = cleaning(null_string)
                          if (result$status != 2) {
                            result = assumptions()
                          }
                          if (result$status != 2) {
                            result = test()
                          }
                          return(result)
                        },
                        
                        error = function(e) {
                          return(result(error = list(e$message, 3)))
                        }
                        )},
                      
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
                      
                      ## results formatting function
                      result = function(test = list(method = "", p.value = ""), chart = "", 
                                        label = "", data = "", error) {
                        
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
                                    data = unclass(data),
                                    msg = unlist(messages),
                                    status = code))
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
                      group_check = function(data) {
                        if(length(unique(data)) == 1)
                          stop("Only 1 group in categorical variable")
                        return(NULL)
                      },
                      
                      ## Check data is not constant
                      value_check = function(meta1, meta2) {
                        datatable = table(meta1, meta2)
                        if (dim(datatable)[1] == 1)
                          stop("Same value for each observation")
                        return(NULL)
                      }
                    ))