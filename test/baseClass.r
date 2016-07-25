library('methods')

Data <- setRefClass("Data", fields = c("meta", "group", "errors"),
                    methods = list(
                      ## initializer function
                      initialize = function(meta, group) {
                        initFields(meta = meta, group = group, errors = list("", 0))
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