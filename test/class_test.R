setwd("~/GitHub/rsnippet")

source("test/baseClass.r")

fixFactor <- function(x) {
  if(is.factor(x)) factor(x) else x
}

# read a metadata file (tsv)
metadata <- read.delim('test/metadata(surv).txt')
metaconfig <- metadata[grep('#', metadata$id),]
metadata <- metadata[-grep('#', metadata$id),]

# select the column you want
meta <- fixFactor(metadata$PlatinumFreeInterval)

# group (randomly generated or select a group)
group <- sample(c('IN','OUT'), length(meta), replace=TRUE)
#group <- rep('OUT', length(meta))
#group[which(metadata$group=="E")] <- 'IN'

# define 'null' strings
null_string <- c("","[Not Applicable]","[Not Available]","[Pending]","[]")

snippet <- "rcode/wilcoxon.R"
source(snippet)

vec = Snippet$new(meta, group)
result = vec$cleaning(null_string)
if (result$status != 2) {
  result = vec$assumptions()
}
if (result$status != 2) {
  result = vec$test()
}
result