#' to run statistical tests based on the user preference
#' @arguments a working directory of a source file
#' @arguments node name
#' @examples
#' Rscript stat_col.r "/path/dir" node10 src/main/resources
#' get arguments
#' args[1] path for working directory 
#' args[2] node, 
#' args[3] metaFile, 
#' args[4] dendroFile, 
#' args[5] result file, 
#' args[6] custom codes,
#' args[7] base path for r script resources
#
args <- commandArgs(trailingOnly = TRUE)
srcPath <- args[7]
setwd(args[1])
print("loading libraries and classes")
library('rjson')
source(paste0(args[7],"/rcode/baseClass.r"))
source(paste0(args[7],"/rcode/resultClass.r"))

findNode <- function(parent, name) {
  if (!is.null(parent$name) && parent$name == name) {
    return (parent)
  } else {
    if (!is.null(parent$children)) {
      len <- length(parent$children)
      for (i in 1:len) {
        node <- findNode(parent$children[[i]], name)
        if (!is.null(node)) return (node)
      }
    }
    else return (NULL);
  }
}

toJson <- function(result){
  ################################################################
  ## generate json string
  ################################################################
  str = '{"stats":['
  count = 1
  for(j in (1:length(result))){
    temp = result[[j]]
    if(!is.null(temp)){
      if (count == 1) {
        str = paste0(str,temp$toJson());
      } else {
        str = paste0(str, ',', temp$toJson())
      }
      count = count + 1
    }
  }
  str = paste0(str, ']', ',"node":"', nodeName, '"}')
  return(str)
}

findLeaves <- function(node) {
  if (!is.null(node$children)) {
    len <- length(node$children)
    for (i in 1:len) {
      findLeaves(node$children[[i]])
    }
  } else {
    count <<- count + 1
    leaf[count] <<- node$name
    #print (node$name)
  }
}

#' customized parameters
print(args[6])
temp <- fromJSON(gsub("'",'"',args[6]))
custom_codes <- NULL
if (length(temp) > 0) {
  for (i in 1:length(temp)) {
    new <- data.frame(col=temp[[i]]$name,snippet=c(rep(temp[[i]]$snippet$name,length(temp[[i]]$name))))
    if (is.null(custom_codes))  custom_codes<-new
    else custom_codes<-rbind(custom_codes,new)
  }  
}

## fetch a list of children of this node
nodeName <- args[2]
data <- fromJSON(file=args[4], method='C')
count <- 0
leaf <- rep(NA,100)
findLeaves(findNode(data, nodeName))
sampleIds <- na.omit(leaf)

## read the metadata file
metadata <- read.delim(args[3])
metaconfig <- metadata[grep('#', metadata$id),]
metadata <- metadata[-grep('#', metadata$id),]

#' fix factor
#' @param x an input array
fixFactor <- function(x) {
  if(is.factor(x)) factor(x) else x
}

################################################################
## find a column name for unique ids
################################################################
unique_id <- 'id'

## to identify null strings
null_string <- c("","[Not Applicable]","[Not Available]","[Pending]","[]")

target_group <- sampleIds[sampleIds != ""]

## check the idx for target group
match_idx <- pmatch(target_group, eval(parse(text=paste0('metadata$',unique_id))), dup = FALSE)  
match_idx <- match_idx[complete.cases(match_idx)]

## make a group according to the each nodes (subset)
#' @NOTE: be careful whether there is 'temp_group' column in meta data...
# metadata$temp_group = "OUT"
# metadata[match_idx,]$temp_group = 'IN'
group <- c()
for (i in (1:nrow(metadata))) {
  if (i %in% match_idx) group[i] <- 'IN'
  else group[i] <- 'OUT'
}

results <- list()

#addToResult <- function(json,results){
#  results[length(results)+1] = json
#  return(results)
#}
nullCount = 1
for (i in 2:ncol(metadata)) {
  results[i-1] = NA
  col_name <- names(metadata[i])
  print(paste0("Running test on ",col_name))
  ## user preference for this column
  eval(parse(text=paste0('config=metaconfig$',col_name)))
  if (sum(config == 'no') == 1) next
  config <- fixFactor(config)
  
  eval(parse(text=paste0('meta=metadata$',col_name)))
  meta <- fixFactor(meta)
  if (!is.null(custom_codes) && col_name %in% custom_codes$col) {
#    snippet <- as.character(custom_codes$snippet[custom_codes$col==col_name])
     snippet <- paste0(args[7],'/rcode/',as.character(custom_codes$snippet[custom_codes$col==col_name]),'.r')  
      print(paste0("custom code for ", col_name, ": ", snippet))
  } else {
    snippet <- paste0(args[7],'/rcode/',config[1],'.r')
  }
  print(paste0("loading snippet file for ",col_name))
  print(paste0(args[7],'/rcode/',config[1],'.r'))
  source(snippet)
  vec = Snippet$new(meta, group)
  
  test_result = vec$doTest(null_string)
  if(test_result$status == 0){
    test_result$attribute=col_name
    #results = addToResult(toJSON(test_result),results)  
    results[i-1] = toJSON(test_result)
  }
  print("test finished")
}
#create output file
fileConn<-file(paste0(args[5]))
#write json string to file
writeLines(paste0('{"stats":[',paste(results[!is.na(results)], collapse = ','),']', ',"node":"', nodeName, '"}')
, fileConn)
close(fileConn)
