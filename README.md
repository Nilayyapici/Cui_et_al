# Cui_et_al
This repository contains code for producing the analyses and figures in Cui_2024 et al: A gut-brain-gut interoceptive circuit loop gates sugar ingestion in Drosophila. 

The pipeline for analyzing two-photon imaging uses raw data (unregistered two-photon TIFF images). Due to the significant storage space required, these data are not currently available online but can be provided upon request. Minimally processed data examples, including time series for imaging ROIs, are available in this repository and provided in data source files. 

**Repository structure **
Each folder contains MATLAB code to process the two-photon raw imaging data, extract the fluorescent values, and generate all the figures for each dataset. The figure numbers are indicated in the readme.txt files in each folder. 

Cui_et_al/2P_ingestion

Cui_et_al/2P_opto+ingestion

Cui_et_al/2P_opto

Each folder contains a "functions" subfolder that contains the additional MATLAB functions required to run the code properly. These functions should be downloaded together with the code. 

**Software Requirements**

Data collection:ThorImage software (Thorlabs, version 4.0.2020.2171), ThorSync software (ThorLabs, version 4.1.2020.1131), SpinView software (FLIR systems, Spinnaker 2.0.0.147)

Data processing:
MATLAB (Mathworks, MATLAB R2022b)
Fiji (ImageJ, Java 1.8.0_172(64-bit))
TurboReg plugin (Biomedical Imaging Group, Swiss Federal Institute of Technology Lausanne, July 7, 2011 distribution)
Zen software (ZEISS, blue edition, version 3.6)
Imaris (Oxford Instruments, version 10.1.1)

The majority of the analyses were performed using MATLAB. 
Statistics were conducted in GraphPad Prism. Figures were produced using both MATLAB and Prism. 



