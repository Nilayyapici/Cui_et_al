%-----------Calculate and plot average response curve (across differenct
%trials) 2021Jan22version-------------
%----In this version, dFF will be re-calculated, and the normalization will
%be performed for each time of stimulation-------
%-------2021Jan22VersionUpdate:Added Binning feature besides the
%interpolation-------------
%-------2024Mar26Update, added features to enalbe alignement to opto stim
%offset--------
%-------Newest update: 2024Apr17--------
clear all
clc

Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3=1;% set to 1 to align time 0 to ingestion onset, or set it to 2 to align time 0 to ingestion offset, or set to 3 if want to align trials to opto stim offset. CHANGED CODE BETWEEN LINE 177 TO 181 !!!
TimeStartBeforeStim=6;%in seconds. Change here!!,usually 6, or 50 for OptoIng
TimeStopAfterStim=6;%in seconds. Change here!!,usually 6, or 300 for OptoIng
TimeResolution=1;% in second,usually 0.25
dFFOutlierThreshold=10000;%Change If need, usually 10
BackGroundSubtractionOn1OrOff0=1;%Change here!!!!!!!!!!!!!!!!!!!!!!!!!!!!

ImageTimeMin=4;%Change here!!
ImageTimeSec=0;%Change here!!
TotalTimeInSec=ImageTimeMin*60+ImageTimeSec;

BasalFTimeLength=3;%In seconds, for ingestion imaging data, usually 10
BalsalFEndTime=0;%for ingestion imaging data, usually 0. basal frame is set to "from the (BalsalFEndTime) before first stim to (BalsalFEndTime+BasalFTimeLength) secs before first stim". For ingestion imaging with opto experiment, set it to 0 to -3s.

list_of_directories = {...
        'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig6(CS,IN1TNT,CEM\Fig6g(ATR+,OptoIng\CEM,IngWithOpto(Exp)'...
        'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig6(CS,IN1TNT,CEM\Fig6i(ATR-,OptoIng\CEM,IngWithOpto(NRC)'...
%         'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\111FluoXlsx\CDG2,IngWithOpto(3groups)\CDG2,IngWithOpto(NRC)'...
%         'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\111FluoXlsx\CDG2,IngWithOpto(3groups)\CDG2,IngWithOpto(Exp)'...
%         'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\111FluoXlsx\CDG2,IngWithOpto(3groups)\CDG2,IngWithOpto(NoRedLight)'...
%         'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\CDG2,IngWithOpto(3groups)\CDG2,IngWithOpto(NRC)'...
%         'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\CDG2,IngWithOpto(3groups)\CDG2,IngWithOpto(Exp)'...
%         'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\CDG2,IngWithOpto(3groups)\CDG2,IngWithOpto(NoRedLight)'...
%     'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\CS,Fasted,UL100mM&1MSucFluoFoodIng\1M'...
%     'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\CS,Fasted,UL100mM&1MSucFluoFoodIng\100mM\OutlierExcluded(InUse)'...
    };

%% -----------Above: please change before each time of use------

% dFFFragment=zeros(FrameStartBeforeStim+FrameStopAfterStim+1,length(LightOnRowList));
for directory_idx  = 1:numel(list_of_directories)
    CurrentDir=strcat(list_of_directories{directory_idx},'\IngAdded');
    cd(CurrentDir);
    Folder1=list_of_directories{directory_idx};
    disp(sprintf('Processing %s',Folder1));
    XlsxList=dir('*.xlsx');

    for idx1=1:size(XlsxList,1)
        
        print2=XlsxList(idx1).name
        [XlsxNum,XlsxTitle]=xlsread(XlsxList(idx1).name);
%% ------------Find BG row, do background subtraciton--------
        BGColNo=find(strcmp(XlsxTitle,'BG'));
        BGFluo=XlsxNum(:,BGColNo);
        ROIFluo=XlsxNum(:,1:BGColNo-1); %Here I assumed ROI columns are placed before BG fluo column, change if needed.
        RepBGFluo=repmat(BGFluo, 1, size(ROIFluo,2));

        if BackGroundSubtractionOn1OrOff0==1
            ROISubBGFluo=ROIFluo-RepBGFluo;
        elseif BackGroundSubtractionOn1OrOff0==0
            ROISubBGFluo=ROIFluo;
        end
        
