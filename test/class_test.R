# setwd("~/GitHub/rsnippet")

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
# or choose a predefined group if using "metadata.tsv" from the ADBio repository
## group <- rep('OUT', length(meta))
## group[which(metadata$group=="E")] <- 'IN'

# define 'null' strings
# if using your own dataset, edit the null_string to match your coding
null_string <- c("","[Not Applicable]","[Not Available]","[Pending]","[]")

# snippet <- "name_of_snippet.R"
snippet <- "rcode/wilcoxon.R"
source(snippet)

# run the test and print the output
vec = Snippet$new(meta, group)
result = vec$doTest(null_string)
result