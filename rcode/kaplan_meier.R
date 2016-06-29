# Title: Kaplan-Meier/Log-Rank
#
# Uses: The Kaplan-Meier test is used with time-to-event (survival) data.
# This test is used to compare event times between multiple groups. It assumes
# that censoring is unrelated to prognosis, that survival probabilities are 
# the same (regardless of early or late recruitment into the study), and that
# events happened at the times specified. The log-rank test is used to test for 
# differences in survival (or another event) times/probabilities calcualted
# using the Kaplan- Meier method. Data can be left, right, or interval censored
# censored to with this method, although this Rsnippet is for use with right
# censored data. The null hypothesis is that the two Kaplan-Meier
# curves are the same while the alternative hypothesis is that the two Kaplan-
# Meier curves are not the same. 
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

error <- function(meta, group, null_string) {
  ret = tryCatch({
    
    if (is.null(meta)) {
      stop("Custom: null")
    }
    
    if (!is.character(meta)) {
      meta = as.character(meta)
    }
    
    ## remove missing values
    mvidx = !(meta %in% null_string)
    if (length(which(mvidx)) == 0) {
      stop("Custom: null")
    }
    group = group[mvidx]
    meta = meta[mvidx]
    
    
    ## separate the time from the coded event
    meta_time = substring(meta, first = 1, last = nchar(meta) - 1)
    meta_time = as.numeric(meta_time)
    meta_event = substring(meta, first = nchar(meta))
    
    ## Remove NAs
    mvidx = (!is.na(meta_time)) & ((meta_event %in% "a") | (meta_event %in% "b"))
    if (length(which(mvidx)) == 0) {
      stop("Custom: coding")
    }
    meta_time = meta_time[mvidx]
    meta_event = meta_event[mvidx]
    rmgroup = group[mvidx]
    
    ## Check data
    table = table(meta_time)
    if (length(meta_time) == 0) {
      stop("Custom: type")
    }
    
    if (dim(table) == 1) {
      stop("Custom: oneval")
    }
    if (length(which(rmgroup %in% "IN")) == 0 ||
        length(which(rmgroup %in% "OUT")) == 0) {
      stop("Custom: nullgroup")
    }
    
    ## change event coding from "a" and "b" to 0 = censor and 1 = event
    for (i in 1:length(meta_event)) {
      if (meta_event[i] == "a") {
        meta_event[i] = 0
      }
      else {
        meta_event[i] = 1
      }
    }
    meta_event = as.numeric(meta_event)
    
    ## Kaplan-Meier/log-rank test
    survdiff(Surv(time = meta_time, event = meta_event, type = "right")
                    ~ rmgroup, rho = 0)
  },
  ## error handler function
  error = function (e) {
    if (grepl("Custom:", e)) {
      if (grepl("nullgroup", e)) {
        return(c("No data in a group", 2))
      }
      if (grepl("null", e)) {
        return(c("No meta data", 2))
      }
      if (grepl("oneval", e)) {
        return(c("Same value for each observation", 3))
      }
      if (grepl("type", e)) {
        return(c("Incorrect data type: received character instead of numeric for time", 3))
      }
      if (grepl("coding", e)) {
        return(c("Incorrect coding: Time should be numeric with 'a' or 'b' appended", 3))
      }
    }
    return(c(e, 1))
  })
  
  ## if length of return statement is 2 then an error occurred
  ## return the error message and code
  if (length(ret) == 2) {
    return(list(msg = ret[[1]], status = ret[[2]]))
  } else {
    return(list(msg = '', status = 0))
  }
}
 
test = function(meta, group, null_string) { 
  if (!is.character(meta)) {
    meta = as.character(meta)
  }
  
  ## remove missing values
  mvidx = !(meta %in% null_string)
  group = group[mvidx]
  meta = meta[mvidx]
  
  ## separate the time from the coded event
  meta_time = substring(meta, first = 1, last = nchar(meta) - 1)
  meta_time = as.numeric(meta_time)
  meta_event = substring(meta, first = nchar(meta))
  
  ## Remove NAs
  mvidx = (!is.na(meta_time)) & ((meta_event %in% "a") | (meta_event %in% "b"))
  meta_time = meta_time[mvidx]
  meta_event = meta_event[mvidx]
  rmgroup = group[mvidx]
  
  ## Change change event coding from "a" and "b" to 0 = censor and 1 = event
  for (i in 1:length(meta_event)) {
    if (meta_event[i] == "a") {
      meta_event[i] = 0
    }
    else {
      meta_event[i] = 1
    }
  }
  meta_event = as.numeric(meta_event)
  
  ## Kaplan-Meier/log-rank test
  test = survdiff(Surv(time = meta_time, event = meta_event, type = "right")
           ~ rmgroup, rho = 0)
  
  ## get index where group switches from "in" to "out"
  fit = survfit(Surv(time = meta_time, event = meta_event, type = "right") ~ rmgroup)
  time = summary(fit)$time
  prob = summary(fit)$surv
  for (i in 1:(length(time) - 1)) {
    if (time[i] > time[i + 1]) {
      index = i
    }
  }
  
  return(list(method = "Log-Rank Test for Survival Data",
              pvalue = (1 - pchisq(test$chisq, length(test$n) - 1)),
              charts = "kaplan",
              labels = '',
              group_in = c(time[1:index], prob[1:index]),
              group_out = c(time[(index + 1):length(time)], prob[(index + 1):length(prob)])))
}