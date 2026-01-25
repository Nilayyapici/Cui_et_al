%For CEM>GCaMP6s ingestion imaging experiments, calculate the Peak dFF, area under curve, and persistency in multiple versions
clear all
clc

TimeBeforeOnsetInSec=50;%This is the time that exist before stim on in the excel file. By default 1 row is 1 sec, so usually for 8m trial which has plotted from -50s to +300s (0 is ingestion onset), this parameter should be 50.
TimeToIncludeIntoCalculationInSec=50;%In sec. By default 1 second is 1 row.
Persistency2TimeWindowInSec=50; %Persistency 2 measures how many percentage of the signal lasts at the end of the time window (time window starts at ingestion onset)
Persistency3ThresholdFactor=0.5;% 0 to 1. The threshold for persistency 3 calculation will be (Persistency3ThresholdFactor * peak dFF of the Persistency3PeakTimeWindow)
Persistency34and5PeakTimeWindow=10%in second, start after ingestion onset, usually 10 for CEM imagin data
Persistency4ThresholdFactor=0.5;% 0 to 1. The threshold for persistency 4 calculation will be (Persistency4ThresholdFactor * min dFF of the Persistency3PeakTimeWindow)
Persistency5ThresholdFactor=0.5;% 0 to 1. The threshold for persistency 5 calculation will be (Persistency5ThresholdFactor * max dFF of the Persistency3PeakTimeWindow)

%% ----------Important Note: This code is only suitable for 1 second per row, start time aligned to ingestion onset, single ROI xlsx files!!!
OutputPath='C:\Users\zjucx\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\CEM\CEMGCaMP6s,ALL';
list_of_directories = {...
    'C:\Users\zjucx\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\CEM\CEMGCaMP6s,AfterRevision\CEM,50mMNaCl,Fasted'...
% 'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\CEM\CEMGCaMP6s,ALL\CEM,1MSuc,Fasted(ContFor100mMSuc)'...
% 'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\CEM\CEMGCaMP6s,ALL\CEM,1MSuc,RefedWS'...
% 'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\CEM\CEMGCaMP6s,ALL\CEM,100mMSuc,Fasted'...
% 'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\CEM\CEMGCaMP6s,ALL\CEM,100mMSuc,RefedWS'...
% 'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\CEM\CEMGCaMP6s,ALL\CEM,1MFru,Fasted'...
% 'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\CEM\CEMGCaMP6s,ALL\CEM,300mMSuA,Fasted'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,1MSuc\OutExc\IngAdded\BindFFSeg'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,100mMSuc\IngAdded\BindFFSeg'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),RefedWS,1MSuc\OutExc\IngAdded\BindFFSeg'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\GutLines\Gut2\IngAdded\BindFFSeg'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\GutLines\Gut3\IngAdded\BindFFSeg'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\GutLines\Gut4\IngAdded\BindFFSeg'...

    };

GroupTitle={'Fasted 50mM NaCl','Fed 1M Sucrose','Fasted 100mM Sucrose','Fed 100mM Sucrose','Fasted 1M Fructose','Fasted 300mM Sucralose'};%Make sure this sequence is in accordance with the input sequence of folders
% GroupTitle={'Gut2','Gut3','Gut4','Gut10','Gut11','Gut13'};
% GroupTitle={'Gr43a, Fasted, High Suc.','Gr43a, Fasted, Low Suc.','Gr43a, Fed, High Suc.'};
%% -----------Above: please change before each time of use------