%% ------Find light on rows, get fragments---------
%------Get light on list, find light on rows----
 if Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==1||Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==2
        StimIndColNo=find(strcmp(XlsxTitle,'IngestionIndicator'));
 elseif Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==3
        StimIndColNo=find(strcmp(XlsxTitle,'LightOn'));
 end
        StimIndCol=XlsxNum(:,StimIndColNo);
        StimOnRowList=find(StimIndCol==1);
        
        FramePerSec=size(XlsxNum,1)/TotalTimeInSec;
        RealStimTime=round(length(StimOnRowList)/FramePerSec);
        ToBeDelete=[];
        
            for i=2:length(StimOnRowList)
                if StimOnRowList(i)-StimOnRowList(i-1)==1
                    ToBeDelete=[ToBeDelete,i];
                end
            end
        StimOnRowList(ToBeDelete)=[];

        StimOffsetRowList=find(StimIndCol==1);
        ToBeDelete=[];
        for i=2:length(StimOffsetRowList)
            if StimOffsetRowList(i)-StimOffsetRowList(i-1)==1
                ToBeDelete=[ToBeDelete,i-1];
            end
        end
        StimOffsetRowList(ToBeDelete)=[];
        StimOffsetRowList=StimOffsetRowList+1;

%-----------Get fragments--------        
        TotalTimeInSec=ImageTimeMin*60+ImageTimeSec;
        TimeToFrame=size(ROISubBGFluo,1)/TotalTimeInSec;
        FrameStartBeforeStim=ceil((TimeStartBeforeStim)*TimeToFrame);
        FrameStopAfterStim=ceil((TimeStopAfterStim)*TimeToFrame);
        
        FluoResponseFragments=[];
        StimIndFragments=[];
        for i=1:1%length(StimOnRowList)%Changed on 2024Jan07. Now this code will only consider the first eating bout as the segment start time
            if Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==1
                FragmentStartFrameNo=StimOnRowList(i)-FrameStartBeforeStim;
                FragmentEndFrameNo=ceil(StimOnRowList(i)+FrameStopAfterStim-1);
            elseif Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==2
                FragmentStartFrameNo=StimOffsetRowList(i)-FrameStartBeforeStim;
                FragmentEndFrameNo=ceil(StimOffsetRowList(i)+FrameStopAfterStim-1);
            elseif Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==3
                FragmentStartFrameNo=StimOffsetRowList(i)-FrameStartBeforeStim;
                FragmentEndFrameNo=ceil(StimOffsetRowList(i)+FrameStopAfterStim-1);
            end

            if FragmentStartFrameNo<1
                FragmentStartFrameNo=1;
            end

                if FragmentEndFrameNo>size(ROISubBGFluo,1)
                    FragmentEndFrameNo=size(ROISubBGFluo,1);
                end
    
                FragmentAddToFluo=ROISubBGFluo(FragmentStartFrameNo:FragmentEndFrameNo,1:end);
                FragmentToAddToStimInd=StimIndCol(FragmentStartFrameNo:FragmentEndFrameNo,end);
    
                if size(FragmentAddToFluo,1)<size(FragmentAddToFluo,2)
                    FragmentAddToFluo=FragmentAddToFluo';
                end
    
                FluoResponseFragments=[FluoResponseFragments, FragmentAddToFluo];
                StimIndFragments=[StimIndFragments,FragmentToAddToStimInd];
        end


%% -------Get Basal F for each stim, calculate dFF----------
%         FirstOnFrame=floor((TimeStartBeforeStim+1)*TimeToFrame);
%         FirstOnFrame=FrameStartBeforeStim+1;%Changed this row in 2020Feb27
    if Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==1
            FirstOnFrame=StimOnRowList(1);%Changed this row in 2024Jan07
    elseif Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==2
            FirstOnFrame=StimOffsetRowList(1);
    elseif Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==3
        FirstOnFrame=StimOffsetRowList(1);%Changed this row in 2024Mar27
    end

        BasalFEndFrame=FirstOnFrame-ceil(BalsalFEndTime*TimeToFrame);
