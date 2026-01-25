%% ======Calculate responded neuorn population and calculate averaged (average among responded neuorns) peak dFF for each fly for ingestion Imaging experiments===
%% ======Use after the PlotAvgIngResp_part1 cutting the responses to dFF segments that only contains the first ingestion bout=======
%% ======Persistency 5 WAS NOT USED! Careful with it!! Persistency 6 was used.=========
clear all
clc

UseGreatestdFFDuringStim0OrUseMeandFFDuringStim1=0;%If you want to use gratested dFF during stim to determin whether or not that cell is positively/negatively/not responded cell, set it to 0, otherwise if you want to use mean dFF during stim, set it to 1.
% YLimSetting=[-0.2,0.5];% Y limit setting for the Mean+-SEM figure
YLimSetting=[-0.2,1];% Y limit setting for the Mean+-SEM figure
FigureWidth=5;
FigureHeight=5;
BoutIndicatorMaxYHeightRatio=0.2;
TimeStartBeforeStim=50;%%Check here!!!!!in seconds. 30 for 8m Gr43a ingestion imaging trial, 50 for 8m CEM ingestion imaging trial, 20 for regular 4m trial. 50 for regular single bout 8m trial. If don't want to cut off just set it to 99999
TimeStopAfterStim=50;%%Check here!!!!!in seconds. 30 for 8m Gr43a ingestion imaging trial, 50 for 8m CEM ingestion imaging trial, 20 for regular 4m trial. 50 for regular single bout 8m trial. If don't want to cut off just set it to 99999

BasalDFFTimeBeginInSec=-50;%Check here!!!!!The minus or plus here is relative to the ingestion bout onset (the onset will be time 0)
BasalDFFTimeEndInSec=0;%Check here!!!!!The minus or plus here is relative to the ingestion bout onset (the onset will be time 0)
RespThresFactor=3;%If this factor is set to 2, the dFF threshold factor used to decide which neurons will be counted as "responded neurons" will be mean of the dFF in the basal time window+ (that factor)*standart deviation of the dFF in the basal time window
TotalTimeSec=TimeStartBeforeStim+TimeStopAfterStim;
SetColorSpec={[0, 0, 1];[0,1,0];[0.6, 0.8250, 0.280];[0.9290, 0.6940, 0.5250];[0.4940, 0.1840, 0.5560];[0.75, 0.5, 0.75];...
    [0.660, 0.8740, 0.480];[0, 0.5, 0.16];[0.5010, 0.7450, 0.9330];[0.6350, 0.0780, 0.2840];[0.6350, 0.0780, 0.55];[0.6350, 0.0780, 0.3];[0.6350, 0.2, 0.55];[0.6350, 0.2780, 0.65];[0.9350, 0.0780, 0.55];[0.8350, 0.780, 0.55];[0.8500, 0.6250, 0.280];[0.6, 0.6250, 0.980]};

PersistencyThresholdFactor=0.5;
TimeBeforeOnsetInSec=50;
TimeToIncludeIntoCalculationInSec=50;

% GroupName={'Gr43a,RefedWS,1MSuc_AfRev','Gr43a,RefedWS,1MSuc_BfRev','Gr43a,St,1MSuc_AfRev','Gr43a,St,1MSuc_BfRev','Gr43a,St,100mMSuc_AfRev','Gr43a,St,100mMSuc_BfRev'};
GroupName={'Gr43a(Ho),St,1MSuc_30sBefRev,Verify','Gr43a(Ho),St,100mMSuc_30sBefRev,Verify','Gr43a(Ho),Fed,1MSuc_30sBefRev,Verify'};
% GroupName={'Gr43a,RefedWS,1MSuc','Gr43a,St,1MSuc','Gr43a,St,100mMSuc','Gr43a,RefedWS,100mMSuc'};
list_of_directories = {...
    'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,1MSuc,BefRev30s'...
    'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,100mMSuc,BefRev30s'...
    'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),RefedWS,1MSuc,BefRev30s'...
%     'C:\Users\zjucx\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,300mMSua'...
%     'C:\Users\zjucx\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,1MFru'...
%     'C:\Users\zjucx\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\PotentialRev\Gr43a,H2O,NSWD'...
% 'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),RefedWS,1MSuc,All\OutExc(Used'...
% 'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,1MSuc,All\OutExc(Used'...
% 'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,100mMSuc,All'...
% 'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),RefedWS,100mMSuc'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),RefedWS,1MSuc,AfRev'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),RefedWS,1MSuc,BefRev'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,1MSuc,AfRev'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,1MSuc,BefRev'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,100mMSuc,AfRev'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,100mMSuc,BefRev'...
};
TestModeOn1OrOff0=1; %This will change the output path, to avoid the issue that sometimes the output path length is too long that the xlsxwrite function doesn't work.
TestOutputPath={...
    'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,1MSuc,BefRev30s'...
    'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,100mMSuc,BefRev30s'...
    'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),RefedWS,1MSuc,BefRev30s'...
%     'C:\Users\zjucx\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,300mMSua'...
%     'C:\Users\zjucx\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,1MFru'...
%     'C:\Users\zjucx\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\PotentialRev\Gr43a,H2O,NSWD'...
% 'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),RefedWS,1MSuc,All\OutExc(Used'...
% 'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,1MSuc,All\OutExc(Used'...
% 'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,100mMSuc,All'...
% 'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),RefedWS,100mMSuc'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),RefedWS,1MSuc,AfRev'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),RefedWS,1MSuc,BefRev'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,1MSuc,AfRev'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,1MSuc,BefRev'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,100mMSuc,AfRev'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,100mMSuc,BefRev'...
};




