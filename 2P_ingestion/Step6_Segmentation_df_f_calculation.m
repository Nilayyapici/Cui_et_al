%-----------Calculate and plot average response curve (across different
%trials) 2021Jan22version-------------
%----In this version, dFF will be re-calculated, and the normalization will
%be performed for each time of stimulation-------
%-------2021Jan22VersionUpdate:Added Binning feature besides the
%interpolation-------------
clear all
clc

BackGroundSubtractionOn1OrOff0=0;%Change here!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Time0IsStimOnIndicator1OrIngestionOnIndicator2=2;%Change here!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TimeStartBeforeStim=50;%in seconds. 30 for 8m Gr43a ingestion imaging trial, 50 for 8m CEM ingestion imaging trial, 20 for regular 4m trial. 50 for regular single bout 8m trial. If don't want to cut off just set it to 99999
TimeStopAfterStim=50;%in seconds. 30 for 8m Gr43a ingestion imaging trial, 50 for 8m CEM ingestion imaging trial, 20 for regular 4m trial. 50 for regular single bout 8m trial. If don't want to cut off just set it to 99999
TimeResolution=1;% in second,usually 0.25 or 1
dFFOutlierThreshold=10000;%Change If need, usually 10

ImageTimeMin=8;%Change here!!!!!!!
ImageTimeSec=0;%Change here!!
TotalTimeInSec=ImageTimeMin*60+ImageTimeSec;

BasalFTimeLength=10;%In seconds, for ingestion imaging data, usually 10
BalsalFEndTime=0;%for ingestion imaging data, usually 0. basal frame is set to "from the (BalsalFEndTime) before first stim to (BalsalFEndTime+BasalFTimeLength) secs before first stim". For ingestion imaging experiment, usually 0 to -10s

list_of_directories = {...
'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig4(GutLineIngImg)\Fig4d(GutLineIngImg\EN2\Gut2'...
'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig4(GutLineIngImg)\Fig4d(GutLineIngImg\EN3\Gut3'...
'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig4(GutLineIngImg)\Fig4d(GutLineIngImg\EN10\Gut10'...
'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig4(GutLineIngImg)\Fig4d(GutLineIngImg\EN11\Gut11'...
%     'F:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\PotentialRev\Gr43a,1MFructose'...
%     'F:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\PotentialRev\Gr43a,50mMNaCl'...
    };

%% -----------Above: please change before each time of use------

% dFFFragment=zeros(FrameStartBeforeStim+FrameStopAfterStim+1,length(StimOnRowList));
for directory_idx  = 1:numel(list_of_directories)
    CurrentDir=strcat(list_of_directories{directory_idx},'\IngAdded');
    cd(CurrentDir);
    Folder1=list_of_directories{directory_idx};
    disp(sprintf('Processing %s',Folder1));
    XlsxList=dir('*.xlsx');

    for idx1=1:size(XlsxList,1)
        
        print2=XlsxList(idx1).name
        [XlsxNum,XlsxTitle]=xlsread(XlsxList(idx1).name);
%% ------------Find BG row, do background subtraciton (or not) --------
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
        if Time0IsStimOnIndicator1OrIngestionOnIndicator2==1
            StimIndColNo=find(strcmp(XlsxTitle,'StimOn')||strcmp(XlsxTitle,'LightOn'));
        elseif Time0IsStimOnIndicator1OrIngestionOnIndicator2==2
            StimIndColNo=find(strcmp(XlsxTitle,'IngestionIndicator'));
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

%-----------Get fragments--------        
        TotalTimeInSec=ImageTimeMin*60+ImageTimeSec;
        TimeToFrame=size(ROISubBGFluo,1)/TotalTimeInSec;
        FrameStartBeforeStim=ceil((TimeStartBeforeStim)*TimeToFrame);
        FrameStopAfterStim=ceil((TimeStopAfterStim)*TimeToFrame);
        
        FluoResponseFragments=[];
        StimIndFragments=[];
        for i=1:1%length(StimOnRowList)%Changed on 2024Jan07. Now this code will only consider the first eating bout as the segment start time
            
            FragmentStartFrameNo=StimOnRowList(i)-FrameStartBeforeStim;
            if FragmentStartFrameNo<1
                FragmentStartFrameNo=1;
            end
            
            FragmentEndFrameNo=ceil(StimOnRowList(i)+FrameStopAfterStim-1);
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
        FirstOnFrame=StimOnRowList(1);%Changed this row in 2024Jan07
        
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
        mkdir('BindFFSeg');
