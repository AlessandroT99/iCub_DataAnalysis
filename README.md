# Master Thesis Data Analysis

Analysis of kinematic features of a collaborative physical human-robot interaction. The results were used to design a controller for a humanoid arm.

## CONTEXT

After performing the data collection during the Posner paradigm experiment, this script is executed to evaluate the just collected data.

This program takes into input the position and the force data obtained from iCub in two different moments:
* BaseLine test: where the robot has been left alone to make the test without any interference and it is named in the data folders as test `B`.
* Posner paradigm experiment: where iCub is performing a test with a human, each of these experiments has been saved in the data folders as test `P_000personID`.

Notice that the data are collected from different ports of iCub:
* Position -> `/icub/cartesianController/X_arm/state:o`
* Force    -> `/icub/X_arm/analog:o`
where X = `left` or `right`

## MAIN PROGRAM

The main program can be found as `mainDataAnalysis.m`, which executes together all the functions that plot and analyze the data.   
The following code is referred to the adaptive behavior processing algorithm which is slightly different from the compliant behavior analysis.

## GENERAL INSTRUCTIONS

Inside each program or function it is possible to find the section "Simulation parameter" at the beginning of the file, inside of that there are two cases:
* __CAPS_CONSTANTS__: used to modify some conditions inside that program or function that avoid printing, saving, or executing some parts of the code.
* __normal_variables__: used to change some common behaviors inside the program or function.

## AUTHOR

Alessandro Tiozzo - alessandro.tiozzo@iit.it
