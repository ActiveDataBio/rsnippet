Snippet <- setRefClass("Snippet", contains = "Data",
                       fields = c("meta_in", "meta_out"),
                       methods = list(
                         ## Error checking
                         error = function(null_string) {
                           ## inital read in
                           check = read_check(meta)
                           if (check[[2]] != 0) {
                             errors[[1]] <<- check[[1]]; errors[[2]] <<- check[[2]]
                             return(result(error = errors))
                           }
                           if (!is.character(meta)) {
                             meta <<- as.character(meta)
                           }
                           
                           ## remove missing values
                           index = !(meta %in% null_string)
                           check = missing_check(index)
                           if (check[[2]] != 0) {
                             errors[[1]] <<- check[[1]]; errors[[2]] <<- check[[2]]
                             return(result(error = errors))
                           }
                           group <<- group[index]
                           meta <<- meta[index]
                           
                           ## change to numeric form
                           meta <<- as.numeric(meta)
                           index = (!is.na(meta))
                           group <<- group[index]
                           meta <<- meta[index]
                           check = group_check(meta, group)
                           if (check[[2]] != 0) {
                             errors[[1]] <<- check[[1]]; errors[[2]] <<- check[[2]]
                             return(result(error = errors))
                           }
                           check = type_check(meta)
                           if (check[[2]] != 0) {
                             if (check[[2]] == 2) {
                               errors[[1]] <<- check[[1]]; errors[[2]] <<- check[[2]]
                               return(result(error = errors))
                             } else {
                               errors <<- c(errors, list(check[[1]], check[[2]]))
                             }
                           }
                           
                           ## split data into in and out groups
                           group_index = (group %in% "IN")
                           meta_in <<- meta[group_index]
                           meta_out <<- meta[!group_index]
                         
                           ## normality test
                           check = norm_check(meta_in, meta_out)
                           if (check[[2]] != 0) {
                             if (check[[2]] == 2) {
                               errors[[1]] <<- check[[1]]; errors[[2]] <<- check[[2]]
                               return(result(error = errors))
                             } else {
                               errors <<- c(errors, list(check[[1]], check[[2]]))
                             }
                           }
                           
                           ## test
                           check = test_check(meta_in, meta_out)
                           if (check[[2]] == 2) {
                             errors[[1]] <<- check[[1]]; errors[[2]] <<- check[[2]]
                           }
                           return(result(error = errors))
                          },
                         
                         ## Statistical test
                         test = function() {
                           var = var.test(meta_in, meta_out, alternative = "two.sided")
                           if (var$p.value < .05) {
                             test = t.test(meta_in, meta_out,
                                           alternative= "two.sided", var.equal = FALSE)
                           } else {
                             test = t.test(meta_in, meta_out,
                                           alterantive = "two.sided", var.equal = TRUE)
                           }
                           
                           return(result(test, c("box"), "", meta_in, meta_out, errors))
                       }))


## Check if data was read in correctly
read_check <- function(meta) {
    check = tryCatch({
      if(is.null(meta)) {
        stop("Custom: null")
      } else {
        return(list('', 0))
      }
    }, 
    error = function(e) {
      if (grepl("Custom", e)) {
        return(list("No meta data", 2))
      }
      return(list(e$message, 2))
    })
  return(check)
}

## Check if data still availabe after removal of missing values
missing_check <- function(index) {
  check = tryCatch({
    if(length(which(index)) == 0) {
      stop("Custom")
    }
    return(list('', 0))
  }, error = function(e) {
    if(grepl("Custom", e)) {
      return(list("No meta data", 2))
    }
    return(list(e$message, 2))
  })
  return(check)
}

## Check if there are observations in each group
group_check <- function(meta, group) {
  check = tryCatch({
    if(length(meta) == 0) {
      stop("Custom: type")
    }
    if (length(which(group %in% "IN")) == 0 ||
        length(which(group %in% "OUT")) == 0) {
      stop("Custom: nullgroup")
    }
    return(list('', 0))
  }, error = function(e) {
    if(grepl("Custom", e)) {
      if (grepl("type", e)) {
        return(list("Incorrect data type: need numeric data", 2))
      }
      if (grepl("nullgroup", e)) {
        return(list("No data in group", 2))
      }
    }
    return(list(e$message, 2))
  })
  return(check)
}

## Check data type
type_check <- function(meta) {
  check = tryCatch({
    table = table(meta)
    if(dim(table) == 1) {
      stop("Custom: oneval")
    }
    for (i in 1:dim(table)) {
      if (table[[i]] > .2 * length(meta)) {
        stop("Custom: type")
      }
    }
    return(list('', 0))
  }, error = function(e) {
    if (grepl("Custom", e)) {
      if (grepl("oneval", e)) {
        return(list("Same value for each observation", 2))
      }
      if (grepl("type", e)) {
        return(list("Possible incorrect data type: expected continuous data", 1))
      }
    }
    return(e$message, 1)
  })
  return(check)
}

## Check normality assumption
norm_check <- function(meta_in, meta_out) {
  check = tryCatch({
    if ((shapiro.test(meta_in)$p.value < .05) ||
        (shapiro.test(meta_out)$p.value < .05)) {
      stop("Custom")
    }
    return(list('', 0))
  }, error = function(e) {
    if (grepl("Custom", e)) {
      return(list("At least one group is not normally distributed, try Wilcoxon rank-sum test", 1))
    }
    return(list(e$message, 2))
  })
  return(check)
}

## Check to ensure tests will work
test_check <- function(meta_in, meta_out) {
  check = tryCatch({
    var = var.test(meta_in, meta_out, alternative = "two.sided")
    if (var$p.value < .05) {
      t.test(meta_in, meta_out, alternative = "two.sided", var.equal = FALSE)
    } else {
      t.test(meta_in, meta_out, alternative = "two.sided", var.equal = TRUE)
    }
    return(list('', 0))
  }, error = function(e) {
    return(list(e$message, 2))
  })
  return(check)
}