<!--adbio-version-->
[![Visit at https://adbio.pnnl.gov](https://adbio.pnnl.gov/bioviz/services/svg/version?ver=0.02)](https://adbio.pnnl.gov/bioviz/releasenotes.html#0.02)
<!--rsnippet-title-->
# Rsnippet Guidelines
<!--rsnippet-description-->
The Rsnippet Guidelines outlines a set of rules and suggestions for formatting rsnippets to be used with the Active Data Biology (ADBio) program. Rsnippets contain and define classes and functions which reads in a series of inputs, runs a statistical test, and returns the outcome of the test for use by the ADBio program and interactive interface. The basic ADBio program includes a variety of default statistical tests implemented for the user. If the user would like to create test snippets themselves, this file should serve as a reference.

<!--rnsippet-file header-->
## Rsnippet File Header
A commented header should be included at the beginning of every Rsnippet. This header will contain:

1. Title
2. Uses
3. Data format
4. Author
5. Date
6. Notes
  
The header should follow the format of the example below:

*Title: Two-sample t-test*

*Uses: The two-sample t-test is used when one variable is continuous and one variable is categorical with two groups. This test assumes that samples have been drawn from normally distributed populations and that the populations have equal variances. The two-sample t-test is used to test for differences in mean between the groups defined by the categorical variable. The null hypothesis is that the means are equal, while the alternative hypothesis is that the means are not equal. Since this test uses the mean, the two-sample t-test should not be chosen when the data has a large range or is significantly skewed.*

*Data Format: Values except for null/missing characters are numeric. (Other examples include: the data is binary, values are encoded as strings)*

*Author: Kaitlin Cornwell*

*Date: June 1, 2016*

*Notes: Follow this example to create Rsnippet headers.*


<!--rsnippet-basic info-->
## Code Format
Rsnippets are required to be written in R. Using reference classes, they define a class they takes in data and performs a statistical test. The writer of the test defines the coding used for the data, but all outputs must follow the same format (as defined below in _The User Defined Class: Snippet -> Return Values_). If the writer intends on using their Rsnippet with the ADBio program server, as opposed solely using their local machine, they are restricted to the Rpackages already used by the server.

##### Accepted R Packages
* base
* methods
* datasets
* utils
* grDevices
* graphics
* stats
* survival
* bioconductor

##### Reference Classes
As noted above, the classes utilized within the Rsnippets are reference classes. In R, there are 3 main types of object oriented programming - S3, S4, and RC (reference classes). RC style programming was chosen because of its similarity to other object oriented programming languages and because it utilizes message passing, which mimics pass by reference. For more information on object oriented programming and the RC type in R visit:
* [Object Oriented (OO) field guide] (http://adv-r.had.co.nz/OO-essentials.html "OO field guide")
* [R documentation on reference classes] (http://search.r-project.org/library/methods/html/refClass.html "R documentation")
* [Reference Class Basics] (http://www.programiz.com/r-programming/reference-class "Basics")
* [Reference Classes] (http://adv-r.had.co.nz/R5.html "Reference Classes")


<!--rsnippet-base class-->
## The Base Class: "Data"
Within the code used to run the Rsnippets, a base class named Data has been defined. The Data class has three fields: meta, group, and errors. Additionally nine methods belong to Data: initialize, cleaning, assumptions, test, result, read_check, missing_check, group_check, and value_check. Within initialize, the fields are initialized as stated in the table _Fields in Data_. The methods cleaning, assumptions, and test are implemented in a way such that no data processing is performed. Thus, the user must implement them. If they are not, then the snippet cannot be used with the ADBio program. See the table within the section _The User Defined Class: Snippet_ for more information regarding the implementation of methods. The result method is written to properly format the returns from the methods within Snippet for use with the program. Do not overwrite the results method. See _The User Defined Class: Snippet -> Return Values_ for more information. Lastly, the four check functions mentioned above are implemented. Each provides a way to check the data at certain steps of the cleaning process. If an assumption of the check is violated, then an error is thrown. See the table below for a description of the checks and their errors.

### Fields in Data

|Field| Description|
|:-------:|:-------:|
|meta|An array of the data that is to be analyzed (the column of data for which the test is to be performed).|
|group|An array of the strings "IN" and "OUT". "IN" signifies that the corresponding index in meta is a part of the cluster that is being analyzed. "OUT" signifies that the corresponding index in meta belongs to a different cluster.|
|errors|A list of the warnings or errors that occurred while cleaning and running the test. Each error should be composed of an error message and a status code. The codes should be 0 for no errors or warnings, 1 for warnings, and 2 for fatal errors. Errors is initialized to `list('', 0)`.|

### Check Methods in Data

|Method|Description|Error Message Returned|
|:--------:|:--------:|:-----------:|
|read_check|Checks to ensure the data were read in correctly. Specifically tests that meta is not `NULL`.|No meta data|
|missing_check|Checks to ensure there are data available after removal of missing values. Specifically tests that the number of values in meta is not 0.|No meta data|
|group_check|Checks to ensure there are data available in each group. Specifically tests that the number of values in each group is not 0.|No data in one group|
|value_check|Checks to ensure the data are not constant. Specifically tests that the number of unique values is not 1.|Same value for each observation|

Note: Each error thrown by the checks should correspond to a status code of 2.

<!--rsnippet-input-->
## Input
Below is a list of the three pieces of information that will be available for use during cleaning and analysis.

|Variable     |Description|
|:-------------:|:---------:|
| meta | An array of the data that is to be analyzed (the column of data for which the test is to be performed). This is included as a field within the Data class.|
| group | An array of the strings "IN" and "OUT". "IN" signifies that the corresponding index in meta is a part of the cluster that is being analyzed. "OUT" signifies that the corresponding index in meta belongs to a different cluster. This is included as a field within the Data class.|
| null_string | An array of the strings that have been used to encode missing/null data. This is included as an input to the cleaning method.|

<!--rsnippet-user class-->
## The User Defined Class: Snippet
The Snippet class should be set to contain the class Data, thus it inherits the fields and methods of Data (note: as mentioned above, the methods within Data are not implemented in a way that supports data cleaning and analysis. Thus, although they are inherited, they must be overwritten). In addition to the inherited objects, the user can add any additional fields or methods within the class or functions outside of the class. The following section will explain each inherited method and its intended use. 

|Method|Description|
|:------------:|:----------:|
|cleaning|The cleaning method handles the data by cleaning it and throwing errors. Some checks that can be carried out include checking that the data was read in correctly and that the data has been coded correctly. Additionally, the cleaning method should handle missing data accordingly (the default is for the missing values to be taken out).|
|assumptions|The assumptions method aims to complete any data cleaning that is test specific. Furthermore, the method should check the assumptions of the test and return a warning or error if the assumptions were not met.|
|test|The test method performs the statistical test and does any preprocessing of the data output before it is returned.|

<!--rsnippet-return values-->
##Return Values
Each method should return the value received from the result function within the Data class. The result method can take inputs of test, chart, labels, group_in, group_out, and error, although only the error input is required.

|Value|Description|
|:--------:|:---------:|
|test|A list consisting of the name of the test that was ran, encoded as a string, and the p-value obtained from the test, encoded as a double. The name of the test should be named "method" while the p-value should be named "p.value".|
|chart|An array of the chart types, encoded as strings, which will be used to output the data. A list of accepted types is available below.|
|labels|The labels that are used for the different groups tested, encoded as an array of strings (only needed for categorical tests).|
|group_in|The data included within the "in" group, encoded as an array. This is used to gather counts for the displayed chart.|
|group_out| The data included within the "out" group, encoded as an array. This is used to gather counts for the displayed chart.|
|error|A list consisting of the error that occurred, a list of warnings, or information that no error occurred. Each value of the list should be a list consisting of the error message, encoded as a string, and a corresponding status code, encoded as an integer. A list of the codes can be found below. If a fatal error occurred this parameter should consist of a list with only the message and status code. If warnings occurred, this parameter should consist of a list of every warning and its status code. The default is a blank string and status code 0 indicating no error or warning occurred.|

##### Important Note
If a fatal error occurred during data processing, the errors field should be returned to the result method within Data.

##### How to Format Output for Kaplan-Meier Charts
To draw a Kaplan-Meier chart, both the probabilities produced by the Kaplan-Meier analysis and the times at which an event occurred must be returned. For each group, group_in and group_out, return a list. The first element of the list should be an array the times at which the events occurred, named times, and the second element should be an array of the probabilities that should be graphed at each time point, named prob.

##### List of Chart Options
Below is a list of the options available for the charts. The first part listed corresponds to the name of the chart in Highcharts (a preview can be seen at http://www.highcharts.com/demo/) while the second part is the string used to notify the program which charts can be graphed. 
* box plot : "box"
* basic column : "column"
* stacked column : "stacked-column"
* stacked percentage column : "percent-column"
* scatter plot : "scatter"
* basic line (used only for Kaplan-Meier graphs) : "kaplan" 

##### List of Status Codes
* 2 : a fatal error occurred and the test cannot be run.
* 1 : an error occurred but the test can still be run (a warning).
* 0 : no error or warnings occurred.

<!--rsnippet-testing-->
## Testing
User written Rsnippets can be tested using the unit tests provided. Using the tests in the automated format in which they are provided provided will only ensure that the tests return the correct output format. To test that the snippet returned the correct results, the tests provided can serve as a template for the kinds of data that should be run, but users must manually ensure that the results are valid.

Unit tests have been split into four categories matching the data types ADBio expects to receive. The files that can be used are:
* unittest_categorical.R
* unittest_nominal.R
* unittest_continuous.R
* unittest_time2event.R