%         BasalFEndFrame=floor(size(FluoResponseFragments,1)/2)-1;
        BasalFStartFrame=BasalFEndFrame-ceil(BasalFTimeLength*TimeToFrame);
%         BasalFStartFrame=1;
        BasalFSegments=ROISubBGFluo(BasalFStartFrame:BasalFEndFrame-1,:);
        BasalF=mean(BasalFSegments);
        
        RepBasalF=repmat(BasalF,size(FluoResponseFragments,1),1);

        DeltaF=FluoResponseFragments-RepBasalF;
        dFF=DeltaF./RepBasalF;
        
        InvertedDFFRowList=[];
        for i3=1:size(DeltaF,1)
            if DeltaF(i3)>0&&dFF(i3)<0
                dFF(i3)=-dFF(i3);
                InvertedDFFRowList=[InvertedDFFRowList;i3];
                print1=strcat('Abnormal dFF detected at ',num2str(i3),'/',num2str(size(DeltaF,1)),'inversed(- to +)')
            elseif DeltaF(i3)<0&&dFF(i3)>0
                dFF(i3)=-dFF(i3);
                InvertedDFFRowList=[InvertedDFFRowList;i3];
                print1=strcat('Abnormal dFF detected at ',num2str(i3),'/',num2str(size(DeltaF,1)),'inversed(+ to -)')
            end
        end
        
        DiscardedDFFColList=[];
        for i4=1:size(dFF,2)
            if max(dFF(:,i4))>dFFOutlierThreshold || min(dFF(:,i4))<(-1*dFFOutlierThreshold)
                DiscardedDFFColList=[DiscardedDFFColList,i4];
            end
        end
        
