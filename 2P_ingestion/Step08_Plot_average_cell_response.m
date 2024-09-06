%% ======Calculate responded neuorn population and calculate averaged (average among responded neuorns) peak dFF for each fly for ingestion Imaging experiments===
%% ======Use after the PlotAvgIngResp_part1 cutting the responses to dFF segments that only contains the first ingestion bout=======

clear all
clc

TestModeOn1OrOff0=1; %This will change the output path, to avoid the issue that sometimes the output path length is too long that the xlsxwrite function doesn't work.
TestOutputPath='F:\666ScriptTest2024Aug26\TestPlotResults';

UseGreatestdFFDuringStim0OrUseMeandFFDuringStim1=0;
% YLimSetting=[-0.2,0.5];% Y limit setting for the Mean+-SEM figure
YLimSetting=[-0.2,0.5];% Y limit setting for the Mean+-SEM figure
FigureWidth=5;
FigureHeight=5;
BoutIndicatorMaxYHeightRatio=0.2;
TimeLengthOf1stBoutCuts_Min=0;%Change here!!
TimeLengthOf1stBoutCuts_Sec=60;%Change here!!
RespThresFactor=3;%If this factor is set to 2, the dFF threshold factor used to decide which neurons will be counted as "responded neurons" will be mean of the dFF in the basal time window+ (that factor)*standart deviation of the dFF in the basal time window
BasalDFFTimeBeginInSec=-30;%The minus or plus here is relative to the ingestion bout onset (the onset will be time 0)
BasalDFFTimeEndInSec=0;%The minus or plus here is relative to the ingestion bout onset (the onset will be time 0)
TotalTimeSec=TimeLengthOf1stBoutCuts_Min*60+TimeLengthOf1stBoutCuts_Sec;
SetColorSpec={[0, 0, 1];[0,1,0];[0.6, 0.8250, 0.280];[0.9290, 0.6940, 0.5250];[0.4940, 0.1840, 0.5560];[0.75, 0.5, 0.75];...
    [0.660, 0.8740, 0.480];[0, 0.5, 0.16];[0.5010, 0.7450, 0.9330];[0.6350, 0.0780, 0.2840];[0.6350, 0.0780, 0.55];[0.6350, 0.0780, 0.3];[0.6350, 0.2, 0.55];[0.6350, 0.2780, 0.65];[0.9350, 0.0780, 0.55];[0.8350, 0.780, 0.55];[0.8500, 0.6250, 0.280];[0.6, 0.6250, 0.980]};


