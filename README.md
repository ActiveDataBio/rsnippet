<!--adbio-version-->
[![Visit at https://adbio.pnnl.gov](https://adbio.pnnl.gov/bioviz/services/svg/version?ver=0.02)](https://adbio.pnnl.gov/bioviz/releasenotes.html#0.02)
<!--rsnippet-title-->
#Rsnippet Guidelines
<!--rsnippet-description-->
The Rsnippet Guidelines outlines a set of rules and suggestions for formatting rsnippets to be used with the ADBio program. The ADBio program comes with a variety of statistical tests already implemeted for the user. If the user would like to create their own tests, this outlines the format that should be used to write their Rcode.
<!--rsnippet-data format-->
##Data Format


<!--rnippet-input-->
##Input
The input should include three separate arrays- meta, group, and null_string.


|Variable     |Description|
|-------------|:---------:|
| meta | An array of the data that is to be analyzed. |
| group | An array of the strings "IN" and "OUT". "IN" signifies that the same index in meta is a part of the cluster that is being analyzed. "OUT" signifies that the same index in meta will belong to the rest of the group. |
| null_string | An array of the strings used to encode missing/null data. |