for directory_idx  = 1:numel(list_of_directories)
    CurrentDir=list_of_directories{directory_idx};
    cd(CurrentDir);
    Folder1=list_of_directories{directory_idx};
    disp(sprintf('Processing %s',Folder1));
    CurFolderlist=dir(Folder1);
    
    DataFolderList=[];
    SyncDataFolderList=[];
    AllPosRespondedCBNoOfThisGroup=0;
    AllNegRespondedCBNoOfThisGroup=0;
    AllPosRespondedCBdFFOfThisGroup=[];
    AllNegRespondedCBdFFOfThisGroup=[];
    AllPosRespondedCBListOfThisGroup=[];
    AllNegRespondedCBListOfThisGroup=[];
    AllNotRespondedCBNoOfThisGroup=0;
    AllNotRespondedCBdFFOfThisGroup=[];
    AllNotRespondedCBListOfThisGroup=[];
    AllRecordedCBNoOfThisGroup=0;
    AllRecordedCBdFFOfThisGroup=[];
    AllRecordedCBListOfThisGroup=[];
    AllRespThreForThisGroup=[];
    %% ----------Decide which neuorns are responded neuorns--------
    CurDir2=strcat(CurrentDir,'\IngAdded\BindFFSeg');
    cd(CurDir2);
    DataList2=dir('*.xlsx');
    AlldFF=[];
    AllInd=[];
    AveragedPosRespDFFOfEachFly=[];
    AveragedNegRespDFFOfEachFly=[];

    GrandListOfPosRespondedCB=[];
    GrandListOfNegRespondedCB=[];
    GrandListOfNotRespondedCB=[];
    GranddFFSegOfPosRespondedCB=[];
    GranddFFSegOfNegRespondedCB=[];
    GranddFFSegOfNotRespondedCB=[];
    GrandListOfPosRespondedFly=[];
    ListOfAllFlyName=[];

    AllPosRespInd=[];
    PosRespCBCountInPosRespFly=[];
    PosRespCBCountInAllFly=[];
    for i3=1:length(DataList2)
        %------Read Data-------
        CurFileName=DataList2(i3).name;
        ListOfAllFlyName=[ListOfAllFlyName;{CurFileName}];
        CurDataPath=strcat(CurDir2,'\',CurFileName);
        [XlsxNum,XlsxText,XlsxAll]=xlsread(CurDataPath);
        
        %-------Decide responded neuorn number--------

        IndicatorColData=XlsxNum(:,end);
        AllInd=[AllInd,IndicatorColData];
        ROIDFFs=XlsxNum(:,1:end-1);
        AlldFF=[AlldFF,ROIDFFs];
        StimOnsetRowNo=min(find(IndicatorColData));%Here!! we are only considering the first eating bout as the onset of stimulus.
        StimOffsetRowNo=max(find(IndicatorColData));
        HowManyRowPerSec=size(XlsxNum,1)/TotalTimeSec;

        %-------Calculate basal dFF Mean And SD-----
        BasalDFFBeginRowNo=StimOnsetRowNo+HowManyRowPerSec*BasalDFFTimeBeginInSec;
        BasalDFFEndRowNo=StimOnsetRowNo+HowManyRowPerSec*BasalDFFTimeEndInSec;
        BasalDFFForAllROI=ROIDFFs(BasalDFFBeginRowNo:BasalDFFEndRowNo-1,:);
        BasalDFFMeanForAllROI=mean(BasalDFFForAllROI);
        BasalDFFSTDForAllROI=std(BasalDFFForAllROI);
        RespondThre=BasalDFFMeanForAllROI+RespThresFactor*BasalDFFSTDForAllROI;%Important! Here if RespThresFactor is set to 3, the Threshold for juding whether a cell is a "positive responded cell" or not will be its' mean basal dFF +- 3* dFF SD 
        AllRespThreForThisGroup=[AllRespThreForThisGroup,RespondThre];
        %-------Get Max And Min dFF during Ingestion
        ROIDFFs=XlsxNum(:,1:end-1);
        dFFDuringStim=ROIDFFs(StimOnsetRowNo:StimOffsetRowNo,:);

        ThisFlyTotalCBNo=size(dFFDuringStim,2);
        MaxdFFDuringStim=max(dFFDuringStim);
        MindFFDuringStim=min(dFFDuringStim);
        GreatestdFFDuringStim=zeros(size(MindFFDuringStim));
        %-------check which value is larger (max dFF or min dFF), and use the
        %largest one--------
        for i=1:size(MindFFDuringStim,2)
            if abs(MaxdFFDuringStim(i))>abs(MindFFDuringStim(i))
                GreatestdFFDuringStim(i)=MaxdFFDuringStim(i);
            else
                GreatestdFFDuringStim(i)=MindFFDuringStim(i);
            end
        end
        %------Or,Calculate the dFF mean and SD DURING ingestion-----
        MeandFFDuringStimForAllROI=mean(dFFDuringStim);
        SDdFFDuringStimForAllROI=std(dFFDuringStim);
        %------Decide whether this cell Positively responded or Neg resp or not----
        ListOfPosRespondedCB=[];
        ListOfNegRespondedCB=[];
        ListOfNotRespondedCB=[];
        GreatestdFFOfPosRespondedCB=[];
        GreatestdFFOfNegRespondedCB=[];
        GreatestdFFOfNotRespondedCB=[];
        ThisFlyPosRespondedCBCount=0;
        ThisFlyNegRespondedCBCount=0;
        ThisFlyNotRespondedCBCount=0;
        dFFSegOfPosRespondedCB=[];
        dFFSegOfNegRespondedCB=[];
        dFFSegOfNotRespondedCB=[];
        
        ThisFlyHasPosRespCB=0;%Reset before loop within fly between CBs
        %-------Check each CB within the fly------
        for i2=1:size(GreatestdFFDuringStim,2)
            CurrentCBName=strcat(CurFileName,'-',XlsxText{i2})
            CurrentFlyName=CurFileName;
            %-----Toggle the compare mode here-------
            if UseGreatestdFFDuringStim0OrUseMeandFFDuringStim1==1
                MinRangeToCompare=MeandFFDuringStimForAllROI-SDdFFDuringStimForAllROI*RespThresFactor;
                MaxRangeToCompare=MeandFFDuringStimForAllROI+SDdFFDuringStimForAllROI*RespThresFactor;
            elseif UseGreatestdFFDuringStim0OrUseMeandFFDuringStim1==0
                MinRangeToCompare=GreatestdFFDuringStim;
                MaxRangeToCompare=GreatestdFFDuringStim;
            else
                warndlg('UseGreatestdFFDuringStim0OrUseMeandFFDuringStim Must be set to 0 or 1!');
            end
        %-------Toggle finished, allocate cell bodies to each group------
                if MinRangeToCompare(i2)>=RespondThre(i2) %If this is true, classify this cell as "positively responded cell"
                    GrandListOfPosRespondedCB=[GrandListOfPosRespondedCB,{CurrentCBName}];
                    ListOfPosRespondedCB=[ListOfPosRespondedCB;XlsxText(i2)]; %#ok<AGROW> 
                    GreatestdFFOfPosRespondedCB=[GreatestdFFOfPosRespondedCB;GreatestdFFDuringStim(i2)];
                    ThisFlyPosRespondedCBCount=ThisFlyPosRespondedCBCount+1;
                    AllPosRespondedCBNoOfThisGroup=AllPosRespondedCBNoOfThisGroup+1;
                    AllPosRespondedCBdFFOfThisGroup=[AllPosRespondedCBdFFOfThisGroup;GreatestdFFDuringStim(i2)];
                    AllPosRespondedCBListOfThisGroup=[AllPosRespondedCBListOfThisGroup;{CurrentCBName}];
                    dFFSegOfPosRespondedCB=[dFFSegOfPosRespondedCB,ROIDFFs(:,i2)];
                    GranddFFSegOfPosRespondedCB=[GranddFFSegOfPosRespondedCB,ROIDFFs(:,i2)];
                    ThisFlyHasPosRespCB=1;
                elseif MaxRangeToCompare(i2)<=(RespondThre(i2)*(-1)) %If this is true, classify this cell as "negatively responded cell"
                    GrandListOfNegRespondedCB=[GrandListOfNegRespondedCB,{CurrentCBName}];
                    ListOfNegRespondedCB=[ListOfNegRespondedCB;XlsxText(i2)]; %#ok<AGROW> 
                    GreatestdFFOfNegRespondedCB=[GreatestdFFOfNegRespondedCB;GreatestdFFDuringStim(i2)];
                    ThisFlyNegRespondedCBCount=ThisFlyNegRespondedCBCount+1;
                    AllNegRespondedCBNoOfThisGroup=AllNegRespondedCBNoOfThisGroup+1;
                    AllNegRespondedCBdFFOfThisGroup=[AllNegRespondedCBdFFOfThisGroup;GreatestdFFDuringStim(i2)];
                    AllNegRespondedCBListOfThisGroup=[AllNegRespondedCBListOfThisGroup;{CurrentCBName}];
                    dFFSegOfNegRespondedCB=[dFFSegOfNegRespondedCB,ROIDFFs(:,i2)];
                    GranddFFSegOfNegRespondedCB=[GranddFFSegOfNegRespondedCB,ROIDFFs(:,i2)];
                else %Otherwise, this cell did not respond
                    GrandListOfNotRespondedCB=[GrandListOfNotRespondedCB,{CurrentCBName}];
                    ListOfNotRespondedCB=[ListOfNotRespondedCB;XlsxText(i2)]; %#ok<AGROW> 
                    GreatestdFFOfNotRespondedCB=[GreatestdFFOfNotRespondedCB;GreatestdFFDuringStim(i2)];
                    ThisFlyNotRespondedCBCount=ThisFlyNotRespondedCBCount+1;
                    AllNotRespondedCBNoOfThisGroup=AllNotRespondedCBNoOfThisGroup+1;
                    AllNotRespondedCBdFFOfThisGroup=[AllNotRespondedCBdFFOfThisGroup;GreatestdFFDuringStim(i2)];
                    AllNotRespondedCBListOfThisGroup=[AllNotRespondedCBListOfThisGroup;{CurrentCBName}];
                    dFFSegOfNotRespondedCB=[dFFSegOfNotRespondedCB,ROIDFFs(:,i2)];
                    GranddFFSegOfNotRespondedCB=[GranddFFSegOfNotRespondedCB,ROIDFFs(:,i2)];
                end
            AllRecordedCBNoOfThisGroup=AllRecordedCBNoOfThisGroup+1;
            AllRecordedCBdFFOfThisGroup=[AllRecordedCBdFFOfThisGroup;GreatestdFFDuringStim(i2)];
            AllRecordedCBListOfThisGroup=[AllRecordedCBListOfThisGroup;{CurrentCBName}]; %#ok<*AGROW> 
        end
        
        if ThisFlyHasPosRespCB==1
            GrandListOfPosRespondedFly=[GrandListOfPosRespondedFly,{CurFileName}];
            AllPosRespInd=[AllPosRespInd,IndicatorColData];
            PosRespCBCountInPosRespFly=[PosRespCBCountInPosRespFly,ThisFlyPosRespondedCBCount];
        end
        PosRespCBCountInAllFly=[PosRespCBCountInAllFly,ThisFlyPosRespondedCBCount];

        AveragedPosRespDFFOfThisFly=mean(dFFSegOfPosRespondedCB,2);
        AveragedPosRespDFFOfEachFly=[AveragedPosRespDFFOfEachFly,AveragedPosRespDFFOfThisFly];

        AveragedNegRespDFFOfThisFly=mean(dFFSegOfNegRespondedCB,2);
        AveragedNegRespDFFOfEachFly=[AveragedNegRespDFFOfEachFly,AveragedPosRespDFFOfThisFly];

        RatioOfPosRespondedCBInAllCB=ThisFlyPosRespondedCBCount/ThisFlyTotalCBNo;
        RatioOfNegRespondedCBInAllCB=ThisFlyNegRespondedCBCount/ThisFlyTotalCBNo;
    
        if TestModeOn1OrOff0==0
            PathToWrite=CurDir2;
        elseif TestModeOn1OrOff0==1
            PathToWrite=TestOutputPath{directory_idx};
        end
        cd(PathToWrite);
        if UseGreatestdFFDuringStim0OrUseMeandFFDuringStim1==0
            mkdir('Stats_Peak');
            NewCurPath=strcat(PathToWrite,'\Stats_Peak\');
        else
            mkdir('Stats_Mean');
            NewCurPath=strcat(PathToWrite,'\Stats_Mean\');
        end
        cd(NewCurPath);

        ListOfAllCB=XlsxText(1:end-1);
        ListOfAllCB=ListOfAllCB';
        GreatestdFFOfAllCB=num2cell(GreatestdFFDuringStim');
        XlsxToWritePath=strcat(NewCurPath,'Stats-',DataList2(i3).name);
        XlsxToWriteTitle=[{'ListOfAllCB'},{'GreatestdFFOfAllCB'},{'TotalCBNo'},...
            {'ResponseThreshold((Mean+-2xSD)OfBasalActivity(-30to0s))'},...
            {'ListOfPositivelyRespondedCB'},{'GreatestdFFOfPositivelyRespondedCB'},...
            {'PositivelyRespondedCBCount'},{'RatioOfPositivelyRespondedCBInAllCB'},...
            {'ListOfNegativelyRespondedCB'},{'GreatestdFFOfNegativelyRespondedCB'},...
            {'NegativelyRespondedCBCount'},{'RatioOfNegativelyRespondedCBInAllCB'}];
        xlswrite(XlsxToWritePath,XlsxToWriteTitle,1,'A1');
        xlswrite(XlsxToWritePath,ListOfAllCB,1,'A2');
        xlswrite(XlsxToWritePath,GreatestdFFOfAllCB,1,'B2');
        xlswrite(XlsxToWritePath,num2cell(ThisFlyTotalCBNo),1,'C2');
        xlswrite(XlsxToWritePath,num2cell(RespondThre'),1,'D2');
        if size(ListOfPosRespondedCB,1)>0
            xlswrite(XlsxToWritePath,ListOfPosRespondedCB,1,'E2');
            xlswrite(XlsxToWritePath,num2cell(GreatestdFFOfPosRespondedCB),1,'F2');
            xlswrite(XlsxToWritePath,num2cell(ThisFlyPosRespondedCBCount),1,'G2');
            xlswrite(XlsxToWritePath,num2cell(RatioOfPosRespondedCBInAllCB),1,'H2');
%             XlsxToWriteTitlePage2=[{'CB1'},{'Activity'},{'TotalCBNo'},...
%             {'ResponseThreshold((Mean+-2xSD)OfBasalActivity(-30to0s))'},...];
%             xlswrite(XlsxToWritePath,num2cell() 2,'A2');
        end
        if size(ListOfNegRespondedCB,1)>0
            xlswrite(XlsxToWritePath,ListOfNegRespondedCB,1,'I2');
            xlswrite(XlsxToWritePath,num2cell(GreatestdFFOfNegRespondedCB),1,'J2');
            xlswrite(XlsxToWritePath,num2cell(ThisFlyNegRespondedCBCount),1,'K2');
            xlswrite(XlsxToWritePath,num2cell(RatioOfNegRespondedCBInAllCB),1,'L2');
        end

        save(strcat(XlsxToWritePath(1:end-5),'.mat'));

    end
    %-----PlotPieChart--------
%     NotPositivelyRespondedCBNoOfThisGroup=AllRecordedCBNoOfThisGroup-AllPosRespondedCBNoOfThisGroup;
%     DataForPie=[NotPositivelyRespondedCBNoOfThisGroup,AllPosRespondedCBNoOfThisGroup];
%     fig2=figure;
% %     pie(DataForPie,'%.2f%%')
%     pie(DataForPie)
%        set(fig2, 'Units', 'Inches', 'Position', [0, 0, 3, 3], 'PaperUnits', 'Inches', 'PaperSize', [3, 3]);
%     labels={'Not Pos Responded','Pos Responded'};
%     lgd=legend(labels,'Location','northeast');
%     title(CurDir2);
%     
%     savefig(strcat('StatPieChart','.fig'));
%     print(fig2, 'StatPieChart','-dpng','-r0');
%     print(fig2, 'StatPieChart','-dsvg','-r0');


% Data for pie chart
NotPositivelyRespondedCBNoOfThisGroup = AllRecordedCBNoOfThisGroup - AllPosRespondedCBNoOfThisGroup;
DataForPie = [NotPositivelyRespondedCBNoOfThisGroup, AllPosRespondedCBNoOfThisGroup];

% Create figure
fig2 = figure;
% Plot the pie chart
h = pie(DataForPie);

% Calculate percentages and add them as labels on the pie chart
percentages = round(DataForPie / sum(DataForPie) * 100, 1);  % Calculate percentages
labels = strcat(cellstr(num2str(percentages')), '%');  % Create labels with percentage

% Update pie chart to include percentage labels and adjust positions
for k = 1:length(h)/2
    % Assign each slice a label (percentage)
    h(2*k).String = labels{k};
    
    % Set color of the percentage labels
    textObj = h(2*k);  % Get the text object
    if k == 1
        textObj.Color = 'white';  % Set first group label color to white
    else
        textObj.Color = 'black';  % Set second group label color to black
    end
    
    % Adjust label position to be on the pie slice (instead of outside)
    theta = h(2*k).Position;  % Get the current label's position (polar coordinates)
    
    % Scale the radius to half its original value
    theta(1:2) = theta(1:2) * 0.28;  % Adjust radius to half
    
    % Set the adjusted position for the label
    h(2*k).Position = theta;  % Move the label closer to the center
end

% Set figure size
set(fig2, 'Units', 'Inches', 'Position', [0, 0, 3, 3], 'PaperUnits', 'Inches', 'PaperSize', [3, 3]);

% Create legend and move it below the pie chart
labels = {'Not Pos Responded', 'Pos Responded'};
lgd = legend(labels, 'Location', 'southoutside');  % Move legend below pie chart
lgd.Box = 'off';  % Optional: remove the legend box

% Set title
title(GroupName(directory_idx));

% Save the figure
savefig(strcat('StatPieChart','.fig'));
print(fig2, 'StatPieChart','-dpng','-r0');
print(fig2, 'StatPieChart','-dsvg','-r0');


    %-----WriteSummaryOfThisGroup
    XlsxToWritePath=strcat(NewCurPath,'StatSum-',GroupName{directory_idx},'.xlsx');
    XlsxToWriteTitle=[{'NoOfAllRecordedCBOfThisGroup'},{'AllRecordedCBListOfThisGroup'},{'AllRecordedCBPeakdFFDuringStimOfThisGroup'},...
        {'dFFThresholdFactor(dFF Threshold=Mean Of Basal dFF vector +- (dFF Threshold Factor * SD of Basal dFF vector))'},{'dFFThresholdForAllRecordedCB'}...
        {'NoOfAllPositivelyRespondedCBOfThisGroup'},{'AllPositivelyRespondedCBListOfThisGroup'},{'AllPositivelyRespondedCBPeakdFFDuringStimOfThisGroup'},...
        {'NoOfAllNegativelyRespondedCBOfThisGroup'},{'AllNegativelyRespondedCBListOfThisGroup'},{'AllNegativelyRespondedCBPeakdFFDuringStimOfThisGroup'},...
        {'NoOfAllNotRespondedCBOfThisGroup'},{'AllNotRespondedCBListOfThisGroup'},{'AllNotRespondedCBPeakdFFDuringStimOfThisGroup'}];
    xlswrite(XlsxToWritePath,XlsxToWriteTitle,1,'A1');
    xlswrite(XlsxToWritePath,num2cell(AllRecordedCBNoOfThisGroup),1,'A2');
    xlswrite(XlsxToWritePath,AllRecordedCBListOfThisGroup,1,'B2');
    xlswrite(XlsxToWritePath,AllRecordedCBdFFOfThisGroup,1,'C2');

    xlswrite(XlsxToWritePath,num2cell(RespThresFactor),1,'D2');
    xlswrite(XlsxToWritePath,num2cell(AllRespThreForThisGroup'),1,'E2');

    if AllPosRespondedCBNoOfThisGroup>0
    xlswrite(XlsxToWritePath,num2cell(AllPosRespondedCBNoOfThisGroup),1,'F2');
    xlswrite(XlsxToWritePath,AllPosRespondedCBListOfThisGroup,1,'G2');
    xlswrite(XlsxToWritePath,AllPosRespondedCBdFFOfThisGroup,1,'H2');
    end
    if AllNegRespondedCBNoOfThisGroup>0
    xlswrite(XlsxToWritePath,num2cell(AllNegRespondedCBNoOfThisGroup),1,'I2');
    xlswrite(XlsxToWritePath,AllNegRespondedCBListOfThisGroup,1,'J2');
    xlswrite(XlsxToWritePath,AllNegRespondedCBdFFOfThisGroup,1,'K2');
    end
    if AllNotRespondedCBNoOfThisGroup>0
    xlswrite(XlsxToWritePath,num2cell(AllNotRespondedCBNoOfThisGroup),1,'L2');
    xlswrite(XlsxToWritePath,AllNotRespondedCBListOfThisGroup,1,'M2');
    xlswrite(XlsxToWritePath,AllNotRespondedCBdFFOfThisGroup,1,'N2');
    end
    XlsxToWriteTitlePage2=[{'Ratio Of Positively Responded CB In All RecordedCB'};...
        {'Ratio Of Negatively Responded CB In All Recorded CB'};...
        {'Ratio Of Not Responded CB In All Recorded CB'};...
        {'Ratio Of Non-Positively Responded CB In All Recorded CB'};...
        {'Ratio Of Non-Negatively Responded CB In All Recorded CB'};...
        {'Ratio Of Any Responded CB In All Recorded CB'}];
    RatioPosOverAll=AllPosRespondedCBNoOfThisGroup/AllRecordedCBNoOfThisGroup;
    RatioNegOverAll=AllNegRespondedCBNoOfThisGroup/AllRecordedCBNoOfThisGroup;
    RatioNotRespOverAll=AllNotRespondedCBNoOfThisGroup/AllRecordedCBNoOfThisGroup;
    RatioNonPosOverAll=1-RatioPosOverAll;
    RatioNonNegOverAll=1-RatioNegOverAll;
    RatioAnyRespOverAll=1-RatioNotRespOverAll;
    DataToWrite=[RatioPosOverAll;RatioNegOverAll;RatioNotRespOverAll;RatioNonPosOverAll;RatioNonNegOverAll;RatioAnyRespOverAll];
    
%     xlswrite(XlsxToWritePath,XlsxToWriteTitlePage2,2,'A1');
    writecell(XlsxToWriteTitlePage2, XlsxToWritePath, 'Sheet', 2, 'Range', 'A1');
%     xlswrite(XlsxToWritePath,num2cell(DataToWrite),2,'B1');
    writecell(num2cell(DataToWrite), XlsxToWritePath, 'Sheet', 2, 'Range', 'B1');
    
    DataToWrite2=num2cell(PosRespCBCountInAllFly');
    TextToWrite2=ListOfAllFlyName;
    XlsxToWrite2=[TextToWrite2,DataToWrite2];
    writecell(XlsxToWrite2, XlsxToWritePath, 'Sheet', 'PosRespCBCountInEachFly', 'Range', 'A1');

%% -----Get Average dFF of responded neuron in each fly, plot averaged dFF curve across fly.
%-------Plot averaged dFF of all Pos Responded Neurons----
%-------Mean with SeparateTrials------
Tracesfig1=figure();
FinalX=[(-1)*TimeStartBeforeStim:1:TimeStopAfterStim-1];

    yyaxis right
    StepRatio=1/size(AllPosRespInd,2);
    AllPosRespIndLength=sum(AllPosRespInd);
    [sorted,sortRefNo]=sort(AllPosRespIndLength,'descend');
    for i=1:size(sortRefNo,2)
        IndToPlot=AllPosRespInd(:,sortRefNo(i));
        IngTime=sum(IndToPlot);
        HeightToPlot=(StepRatio*i)*BoutIndicatorMaxYHeightRatio;
        xb1=[0 0 IngTime IngTime];
        yb1=[0 HeightToPlot HeightToPlot 0];
        b1=patch(xb1,yb1,'k');
        hold on
        b1.FaceColor=SetColorSpec{sortRefNo(i)};
        b1.FaceAlpha=0.15;
        b1.EdgeAlpha=0;
        b1.EdgeColor='none';
    end
      
ylabel('Putative Ingestion Bout');
ylim([0,1]);

yyaxis left
for i=1:size(AveragedPosRespDFFOfEachFly,2)
    p1=plot(FinalX,AveragedPosRespDFFOfEachFly(:,i),'-','Color',SetColorSpec{i},'LineWidth',1.5);
    hold on
    for i2=1:PosRespCBCountInPosRespFly(i)
        ColNoOfSpecificCBToPlot=sum(PosRespCBCountInPosRespFly(1:i-1))+i2;
        p3=plot(FinalX,GranddFFSegOfPosRespondedCB(:,ColNoOfSpecificCBToPlot),...
            '-','Color',SetColorSpec{i},'LineWidth',0.3);
        hold on
    end
end
p2=plot(FinalX,mean(AveragedPosRespDFFOfEachFly,2),'-','Color',[0 0 0],'LineWidth',1.5);

xlabel('Time(s)');
ylabel('\DeltaF/F');

savefig(strcat('AveragedPosRespDFFOfEachFly_SeparateTrials','.fig'));
print(Tracesfig1, 'AveragedPosRespDFFOfEachFly_SeparateTrials','-dpng','-r0');
print(Tracesfig1, 'AveragedPosRespDFFOfEachFly_SeparateTrials','-dsvg','-r0');
%-------Write all data being Plotted------
TitleOfAllCellPlotted=GrandListOfPosRespondedCB;
DataOfAllCellPlotted=num2cell(GranddFFSegOfPosRespondedCB);
AllToWrite=[TitleOfAllCellPlotted;DataOfAllCellPlotted];
writecell(AllToWrite, XlsxToWritePath, 'Sheet', 'PosRespdFFSeg', 'Range', 'A1');
TitleOfAllFlyPlotted=GrandListOfPosRespondedFly;
DataOfAllFlyPlotted=num2cell(AveragedPosRespDFFOfEachFly);
AllToWriteMeanWithinFly=[TitleOfAllFlyPlotted;DataOfAllFlyPlotted];
writecell(AllToWriteMeanWithinFly, XlsxToWritePath, 'Sheet', 'MeanPosRespdFFWithinFly', 'Range', 'A1');
AllPosRespIndToWrite=num2cell(AllPosRespInd);
AllToWritePlottedIngInd=[TitleOfAllFlyPlotted;AllPosRespIndToWrite];
writecell(AllToWritePlottedIngInd, XlsxToWritePath, 'Sheet', 'PlottedPosRespIngInd', 'Range', 'A1');
TitleColToWrite=[];
DataColToWrite=[];
for i3=1:length(PosRespCBCountInPosRespFly)
    for i4=1:PosRespCBCountInPosRespFly(i3)
        TempColInd=sum(PosRespCBCountInPosRespFly(1:i3))-PosRespCBCountInPosRespFly(i3)+i4
        TitleColToWrite=[TitleColToWrite,GrandListOfPosRespondedCB(TempColInd)];
        DataColToWrite=[DataColToWrite,DataOfAllCellPlotted(:,TempColInd)];
        if i4==PosRespCBCountInPosRespFly(i3)
            TitleColToWrite=[TitleColToWrite,{strcat('IngInd-',GrandListOfPosRespondedCB{TempColInd})}];
            DataColToWrite=[DataColToWrite,AllPosRespIndToWrite(:,i3)];
        end
    end
end
AllToWrite=[TitleColToWrite;DataColToWrite];
writecell(AllToWrite, XlsxToWritePath, 'Sheet', 'PosRespdFFSeg&IngInd', 'Range', 'A1');
%% ----------Plot each fly separately--------
% Create a folder to save the figures
outputFolder = 'NeuronSepFig';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

FinalX = [(-1) * TimeStartBeforeStim : 1 : TimeStopAfterStim - 1];

% Loop through all Flys
for i = 1 : size(AveragedPosRespDFFOfEachFly, 2)
    % Loop through all neurons in the current Fly
    for i2 = 1 : PosRespCBCountInPosRespFly(i)
        % Calculate the column number for the current neuron
        ColNoOfSpecificCBToPlot = sum(PosRespCBCountInPosRespFly(1 : i - 1)) + i2;
        
        % Create a new figure for this neuron
        NeuronFig = figure();
        
        % Plot the neuron's response (left y-axis)
        yyaxis left;
        plot(FinalX, GranddFFSegOfPosRespondedCB(:, ColNoOfSpecificCBToPlot), ...
            '-', 'Color', 'k', 'LineWidth', 1.5);
        hold on;
        
        % Plot the Fly mean (dashed line for reference)
        plot(FinalX, AveragedPosRespDFFOfEachFly(:, i), '--', ...
            'Color', 'k', 'LineWidth', 2);
        ylabel('\DeltaF/F');
        set(gca, 'YColor', 'k');
        
        % Plot putative ingestion bout (right y-axis)
        yyaxis right;
        IndToPlot = AllPosRespInd(:, i);
        IngTime = sum(IndToPlot);
        StepRatio = 1 / size(AllPosRespInd, 2);
        HeightToPlot = BoutIndicatorMaxYHeightRatio;
        xb1 = [0 0 IngTime IngTime];
        yb1 = [0 HeightToPlot HeightToPlot 0];
        b1 = patch(xb1, yb1, 'k');
        b1.FaceColor = 'k';
        b1.FaceAlpha = 0.15;
        b1.EdgeAlpha = 0;
        b1.EdgeColor = 'none';
        ylabel('Putative Ingestion Bout');
        ylim([0, 1]);
        
        % Add labels and title
        xlabel('Time (s)');
        title(sprintf('Neuron %d in Fly %d', i2, i));
        
        % Adjust ticks, axes colors, and remove the top border
        set(gca, 'box', 'off', 'TickDir', 'out', 'XColor', 'k', 'YColor', 'k');
        
        % Save the figure in the created folder
        savefig(NeuronFig, fullfile(outputFolder, sprintf('Neuron_Fly%d_Neuron%d.fig', i, i2)));
        print(NeuronFig, fullfile(outputFolder, sprintf('Neuron_Fly%d_Neuron%d', i, i2)), '-dpng', '-r0');
        print(NeuronFig, fullfile(outputFolder, sprintf('Neuron_Fly%d_Neuron%d', i, i2)), '-dsvg', '-r0');
        
        % Close the figure to save memory
        close(NeuronFig);
    end

    % Create a summary figure for the current Fly
    FlyFig = figure();
    
    % Plot all individual neurons in the Fly (left y-axis)
    yyaxis left;
    for i2 = 1 : PosRespCBCountInPosRespFly(i)
        ColNoOfSpecificCBToPlot = sum(PosRespCBCountInPosRespFly(1 : i - 1)) + i2;
        plot(FinalX, GranddFFSegOfPosRespondedCB(:, ColNoOfSpecificCBToPlot), ...
            '-', 'Color', 'k', 'LineWidth', 0.5); % Black lines for individual neurons
        hold on;
    end
    
    % Plot the Fly mean response (thicker line)
    plot(FinalX, AveragedPosRespDFFOfEachFly(:, i), '--', ...
        'Color', 'k', 'LineWidth', 2);
    ylabel('\DeltaF/F');
    set(gca, 'YColor', 'k');
    
    % Plot putative ingestion bout (right y-axis)
    yyaxis right;
    IndToPlot = AllPosRespInd(:, i);
    IngTime = sum(IndToPlot);
    HeightToPlot = BoutIndicatorMaxYHeightRatio;
    xb1 = [0 0 IngTime IngTime];
    yb1 = [0 HeightToPlot HeightToPlot 0];
    b1 = patch(xb1, yb1, 'k');
        b1.FaceColor = 'k';
        b1.FaceAlpha = 0.15;
        b1.EdgeAlpha = 0;
        b1.EdgeColor = 'none';
    ylabel('Putative Ingestion Bout');
    ylim([0, 1]);
    
    % Add labels and title
    xlabel('Time (s)');
    title(sprintf('Summary for Fly %d', i));
    
    % Adjust ticks, axes colors, and remove the top border
    set(gca, 'box', 'off', 'TickDir', 'out', 'XColor', 'k', 'YColor', 'k');
    
    % Save the Fly summary figure
    savefig(FlyFig, fullfile(outputFolder, sprintf('Fly%d_Summary.fig', i)));
    print(FlyFig, fullfile(outputFolder, sprintf('Fly%d_Summary', i)), '-dpng', '-r0');
    print(FlyFig, fullfile(outputFolder, sprintf('Fly%d_Summary', i)), '-dsvg', '-r0');
    
    % Close the figure to save memory
    close(FlyFig);
end

%% -------Plot Mean +- SEM figure-------

Tracesfig2=figure();

yyaxis right
    StepRatio=1/size(AllPosRespInd,2);
    AllPosRespIndLength=sum(AllPosRespInd);
    [sorted,sortRefNo]=sort(AllPosRespIndLength,'descend');
    for i=1:size(sortRefNo,2)
        IndToPlot=AllPosRespInd(:,sortRefNo(i));
        IngTime=sum(IndToPlot);
        HeightToPlot=(StepRatio*i)*BoutIndicatorMaxYHeightRatio;
        xb1=[0 0 IngTime IngTime];
        yb1=[0 HeightToPlot HeightToPlot 0];
        b1=patch(xb1,yb1,'k');
        hold on
%         b1.FaceColor=SetColorSpec{sortRefNo(i)};
        b1.FaceAlpha=0.15;
        b1.EdgeAlpha=0;
        b1.EdgeColor='none';
    end
      
ylabel('Proboscis Touching');
ylim([0,1]);
    ax1 = gca;                   % gca = get current axis
    ax1.YAxis(2).Visible = 'off';   % remove y-axis
    yticks([]);


yyaxis left
FinalX=[(-1)*TimeStartBeforeStim:1:TimeStopAfterStim-1];
SEMOfResponse=std(AveragedPosRespDFFOfEachFly,[],2)./sqrt(size(AveragedPosRespDFFOfEachFly,2));
s=shadedErrorBar(FinalX,mean(AveragedPosRespDFFOfEachFly,2),SEMOfResponse,'lineProps','k');

set(Tracesfig2, 'Units', 'Inches', 'Position', [0, 0, FigureWidth, FigureHeight], 'PaperUnits', 'Inches', 'PaperSize', [12, 3.5]);
set(gca,'TickDir','out');
set(gca,'YColor','k');

xlabel('Time(s)');
ylabel('\DeltaF/F');
ylim(YLimSetting);

savefig(strcat('AveragedPosRespDFFOfEachFly_Mean+-SEM','.fig'));
print(Tracesfig2, 'AveragedPosRespDFFOfEachFly_Mean+-SEM','-dpng','-r0');
print(Tracesfig2, 'AveragedPosRespDFFOfEachFly_Mean+-SEM','-dsvg','-r0');
save('CalcInfo.mat');

%% ----------Calculate persistency-----------
%Goal: Find the total time duration in the x axis that has a dFF y value
%higher than (0.5*peak dFF during ingsetion).

PersistencyStatWritePath=strcat(NewCurPath,'PersStat-',GroupName{directory_idx},'.xlsx');
%% -------Calcualte persistency5 (time above threshold) for each positively responded cell-----------
PersistencyThresVal5CB=PersistencyThresholdFactor*AllPosRespondedCBdFFOfThisGroup;

AllPosRespCBPersistency5=[];
for i=1:length(PersistencyThresVal5CB)
    SegmentToCompare=GranddFFSegOfPosRespondedCB(TimeBeforeOnsetInSec+1: ...
        TimeBeforeOnsetInSec+TimeToIncludeIntoCalculationInSec,i);
    AllPosRespCBPersistency5=[AllPosRespCBPersistency5;length( ...
        find(SegmentToCompare>=PersistencyThresVal5CB(i)))];
end

GrandTitle3=[{'CB Name (Trial Name+CB Name)'},{'Persistency In Second (=total time duration of dFF value higher than threshold value shown on the next page)'}];
DataToWrite3=num2cell(AllPosRespCBPersistency5);
TitleToWrite3=GrandListOfPosRespondedCB';
AllToWrite3=[GrandTitle3;TitleToWrite3,DataToWrite3];
writecell(AllToWrite3, PersistencyStatWritePath, 'Sheet', 'Persistency_CB');
TitleToWrite5=[{'Name Of Positively Responded CB (GrandListOfPosRespondedCB)'},...
    {'CB PeakdFF during ingesion(AllPosRespondedCBdFFOfThisGroup)'},...
    {'PersistencyThresholdFactor'},...
    {'Threshold Value For Each Cell Body (=PersistencyThresholdFactor*CB PeakdFF during ingesion) (PersistencyThresValCB)'}];
DataToWrite5=[GrandListOfPosRespondedCB',...
    num2cell(AllPosRespondedCBdFFOfThisGroup),...
    num2cell(repmat(PersistencyThresholdFactor,size(AllPosRespondedCBdFFOfThisGroup,1),1)),...
    num2cell(PersistencyThresVal5CB)];
AllToWrite5=[TitleToWrite5;DataToWrite5];
writecell(AllToWrite5, PersistencyStatWritePath, 'Sheet', 'Persistency_CB_Para');
%% -------Calculate CB Persistency 6 (1st falling edge time post-peak - 1st rising edge time post-ing onset)-----------
%-----calculate peak width = falling half life - rising half life-----
HalfPeakdFFOfAllCB=0.5*AllPosRespondedCBdFFOfThisGroup; %AllPosRespondedCBdFFOfThisGroup is the peak dFF DURUING INGESTION for each fly

AllCBWidthOfFirstPeak=[];
for i=1:size(GranddFFSegOfPosRespondedCB,2)
    SegmentToCompare=GranddFFSegOfPosRespondedCB(TimeBeforeOnsetInSec+1: ...
    TimeBeforeOnsetInSec+TimeToIncludeIntoCalculationInSec,i);

    CBdFFSegAboveHalfPeak=zeros(size(SegmentToCompare));
    dFFRowListToKeep=find(SegmentToCompare>=HalfPeakdFFOfAllCB(i));
    CBdFFSegAboveHalfPeak(dFFRowListToKeep)=SegmentToCompare(dFFRowListToKeep);

    zeroRow=zeros(1,size(CBdFFSegAboveHalfPeak,2));
    ZeroPlusdFFSegAboveHalfPeak=[zeroRow;CBdFFSegAboveHalfPeak;zeroRow];%Adding one extra row of zeros at the beginnin and end of the dFFSegmentToCompare so that the later algorithem which detects the rising and falling edge by "0"s will be gurateed to work

    RowNoOfZeros=[];
    RowNoOfZeros=find(ZeroPlusdFFSegAboveHalfPeak==0);

    %---------Detect the RisingEdges and FallingEdges--------
    RisingEdgeList=[];
    FallingEdgeList=[];
    for j=1:length(RowNoOfZeros)-1
        if RowNoOfZeros(j+1)-RowNoOfZeros(j)>1
            RisingEdgeList=[RisingEdgeList,RowNoOfZeros(j)];
            FallingEdgeList=[FallingEdgeList,RowNoOfZeros(j+1)-1];%Notice: Because of this row of code, the evental calculation result for peak width will be equivalent to (the row number taht the y value falls below half peak for the first time- the row number the y value rise above the half peak for the first time)
        end
    end
    [PeakFlydFFVal,PeakFlydFFXRowNo]=max(SegmentToCompare);
    for i=1:length(FallingEdgeList)
        if FallingEdgeList(i)>PeakFlydFFXRowNo
            WidthOfPeak=FallingEdgeList(i)-RisingEdgeList(1);
            break
        end
    end
    AllCBWidthOfFirstPeak=[AllCBWidthOfFirstPeak;WidthOfPeak];
end

TitleToWrite7={'CB Name',...
    'CB Persistency 6 (Time of 1st falling edge after peak - Time of 1st rising edge after ingestion onset) (Rising/Falling Edge determined by half peak dFF)'};
DataToWrite7=[GrandListOfPosRespondedCB',...
    num2cell(AllCBWidthOfFirstPeak)];
AllToWrite7=[TitleToWrite7;DataToWrite7];
writecell(AllToWrite7, PersistencyStatWritePath, 'Sheet', 'CB_Persistency6');

%% -------Calcualte persistency 5 for each positively responded fly (time duration above 0.5*peak dFF during ignestion) after ingestion onset-----------
%-----Find peak dFF of the mean dFF across all different positively
%responded cell bodies within each fly----------
MaxFlydFFDuringStim=[];
MinFlydFFDuringStim=[];
GreatestFlydFFDuringStim=[];
    %-------Get Max And Min dFF during Ingestion
    for i=1:size(AllPosRespInd,2)
        StimOnsetRowNo=min(find(AllPosRespInd(:,i)));
        StimOffSetRowNo=max(find(AllPosRespInd(:,i)));
        FlydFFDuringStim=AveragedPosRespDFFOfEachFly(StimOnsetRowNo:StimOffsetRowNo,i);
        MaxFlydFFDuringStim=[MaxFlydFFDuringStim;max(FlydFFDuringStim)];
        MinFlydFFDuringStim=[MinFlydFFDuringStim;min(FlydFFDuringStim)];;
        %-------check which value is larger (max dFF or min dFF), and use the
        %largest one--------
        if abs(MaxFlydFFDuringStim)>abs(MinFlydFFDuringStim)
            GreatestFlydFFDuringStim=[GreatestFlydFFDuringStim;MaxFlydFFDuringStim(i)];
        else
            GreatestFlydFFDuringStim=[GreatestFlydFFDuringStim;MinFlydFFDuringStim(i)];
        end
    end
%---------Calculate Persistency For Each Fly (averaged across cells)------
PersistencyThresValForFly=PersistencyThresholdFactor*GreatestFlydFFDuringStim;

AllPosRespFlyPersistency=[];
for i=1:length(PersistencyThresValForFly)
    SegmentToCompare=AveragedPosRespDFFOfEachFly(TimeBeforeOnsetInSec+1: ...
        TimeBeforeOnsetInSec+TimeToIncludeIntoCalculationInSec,i);
    AllPosRespFlyPersistency=[AllPosRespFlyPersistency;length( ...
        find(SegmentToCompare>=PersistencyThresValForFly(i)))];
end

GrandTitle4=[{'Fly Name (Equivalent to Trial Name)'},{'Persistency In Second (=total time duration of dFF value higher than threshold value shown on the next page)'}];
DataToWrite4=num2cell(AllPosRespFlyPersistency);
TitleToWrite4=GrandListOfPosRespondedFly';
AllToWrite4=[GrandTitle4;TitleToWrite4,DataToWrite4];
writecell(AllToWrite4, PersistencyStatWritePath, 'Sheet', 'Persistency_Fly');

TitleToWrite6=[{'Name Of Positively Responded Fly (GrandListOfPosRespondedFly)'},...
    {'Fly PeakdFF during ingesion(GreatestFlydFFDuringStim)'},...
    {'PersistencyThresholdFactor'},...
    {'Threshold Value For Each Fly (=PersistencyThresholdFactor*Fly PeakdFF during ingesion) (PersistencyThresValForFly)'}];
DataToWrite6=[GrandListOfPosRespondedFly',...
    num2cell(GreatestFlydFFDuringStim),...
    num2cell(repmat(PersistencyThresholdFactor,size(GreatestFlydFFDuringStim,1),1)),...
    num2cell(PersistencyThresValForFly)];
AllToWrite6=[TitleToWrite6;DataToWrite6];
writecell(AllToWrite6, PersistencyStatWritePath, 'Sheet', 'Persistency_Fly_Para');

%% -------Calculate Fly Persistency 6 (1st falling edge time post-peak - 1st rising edge time post-ing onset)-----------
%-----calculate peak width = falling half life - rising half life-----
HalfPeakdFFOfAllFly=0.5*GreatestFlydFFDuringStim;

AllFlyWidthOfPeak=[];
for i=1:size(AveragedPosRespDFFOfEachFly,2)
    SegmentToCompare=AveragedPosRespDFFOfEachFly(TimeBeforeOnsetInSec+1: ...
    TimeBeforeOnsetInSec+TimeToIncludeIntoCalculationInSec,i);

    FlydFFSegAboveHalfPeak=zeros(size(SegmentToCompare));
    dFFRowListToKeep=find(SegmentToCompare>=HalfPeakdFFOfAllFly(i));
    FlydFFSegAboveHalfPeak(dFFRowListToKeep)=SegmentToCompare(dFFRowListToKeep);

    zeroRow=zeros(1,size(FlydFFSegAboveHalfPeak,2));
    ZeroPlusdFFSegAboveHalfPeak=[zeroRow;FlydFFSegAboveHalfPeak;zeroRow];%Adding one extra row of zeros at the beginnin and end of the dFFSegmentToCompare so that the later algorithem which detects the rising and falling edge by "0"s will be gurateed to work

    RowNoOfZeros=[];
    RowNoOfZeros=find(ZeroPlusdFFSegAboveHalfPeak==0);

    %---------Detect the RisingEdges and FallingEdges--------
    RisingEdgeList=[];
    FallingEdgeList=[];
    for j=1:length(RowNoOfZeros)-1
        if RowNoOfZeros(j+1)-RowNoOfZeros(j)>1
            RisingEdgeList=[RisingEdgeList,RowNoOfZeros(j)];
            FallingEdgeList=[FallingEdgeList,RowNoOfZeros(j+1)-1];%Notice: Because of this row of code, the evental calculation result for peak width will be equivalent to (the row number taht the y value falls below half peak for the first time- the row number the y value rise above the half peak for the first time)
        end
    end
    [PeakFlydFFVal,PeakFlydFFXRowNo]=max(SegmentToCompare);
    for i=1:length(FallingEdgeList)
        if FallingEdgeList(i)>PeakFlydFFXRowNo
            WidthOfPeak=FallingEdgeList(i)-RisingEdgeList(1);
            break
        end
    end
    AllFlyWidthOfPeak=[AllFlyWidthOfPeak;WidthOfPeak];
end

TitleToWrite8={'Fly Trial Name',...
    'Fly Persistency 6 (Time of 1st falling edge after peak - Time of 1st rising edge after ingestion onset) (Rising/Falling Edge determined by half MAX dFF)'};
DataToWrite8=[GrandListOfPosRespondedFly',...
    num2cell(AllFlyWidthOfPeak)];
AllToWrite8=[TitleToWrite8;DataToWrite8];
writecell(AllToWrite8, PersistencyStatWritePath, 'Sheet', 'Fly_Persistency6');

end  