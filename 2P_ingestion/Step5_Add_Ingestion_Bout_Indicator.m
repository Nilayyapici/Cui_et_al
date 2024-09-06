clear all
clc

ImageTimeMin=8;%Change here!!
ImageTimeSec=0;%Change here!!
TotalTimeSec=ImageTimeMin*60+ImageTimeSec;
SetColorSpec={[0, 0, 1];[0,1,0];[0.6, 0.8250, 0.280];[0.9290, 0.6940, 0.5250];[0.4940, 0.6840, 0.5560];[0.75, 0.5, 0.75];...
    [0.660, 0.8740, 0.480];[0, 0.5, 0.16];[0.5010, 0.7450, 0.9330];[0.6350, 0.0780, 0.2840];[0.6350, 0.0780, 0.55];[0.6350, 0.0780, 0.3];[0.6350, 0.2, 0.55];[0.6350, 0.2780, 0.65];[0.9350, 0.0780, 0.55];[0.8350, 0.780, 0.55];[0.8500, 0.6250, 0.280];[0.6, 0.6250, 0.980]};


list_of_directories = {...
'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig4(GutLineIngImg)\Fig4d(GutLineIngImg\EN2\Gut2'...
'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig4(GutLineIngImg)\Fig4d(GutLineIngImg\EN3\Gut3'...
'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig4(GutLineIngImg)\Fig4d(GutLineIngImg\EN10\Gut10'...
'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig4(GutLineIngImg)\Fig4d(GutLineIngImg\EN11\Gut11'...
%     'F:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\PotentialRev\Gr43a,1MFructose'...
%     'F:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\PotentialRev\Gr43a,50mMNaCl'...
};

for directory_idx  = 1:numel(list_of_directories)
    CurrentDir=list_of_directories{directory_idx};
    cd(CurrentDir);
    Folder1=list_of_directories{directory_idx};
    disp(sprintf('Processing %s',Folder1));
    CurFolderlist=dir(Folder1);
    
    DataFolderList=[];
    SyncDataFolderList=[];
    for idx1=1:size(CurFolderlist,1)
        DataFolderList=dir('*.xlsx');
    end
%---------Load Data--------------
    for i2=1: size(DataFolderList)
        Folder2=DataFolderList(i2).name;
        CurDataPath=strcat(Folder1,'\',Folder2);
        CurFileName=Folder2(1:end-5);
%-------Read xlsx-------------

        [XlsxNum,XlsxText,XlsxAll]=xlsread(CurDataPath);
%         XlsxNum(1, :)=[];
        NewXlsxText2=XlsxText(1:end-1);
        ROIColNo=[1: size(XlsxAll,2)-1];
        ROIFluo=XlsxNum(:,ROIColNo);
        IngColData=XlsxNum(:,end);
        
        FrameNo=size(XlsxNum,1);
%----------Read ingesiton time information----------
        LinkerPositionInTitle=strfind(Folder2,'-');
        DataName=Folder2(LinkerPositionInTitle(1)+1:end-5);
        IngFileName=strcat('Ing',DataName,'.txt');
        IngDataPath=strcat(Folder1,'\',IngFileName);
        
        IngText=importdata(IngDataPath);
        IngText=IngText{1};
    
    HypPos=find(IngText=='-');
    HypPos=int8(HypPos);
    DotPos=find(IngText=='.');
    DotPos=int8(DotPos);
    
    BeginEndMin=[];
    BeginEndSec=[];
    
    for i2=1:length(DotPos)
        BeginEndMin=[BeginEndMin,str2num(IngText(DotPos(i2)-1))];
        if IngText(DotPos(i2)+2)~='/'||IngText(DotPos(i2)+2)~='-'
            if str2num(IngText(DotPos(i2)+2))>=0
                BeginEndSec=[BeginEndSec,str2num(IngText(DotPos(i2)+1:DotPos(i2)+2))];
            else
                BeginEndSec=[BeginEndSec,str2num(IngText(DotPos(i2)+1))];
            end
        else
            BeginEndSec=[BeginEndSec,str2num(IngText(DotPos(i2)+1))];
        end
    end
    
    IngBegMin=[];
    IngBegSec=[];
    IngEndMin=[];
    IngEndSec=[];
    for i3=1:length(BeginEndMin)
        if mod(i3,2)==0%if i3 is even, then it is the ing end time 
            IngEndMin=[IngEndMin,BeginEndMin(i3)];
        else
            IngBegMin=[IngBegMin,BeginEndMin(i3)];
        end
    end
    
    for i3=1:length(BeginEndSec)
        if mod(i3,2)==0%if i3 is even, then it is the ing end time 
            IngEndSec=[IngEndSec,BeginEndSec(i3)];
        else
            IngBegSec=[IngBegSec,BeginEndSec(i3)];
        end
    end

    IngVecByTime=zeros(FrameNo,1);
    TimeOverFrameRatio=TotalTimeSec/FrameNo;
    FrameOverTimeRatio=FrameNo/TotalTimeSec;
    for i1=1:length(IngBegMin)
        BegTimeInSec=IngBegMin(i1)*60+IngBegSec(i1);
        EndTimeInSec=IngEndMin(i1)*60+IngEndSec(i1);
        IngVecByTime(round(BegTimeInSec*FrameOverTimeRatio):round(EndTimeInSec*FrameOverTimeRatio))=1;
    end


 %-----------Write Into new excel sheet---------
HasLightStimInThisTrial1OrNot0=1;
LightOnColNo=find(strcmp(XlsxText,'LightOn'));
if ~isempty(LightOnColNo)
    LightOnIndSum=sum(XlsxNum(:,LightOnColNo));
    if LightOnIndSum==0
        HasLightStimInThisTrial1OrNot0=0;
    elseif LightOnIndSum>0
        HasLightStimInThisTrial1OrNot0=1;
    end
end
if HasLightStimInThisTrial1OrNot0==1
    XlsxTitle=[XlsxAll(1,1:end),{'IngestionIndicator'}];
    AllNumToWrite=[XlsxNum(:,1:end),IngVecByTime];
    XlsxToWrite=[XlsxTitle;num2cell(AllNumToWrite)];
elseif HasLightStimInThisTrial1OrNot0==0
    XlsxTitle=[XlsxAll(1,1:end-1),{'IngestionIndicator'}];
    AllNumToWrite=[XlsxNum(:,1:end-1),IngVecByTime];
    XlsxToWrite=[XlsxTitle;num2cell(AllNumToWrite)];
end

mkdir('IngAdded')
FileName=strcat('I-',CurFileName);
xlswrite(strcat(CurrentDir,'\IngAdded\',FileName,'.xlsx'), XlsxToWrite);

save (strcat(CurrentDir,'\IngAdded\CalcInfo-',FileName(1:end-5),'.mat'),'-mat');
%----------Write cutted dFF--------


    end 
    
end

