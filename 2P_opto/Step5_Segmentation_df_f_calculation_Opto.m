%-----------Calculate and plot average response curve (across differenct
%trials) 2021Jan22version-------------
%----In this version, dFF will be re-calculated, and the normalization will
%be performed for each time of stimulation-------
%-------2021Jan22VersionUpdate:Added Binning feature besides the
%interpolation-------------
clear all
clc

stimtime=10; %In Second, Change here if need!!! Usually 1s or 10s
TimeStartBeforeStim=10;%in seconds. Change here!!,usually7 for 1s stim trials, or 10 for 10s stim trials
TimeStopAfterStim=10;%in seconds. Change here!!,usually7 for 1s stim trials, or 20 for 10s stim trials
TimeResolution=0.25;% in second,usually 0.25
dFFOutlierThreshold=10;%Change If need, usually 10

ImageTimeMin=4;%Change here!!
ImageTimeSec=0;%Change here!!

%------Note: By default, in this code, basal F segment was chosen as all
%the time before stimulation (-7s(before stim) to 0s, in this case)----
BasalFTimeLength=5;%In seconds, usually 5 for 1s and 10s stim trials
BalsalFEndTime=1;%basal frame is set to "from the (BalsalFEndTime) before first stim to (BalsalFEndTime+BasalFTimeLength) secs before first stim", usually 1 for 1s and 10s stim trials

