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
# censored data. Meier method. The null hypothesis is that the two Kaplan-Meier
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

test <- function(meta, group, null_string) {
  meta = as.character(meta)
  
  ## separate the time from the coded event
  meta_time = substring(meta, first = 1, last = nchar(meta) - 1)
  meta_time = as.numeric(meta_time)
  meta_event = substring(meta, first = nchar(meta))
  
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
  test = survdiff(Surv(time = meta_time, event = meta_event, type = "right")
                  ~ group, rho = 0)
  
  return(c(testMethods = "Log-Rank Test for Survival Data",
           pvalues = (1 - pchisq(test$chisq, length(test$n) - 1)),
           charts = "line",
           labels = '',
           gin = paste(meta_time[group %in% "IN"], collapse = ','),
           gout = paste(meta_time[group %in% "OUT"], collapse = ',')))
}
