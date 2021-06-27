# MulApprox
MulApprox - A comprehensive library of state-of-the-art approximate multipliers

## Overview

The area of approximate multiplier lacks the comprehensive library of state-of-the-art work. Here, we fill this gap by presenting a collection of approximate multipliers in the form of a library. The library enables researchers in this field to compare their solutions with state-of-the-art designs easily. All the Verilog/CMOS implementations and behaviour models of the state-of-the-art and our multipliers is made available publicly, together with the software used for the error assessment and application study. To the best of our knowledge, there is no such comprehensive library of state-of-the-art approximate multipliers publicly available. 

## Code organisation 

- verilog/ -> Verilog source files for approximate multipliers grouped according to their class.

- behaviour_models/ -> C source files that describe the functionality of approximate multipliers.

- utils/OpenROAD/ -> Used constraints and configuration in OpenROAD synthesis flow 

- utils/ErrorAssessment/ -> C source files that calculate NMED and MRE

- utils/Caffe_src/ -> Cuda files for implementing convolutional and fully connected layers with approximate multiplication in the Caffe framework
