# Title: Kaplan-Meier/Log-Rank
#
# Uses: The Kaplan-Meier test is used with time-to-event (survival) data.
# This test is used to compare event times between multiple groups. It assumes
# that censoring is unrelated to prognosis, that survival probabilities are 
# the same (regardless of early or late recruitment into the study), and that
# events happened at the times specified. The log-rank test is used to test for 
# differences in survival (or another event) times/probabilities calculated
# using the Kaplan- Meier method. Data can be left, right, or interval censored,
# although this Rsnippet is for use with right censored data. The null
# hypothesis is that the two Kaplan-Meier curves are the same while the
# alternative hypothesis is that the two Kaplan-Meier curves are not the same.
#
# Data format: The meta data should be encoded as a string. The time to the
# event should be numeric with a letter appended on the end to indicate
# whether an event or censoring occured. Use a to indicate censoring and b
# to indicate the event occured. For example, the meta data should read 
# "208a" or "107b"
#
# Author: Kaitlin Cornwell
# 
# Date: June 8, 2016
#
# Notes: This Rsnippet requieres the package "survival". Although data can 
# be left censored, right censored, interval censored, or counted, this code
# is designed for right censored data. To change this, see documentation for
# "Surv" and "survdiff".

Snippet <- setRefClass("Snippet", contains = "Data", fields = c("time", "event"),
                       methods = list(
                         cleaning = function(null_string) {
                           tryCatch({
                            ## initial read in
                            read_check(meta)
                            meta <<- as.character(meta)
                           
                            ## remove missing vlaues
                            index = !(meta %in% null_string)
                            missing_check(index)
                            meta <<- meta[index]
                            group <<- group[index]
                           
                            ## separate time from coded event
                            time <<- substring(meta, first = 1, last = nchar(meta) - 1)
                            time <<- as.numeric(time)
                            event <<- substring(meta, first = nchar(meta))
                           
                            ## remove NAs
                            index = (!is.na(time) & ((event %in% "a") | (event %in% "b")))
                            event <<- event[index]
                            time <<- time[index]
                            group <<- group[index]
                            group_check(time, group)
                          },
                          
                          error = function(e) {
                            e$message = gsub("\n", " ", e$message)
                            errors <<- list(e$message, 2)
                          },
                          
                          finally = {
                            return(result(error = errors))
                          })
                         },
                         
                         assumptions = function() {
                           tryCatch({
                            value_check(meta)
                           
                            ## remove negative time values
                            index = which(time >= 0)
                            time <<- time[index]
                            event <<- event[index]
                            group <<- group[index]
                            group_check(time, group)
                            value_check(time)
                           
                            ## change coding from "a" and "b" to 0 = censor and 1 = time
                            for (i in 1:length(event)) {
                              if (event[i] == "a")
                                event[i] <<- 0
                              else
                                event[i] <<- 1
                            }
                            event <<- as.numeric(event)
                          },
                          
                          error = function(e) {
                            e$message = gsub("\n", " ", e$message)
                            errors <<- list(e$message, 2)
                          },
                          
                          finally = {
                            return(result(error = errors))
                          })
                         },
                         
                         test = function() {
                           tryCatch({
                            km_test = survdiff(Surv(time = time, event = event, type = "right")
                                                ~ group, rho = 0)
                            test = list(method = "Log-rank test for Survival Data",
                                        p.value = (1 - pchisq(km_test$chisq, length(km_test$n) - 1)))
                           
                            ## get index wehre group switches from "in" to "out"
                            fit = survfit(Surv(time = time, event = event, type = "right")
                                          ~ group)
                            times = summary(fit)$time
                            prob = summary(fit)$surv
                            index = 0
                            for (i in 1:(length(times) - 1)) {
                              if (times[i] > times[i + 1])
                                index = i
                            }
                           
                            return(result(test, c("kaplan"), "",
                                          list(time = times[1:index], 
                                                prob = prob[1:index]),
                                          list(time = times[(index + 1):length(times)],
                                                prob = prob[(index + 1):length(times)]),
                                          errors))
                          },
                          
                          error = function(e) {
                            e$message = gsub("\n", " ", e$message)
                            return(result(error = list(e$message, 2)))
                          })
                         }
                       ))

## Check if data was read in correctly
read_check <- function(meta) {
  if(is.null(meta)) {
    stop("No meta data")
  }
  return(NULL)
}

## Check if data still availabe after removal of missing values
missing_check <- function(index) {
  if (length(which(index)) == 0) {
    stop("No meta data")
  }
  return(NULL)
}

## Check if there are observations in each group
group_check <- function(meta, group) {
  if (length(meta) == 0) {
    stop("Incorrect coding")
  }
  if (length(which(group %in% "IN")) == 0 || 
      length(which(group %in% "OUT")) == 0) {
    stop("No data in one group")
  }
  return("NULL")
}

## Check data is not constant
value_check <- function(meta) {
  datatable = table(meta)
  if (dim(datatable) == 1)
    stop("Data is constant")
  return(NULL)
}