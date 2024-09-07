# Cui_et_al
This repository contains code for producing the analyses and figures in Cui et al: A gut-brain-gut interoceptive circuit loop gates sugar ingestion in Drosophila (2024). 

The pipeline for analyzing two-photon imaging uses raw data (unregistered two-photon TIFF images). Due to the significant storage space required, these data are not currently available online but can be provided upon request. Minimally processed data examples, including time series for imaging ROIs are provided in data source files. 

**Repository structure**

Each folder contains MATLAB code to process the two-photon raw imaging data, extract the fluorescent values, and generate all the figures for each dataset. The figure numbers that uses the code are indicated in the readme.txt files in each folder. Each folder contains an instruction.txt that explains how the code should be run on the raw data. 

Cui_et_al/2P_ingestion

Cui_et_al/2P_opto+ingestion

Cui_et_al/2P_opto

Each folder contains a "functions" subfolder that contains the additional MATLAB functions required to run the code properly. These functions should be downloaded together with the code. 

**Software Requirements**

**Data collection**

ThorImage software (Thorlabs, version 4.0.2020.2171), ThorSync software (Thorlabs, version 4.1.2020.1131), SpinView software (FLIR systems, Spinnaker 2.0.0.147)

**Data processing**

Two photon imaging: MATLAB (Mathworks, MATLAB R2022b), Fiji (ImageJ, Java 1.8.0_172(64-bit), TurboReg plugin (Biomedical Imaging Group, Swiss Federal Institute of Technology Lausanne, July 7, 2011 distribution)

Confical imaging: Zen software (ZEISS, blue edition, version 3.6),  Imaris (Oxford Instruments, version 10.1.1). 

**Data Analysis**

The majority of the analyses were performed using MATLAB (Mathworks, MATLAB R2022b). 
Statistics were conducted in GraphPad Prism(GraphPad, Version 10.1.1). Figures were produced using both MATLAB and Prism. 

Guidelines to run each code are provided in the instructions.txt file in each code folder.  

**Installation guide**



