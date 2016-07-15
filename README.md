<!--adbio-version-->
[![Visit at https://adbio.pnnl.gov](https://adbio.pnnl.gov/bioviz/services/svg/version?ver=0.02)](https://adbio.pnnl.gov/bioviz/releasenotes.html#0.02)
<!--rsnippet-title-->
# Rsnippet Guidelines
<!--rsnippet-description-->
The Rsnippet Guidelines outlines a set of rules and suggestions for formatting rsnippets to be used with the Active Data Biology (ADBio) program. Rsnippets contain and define classes and functions which reads in a series of inputs, runs a statistical test, and returns the outcome of the test for use by the ADBio program and interactive interface. The basic ADBio program includes a variety of default statistical tests implemented for the user. If the user would like to create their own tests, this file should serve as a reference.

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

*Uses: The two-sample t-test is used when one varaible is continuous and one variable is categorical with two groups. This test assumes that samples have been drawn from normally distributed populations and that the populations have equal variances. The two-sample t-test is used to test for differences in mean between the groups defined by the categorical variable. The null hypothesis is that the means are equal, while the alternative hypothesis is that the means are not equal. Since this test uses the mean, the two-sample t-test should not be chosen when the data has a large range or is signifcanly skewed.*

*Data Format: Values except for null/missing characters are numeric. (Other examples include: the data is binary, values are encoded as strings)*

*Author: Kaitlin Cornwell*

*Date: June 1, 2016*

*Notes: Follow this example to create Rsnippet headers.*


<!--rsnippet-basic info-->
## Code Format
Rsnippets are required to be written in R. Using reference classes, they define a class which takes in data and performs a statistical test. The coding used for the data is defined by the writer of the test, but all outputs must follow the same format (as defined below in The User Defined Class: Snippet -> Return Values). If the writer plans on using their Rsnippet with the ADBio program server, as opposed solely using their local machine, they are restricted to the Rpackages already used by the server.

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
As noted above, the classes utilized within the Rsnippets are reference classes. In R, there are 3 main types of object oriented programming - S3, S4, and RC (reference classes). RC style programming was chosen because of its similarity other object oriented programming languages and because it is the only structure that mimics pass by reference. For more information on object oriented programming and the RC type in R visit:
* [Object Oriented (OO) field guide] (http://adv-r.had.co.nz/OO-essentials.html "OO field guide")
* [R documentation on reference classes] (http://search.r-project.org/library/methods/html/refClass.html "R documentation")
* [Reference Class Basics] (http://www.programiz.com/r-programming/reference-class "Basics")
* [Reference Classes] (http://adv-r.had.co.nz/R5.html "Reference Classes")


<!--rsnippet-base class-->
## The Base Class: "Data"
Within the code used to run the Rsnippets, a super class Data has been defined. The data class has three fields: meta, group, and errors. Additionally four methods belong to Data: cleaning, assumptions, test, and result. The fields are initialized as stated in the following table. Within Data, the methods cleaning, assumptions, and test are implemented in a way such that no data processing is perfromed. Thus, they must be implemented by the user. If they are not, then the snippet cannot be used with the ADBio program. See the table within the section The User Defined Class: Snippet for more information regarding the implementation of methods. The result method is written to properly format the returns from the methods within Snippet for use with the program. Do not overwrite the results method. See The User Defined Class: Snippet -> Return Values for more information.

### Fields in Data

|Field| Description|
|:-------:|:-------:|
|meta|An array of the data that is to be analyzed (the column of data for which the test is to be performed).|
|group|An array of the strings "IN" and "OUT". "IN" signifies that the corresponding index in meta is a part of the cluster that is being analyzed. "OUT" signifies that the corresponding index in meta belongs to a different cluster.|
|errors|A list of the warnings or errors that occurred while cleaning and running the test. Each error should be composed of an error message and a status code. The codes should be 0 for no errors or warnings, 1 for warnings, and 2 for fatal errors. Errors is initialized to list('', 0).|

<!--rsnippet-input-->
## Input
Below is a list of the three pieces of information that will be available for use during cleaning and analysis.

|Variable     |Description|
|:-------------:|:---------:|
| meta | An array of the data that is to be analyzed (the column of data for which the test is to be performed). This is include as a field within the Data class.|
| group | An array of the strings "IN" and "OUT". "IN" signifies that the corresponding index in meta is a part of the cluster that is being analyzed. "OUT" signifies that the corresponding index in meta belongs to a different cluster. This is included as a field to the Data class.|
| null_string | An array of the strings that have been used to encode missing/null data. This is included as an input to the cleaning method.|

<!--rsnippet-user class-->
## The User Defined Class: Snippet
The snippet class should be set to contain the class "Data", thus it inherits the fields and methods of Data (note: as mentioned above, the methods within Data are not implemetned in a way that supports data cleaning and analysis, thus, although they are inherited, they must be overwritten). In addition to the inherited objects, the user can add any additional fields or methods within the class or functions outside of the class. The following section will explain each inherited method and its intended use. 

|Method|Description|
|:------------:|:----------:|
|cleaning|Handles the data by cleaning it and throwing errors. Some checks that can be included are that the data was read in correctly, the data is of the proper type or is coded correctly, etc. Additionally, the cleaning method should handle missing data accoridingly (the default is for the missing values to be taken out).|
|assumptions|this method aims to complete any data cleaning that is test specific. Furthermore, the method should check the assumptions of the test and return a warning or error if the assumptions were not met.|
|test|this method performs the statistical test and does any preprocessing of the data output before it is returned.|

<!--rsnippet-return values-->
##Return Values
Each method should return the value received from the result function within the Data class. The result method can take inputs of test, chart, labels, group_in, group_out, and error, although only the error input is required.

|Value|Description|
|:--------:|:---------:|
|test|A list consisting of the name of the test that was ran, encoded as a string, and the p-value obtained from the test, encoded as a double. The name of the test should be labeled as "method" while the p-value should be labeled as "p.value".|
|chart|An array of the chart types, encoded as strings, which will be used to output the data. A list of types is available below.|
|labels|The labels that are used for the differnet groups tested, encoded as an array of strings.|
|gin|The data included within the "in" group, encoded as an array. This is used to gather counts for teh displayed chart.|
|gout| The data included within the "out" group, encoded as an array. This is used to gather counts for the displayed chart.|
|error|A list constisting of the the error that occured, a list of warnings, or information that no error occurred. Each value of the list should be a list consisiting of the error message, encoded as a string, and a corresponding status code, encoded as a integer. A list of the codes can be found below. If a fatal error occurred this parameter should consist of a list with only the message and status code. If warnings occurred, this parameter should consist of a list of every warning and its status code. The default is a blank string and status code 0 indicating no error or warning occurred.|

##### Important Note
If a fatal error occurred during data processing, the errors field should be returned to the result method within Data.

##### List of Chart Options
Below is a list of the options avaialbe for the charts. The first part listed corresponds to the name of the chart in Highcharts (a preview can be seen at http://www.highcharts.com/demo/) while the second part is the string used to notify the program which charts can be graphed. 
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
