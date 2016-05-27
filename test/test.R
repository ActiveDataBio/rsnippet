# set your working directory
setwd("~/GitHub/rsnippet");

# read a metadata file (tsv)
metadata <- read.delim('test/metadata.tsv')
metaconfig <- metadata[grep('#', metadata$id),]
metadata <- metadata[-grep('#', metadata$id),]

# select the column you want
meta <- metadata$PlatinumFreeInterval

# group (randomly generated)
group <- sample(c('IN','OUT'),160, replace=TRUE)

# define 'null' strings
null_string <- c("","[Not Applicable]","[Not Available]","[Pending]","[]")

# fetch your r snippet
snippet <- "rcode/continuous.r"
source(snippet)

test_result <- test(meta, group, null_string)