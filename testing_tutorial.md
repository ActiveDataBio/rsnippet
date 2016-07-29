<!--rsnippet-testing-title-->
# Active Data Biology: Testing R Snippets
<!--rsnippet-testing-description-->
This document will walk users through how to test their customized Rsnippets. Although the code has been written to run in conjunction with the ADBio program, it can be run on its own for testing purposes. Rsnippets can be tested using the sample dataset, metadata.tsv, or with one of the provided unit tests that corresponds with the Rsnippet's expected data type.

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
  *	Each accepted package, except for survival and Bioconductor, are default packages and thus should already be installed on R. Additionally, the packages survival or Bioconductor only need to be downloaded or loaded if the Rsnippet requires them.
4. Set the working directory to the location in which the Rsnippet and other required files were saved.
5. Read in the data set
  * Note: this step only needs to be done once
  * If the file baseClass.R is located elsewhere than your current working directory, change the file path within the call to <code>source</code> to match where the file is located.
  * (If using class_test.R for testing) If the metadata file is not located in your current working directory, change the file path within the call to <code>read.delim</code> to match where the file is located.
  * (If using class_test.R for testing) If you are using your own dataset, change <code>null_string</code> to match the coding of null values within your data set (line 25).
  * Run lines 3 through 13 of class_test.R or lines 18 through 72 of a unit test.

<!--rnsippet-testing-Running using class_test.R-->
## Testing the Rsnippet using class_test.R
6. Indicate the variable that will be tested (line 15).
  * Variable descriptions for the sample metadata set can be found in Table 1 at the end of this document.
  * To change variables, replace the value after <code>metadata$</code> with the new variable name (e.g. <code>metadata$vital_status</code>, <code>metadata$K.M.Column</code>).
7. Create a vector, named <code>group</code>, that assigns each observation to the “in” group or the “out” group. 
  * Two group assignment options are provided:
    * Randomly assign each observation to one of the two groups we are testing between, “IN” and “OUT” (line 18).
    * If you are using the example metadata, you can also choose one group to be “IN” and test against the remainder of the data, the “OUT” group (line 20-21).
      * Change the chosen index of group from <code>which(metadata$group == “E”)</code> to the group of your choice.
      * Group choices are : A, B, C, D, E
8. Choose a statistical test to run (line 22 - 23)
  * To change the test, assign the variable <code>snippet</code> to the test’s file name in quotations (e.g. <code>snippet <- “t_test.R”</code> or <code>snippet <- “wilcoxon.R”</code>).
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
    * labels: the labels that are used for the different groups tested, encoded as an array of strings (only used for categorical tests)
    * group_in: the data included in the “in” group, encoded as an array
      * If using the chart “column”, “stacked-column”, or “percent-column” this should be an array of the counts within each group of the categorical variable
    * group_out: the data included in the “out” group, encoded as an array
      * If using the chart “column”, “stacked-column”, or “percent-column” this should be an array of the counts within each group of the categorical variable
    * msg: a list of the error or warning messages created during the test 
      * If no errors occurred this will be a blank string
    * status: a code corresponding to whether the test was a success or not, encoded as the integer 0 – no warnings or errors, 1 – warnings occurred, or 2 – a fatal error occurred
    * If an error occurred during the test then every field should return a blank string except for error and msg
      *This can be done by returning only the list <code>errors</code> to the method <code>result</code>
10. The previous steps can be repeated as desired
  * To repeat the same test, rerun lines 32 - 34.
  * If a change is made within the snippet file, the <code>source()</code> call must be reran (line 29).

<!--rsnippet-testing-unit test-->
## Running the Program using a Unit Test
Important Note: The unit test only ensures that the return values were formatted correctly. A passed unit test does not ensure that the Rsnippet is working properly. The output should be checked manually for correctness.

1. Choose a statistical test to run (lines 73 - 74)
  * To change the test, assign the variable snippet to the test’s file name in quotations (e.g. <code>snippet <- “t_test.R”</code> or <code>snippet <- “wilcoxon.R”</code>).
    * If the Rsnippet is not included in the working directory, change the path within the assignment of <code>snippet</code> to where the file is located.
2. Get results (lines 76 - 158)
  * If an unhandled error occurred during the test, then an error message will be displayed.
  * If the results of the test were not formatted correctly then an error messge will be displayed.
  * If the test did not return a fatal error when it should have (e.g. all the data was missing) then an error message will be displayed.
  * If the test passed (i.e. the format of the result received from the test was correct) a message will display saying that the test was formatted correctly.
3. The previous steps can be repeated as desired.
  * To repeat the same tests, rerun lines 76 - 158
  * Each test can also be run individually instead of all at once.
  * If a change is made within the snippet file, the <code>source</code> call must be reran (line 73).