list_of_directories = {...
    'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig5(IN1-CEM\Fig5e(IN1-CEM,10sOpto\Fig5e,left\IN1Chr,10s'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\Gal4 imaging\IN1-CDG2,NoLexA,PG\10s'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\Wiso,St(p\1s'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\Gr64f(P'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\Gr66a(P'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\ppk28,St(p'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\TMC(p'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\Gr43aII(P\2019-2020,InUse'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\Gr43aII-Cha(New)(P\2020(InUse'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\Gr43aIII(p'...
% 'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\GutLines\(Gut2)24D12G4A,38B05G4D(P\1s(p'...
% 'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\Gal4 imaging\IN1-CDG2,NoLexA,PG\1s'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\Gr64f&Gr66a(p'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\Ir25a(p'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\Dh44(p'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\Gr5a(p'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\Gr64a(P'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\Gr64d(P'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\GutLines\(Gut1)25F11G4A,38B05G4D(p\1s(p'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\GutLines\(Gut3)25F11G4A,24D12G4D(P\10mA1s'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\GutLines\(Gut4)24D12G4A,15D05G4D(P'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\GutLines\(Gut5)25F11G4A,15D05G4D(P'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\GutLines\(Gut6)44F09G4A,24D12G4D(p'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\GutLines\(Gut8)44F09G4A,25F11G4D(p\Only1stROI'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\GutLines\(Gut9)44F09G4A,15D05G4D(p'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\GutLines\(Gut10)37A08G4A,38B05G4D(p\BASelectedSA+SA'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\GutLines\(Gut11)37A08G4A,24D12G4D(p'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\GutLines\(Gut12)37A08G4A,25F11G4D(p'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\GutLines\(Gut15)24D12G4A,70C02G4D(p\SA+BAsSA'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\GutLines\(Gut18)44F09G4A,70C02G4D(p\SA+BAsSA'...
% 'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\GutLines\(Gut20)44F09G4A,20G03G4D(p\SA+selectedBA'...
% 'G:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\GutLines\(Gut15)24D12G4A,70C02G4D(p\SA+BAsSA\OutlierInc'...
    };

%% -----------Above: please change before each time of use------

% dFFFragment=zeros(FrameStartBeforeStim+FrameStopAfterStim+1,length(LightOnRowList));
for directory_idx  = 1:numel(list_of_directories)
    CurrentDir=list_of_directories{directory_idx};
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
        ROISubBGFluo=ROIFluo-RepBGFluo;
        
%% ------Find light on rows, get fragments---------
%------Get light on list, find light on rows----
        StimIndColNo=find(strcmp(XlsxTitle,'LightOn'));
        StimIndCol=XlsxNum(:,StimIndColNo);
        
        LightOnRowList=find(StimIndCol==1);
        
        ToBeDelete=[];
        
            for i=2:length(LightOnRowList)
                if LightOnRowList(i)-LightOnRowList(i-1)==1
                    ToBeDelete=[ToBeDelete,i];
                end
            end
        LightOnRowList(ToBeDelete)=[];

%-----------Get fragments--------        
        TotalTimeInSec=ImageTimeMin*60+ImageTimeSec;
        TimeToFrame=size(ROISubBGFluo,1)/TotalTimeInSec;
        FrameStartBeforeStim=ceil((TimeStartBeforeStim)*TimeToFrame);
        FrameStopAfterStim=ceil((TimeStopAfterStim)*TimeToFrame);
        
        FluoResponseFragments=[];
        for i=1:length(LightOnRowList)
            if size(XlsxNum,2)>3
            FragmentAddToFluo=ROISubBGFluo(LightOnRowList(i)-FrameStartBeforeStim : ...
                ceil(LightOnRowList(i)+FrameStopAfterStim + stimtime*TimeToFrame-1),1:2);
            else
            FragmentAddToFluo=ROISubBGFluo(LightOnRowList(i)-FrameStartBeforeStim : ...
                ceil(LightOnRowList(i)+FrameStopAfterStim + stimtime*TimeToFrame-1),1);
            end
            if size(FragmentAddToFluo,1)<size(FragmentAddToFluo,2)
                FragmentAddToFluo=FragmentAddToFluo';
            end
            FluoResponseFragments=[FluoResponseFragments, FragmentAddToFluo];
        end


%% -------Get Basal F for each stim, calculate dFF----------
%         FirstOnFrame=floor((TimeStartBeforeStim+1)*TimeToFrame);
        FirstOnFrame=FrameStartBeforeStim+1;%Changed this row in 2020Feb27
        
        BasalFEndFrame=FirstOnFrame-ceil(BalsalFEndTime*TimeToFrame);
%         BasalFEndFrame=floor(size(FluoResponseFragments,1)/2)-1;
        BasalFStartFrame=BasalFEndFrame-ceil(BasalFTimeLength*TimeToFrame);
%         BasalFStartFrame=1;
        BasalFSegments=FluoResponseFragments(BasalFStartFrame:BasalFEndFrame-1,:);
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
        
        mkdir('IntdFFSeg');
        mkdir('BindFFSeg');
        save(strcat(CurrentDir,'\IntdFFSeg\','dFFCalInfo-',XlsxList(idx1).name,'.mat'));
        save(strcat(CurrentDir,'\BindFFSeg\','dFFCalInfo-',XlsxList(idx1).name,'.mat'));
        %--------Interpolate dFFs from frames to time axis-------
%         TotalTimeInSec=
        FrameNo=size(dFF,1);
        FPS=TimeToFrame;
%         Newx=[FPS*TimeResolution:FPS*TimeResolution:(FrameNo-mod(FrameNo,FPS))]';
        NewxStart=FrameStartBeforeStim-TimeStartBeforeStim*FPS;
%         NewxEnd=FrameStartBeforeStim+TimeStopAfterStim*FPS+stimtime*FPS+1;
        NewxEnd=NewxStart+(TimeStartBeforeStim+TimeStopAfterStim+stimtime)*FPS;
        Newx=[NewxStart:FPS*TimeResolution:NewxEnd-TimeResolution]';
%         FinalTimeLength=floor(TotalTimeInSec-(1/FPS));
%         Finalx=[0:1:(FinalTimeLength-1)];
        
        InterpolatedDFF=interp1((0:FrameNo-1), dFF, Newx, 'linear');
        %------Calculate Binned dFF-----------
        FrameList=(0:FrameNo-1);
        BinEdges=[0:(FPS*TimeResolution):FPS*(TimeStartBeforeStim+TimeStopAfterStim+stimtime)];
        Bin1=discretize(FrameList,BinEdges);
        
        BinnedDFF=[];
        for ibin=1:max(Bin1)
            BinnedDFF=[BinnedDFF;mean(dFF(find(Bin1==ibin),:),1)];
        end
        %----------Write Re-calculated dFF into xlsx-------
        FileName=strcat('IntdFFSeg-',XlsxList(idx1).name);
        FileName2=strcat('BindFFSeg-',XlsxList(idx1).name);
        if size(XlsxNum,2)>3
            TitleToWrite={'Ar1Stim1','Ar2Stim1','Ar1Stim2','Ar2Stim2','Ar1Stim3','Ar2Stim3','Ar1Stim4','Ar2Stim4','Ar1Stim5','Ar2Stim5','LightOn'};
        else
            TitleToWrite={'ArStim1','ArStim2','ArStim3','ArStim4','ArStim5','LightOn'};
        end
        %----Write Interpolated DFF---------
        LightOnIndToWrite=zeros(size(InterpolatedDFF,1),1);
%         LightOnRowNo=(TimeStartBeforeStim/TimeResolution:TimeStartBeforeStim/TimeResolution+stimtime/TimeResolution-1);
        LightOnStartTime=floor((FrameStartBeforeStim+1)*(size(InterpolatedDFF,1)/size(dFF,1)));
        LightOnEndTime=LightOnStartTime+stimtime/TimeResolution-1;
        LightOnRowNo=(LightOnStartTime:LightOnEndTime);
        LightOnIndToWrite(LightOnRowNo)=1;
        NumToWrite=[InterpolatedDFF,LightOnIndToWrite];
        
        XlsxToWrite=[TitleToWrite;num2cell(NumToWrite)];
        XlsxToWrite(:,DiscardedDFFColList)=[];
        xlswrite(strcat(CurrentDir,'\IntdFFSeg\',FileName,'.xlsx'), XlsxToWrite);
        %-----------Write Binned DFF---------------
        LightOnIndToWrite=zeros(size(BinnedDFF,1),1);
%         LightOnRowNo=(TimeStartBeforeStim/TimeResolution:TimeStartBeforeStim/TimeResolution+stimtime/TimeResolution-1);
        LightOnStartTime=floor((FrameStartBeforeStim+1)*(size(BinnedDFF,1)/size(dFF,1)));
        LightOnEndTime=LightOnStartTime+stimtime/TimeResolution-1;
        LightOnRowNo=(LightOnStartTime:LightOnEndTime);
        LightOnIndToWrite(LightOnRowNo)=1;
        NumToWrite2=[BinnedDFF,LightOnIndToWrite];
        
        XlsxToWrite2=[TitleToWrite;num2cell(NumToWrite2)];
        XlsxToWrite2(:,DiscardedDFFColList)=[];
        xlswrite(strcat(CurrentDir,'\BindFFSeg\',FileName2,'.xlsx'), XlsxToWrite2);
        
%         print1=size(dFFFragment)
    end
end
