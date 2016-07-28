<!--rsnippet-testing-title-->
# Active Data Biology: Testing R Snippets
<!--rsnippet-testing-description-->
This document will walk users through how to test their customized Rsnippets. Although the code has been written to run in conjunction with the ADBio program, it can be run on its own for testing purposes. Rsnippets can be tested using the sample dataset, metadata.tsv, or with the corresponding provided unit test.

<!--rsnippet-testing-setup-->
## Set-up
1. If it is not already done, download [R](https://cran.cnr.berkeley.edu/) and (optionally) [RStudio](https://www.rstudio.com/products/rstudio/download/) onto your computer.
2. Download the necessary files from the [Active Data Biology repository](https://github.com/ActiveDataBio/ADB-User-Study) on GitHub.
  * The files needed to run the test are
    * baseClass.R
    * class_test.R
    * metadata.tsv (or your own data set)
    * (optional) one of the unit test files
  * All R files can be found within the folder “rcode” and the sample dataset can be found on the initial page of the repository.
3. Download and load any necessary R packages
  * The accepted R packages are
    * base
    * Bioconductor
    * datasets
    * graphics
    * grDevices
    * methods
    * stats
    * survival
    * utils
  *	Each accepted package except for survival and Bioconductor are default packages, thus they should already be installed on R. Additionally, unless your test requires the packages survival or Bioconductor, they do not need to be downloaded or loaded.
4. Set the working directory to the location in which the Rsnippet and other required fields are saved.
5. Read in the data set
  * Note: this step only needs to be done once
  * If the file baseClass.R is located elsewhere than your current working directory, change the file path within the call to source to match where the file is located.
  * (If using class_test.R for testing) If the metadata file is not located in your current working directory, or you are using your own dataset, change the file path within the call to read.delim to match where the file is located.
  * (If using class_test.R for testing) If you are using your own dataset, change <code>null_string</code> to match the coding of null values within your data set.
  * Run lines 3 through 13 of class_test.R or lines 18 through 72 of a unit test.

<!--rnsippet-testing-Running using class_test.R-->
## Testing the Rsnippet using class_test.R
6. Indicate the variable that will be tested (line 15).
  * Variable descriptions for the sample metadata set can be found in Table 1 at the end of this document.
  * To change variables, replace the value after <code>metadata$</code> with the new variable name (e.g. <code>metadata$vital_status</code>, <code>metadata$K.M.Column</code>).
7. Create a vector, group, that assigns each observation to the “in” group or the “out” group. 
  * Two group options are provided:
    * Randomly assign each observation to one of the two groups we are testing between, “IN” and “OUT” (line 18).
    * If you are using the example metadata, you can also choose one group to be “IN” and test against the remainder of the data, the “OUT” group (line 20-21).
      * Change the chosen index of group from <code>which(metadata$group == “E”)</code> to the group of your choice.
      * Group choices are : A, B, C, D, E
8. Choose a statistical test to run (line 22 - 23)
  * To change the test, assign the variable snippet to the test’s file name in quotations (e.g. <code>snippet <- “t_test.R”</code> or <code>snippet <- “wilcoxon.R”</code>).
    * If the Rsnippet is not included in the working directory, change the path within the assignment of snippet to where the file is located.
9. Get results (line 32 - 34)
  * Every result should be list containing the following:
    * method: the name of the test that was run
    * pvalue: the p-value returned from the statistical test
    * chart: an array of the chart types, encoded as strings
      * Chart options:
        * box plot: "box"
        * basic column: "column"
        * stacked column: "stacked-column"
        * stacked percentage column: "percent-column"
        * scatter plot: "scatter"
        * basic line (used only for Kaplan-Meier graphs): "kaplan"
    * labels: the labels that are used for the different groups tested, encoded as an array of strings (only used for categorical tests).
