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

## Overview

| Paper | Multiplier acronym | Verilog | Behaviour model |
|:-----------------------|:-------:|:-------:|:---------------:|
| [Design of Approximate Radix-4 Booth Multipliers for Error-TolerantComputing](https://ieeexplore.ieee.org/document/7862783)                       |    R4ABM     |    :heavy_check_mark:     |        :heavy_check_mark:         |
| [Approximate Hybrid High Radix Encoding for Energy-Efficient Inexact Multipliers](https://ieeexplore.ieee.org/document/8105832)               | RAD1024         | :heavy_check_mark:     |        :heavy_check_mark:  |
| [Hybrid Low Radix Encoding-Based Approximate Booth Multipliers](https://ieeexplore.ieee.org/abstract/document/9003227)       |    HLR_BM     | :heavy_check_mark:         |     :heavy_check_mark:              |
| [On the Design of Logarithmic Multiplier Using Radix-4 Booth Encoding](https://ieeexplore.ieee.org/document/9056840)       |    LOBO     | :heavy_check_mark:         |     :heavy_check_mark:              |
| [A Hybrid Radix-4 and Approximate Logarithmic Multiplier for Energy Efficient Image Processing](https://www.mdpi.com/2079-9292/10/10/1175)       |    HRALM     | :heavy_check_mark:         |     :heavy_check_mark:              |
| [Computer Multiplication and Division Using Binary Logarithms](https://ieeexplore.ieee.org/document/5219391)       |    MITCHEL     | :heavy_check_mark:         |     :heavy_multiplication_x:              |
| [DRUM: A Dynamic Range Unbiased Multiplier for approximate applications](https://ieeexplore.ieee.org/document/7372600)       |    DRUM     | :heavy_check_mark:         |    :heavy_multiplication_x:              |
| [RoBA Multiplier: A Rounding-Based Approximate Multiplier for High-Speed yet Energy-Efficient Digital Signal Processing](https://ieeexplore.ieee.org/document/7517375)       |    (AS)ROBA     | :heavy_check_mark:         |     :heavy_check_mark:              |
| [Design and Evaluation of Approximate Logarithmic Multipliers for Low Power Error-Tolerant Applications](https://ieeexplore.ieee.org/abstract/document/8280549)       |    ALM_SOA     | :heavy_check_mark:         |     :heavy_check_mark:              |
| [Efficient Mitchell’s Approximate Log Multipliers for Convolutional Neural Networks](https://ieeexplore.ieee.org/abstract/document/8532287)       |    MITCHEL_TRUNC     | :heavy_check_mark:         |     :heavy_check_mark:              |
| [An Improved Logarithmic Multiplier for Energy-Efficient Neural Computing](https://ieeexplore.ieee.org/abstract/document/9086744)       |    ILM_AA     | :heavy_check_mark:         |     :heavy_multiplication_x:              |
| [Design and Analysis of Energy-Efficient Dynamic Range Approximate Logarithmic Multipliers for Machine Learning](https://ieeexplore.ieee.org/abstract/document/9126271)       |    DRALM     | :heavy_check_mark:         |     :heavy_check_mark:              |
| [A Two-Stage Operand Trimming Approximate Logarithmic Multiplier](https://ieeexplore.ieee.org/document/9393561)       |    DRALM     | :heavy_check_mark:         |     :heavy_check_mark:              |






