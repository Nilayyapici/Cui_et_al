%---------Read all stim seg files and make box plot from
%it-----------,2022,Jun,10 edit: write the averaged peak dFF by fly in xlsx page 1, and peak dFF details (with separated stim within each trial) in page 2-------
clc
clear all

StimStartRow=31;%Usually set to 31 for Regular opto trials. Set to 15 for Opto post ingestion trials
TimeAxisResolution=0.25;%in seconds. Usually set to 0.25 for Regular opto trials. Set to 1 for Opto post ingestion trials

CompareRangeStartInTime=0;%in sec. Relative to Stim start time. If it equal to stim start time, this parameter should be 0.
CompareRangeEndInTime=4;%in sec. Usually set to 4
UseBinnedData=1;% set to 1 if you want to use binned version of dFF, set to 0 if  you want to use interpolated version of dFF

list_of_directories = {...
    'C:\Users\zjucx\Dropbox\Worki\AvgdFFData-Current\IN1 imaging\Starved\Gr64c(p\BASelectedSA'...
    'C:\Users\zjucx\Dropbox\Worki\AvgdFFData-Current\IN1 imaging\Starved\Gr64e(p\BAselectSA'...
%     'D:\Drive20BackUp\DataAnalysis\111FluoXlsx,WithBGSub\+Chr_OptoPostIng\ATR+'...
%     'D:\Drive20BackUp\DataAnalysis\111FluoXlsx,WithBGSub\IN1+_OptoPostIng\ATR+'...
%     'D:\Drive20BackUp\DataAnalysis\111FluoXlsx,WithBGSub\IN1Chr_OptoPostIng\ATR+'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IN1 imaging\Starved\Wiso,St(p\1s'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IN1 imaging\Starved\Gr64f(P'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IN1 imaging\Starved\Gr66a(P'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IN1 imaging\Starved\ppk28,St(p'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IN1 imaging\Starved\TMC(p\SA+sBA'...
%     'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig1(Optos)\Fig1c\Wiso,St(p\1s'...
%     'F:\222Paper2024-mycopy\2_DataForFigs_Current\FigS4(AllENLineOpto\a(EN1)\(Gut1)25F11G4A,38B05G4D(p'...
%     'F:\222Paper2024-mycopy\2_DataForFigs_Current\FigS4(AllENLineOpto\b(EN2)\(Gut2)24D12G4A,38B05G4D(P\1s(p'...
%     'F:\222Paper2024-mycopy\2_DataForFigs_Current\FigS4(AllENLineOpto\c(EN3)\(Gut3)25F11G4A,24D12G4D(P'...
%     'F:\222Paper2024-mycopy\2_DataForFigs_Current\FigS4(AllENLineOpto\d(EN4)\(Gut4)24D12G4A,15D05G4D(P'...
%     'F:\222Paper2024-mycopy\2_DataForFigs_Current\FigS4(AllENLineOpto\e(EN5)\(Gut5)25F11G4A,15D05G4D(P'...
%     'F:\222Paper2024-mycopy\2_DataForFigs_Current\FigS4(AllENLineOpto\f(EN6)\(Gut6)44F09G4A,24D12G4D(p'...
%     'F:\222Paper2024-mycopy\2_DataForFigs_Current\FigS4(AllENLineOpto\g(EN8)\(Gut8)44F09G4A,25F11G4D(p'...
%     'F:\222Paper2024-mycopy\2_DataForFigs_Current\FigS4(AllENLineOpto\h(EN9)\(Gut9)44F09G4A,15D05G4D(p'...
%     'F:\222Paper2024-mycopy\2_DataForFigs_Current\FigS4(AllENLineOpto\i(EN10)\(Gut10)37A08G4A,38B05G4D(p'...
%     'F:\222Paper2024-mycopy\2_DataForFigs_Current\FigS4(AllENLineOpto\j(EN11)\(Gut11)37A08G4A,24D12G4D(p'...
%     'F:\222Paper2024-mycopy\2_DataForFigs_Current\FigS4(AllENLineOpto\k(EN12)\(Gut12)37A08G4A,25F11G4D(p'...
%     'F:\222Paper2024-mycopy\2_DataForFigs_Current\FigS4(AllENLineOpto\l(EN13)\(Gut13)37A08G4A,70C02G4D(p\BASelectedSA+SA(Used'...
%     'F:\222Paper2024-mycopy\2_DataForFigs_Current\FigS4(AllENLineOpto\m(EN15)\(Gut15)24D12G4A,70C02G4D(p\SA+BAsSA\OutlierExcVer'...
%     'F:\222Paper2024-mycopy\2_DataForFigs_Current\FigS4(AllENLineOpto\n(EN18)\(Gut18)44F09G4A,70C02G4D(p'...
%     'F:\222Paper2024-mycopy\2_DataForFigs_Current\FigS4(AllENLineOpto\o(EN20)\(Gut20)44F09G4A,20G03G4D(p'...
    };

OutputPath='C:\Users\zjucx\Dropbox\Worki\AvgdFFData-Current\IN1 imaging\Starved\Stat-Gr64c,e';%You Output path of choice
XlsxTitle={'Gr64c','Gr64e'};
% XlsxTitle={'+_Chrimson, ATR+','IN1_+, ATR+','IN1_Chrimson, ATR+'};
% XlsxTitle={'Wiso','Gr64f','Gr66a','Ppk28','TMC'};%Fig 1, Make sure this sequence is in accordance with the input sequence of folders
% XlsxTitle={'Wiso','EN-1','EN-2','EN-3','EN-4','EN-5',...
%     'EN-6','EN-8','EN-9','EN-10','EN-11',...
%     'EN-12','EN-13','EN-15','EN-18','EN-20'};
% XlsxTitle={'Wiso','Gr66a&Gr64f','Ir25a','Dh44','Gr5a','Gr64a','Gr64d'};
% XlsxTitle={'Wiso','Gr43aki','Gr43aki,ChAT-Gal80','Gr43atg'};
% XlsxTitle={'Exp_Group','Control'};
% XlsxTitle={'Gr28b.d'};%Make sure this sequence is in accordance with the input sequence of folders
% XlsxTitle={'Gut1','Gut2','Gut2(NRC)','Gut3', 'Gut4','Gut5','Gut6',...
%     'W1118','Dh44','Gr5a','Gr43a(II)','Gr43a(II)G4,ChaG80',...
%     'Gr43a(III)','Gr64a','Gr64d','Gr64f','Gr66a','Gr64f&Gr66a',...
%     'Ir25a','ppk28,Starved','TMC'};

%------------Adjust above------
AllSumPeakdFFOfEachFly=[];
for directory_idx  = 1:numel(list_of_directories)
    XlsxData=[];
    XlsxTit=[];
    XlsxNum=[];
    CurrentDir=list_of_directories{directory_idx};
    cd(CurrentDir);
    Folder1=list_of_directories{directory_idx};
    disp(sprintf('Processing %s',Folder1));
    cd (Folder1);
    XlsxList=dir('*.xlsx');
    
    if UseBinnedData==1
        CurrentDir=strcat(list_of_directories{directory_idx},'\BindFFSeg\Plots');
    else
        CurrentDir=strcat(list_of_directories{directory_idx},'\IntdFFSeg\Plots');
    end
    TempFilePath=[CurrentDir,'\PlottedData.xlsx'];
    [XlsxNum, XlsxTit]=xlsread(TempFilePath);
    FileName=XlsxTit(1,:);
    StimArName=XlsxTit(2,:);
    CombName=strcat(FileName,StimArName);
    CombName=CombName';
    AllPossFlyName=unique(FileName);
    FlyMarker=[];
    for i=1:length(AllPossFlyName)
        for j=1:length(FileName)
            if strcmp(FileName(j),AllPossFlyName(i))
                FlyMarker=[FlyMarker;i];
            end
        end
    end

    %------Get Stim Start Row No------
    if UseBinnedData==1
        Dir2=strcat(list_of_directories{directory_idx},'\BindFFSeg');
    else
        Dir2=strcat(list_of_directories{directory_idx},'\IntdFFSeg');
    end
    cd(Dir2);
    XlsxList2=dir('*.xlsx');
    TempFilePath=strcat(Dir2,'\',XlsxList2(1).name);
    [XlsxNum2, XlsxTit2]=xlsread(TempFilePath);
    StimOnIndCol=XlsxNum2(:,end);
    StimOnRowNoList=find(StimOnIndCol==1);
    StimStartRow=min(StimOnRowNoList);
%% -------Get Peak dFF of each stim--------
    TimeAxisFPS=round(1/TimeAxisResolution);
    dFFSegUsedForCalc=XlsxNum(StimStartRow+CompareRangeStartInTime*TimeAxisFPS:StimStartRow+CompareRangeEndInTime*TimeAxisFPS-1,1:end);
    MinOfEachSeg=min(dFFSegUsedForCalc,[],1);
    MaxOfEachSeg=max(dFFSegUsedForCalc,[],1);
    AUCOfEachSeg=trapz(dFFSegUsedForCalc);
    MeanOfEachSeg=mean(dFFSegUsedForCalc);
    %-------Compare the absolute value of min and max of each segment, use
    %the one that has the largest absolute value and keep the +-sign----
    AbsMin=abs(MinOfEachSeg);
    AbsMax=abs(MaxOfEachSeg);
    MaxOrMinOfEachSeg=[];
%     AbsCompare=AbsMax-AbsMin;
    for i=1:size(AbsMin,2)
        if AbsMax(i)>=AbsMin(i)
            if MaxOfEachSeg(i)>=0
                MaxOrMinOfEachSeg=[MaxOrMinOfEachSeg,AbsMax(i)];
            else
                MaxOrMinOfEachSeg=[MaxOrMinOfEachSeg,(-1)*AbsMax(i)];
            end
        elseif AbsMax(i)<AbsMin(i)
            if MinOfEachSeg(i)>=0
                MaxOrMinOfEachSeg=[MaxOrMinOfEachSeg,AbsMin(i)];
            else
                MaxOrMinOfEachSeg=[MaxOrMinOfEachSeg,(-1)*AbsMin(i)];
            end
        end
    end
    MaxOrMinOfEachSeg=MaxOrMinOfEachSeg';

    XlsxData(1:size(MaxOrMinOfEachSeg,1),1)=MaxOrMinOfEachSeg;
    XlsxData(1:size(AUCOfEachSeg,2),2)=AUCOfEachSeg';
    XlsxData(1:size(MeanOfEachSeg,2),3)=MeanOfEachSeg';

%% -----Calculate average peak dFF,AUC,MeandFF of each fly-----
    AvgPeakdFFByFly=[];
    GreatestPeakdFFByFly=[];
    for i=1:length(AllPossFlyName)
        ThisFlysRow=find(FlyMarker==i);
        AvgPeakdFFByFlyToAdd=mean(MaxOrMinOfEachSeg(ThisFlysRow));
        MaxPeakdFFByFlyToAdd=max(MaxOrMinOfEachSeg(ThisFlysRow));
        MinPeakdFFByFlyToAdd=min(MaxOrMinOfEachSeg(ThisFlysRow));
        if abs(MinPeakdFFByFlyToAdd)>abs(MaxPeakdFFByFlyToAdd)
            GreatestPeakdFFByFlyToAdd=MinPeakdFFByFlyToAdd;
        else
            GreatestPeakdFFByFlyToAdd=MaxPeakdFFByFlyToAdd;
        end
        AvgPeakdFFByFly=[AvgPeakdFFByFly;AvgPeakdFFByFlyToAdd];
        GreatestPeakdFFByFly=[GreatestPeakdFFByFly;GreatestPeakdFFByFlyToAdd];
    end
    

    AvgAUCByFly=[];
    for i=1:length(AllPossFlyName)
        ThisFlysRow=find(FlyMarker==i);
        AvgAUCByFlyToAdd=mean(AUCOfEachSeg(ThisFlysRow));
        AvgAUCByFly=[AvgAUCByFly;AvgAUCByFlyToAdd];
    end

    AvgMeandFFByFly=[];
    for i=1:length(AllPossFlyName)
        ThisFlysRow=find(FlyMarker==i);
        AvgMeandFFByFlyToAdd=mean(MeanOfEachSeg(ThisFlysRow));
        AvgMeandFFByFly=[AvgMeandFFByFly;AvgMeandFFByFlyToAdd];
    end

cd(OutputPath);
xlsfilename=strcat('BoxPlotData-',XlsxTitle(directory_idx));
%--------write the averaged peak dFF by fly in page 1-------
TitlePage1=[{'FlyNo'},{'AvgPeakdFF'},{'GreatestPeakdFF'},{'AvgAUC'},{'AvgMeandFF'},{'TrialInfo'},...
    {'CompareRangeStartInTime'},{'CompareRangeEndInTime'}];
UniqueFlyMarker=unique(FlyMarker);
XlsxToWrtiePage1=[num2cell(UniqueFlyMarker),num2cell(AvgPeakdFFByFly),num2cell(GreatestPeakdFFByFly)...
    num2cell(AvgAUCByFly),num2cell(AvgMeandFFByFly),AllPossFlyName',...
    num2cell(repmat(CompareRangeStartInTime,size(UniqueFlyMarker,1),1)),...
    num2cell(repmat(CompareRangeEndInTime,size(UniqueFlyMarker,1),1))];
AllToWritePage1=[TitlePage1;XlsxToWrtiePage1];
writecell(AllToWritePage1,strcat(xlsfilename{1},'.xlsx'),'Sheet',1);
%--------write peak dFF details in page 2--------
XlsxToWritePage2=[num2cell(FlyMarker),CombName,num2cell(XlsxData)];
XlsxTitle2=[{'FlyNo'},{'Trial&StimInfo'},{'PeakdFFOfThisStim'},{'AUCOfThisStim'},{'MeandFFOfThisStim'}];
% [ZeroRow,ZeroCol]=find(XlsxData==0);
% ZeroRow=ZeroRow+1;
XlsxToWrite2=[XlsxTitle2;XlsxToWritePage2];
% for i2=1:length(ZeroRow)
%     XlsxToWrite2(ZeroRow(i2),ZeroCol(i2))={''};
% end
writecell(XlsxToWrite2,strcat(xlsfilename{1},'.xlsx'),'Sheet',2);
save(strcat('CalcInfo-',xlsfilename{1}));
%--------Write summary xlsx separately
XlsxToWrite3=[XlsxTitle(directory_idx);num2cell(AvgPeakdFFByFly)];
XlsxToWrite3=XlsxToWrite3';
writecell(XlsxToWrite3,strcat('SummaryOfPeakdFF.xlsx'),'Sheet',1,'WriteMode','append');
clear XlsxNum XlsxTit XlsxData
end