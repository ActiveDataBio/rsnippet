meta = as.character(meta)

mvidx = !(meta %in% null_string)
rmgroup = group[mvidx]
rmmeta = meta[mvidx]
level_size = dim(table(rmmeta))

if (level_size == 1 || level_size == nrow(metadata)) {
  return (NULL) 
} else {
  ## make a contingency table
  tempTable = table(rmmeta, rmgroup)
  if (dim(tempTable)[2] != 2) next
  tempRows = rownames(tempTable)
  
  test = fisher.test(rmmeta, rmgroup)
}