%         mkdir('IntdFFSeg');
%         save(strcat(CurrentDir,'\IntdFFSeg\','dFFCalInfo-',XlsxList(idx1).name,'.mat'),'BackGroundSubtractionOn1OrOff0','ROIFluo','BGFluo','ROISubBGFluo',...
%             'TotalTimeInSec','TimeStartBeforeStim','FrameStartBeforeStim','TimeStopAfterStim','FrameStopAfterStim','FluoResponseFragments',...
%             'LightOnRowList','BasalFTimeLength','BalsalFEndTime','BasalFStartFrame','BasalFEndFrame',...
%             'BasalFSegments','BasalF','RepBasalF','DeltaF','dFF','InvertedDFFRowList','dFFOutlierThreshold','DiscardedDFFColList');
%         save(strcat(CurrentDir,'\BindFFSeg\','dFFCalInfo-',XlsxList(idx1).name,'.mat'),'BackGroundSubtractionOn1OrOff0','ROIFluo','BGFluo','ROISubBGFluo',...
%             'TotalTimeInSec','TimeStartBeforeStim','FrameStartBeforeStim','TimeStopAfterStim','FrameStopAfterStim','FluoResponseFragments',...
%             'LightOnRowList','BasalFTimeLength','BalsalFEndTime','BasalFStartFrame','BasalFEndFrame',...
%             'BasalFSegments','BasalF','RepBasalF','DeltaF','dFF','InvertedDFFRowList','dFFOutlierThreshold','DiscardedDFFColList');
% %         %--------Interpolate dFFs from frames to time axis-------
% % %         TotalTimeInSec=
% % %         Newx=[FPS*TimeResolution:FPS*TimeResolution:(FrameNo-mod(FrameNo,FPS))]';
% %         NewxStart=FrameStartBeforeStim-TimeStartBeforeStim*FPS;
% %         NewxEnd=NewxStart+(TimeStartBeforeStim+TimeStopAfterStim)*FPS;
% %         Newx=[NewxStart:FPS*TimeResolution:NewxEnd-TimeResolution]';
% % %         FinalTimeLength=floor(TotalTimeInSec-(1/FPS));
% % %         Finalx=[0:1:(FinalTimeLength-1)];
% %         
% %         InterpolatedDFF=interp1((0:FrameNo-1), dFF, Newx, 'linear');

%------------Bin the dFF into each second---------
if Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==1
    mkdir('BindFFSegIo');
elseif Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==2
    mkdir('BindFFSegIf');
elseif Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==3
    mkdir('BindFFSegOf');
end

        FrameNo=size(dFF,1);
        FPS=TimeToFrame;
        FrameList=(0:FrameNo-1);
        BinEdges=[0:(FPS*TimeResolution):FPS*(TimeStartBeforeStim+TimeStopAfterStim)];
        Bin1=discretize(FrameList,BinEdges);
        
        BinnedDFF=[];
        BinnedInd=[];
        for ibin=1:max(Bin1)
            BinnedDFF=[BinnedDFF;mean(dFF(find(Bin1==ibin),:),1)];
            BinnedInd=[BinnedInd;max(StimIndFragments(find(Bin1==ibin),:))];
        end

        %----------Write Re-calculated dFF into xlsx-------
%         FileName=strcat('IntdFFSeg-',XlsxList(idx1).name);
    if Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==1
        FileName2=strcat('BindFFSegIo-',XlsxList(idx1).name);
        TitleToWrite={XlsxTitle{1:end-3},'IngestionOn'};
    elseif Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==2
        FileName2=strcat('BindFFSegIf-',XlsxList(idx1).name);
        TitleToWrite={XlsxTitle{1:end-3},'IngestionOn'};
    elseif Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==3
        FileName2=strcat('BindFFSegOf-',XlsxList(idx1).name);
        TitleToWrite={XlsxTitle{1:end-3},'OptoOn'};
    end
%         %----Write Interpolated DFF---------
%         LightOnIndToWrite=zeros(size(InterpolatedDFF,1),1);
%         LightOnStartTime=floor((FrameStartBeforeStim+1)*(size(InterpolatedDFF,1)/size(dFF,1)))+1;
%         LightOnEndTime=LightOnStartTime+RealStimTime/TimeResolution;
%         LightOnRowNo=(LightOnStartTime:LightOnEndTime);
%         LightOnIndToWrite(LightOnRowNo)=1;
%         NumToWrite=[InterpolatedDFF,LightOnIndToWrite(1:size(InterpolatedDFF,1))];
%         
%         XlsxToWrite=[TitleToWrite;num2cell(NumToWrite)];
%         XlsxToWrite(:,DiscardedDFFColList)=[];
%         xlswrite(strcat(CurrentDir,'\IntdFFSeg\',FileName), XlsxToWrite);
        %-----------Write Binned DFF---------------
        LightOnIndToWrite=zeros(size(BinnedDFF,1),1);
%         LightOnRowNo=(TimeStartBeforeStim/TimeResolution:TimeStartBeforeStim/TimeResolution+stimtime/TimeResolution-1);
        LightOnStartTime=floor((FrameStartBeforeStim+1)*(size(BinnedDFF,1)/size(dFF,1)))+1;
        LightOnEndTime=LightOnStartTime+RealStimTime/TimeResolution;
        LightOnRowNo=(LightOnStartTime:LightOnEndTime);
        LightOnIndToWrite(LightOnRowNo)=1;
        NumToWrite2=[BinnedDFF,BinnedInd];
        
        XlsxToWrite2=[TitleToWrite;num2cell(NumToWrite2)];
        XlsxToWrite2(:,DiscardedDFFColList)=[];
    if Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==1
        xlswrite(strcat(CurrentDir,'\BindFFSegIo\',FileName2), XlsxToWrite2);
        save (strcat(CurrentDir,'\BindFFSegIo\dFFCalcInfo-',FileName2(1:end-5),'.mat'),'-mat');
    elseif Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==2
        xlswrite(strcat(CurrentDir,'\BindFFSegIf\',FileName2), XlsxToWrite2);
        save (strcat(CurrentDir,'\BindFFSegIf\dFFCalcInfo-',FileName2(1:end-5),'.mat'),'-mat');
    elseif Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==3
        xlswrite(strcat(CurrentDir,'\BindFFSegOf\',FileName2), XlsxToWrite2);
        save (strcat(CurrentDir,'\BindFFSegOf\dFFCalcInfo-',FileName2(1:end-5),'.mat'),'-mat');
    end
        
%         print1=size(dFFFragment)
    end
end
