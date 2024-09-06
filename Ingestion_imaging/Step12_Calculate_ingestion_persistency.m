%--------Find the peak dFF after ingestion and the Width of a peak (falling half life time - rising half life time)------------
clear all
clc


%----------Important Note: This code is only suitable for 1 second per row, start time aligned, single ROI xlsx files!!!
list_of_directories = {...
'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\IN1_TNTFluoFoodIng\WxTNT\OutlierInced\IngAdded\BindFFSegIo'...
'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\IN1_TNTFluoFoodIng\WxIN1\IngAdded\BindFFSeg'...
'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\IN1_TNTFluoFoodIng\IN1xTNT\IngAdded\BindFFSeg'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\CS,Fasted,UL100mM&1MSucFluoFoodIng\1M\IngAdded\BindFFSegIo'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\CS,Fasted,UL100mM&1MSucFluoFoodIng\100mM\OutlierExcluded(InUse)\IngAdded\BindFFSegIo'...

    };

OutputPath='G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\Stat-IN1xTNT';
% OutputPath='G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\Stat-CS,UnLimited1M,100mM';
GroupTitle={'WxTNT','IN1xW','IN1xTNT'};
% GroupTitle={'CS,~1M','CS,~100mM'};
%% -----------Above: please change before each time of use------

% dFFFragment=zeros(FrameStartBeforeStim+FrameStopAfterStim+1,length(LightOnRowList));
for directory_idx  = 1:numel(list_of_directories)
    CurrentDir=list_of_directories{directory_idx};
    cd(CurrentDir);
    Folder1=list_of_directories{directory_idx};
    disp(sprintf('Processing %s',Folder1));
    XlsxList=dir('*.xlsx');

    AllAUC=[];
    AllPeakdFF=[];
    AllWidthOfFirstPeak=[];
    AllTrialName=[];
    
    XlsxToWrite=[];
    for idx1=1:size(XlsxList,1)
        cd(CurrentDir);
        print2=XlsxList(idx1).name
        AllTrialName=[AllTrialName;{print2}];
        [XlsxReadNum,XlsxReadTitle]=xlsread(XlsxList(idx1).name);
        
        IngIndCol=XlsxReadNum(:,end);
        StimOnsetRownNo=min(find(IngIndCol==1));
        TimeToIncludeIntoPeakdFFCalculationInSec=sum(logical(find(IngIndCol==1)));%This row determined that peak dFF only consider time DURING ingestion

        %-------Read data------
        CurrentdFF=XlsxReadNum(:,1:end-1);
        dFFSegToCalculateForPeakdFF=CurrentdFF(StimOnsetRownNo:StimOnsetRownNo+TimeToIncludeIntoPeakdFFCalculationInSec-1,:);
        dFFSegToCalculateForPeakWidth=CurrentdFF(StimOnsetRownNo:end,:);
%         CurrentAUC=trapz(dFFSegToCalculate);

        %------Calculate Peak dFF during ingestion------
        [CurrentMindFF,MindFFRowNoInSeg]=min(dFFSegToCalculateForPeakdFF);
        [CurrentMaxdFF,MaxdFFRowNoInSeg]=max(dFFSegToCalculateForPeakdFF);

        if abs(CurrentMindFF)>abs(CurrentMaxdFF)
            CurrentPeakdFF=CurrentMindFF;
        else
            CurrentPeakdFF=CurrentMaxdFF;
        end
        AllPeakdFF=[AllPeakdFF;CurrentPeakdFF];
        %-----calculate peak width = falling half life - rising half life-----
        CurrentHalfPeakdFF=0.5*CurrentPeakdFF;
        dFFSegAboveHalfPeak=zeros(size(dFFSegToCalculateForPeakWidth));

        AllROIWidthOfFirstPeak=[];
        for i=1:size(CurrentHalfPeakdFF,2)
            dFFRowListToKeep=find(dFFSegToCalculateForPeakWidth(:,i)>=CurrentHalfPeakdFF(i)),i;
%             FiltereddFFSeg(dFFRowListToKeep,i)=dFFSegToCalculateForPeakWidth(dFFRowListToKeep,i);
            dFFSegAboveHalfPeak(dFFRowListToKeep,i)=dFFSegToCalculateForPeakWidth(dFFRowListToKeep,i);
        end

            zeroRow=zeros(1,size(dFFSegAboveHalfPeak,2));
            ZeroPlusdFFSegAboveHalfPeak=[zeroRow;dFFSegAboveHalfPeak;zeroRow];
        
        for i=1:size(CurrentHalfPeakdFF,2)
            RowNoOfZeros=[];
            RowNoOfZeros=find(ZeroPlusdFFSegAboveHalfPeak(:,i)==0);

            RisingEdgeList=[];
            FallingEdgeList=[];
            for j=1:length(RowNoOfZeros)-1
                if RowNoOfZeros(j+1)-RowNoOfZeros(j)>1
                    RisingEdgeList=[RisingEdgeList,RowNoOfZeros(j)];
                    FallingEdgeList=[FallingEdgeList,RowNoOfZeros(j+1)];%Notice: Because of this row of code, the evental calculation result for peak width will be equivalent to (the row number taht the y value falls below half peak for the first time- the row number the y value rise above the half peak for the first time)
                end
            end
            WdithOfFirstPeak=FallingEdgeList(1)-RisingEdgeList(1);
            AllROIWidthOfFirstPeak=[AllROIWidthOfFirstPeak,WdithOfFirstPeak];
        end
        AllWidthOfFirstPeak=[AllWidthOfFirstPeak;AllROIWidthOfFirstPeak];
    end
        %-------calculate AUC for
        %------Add to Xlsx To Write------
        %-----Write Peak dFF during ingestion-----
        DataAreaToWriteP1=[AllTrialName,num2cell(AllPeakdFF)];
        XlsxBigTitleP1=[{'Peak dFF During Ing - Trial Name'},XlsxReadTitle(1:end-1)];
        AllToWriteP1=[XlsxBigTitleP1;DataAreaToWriteP1];
        
        cd(OutputPath);
        xlswrite(strcat(OutputPath,'\PeakdFFDuringIng,',GroupTitle{directory_idx},'.xlsx'), AllToWriteP1);
        save(strcat('CalInfo-PeakdFFDuringIng,',GroupTitle{directory_idx},'.mat'));
        %-----Write First Peak Width------
        DataAreaToWriteP2=[AllTrialName,num2cell(AllWidthOfFirstPeak)];
        XlsxBigTitleP2=[{'First Peak Width - Trial Name'},XlsxReadTitle(1:end-1)];
        AllToWriteP2=[XlsxBigTitleP2;DataAreaToWriteP2];
        
        cd(OutputPath);
        xlswrite(strcat(OutputPath,'\FirstPeakWidth,',GroupTitle{directory_idx},'.xlsx'), AllToWriteP2);
        save(strcat('CalInfo-FirstPeakWidth,',GroupTitle{directory_idx},'.mat'));
end