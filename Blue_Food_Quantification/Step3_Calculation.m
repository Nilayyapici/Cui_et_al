%% =======FDA Analysis Step 3_Post Processing Plotting===========
clear all
clc 
%----------↓Adjustable Arguments-----------

InputDataFolderPath='J:\CropData\OD-IN1xTNT';
GroupNo=3;
CapillaryPhotoFolderName='\Cap';
ColNoTifFileName=1;
ColNoSizeRatio=2;
ColNoBlueRatio=3;
ColNoROI1SizeByMM=4;%ROI1 is Crop, ROI2 is Midgut
ColNoROI2SizeByMM=5;%ROI1 is Crop, ROI2 is Midgut
ColNoBlueRatioOfROI1=6;
ColNoNoOfBluePixelInROI1=7;
ColNoNoOfTotalPixelInROI1=8;
ColNoBlueRatioOfROI2=9;
ColNoNoOfBluePixelInROI2=10;
ColNoNoOfTotalPixelInROI2=11;
UmPerPixel=0.75488;%For my Keyence Setting 1, scale is 0.75488um/pixel
AreaPerPixelInUmSq=UmPerPixel*UmPerPixel;

ColNoFinalFeedingVolumeInMM=2;
CapillaryInnerRadiusInMM=0.25;
%------------Navigate to Path------------
cd(InputDataFolderPath);
FolderListStruct=dir(InputDataFolderPath);
FolderListStruct=FolderListStruct(3:end);

%------Read Excel Results------
CropAreaPerNLOfFood=[];
CropBlueAreaPerNLOfFood=[];
MidgutAreaPerNLOfFood=[];
MidgutBlueAreaPerNLOfFood=[];
for i=1:GroupNo%size(FolderListStruct,1)
    CurrentFolderName=FolderListStruct(i).name;
    CurrentFolderPath=strcat(FolderListStruct(i).folder,'\',CurrentFolderName);

    CurrentSizeAndBlueRatioTable=readcell(strcat(CurrentFolderPath,'\SizeAndBlueRatioOfAllImgs.xls'));
    TableTitle=CurrentSizeAndBlueRatioTable(1,:);
    TableNum=CurrentSizeAndBlueRatioTable(2:end,:);
    TifFileNameList=TableNum(:,1);
    %-------Calculate ROI1(Crop) Area In UM^2-----------    
    CropAreaInUMSq=str2double(TableNum(:,ColNoROI1SizeByMM))*1000*1000;

    %-------Calculate ROI1(Crop) Blue Dye Containing Area In UM^2-----------
    CropBluePixelNo=str2double(TableNum(:,ColNoNoOfBluePixelInROI1));
    CropBlueAreaInUMSq=CropBluePixelNo.*AreaPerPixelInUmSq;

    %-------Calculate ROI2(MidGut) Area In UM^2-----------    
    MidgutAreaInUMSq=str2double(TableNum(:,ColNoROI2SizeByMM))*1000*1000;

    %-------Calculate ROI2(MidGut) Blue Dye Containing Area In UM^2-----------
    MidgutBluePixelNo=str2double(TableNum(:,ColNoNoOfBluePixelInROI2));
    MidgutBlueAreaInUMSq=MidgutBluePixelNo.*AreaPerPixelInUmSq;

    %-------Calculate Food Distribution Index (FDI)=BlueAreaInCrop/BlueAreaInMidgut------
    FDI=CropBlueAreaInUMSq./MidgutBlueAreaInUMSq;

    %-------Get Eating Volume Of Each Fly----
    CapFolderPath=strcat(InputDataFolderPath,'\',CurrentFolderName,CapillaryPhotoFolderName);
    CurrentEatingVolTable=readcell(strcat(CapFolderPath,'\FinalFeedingVolumeMeasure.xls'));
    EatingVolTabelNum=CurrentEatingVolTable(2:end,:);
    FirstCapillaryImageName=EatingVolTabelNum(:,1);

    EatingVolumeLengthChangeInMM=cell2mat(EatingVolTabelNum(:,ColNoFinalFeedingVolumeInMM));
    FinalEatingVolumeInMMCube=EatingVolumeLengthChangeInMM*pi*CapillaryInnerRadiusInMM*CapillaryInnerRadiusInMM;
    FinalEatingVolumeInNL=FinalEatingVolumeInMMCube*1000;

    %-------TBA, Scatter Plot here? X is Eating Vol, Y is Crop Blue Area?-------

    %-------Calculate CropAreaPerNLOfFood, CropBlueAreaPerNLOfFood, And For Midgut------
    CropAreaPerNLOfFood=CropAreaInUMSq./FinalEatingVolumeInNL;
%     CropAreaPerNLOfFood=[CropAreaPerNLOfFood,CurCropAreaPerNLOfFood]; 

    CropBlueAreaPerNLOfFood=CropBlueAreaInUMSq./FinalEatingVolumeInNL;
%     CropBlueAreaPerNLOfFood=[CropBlueAreaPerNLOfFood,CurCropBlueAreaPerNLOfFood];

    MidgutAreaPerNLOfFood=MidgutAreaInUMSq./FinalEatingVolumeInNL;
%     MidgutAreaPerNLOfFood=[MidgutAreaPerNLOfFood,CurMidgutAreaPerNLOfFood];

    MidgutBlueAreaPerNLOfFood=MidgutBlueAreaInUMSq./FinalEatingVolumeInNL;
%     MidgutBlueAreaPerNLOfFood=[MidgutBlueAreaPerNLOfFood,CurMidgutBlueAreaPerNLOfFood]; %#ok<*AGROW> 

    %---------Write Result-------
    HeaderToWrite=[{'GroupName'},{'TifFileName'},{'CropArea(um^2)'},{'CropBlueArea(um^2)'},...
        {'MidgutAreaInUMSq(um^2)'},{'MidgutBlueArea(um^2)'},{'FDI(CropBlueAreaInUMSq/MidgutBlueAreaInUMSq)'},...
        {'FirstCapillaryImageName(OfAllImagesOftheSameFly)'},...
        {'FeedingVolume(nl)'},{'CropAreaPerNLOfFood(um^2/nl)'},{'CropBlueAreaPerNLOfFood(um^2/nl)'},...
        {'MidgutAreaPerNLOfFood(um^2/nl)'},{'MidgutBlueAreaPerNLOfFood(um^2/nl)'}];
    writecell(HeaderToWrite,strcat(InputDataFolderPath,'\DataSummary.xls'),'WriteMode','append');

    GroupNameForWrite=repmat({CurrentFolderName},size(TableNum,1),1);
    NumToWrite=[GroupNameForWrite,TifFileNameList,num2cell(CropAreaInUMSq),num2cell(CropBlueAreaInUMSq),...
        num2cell(MidgutAreaInUMSq),num2cell(MidgutBlueAreaInUMSq),num2cell(FDI),...
        FirstCapillaryImageName,...
        num2cell(FinalEatingVolumeInNL),num2cell(CropAreaPerNLOfFood),num2cell(CropBlueAreaPerNLOfFood),...
        num2cell(MidgutAreaPerNLOfFood),num2cell(MidgutBlueAreaPerNLOfFood)];
    writecell(NumToWrite,strcat(InputDataFolderPath,'\DataSummary.xls'),'WriteMode','append');
end

