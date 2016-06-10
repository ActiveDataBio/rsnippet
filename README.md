<!--adbio-version-->
[![Visit at https://adbio.pnnl.gov](https://adbio.pnnl.gov/bioviz/services/svg/version?ver=0.02)](https://adbio.pnnl.gov/bioviz/releasenotes.html#0.02)
<!--rsnippet-title-->
#Rsnippet Guidelines
<!--rsnippet-description-->
The Rsnippet Guidelines outlines a set of rules and suggestions for formatting rsnippets to be used with the ADBio program. Rsnippets include a function which takes in a series of inputs, runs a statistical test, and returns the outcome of the test for use by the ADBio program and interactive interface. The basic ADBio program includes a variety of statistical tests implemented for the user. If the user would like to create their own tests, this file should serve as a reference.

<!--rsnippet-data-->
##Code Format
Rsnippets are required to be written in R. They define a function named test which takes in three arrays, performs a statistical test, and then returns an array of items for use by the ADBio program. If the writer plans on using their Rsnippet with the ADBio program server, as opposed solely using their local machine, they are restricted to the Rpackages already used by the server. The format of data input is defined by the writer of the test, but all outputs must follow the same format.
##### Accepted R Packages
* base
* methods
* datasets
* utils
* grDevices
* graphics
* stats
* survival

<!--rnsippet-file header-->
##Rsnippet File Header
A header should be included at the beginning of every Rsnippet. This header will include:

1. Title
2. Uses
3. Data format
4. Author
5. Date
6. Notes
  
The header should follow the format of the example below:

*Title: Two-sample t-test*

*Uses: The two-sample t-test is used when one varaible is continuous and one variable is categorical with two groups. This test assumes that samples have been drawn from normally distributed populations and that the populations have equal variances. The two-sample t-test is used to test for differences in mean between the groups defined by the categorical variable. The null hypothesis is that the means are equal, while the alternative hypothesis is that the means are not equal. Since this test uses the mean, the two-sample t-test should be chosen when the data does not have a large range or is not significantly skewed.*

*Data Format: Values except for null/missing characters are numeric. (Other examples include: the data is binary, values are encoded as strings)*

*Author: Kaitlin Cornwell*

*Date: June 1, 2016*

*Notes: Follow this example to create Rsnippet headers.*

<!--rsnippet-input-->
##Input
The input should include three separate arrays - meta, group, and null_string.

|Variable     |Description|
|:-------------:|:---------:|
| meta | An array of the data that is to be analyzed (the column of data for which the test is to be performed). |
| group | An array of the strings "IN" and "OUT". "IN" signifies that the corresponding index in meta is a part of the cluster that is being analyzed. "OUT" signifies that the corresponding index in meta belongs to a different cluster. |
| null_string | An array of the strings that have been used to encode missing/null data. |

<!--rsnippet-body-->
##Body and Testing
To begin, missing data should be handled accordingly. Additionally, if there are overt assumptions regarding the test, they should be checked. For example, if a test on a categorical variable requires that counts within a group are greater than a certain number, that assumption should be tested. If the assumption is not met, then an error code and message can be returned. Once all necessary assumptions have been checked, the test should be performed.

<!--rsnippet-return values-->
##Return Values
The Rnsippet test function returns an array of values - testMethods, pvalues, charts, labels, gin, gout, msg, and status.

|Value     |Description|
|:--------:|:-------:
|testMethods|The name of the test used encoded as a string.|
|pvalues|The p-value obtained with the statistical test, encoded as a double.|
|charts|An array of the chart types, encoded as strings, that will be used to output the data. Chart type options can be found at http://www.highcharts.com/demo.|
|labels|The labels that are to be used for the different groups tested, encoded as an array of strings.|
|gin|The data included within the "in" group, encoded as an array. This is used to gather counts for the displayed chart.|
|gout|The data included within the "out" group, encoded as an array. This is used to gather counts for the displayed chart.|
|msg| The error message recieved during data processing, encoded as a string. If no error was encountered, return an empty string (i.e: "").|
|status|The value returned after the data was processed, encoded as a numeric. If no error occurred the value 0 is returned. Otherwise a value corresponding to the error that occurred is returned. See the list below for a list of codes.|
##### Important Note
If a fatal error occurred during data processing, return only an array containing the msg and status. If the statistical test was completed, return all values found in the table above.

##### List of Status Codes
* 4 is returned if there was an error within the "in" and "out" groups (e.g: after cleaning, the "in" group did not have any observations)
* 3 is returned if the data received is the incorrect type (e.g: received categorical instead of continuous)
* 2 is returned if meta is empty or NULL.
* 1 is returned for any other type of error.
* 0 is returned if no error occurred.