%         %--------Interpolate dFFs from frames to time axis-------
% %         TotalTimeInSec=
% %         Newx=[FPS*TimeResolution:FPS*TimeResolution:(FrameNo-mod(FrameNo,FPS))]';
%         NewxStart=FrameStartBeforeStim-TimeStartBeforeStim*FPS;
%         NewxEnd=NewxStart+(TimeStartBeforeStim+TimeStopAfterStim)*FPS;
%         Newx=[NewxStart:FPS*TimeResolution:NewxEnd-TimeResolution]';
% %         FinalTimeLength=floor(TotalTimeInSec-(1/FPS));
% %         Finalx=[0:1:(FinalTimeLength-1)];
%         
%         InterpolatedDFF=interp1((0:FrameNo-1), dFF, Newx, 'linear');
    %--------Bin dFFs From Frames to time axis------
        FrameNo=size(dFF,1);
        FPS=TimeToFrame;
        FrameList=(0:FrameNo-1);
        BinEdges=[0:(FPS*TimeResolution):FPS*(TimeStartBeforeStim+TimeStopAfterStim)];
        Bin1=discretize(FrameList,BinEdges);
        
        BinnedDFF=[];
        BinnedIngInd=[];
        for ibin=1:max(Bin1)
            BinnedDFF=[BinnedDFF;mean(dFF(find(Bin1==ibin),:),1)];
            BinnedIngInd=[BinnedIngInd;max(StimIndFragments(find(Bin1==ibin),:))];
        end

        %----------Write Re-calculated dFF into xlsx-------
%         FileName=strcat('IntdFFSeg-',XlsxList(idx1).name);
        FileName2=strcat('BindFFSeg-',XlsxList(idx1).name);
        TitleToWrite={XlsxTitle{1:end-2},'IngestionOn'};
%         %----Write Interpolated DFF---------
%         StimOnIndToWrite=zeros(size(InterpolatedDFF,1),1);
% %         StimOnStartTime=floor((FrameStartBeforeStim+1)*(size(InterpolatedDFF,1)/size(dFF,1)))+1;
%         StimOnStartTime=floor(FirstStimOnFrame/FramePerSec);
%         StimOnEndTime=StimOnStartTime+RealStimTime/TimeResolution;
%         StimOnRowNo=(StimOnStartTime:StimOnEndTime);
%         for i=1:size(StimOnIndToWrite)
%         end
%         StimOnIndToWrite(StimOnRowNo)=1;
%         NumToWrite=[InterpolatedDFF,StimOnIndToWrite];
%         
%         XlsxToWrite=[TitleToWrite;num2cell(NumToWrite)];
%         XlsxToWrite(:,DiscardedDFFColList)=[];
%         xlswrite(strcat(CurrentDir,'\IntdFFSeg\',FileName), XlsxToWrite);
% 
%         save (strcat(CurrentDir,'\IntdFFSeg\dFFCalcInfo-',FileName2(1:end-5),'.mat'),'-mat');
        
%         %------Convert Stim On Indicator to time Axis (Obsolete on 2024Jan09!!)-------
%         StimOnIndToWrite=zeros(size(BinnedDFF,1),1);
%         for i=1:size(StimOnIndToWrite)
%             IndicatorBinL=floor(i*FramePerSec);
%             IndicatorBinU=ceil(i*FramePerSec);
%             SumOfIndInThisBin=sum(StimIndCol(IndicatorBinL:IndicatorBinU));
%             if SumOfIndInThisBin>0
%                 StimOnIndToWrite(i)=1;
%             end
%         end

        %-----------Write Binned DFF---------------
        
        NumToWrite2=[BinnedDFF,BinnedIngInd];
        
        XlsxToWrite2=[TitleToWrite;num2cell(NumToWrite2)];
        XlsxToWrite2(:,DiscardedDFFColList)=[];
        xlswrite(strcat(CurrentDir,'\BindFFSeg\',FileName2), XlsxToWrite2);
        
        save (strcat(CurrentDir,'\BindFFSeg\dFFCalcInfo-',FileName2(1:end-5),'.mat'),'-mat');
%         print1=size(dFFFragment)
    end
end
