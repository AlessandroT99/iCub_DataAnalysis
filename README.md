# iCub_DataAnalysis
--------------------------
After had performed the data collection during the Posner paradigm experiment (https://gitlab.iit.it/cognitiveInteraction/physicalHRI4cutting/),
this script is executed to evaluate the just collected data.

This program takes in input the position and the force data from obtained from iCub in two different
moments:
* BaseLine test: where the robot has been leave alone making the test without no interference
and it is named in the data folders as test `P`.
* Posner paradigm experiment: where iCub is performing a test with a human, each of this experiments
has been saved in the data folders as test `P_000personID`

Notice that the data are collected from different ports of iCub:
* Position -> `/icub/cartesianController/X_arm/state:o`
* Force    -> `/icub/X_arm/analog:o`
where X = `left` or `right`

## DESCRIPTION
-------------------
### MAIN PROGRAM
The main program can be found as `dataPlotter.m`, is the one which execute togheter
all the fuctions that plots and analyze the data.

### GENERAL INSTRUCTIONS
Inside each program or function it is possible to find the section "Simulation parameter"
at the begin of the file, inside of that there are two cases:
* CAPS_CONSTANTS: used to modify some conditions inside that program or function
which avoid to print, save or execute some parts of the code
* normal_variables: used to change some common behaviors inside the program or function

### AUTHOR
----------------
Alessandro Tiozzo - alessandro.tiozzo@iit.it