% dFFFragment=zeros(FrameStartBeforeStim+FrameStopAfterStim+1,length(LightOnRowList));
for directory_idx  = 1:numel(list_of_directories)
    CurrentDir=strcat(list_of_directories{directory_idx},'\IngAdded\BindFFSeg');
    cd(CurrentDir);
    disp(sprintf('Processing %s',CurrentDir));
    XlsxList=dir('*.xlsx');

    AllAUC=[];
    AllPeakdFF=[];
    AllMindFF=[];
    AllMaxdFF=[];
    AllPersistency1=[];
    AllTrialName=[];
    AllDecayPercentage=[];
    AllPersistencyTestTime=[];
    AllPersistency3=[];
    AllNegOrPosTrace=[];
    AllPersis3ThresholdRatio=[];
    AllPersis34and5ThresTimeWindowLegnth=[];
    AllPersis3Threshold=[];
    AllPersistency4=[];
    AllPersis4ThresholdRatio=[];
    AllPersis4Threshold=[];
    AllPersistency5=[];
    AllPersis5ThresholdRatio=[];
    AllPersis5Threshold=[];
    XlsxToWrite=[];
    for idx1=1:size(XlsxList,1)
        cd(CurrentDir);
        print2=XlsxList(idx1).name
        AllTrialName=[AllTrialName;{print2}];
        [XlsxReadNum,XlsxReadTitle]=xlsread(XlsxList(idx1).name);
        
        %------Calculate area under curve-----
        CurrentdFF=XlsxReadNum(:,1);
        dFFSegToCalculate=CurrentdFF(TimeBeforeOnsetInSec+1:TimeBeforeOnsetInSec+TimeToIncludeIntoCalculationInSec);
        CurrentAUC=trapz(dFFSegToCalculate);

        AllAUC=[AllAUC;CurrentAUC];
        %------Calculate Peak dFF------
        [CurrentMindFF,MindFFRowNoInSeg]=min(dFFSegToCalculate);
        AllMindFF=[AllMindFF;min(dFFSegToCalculate)];
        [CurrentMaxdFF,MaxdFFRowNoInSeg]=max(dFFSegToCalculate);
        AllMaxdFF=[AllMaxdFF;max(dFFSegToCalculate)];
        if abs(CurrentMindFF)>abs(CurrentMaxdFF)
            CurrentPeakdFF=CurrentMindFF;
        else
            CurrentPeakdFF=CurrentMaxdFF;
        end
        AllPeakdFF=[AllPeakdFF;CurrentPeakdFF];
        %-----Calculate persistency ver 1 = AUC/PeakdFF-----
        CurrentPersistency1=CurrentAUC/CurrentPeakdFF;
        AllPersistency1=[AllPersistency1;CurrentPersistency1];

        %-------Calculate persistency ver 2: Decay Percentage = After PersistTest Time window, how many dFF lasts----
        PersistencyTestTime=Persistency2TimeWindowInSec;
        CurrentDecayPercentage=dFFSegToCalculate(PersistencyTestTime)/CurrentPeakdFF;
        AllDecayPercentage=[AllDecayPercentage;CurrentDecayPercentage];      

        %-------Calculate persistency ver 3, 4 and 5: Time duration that the signal remain below/above a threshold (ver 3), or just below the threshold (ver 4), or just above the threshold (ver5)------
        MindFFInPersis3TimeWindow=min(dFFSegToCalculate(1:Persistency34and5PeakTimeWindow));
        MaxdFFInPersis3TimeWindow=max(dFFSegToCalculate(1:Persistency34and5PeakTimeWindow));
        AbsGreatestdFFInPersis3TimeWindow=max(abs(MaxdFFInPersis3TimeWindow),abs(MindFFInPersis3TimeWindow));
        if abs(MindFFInPersis3TimeWindow)>abs(MaxdFFInPersis3TimeWindow)
            ThisdFFIsMoreNegative1ThanPositive0=1;
            Persistency3Threshold=Persistency3ThresholdFactor*AbsGreatestdFFInPersis3TimeWindow*-1;
        else
            ThisdFFIsMoreNegative1ThanPositive0=0;
            Persistency3Threshold=Persistency3ThresholdFactor*AbsGreatestdFFInPersis3TimeWindow;
        end
        Persistency4Threshold=Persistency4ThresholdFactor*MindFFInPersis3TimeWindow;
        Persistency5Threshold=Persistency5ThresholdFactor*MaxdFFInPersis3TimeWindow;
        
        if ThisdFFIsMoreNegative1ThanPositive0==1
            RowsBelowThreshold=find(dFFSegToCalculate<=Persistency3Threshold);
            CurrentPersistency3=length(RowsBelowThreshold);
        elseif ThisdFFIsMoreNegative1ThanPositive0==0
            RowsAboveThreshold=find(dFFSegToCalculate>=Persistency3Threshold);
            CurrentPersistency3=length(RowsAboveThreshold);
        end
        CurrentPersistency4=length(find(dFFSegToCalculate<=Persistency4Threshold));
        CurrentPersistency5=length(find(dFFSegToCalculate>=Persistency5Threshold));

        AllPersistency3=[AllPersistency3;CurrentPersistency3];
        AllPersis3ThresholdRatio=[AllPersis3ThresholdRatio;Persistency3ThresholdFactor];
        AllPersis34and5ThresTimeWindowLegnth=[AllPersis34and5ThresTimeWindowLegnth;Persistency34and5PeakTimeWindow];
        AllPersis3Threshold=[AllPersis3Threshold;Persistency3Threshold];

        AllNegOrPosTrace=[AllNegOrPosTrace;ThisdFFIsMoreNegative1ThanPositive0];
        
        AllPersistency4=[AllPersistency4;CurrentPersistency4];
        AllPersistency5=[AllPersistency5;CurrentPersistency5];
        AllPersis4ThresholdRatio=[AllPersis4ThresholdRatio;Persistency4ThresholdFactor];
        AllPersis4Threshold=[AllPersis4Threshold;Persistency4Threshold];
        AllPersis5ThresholdRatio=[AllPersis5ThresholdRatio;Persistency5ThresholdFactor];
        AllPersis5Threshold=[AllPersis5Threshold;Persistency5Threshold];
        %-------Record persistency test time window-------
        AllPersistencyTestTime=[AllPersistencyTestTime;PersistencyTestTime];
        %------Add to Xlsx To Write------
        XlsxBigTitle=[{'Trial Name'},{'AUC'},{'Min dFF'},{'Max dFF'},{'Peak dFF'},...
            {'Persistency1 = AUC/Peak dFF'},{'Persistency2: Decay Percentage'},...
            {'Persistency3, Time above or below threshold ratio * Greatest dFF (s)'},{'Persis 3 Threshold Ratio (0 to 1)'},...
            {'Persis 3, 4 and 5 Threshold Time Window Length(s)(Start from ingestion onset)'},{'Threshold Value'},...
            {'Persistency4, Time below threshold ratio * Min dFF (s)'},{'Persis 4 Threshold Ratio (0 to 1)'},{'Threshold Value'},...
            {'Persistency5, Time above threshold ratio * Max dFF (s)'},{'Persis 5 Threshold Ratio (0 to 1)'},{'Threshold Value'},...
            {'Min value Greater than Max value (1) Or not (0)'},{'Persistency calculation time window Length(s)(start from ingestion onset)'}];
        XlsxNumToWrite=[AllAUC,AllMindFF,AllMaxdFF,AllPeakdFF,...
            AllPersistency1,AllDecayPercentage,...
            AllPersistency3,AllPersis3ThresholdRatio,...
            AllPersis34and5ThresTimeWindowLegnth,AllPersis3Threshold,...
            AllPersistency4,AllPersis4ThresholdRatio,AllPersis4Threshold,...
            AllPersistency5,AllPersis5ThresholdRatio,AllPersis5Threshold,...
            AllNegOrPosTrace,AllPersistencyTestTime];
        XlsxNumToWrite=num2cell(XlsxNumToWrite);
        XlsxToWriteBelowTitle=[AllTrialName,XlsxNumToWrite];
        AllXlsxToWrite=[XlsxBigTitle;XlsxToWriteBelowTitle];

    end
        
        cd(OutputPath);
        mkdir('PersCal')
        cd(strcat(OutputPath,'\PersCal'));
        xlswrite(strcat(OutputPath,'\PersCal\PersistencyCalculation,0-',num2str(TimeToIncludeIntoCalculationInSec),',',GroupTitle{directory_idx},'s.xlsx'), AllXlsxToWrite);
        save(strcat('CalInfoForPersistency,0-',num2str(TimeToIncludeIntoCalculationInSec),',',GroupTitle{directory_idx},'.mat'));

end