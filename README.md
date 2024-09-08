# Cui_et_al
This repository contains code for producing the analyses and figures in Cui et al: *A gut-brain-gut interoceptive circuit loop gates sugar ingestion in Drosophila (2024)*. 

The pipeline for analyzing two-photon imaging uses raw data (unregistered two-photon TIFF images). Due to the significant storage space required, these data are not currently available online but can be provided upon request. Minimally processed data examples (such as time series for imaging ROIs) are provided in this data repository. 

**Repository structure**

Each folder contains MATLAB code to process two-photon raw imaging data, extract fluorescence values, and generate figures for each dataset. Figure numbers that use the code are indicated in the readme.txt file within each folder.

**Folder Contents:**

* **MATLAB Code**: Scripts to process raw data, extract values, and create figures.
* **Readme.txt**: A file indicating which figures are generated using the included code.
* **Instruction.txt**: A guide on how to run the provided MATLAB code on the raw data.
* **Functions**: Contains additional MATLAB functions required for the code to run correctly. Ensure this folder is downloaded along with the main code files.

**Software Requirements**

**Data collection**

*Two photon imaging*
* ThorImage software (Thorlabs, version 4.0.2020.2171)
* ThorSync software (Thorlabs, version 4.1.2020.1131)
* SpinView software (FLIR systems, Spinnaker 2.0.0.147)

*Confocal imaging* 
* Zen software (ZEISS, black edition, 2.1 SP3)
  
**Data processing**

*Two photon imaging*
* MATLAB (Mathworks, MATLAB R2022b)
* Fiji (ImageJ, Java 1.8.0_172(64-bit)
* TurboReg plugin (Biomedical Imaging Group, Swiss Federal Institute of Technology Lausanne, July 7, 2011 distribution).

*Confocal imaging* 
* Zen software (ZEISS, blue edition, version 3.6)
* Imaris (Oxford Instruments, version 10.1.1). 

**Data Analysis**

The majority of the analyses were performed using MATLAB (Mathworks, MATLAB R2022b). 
Statistics were conducted in GraphPad Prism (GraphPad, Version 10.1.1). Figures were produced using both MATLAB and Prism. 

**Installation guidelines**

* This code requires the MATLAB desktop application to run. MATLAB installation approximately takes 5-10 minutes in a regular desktop computer. After the main software installation is completed, install the MATLAB Image Processing Toolbox (Version 11.6, MathWorks) which is required to process two-photon image frames. 

* This code also requires additional MATLAB functions to run. These functions are provided in the repository. Place these functions in the correct MATLAB path before running the code. 

* Place all the code files (.m files) into the same folder and run the code using MATLAB according to the instructions. 

* Code run time per trial is approximately 15 minutes, but this might change based on the computer processing speed. 



