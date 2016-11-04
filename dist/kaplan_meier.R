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
                            coding_check(index)
                            event <<- event[index]
                            time <<- time[index]
                            group <<- group[index]
                            meta <<- meta[index]
                            group_check(group)
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
                            value_check(meta, group)
                           
                            ## remove negative time values
                            index = which(time >= 0)
                            meta <<- meta[index]
                            time <<- time[index]
                            event <<- event[index]
                            group <<- group[index]
                            group_check(group)
                            value_check(meta, group)
                            
                            ## check number of events per group
                            events_check(event, group)
                            
                            ## change coding from "a" and "b" to 0 = censor and 1 = event
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
                            
                            event_in = event[group %in% "IN"]
                            index = length(which(event_in %in% 1))
                           
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

coding_check = function(index) {
  if (length(which(index)) == 0) {
    stop("Incorrect coding")
  }
  return(NULL)
}

events_check = function(event, group) {
  event_in = event[group %in% "IN"]
  event_out = event[group %in% "OUT"]
  
  if (length(which(event_in == "b")) == 0 ||
      length(which(event_out == "b")) == 0) {
    stop("No events for one group")
  }
  return(NULL)
}
