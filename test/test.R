# set your working directory
setwd("~/GitHub/rsnippet");

fixFactor <- function(x) {
  if(is.factor(x)) factor(x) else x
}

# read a metadata file (tsv)
metadata <- read.delim('test/metadata.tsv')
metaconfig <- metadata[grep('#', metadata$id),]
metadata <- metadata[-grep('#', metadata$id),]

# select the column you want
meta <- fixFactor(metadata$pretreatment_history)

# group (randomly generated or select a group)
# group <- sample(c('IN','OUT'), length(meta), replace=TRUE)
group <- rep('OUT', length(meta))
group[which(metadata$group=="E")] <- 'IN'

# define 'null' strings
null_string <- c("","[Not Applicable]","[Not Available]","[Pending]","[]")

# fetch your r snippet
snippet <- "rcode/chisq_fisher.r"
source(snippet)

# you can see your results if your snippet doesn't have any issue.
# otherwise, you can see some error messages in console.
result <- test(meta, group, null_string)
