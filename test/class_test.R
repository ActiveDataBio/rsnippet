setwd("~/GitHub/rsnippet")

Data <- setRefClass("Data", fields = c("meta", "group", "errors"),
                    methods = list(
                      ## initializer function
                      initialize = function(meta, group) {
                        initFields(meta = meta, group = group, errors = list("", 0))
                      },
                      
                      ## error testing/handling function
                      error = function() {
                        errors[[1]] <<- "Error function not found"
                        errors[[2]] <<- 2
                        return(result(error = errors))
                      },
                      
                      ## statistical testing function
                      test = function() {
                        errors[[1]] <<- "Test function not found"
                        errors[[2]] <<- 2
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
                      }
                    ))

fixFactor <- function(x) {
  if(is.factor(x)) factor(x) else x
}

# read a metadata file (tsv)
metadata <- read.delim('test/metadata(surv).txt')
metaconfig <- metadata[grep('#', metadata$id),]
metadata <- metadata[-grep('#', metadata$id),]

# select the column you want
meta <- fixFactor(metadata$tissue_source_site)

# group (randomly generated or select a group)
group <- sample(c('IN','OUT'), length(meta), replace=TRUE)
#group <- rep('OUT', length(meta))
#group[which(metadata$group=="E")] <- 'IN'

# define 'null' strings
null_string <- c("","[Not Applicable]","[Not Available]","[Pending]","[]")

snippet <- "T_test.R"
source(snippet)

vec = Snippet$new(meta, group)
result = vec$error(null_string)
if (result$status != 2) {
  result = vec$test()
}
result
