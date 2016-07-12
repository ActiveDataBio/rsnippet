# Used to run multivariate tests
#
# Author: Kaitlin Cornwell
#
# Date: June 21, 2016

## Data read in
# set your working directory
setwd("~/GitHub/rsnippet");

fixFactor <- function(x) {
  if(is.factor(x)) factor(x) else x
}

# read a metadata file (tsv)
metadata <- read.delim('test/metadata(surv).txt')
metaconfig <- metadata[grep('#', metadata$id),]
metadata <- metadata[-grep('#', metadata$id),]

# select the column you want
meta1 <- fixFactor(metadata$PlatinumStatus)          # var is continuous, categorical or time to event
meta2 <- fixFactor(metadata$additional_radiation_therapy)                     # var is only categorical
# define 'null' strings
null_string <- c("","[Not Applicable]","[Not Available]","[Pending]","[]")

# data cleaning
meta1 = as.character(meta1)
meta2 = as.character(meta2)

meta2 = meta2[!(meta1 %in% null_string)]
meta1 = meta1[!(meta1 %in% null_string)]
meta1 = meta1[!(meta2 %in% null_string)]
meta2 = meta2[!(meta2 %in% null_string)]

### Categorical vs. Categorical
table = table(meta1, meta2)
# find row and column sums
row_sums = vector(mode = "numeric", length = 0)
for (i in 1:dim(table)[1]) {
  row_sums = c(row_sums, sum(table[i,]))
}
col_sums = vector(mode = "numeric", length = 0)
for (j in 1:dim(table)[2]) {
  col_sums = c(col_sums, sum(table[,j]))
}

count = 0
for (i in 1:dim(table)[1]) {
  for (j in 1:dim(table)[2]) {
    if ((row_sums[i] * col_sums[j]) / length(meta1) < 5) {
      count = count + 1
    }
  }
}

if (dim(table)[1] == 1 || dim(table)[2] == 1) {
  test = NA
} else {
  if (count / (dim(table)[1] * dim(table)[2]) > .2) {
    test = fisher.test(meta1, meta2)
  } else {
    test = chisq.test(meta1, meta2)
  }
}
test

### Continuous vs. ordinal
meta1 = as.numeric(meta1)
meta2 = meta2[!is.na(meta1)]
meta1 = meta1[!is.na(meta1)]
meta2 = as.numeric(meta2)
meta1 = meta1[!is.na(meta2)]
meta2 = meta2[!is.na(meta2)]

test = cor.test(meta1, meta2, alternative = "two.sided", method = "spearman")
test

### Time to event (as continuous - no censored) vs. ordinal
meta1_time = substring(meta1, first = 1, last = (nchar(meta1) - 1))
meta1_time = as.numeric(meta1_time)
meta1_event = substring(meta1, first = nchar(meta1))
meta2 = meta2[!is.na(meta1_time)]
meta1_event = meta1_event[!is.na(meta1_time)]
meta1_time = meta1_time[!is.na(meta1_time)]
meta2 = as.numeric(meta2)
meta1_time = meta1_time[!is.na(meta2)]
meta1_event = meta1_event[!is.na(meta2)]
meta2 = meta2[!is.na(meta2)]

for (i in 1:length(meta1_event)) {
  if (meta1_event[i] == "a") {
    meta1_event[i] = 0
  } else {
    meta1_event[i] = 1
  }
}
meta1_event = as.numeric(meta1_event)

alive = which(meta1_event == 0)
meta1_time = meta1_time[-alive]
meta2 = meta2[-alive]

test = cor.test(meta1_time, meta2, alternative = "two.sided", method = "spearman")
test

### Time to event (as continuous - no censored) vs. continuous
meta1_time = substring(meta1, first = 1, last = (nchar(meta1) - 1))
meta1_time = as.numeric(meta1_time)
meta1_event = substring(meta1, first = nchar(meta1))
meta2 = meta2[!is.na(meta1_time)]
meta1_event = meta1_event[!is.na(meta1_time)]
meta1_time = meta1_time[!is.na(meta1_time)]
meta2 = as.numeric(meta2)
meta1_time = meta1_time[!is.na(meta2)]
meta1_event = meta1_event[!is.na(meta2)]
meta2 = meta2[!is.na(meta2)]

for (i in 1:length(meta1_event)) {
  if (meta1_event[i] == "a") {
    meta1_event[i] = 0
  } else {
    meta1_event[i] = 1
  }
}
meta1_event = as.numeric(meta1_event)

alive = which(meta1_event == 0)
meta1_time = meta1_time[-alive]
meta2 = meta2[-alive]

if ((shapiro.test(meta1_time)$p.value < .05) || (shapiro.test(meta2)$p.value < .05)) {
  test = cor.test(meta1_time, meta2, alternative = "two.sided", method = "spearman")
} else {
  test = cor.test(meta1_time, meta2, alternative = "two.sided", method = "pearson")
}
test

### Time to event vs. Categorical
meta1_time = substring(meta1, first = 1, last = (nchar(meta1) - 1))
meta1_time = as.numeric(meta1_time)
meta1_event = substring(meta1, first = nchar(meta1))
meta2 = meta2[!is.na(meta1_time)]
meta1_event = meta1_event[!is.na(meta1_time)]
meta1_time = meta1_time[!is.na(meta1_time)]

for (i in 1:length(meta1_event)) {
  if (meta1_event[i] == "a") {
    meta1_event[i] = 0
  } else {
    meta1_event[i] = 1
  }
}
meta1_event = as.numeric(meta1_event)

test = survdiff(Surv(event = meta1_event, time = meta1_time, type = 'right') ~ meta2, rho = 0)
test

### Ordinal vs. Categorical
meta1 = as.numeric(meta1)
meta2 = meta2[!is.na(meta1)]
meta1 = meta1[!is.na(meta1)]

groups = length(unique(meta2))

if (groups == 2) {
  test = wilcox.test(meta1 ~ meta2)
} else {
  test = kruskal.test(meta1 ~ as.factor(meta2))
}
test

### Continuous vs. Categorical
meta1 = as.numeric(meta1)
meta2 = meta2[!is.na(meta1)]
meta1 = meta1[!is.na(meta1)]

groups = attributes(table(meta2))$dimnames$meta2
norm_test = vector()
if (length(groups) == 1) {
  norm_test = c(NA)
} else {
  for (i in 1:length(groups)) {
    if ((length(which(meta2 %in% groups[i]))) > 2) {
      norm_test = c(norm_test, shapiro.test(meta1[meta2 %in% groups[i]])$p.value)
    } else {
      norm_test = c(norm_test, NA)
    }
  }
}

if (!any(is.na(norm_test))) {
  if (any(norm_test < .05)) {
    if (length(groups) == 2) {
      test = wilcox.test(meta1 ~ meta2)
    } else {
      test = kruskal.test(meta1 ~ as.factor(meta2))
    }
  } else {
    if (length(groups) == 2) {
      test = t.test(meta1 ~ meta2)
    } else {
      test = anova(aov(meta1 ~ meta2))
    }
  }
} else {
  test = NA
}
test