list_of_directories = {...
    'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig3(GLID&Gr43a)-NeedToMergeWNilay\Fig3e(dFFTrace\Fig3e,right-Fasted,LowSuc'...
%     'F:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\PotentialRev\Gr43a,1MFructose'...
};
GroupName={'1MSuc,Fasted','50mMNaCl'};
% GroupName={'Gr43a(RefedWS,1MSuc)','Gr43a(St,1MSuc)','Gr43a(St,100mMSuc)'};

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
    for i3=1:length(DataList2)
        %------Read Data-------
        CurDataPath=strcat(CurDir2,'\',DataList2(i3).name)
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

        TotalCBNo=size(dFFDuringStim,2);
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
        PosRespondedCBCount=0;
        NegRespondedCBCount=0;
        NotRespondedCBCount=0;
        dFFSegOfPosRespondedCB=[];
        dFFSegOfNegRespondedCB=[];
        dFFSegOfNotRespondedCB=[];
        for i2=1:size(GreatestdFFDuringStim,2)
            CurrentCBName=strcat(DataList2(i3).name,'-',XlsxText{i2})
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
                if MinRangeToCompare(i2)>=RespondThre(i2) 
                    ListOfPosRespondedCB=[ListOfPosRespondedCB;XlsxText(i2)]; %#ok<AGROW> 
                    GreatestdFFOfPosRespondedCB=[GreatestdFFOfPosRespondedCB;GreatestdFFDuringStim(i2)];
                    PosRespondedCBCount=PosRespondedCBCount+1;
                    AllPosRespondedCBNoOfThisGroup=AllPosRespondedCBNoOfThisGroup+1;
                    AllPosRespondedCBdFFOfThisGroup=[AllPosRespondedCBdFFOfThisGroup;GreatestdFFDuringStim(i2)];
                    AllPosRespondedCBListOfThisGroup=[AllPosRespondedCBListOfThisGroup;{CurrentCBName}];
                    dFFSegOfPosRespondedCB=[dFFSegOfPosRespondedCB,ROIDFFs(:,i2)];
                elseif MaxRangeToCompare(i2)<=(RespondThre(i2)*(-1)) 
                    ListOfNegRespondedCB=[ListOfNegRespondedCB;XlsxText(i2)]; %#ok<AGROW> 
                    GreatestdFFOfNegRespondedCB=[GreatestdFFOfNegRespondedCB;GreatestdFFDuringStim(i2)];
                    NegRespondedCBCount=NegRespondedCBCount+1;
                    AllNegRespondedCBNoOfThisGroup=AllNegRespondedCBNoOfThisGroup+1;
                    AllNegRespondedCBdFFOfThisGroup=[AllNegRespondedCBdFFOfThisGroup;GreatestdFFDuringStim(i2)];
                    AllNegRespondedCBListOfThisGroup=[AllNegRespondedCBListOfThisGroup;{CurrentCBName}];
                    dFFSegOfNegRespondedCB=[dFFSegOfNegRespondedCB,ROIDFFs(:,i2)];
                else %Otherwise, this cell did not respond
                    ListOfNotRespondedCB=[ListOfNotRespondedCB;XlsxText(i2)]; %#ok<AGROW> 
                    GreatestdFFOfNotRespondedCB=[GreatestdFFOfNotRespondedCB;GreatestdFFDuringStim(i2)];
                    NotRespondedCBCount=NotRespondedCBCount+1;
                    AllNotRespondedCBNoOfThisGroup=AllNotRespondedCBNoOfThisGroup+1;
                    AllNotRespondedCBdFFOfThisGroup=[AllNotRespondedCBdFFOfThisGroup;GreatestdFFDuringStim(i2)];
                    AllNotRespondedCBListOfThisGroup=[AllNotRespondedCBListOfThisGroup;{CurrentCBName}];
                    dFFSegOfNotRespondedCB=[dFFSegOfNotRespondedCB,ROIDFFs(:,i2)];
                end
            AllRecordedCBNoOfThisGroup=AllRecordedCBNoOfThisGroup+1;
            AllRecordedCBdFFOfThisGroup=[AllRecordedCBdFFOfThisGroup;GreatestdFFDuringStim(i2)];
            AllRecordedCBListOfThisGroup=[AllRecordedCBListOfThisGroup;{CurrentCBName}]; %#ok<*AGROW> 
        end
        
        AveragedPosRespDFFOfThisFly=mean(dFFSegOfPosRespondedCB,2);
        AveragedPosRespDFFOfEachFly=[AveragedPosRespDFFOfEachFly,AveragedPosRespDFFOfThisFly];

        AveragedNegRespDFFOfThisFly=mean(dFFSegOfNegRespondedCB,2);
        AveragedNegRespDFFOfEachFly=[AveragedNegRespDFFOfEachFly,AveragedPosRespDFFOfThisFly];

        RatioOfPosRespondedCBInAllCB=PosRespondedCBCount/TotalCBNo;
        RatioOfNegRespondedCBInAllCB=NegRespondedCBCount/TotalCBNo;
    
        if TestModeOn1OrOff0==0
            PathToWrite=CurDir2;
        elseif TestModeOn1OrOff0==1
            PathToWrite=TestOutputPath;
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
        xlswrite(XlsxToWritePath,num2cell(TotalCBNo),1,'C2');
        xlswrite(XlsxToWritePath,num2cell(RespondThre'),1,'D2');
        if size(ListOfPosRespondedCB,1)>0
            xlswrite(XlsxToWritePath,ListOfPosRespondedCB,1,'E2');
            xlswrite(XlsxToWritePath,num2cell(GreatestdFFOfPosRespondedCB),1,'F2');
            xlswrite(XlsxToWritePath,num2cell(PosRespondedCBCount),1,'G2');
            xlswrite(XlsxToWritePath,num2cell(RatioOfPosRespondedCBInAllCB),1,'H2');
        end
        if size(ListOfNegRespondedCB,1)>0
            xlswrite(XlsxToWritePath,ListOfNegRespondedCB,1,'I2');
            xlswrite(XlsxToWritePath,num2cell(GreatestdFFOfNegRespondedCB),1,'J2');
            xlswrite(XlsxToWritePath,num2cell(NegRespondedCBCount),1,'K2');
            xlswrite(XlsxToWritePath,num2cell(RatioOfNegRespondedCBInAllCB),1,'L2');
        end

        save(strcat(XlsxToWritePath(1:end-5),'.mat'));

    end
    %-----PlotPieChart--------
    NotPositivelyRespondedCBNoOfThisGroup=AllRecordedCBNoOfThisGroup-AllPosRespondedCBNoOfThisGroup;
    DataForPie=[NotPositivelyRespondedCBNoOfThisGroup,AllPosRespondedCBNoOfThisGroup];
    fig2=figure;
%     pie(DataForPie,'%.2f%%')
    pie(DataForPie)
       set(fig2, 'Units', 'Inches', 'Position', [0, 0, 8, 8], 'PaperUnits', 'Inches', 'PaperSize', [8, 8]);
    labels={'Not Pos Responded','Pos Responded'};
    lgd=legend(labels,'Location','northeast');
    title(CurDir2);
    
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
    
    xlswrite(XlsxToWritePath,XlsxToWriteTitlePage2,2,'A1');
    xlswrite(XlsxToWritePath,num2cell(DataToWrite),2,'B1');

%% -----Get Average dFF of responded neuron in each fly, plot averaged dFF curve across fly.
%-------Plot averaged dFF of all Pos Responded Neurons----
%-------Mean with SeparateTrials------
Tracesfig1=figure();
FinalX=[-30:1:29];


    yyaxis right
    StepRatio=1/size(AllInd,2);
    AllIndLength=sum(AllInd);
    [sorted,sortRefNo]=sort(AllIndLength,'descend');
    for i=1:size(sortRefNo,2)
        IndToPlot=AllInd(:,sortRefNo(i));
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
      
ylabel('Proboscis Touching');
ylim([0,1]);

yyaxis left
for i=1:size(AveragedPosRespDFFOfEachFly,2)
    p1=plot(FinalX,AveragedPosRespDFFOfEachFly(:,i),'-','Color',SetColorSpec{i},'LineWidth',1);
    hold on
end
p2=plot(FinalX,mean(AveragedPosRespDFFOfEachFly,2),'-','Color',[0 0 0],'LineWidth',1.5);

xlabel('Time(s)');
ylabel('\DeltaF/F');

savefig(strcat('AveragedPosRespDFFOfEachFly_SeparateTrials','.fig'));
print(Tracesfig1, 'AveragedPosRespDFFOfEachFly_SeparateTrials','-dpng','-r0');
print(Tracesfig1, 'AveragedPosRespDFFOfEachFly_SeparateTrials','-dsvg','-r0');
%-------Mean +- SEM-------

Tracesfig2=figure();

yyaxis right
    StepRatio=1/size(AllInd,2);
    AllIndLength=sum(AllInd);
    [sorted,sortRefNo]=sort(AllIndLength,'descend');
    for i=1:size(sortRefNo,2)
        IndToPlot=AllInd(:,sortRefNo(i));
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
FinalX=[-30:1:29];
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
end  
