%----FlyDataProcessing3-AfterBatchExtraction,190630 edition------
% 2020Nov1 Update: The program will read the stimulation time length and if
% the stim time length is <1s then it will automatically determind the
% stimulation is in pulse mode, and adjust plotting accordingly.
%----Batch dF/F computing & Plotting--------
clear all
clc

BackGroundSubtractionOn1OrOff0=0;%Change here!!!!!!!!!!!!!!!!!!!!!!!!!!!!
FineTuningLightOnFrame=0;
RawFluoFileName='RegFluoDatL.xlsx';
xmlname='Experiment.xml';
ThorSyncFileName='Episode001.h5';
ThorSyncSettingFileName='ThorRealTimeDataSettings.xml';
SetColorSpec={[0,0,1];[0,1,0];[0.9290, 0.6940, 0.5250];[1, 0.3, 1];[0.5, 0.70, 0.7410];[0.940, 0.840, 0.6560];[0.5, 0.5, 0.75];...
    [0.660, 0.8740, 0.480];[0, 0.5, 0.16];[0.5010, 0.7450, 0.9330];[0.6350, 0.0780, 0.2840];[0.6350, 0.0780, 0.55];[0.6350, 0.0780, 0.3];[0.6350, 0.2, 0.55];[0.6350, 0.2780, 0.65];[0.9350, 0.0780, 0.55];[0.8350, 0.780, 0.55];[0.8500, 0.6250, 0.280];[0.6, 0.6250, 0.980];[0.16, 0.1620, 0.980];[0.26, 0.26, 0.9];[0.36, 0.36250, 0.2];[0.46, 0.50, 0.90];[0.1, 0.5, 0.16];[0.2, 0.15, 0.16];[0.3, 0.25, 0.16];[0.4, 0.5, 0.16];[0.5, 0.5, 0.16];[0.6, 0.5, 0.16];[0.7, 0.5, 0.16];[0.8, 0.5, 0.16];[0.9, 0.5, 0.16];[0.4, 0.25, 0.16]};

BasalFrameTime=10;
BalsalFEndTime=3;%This means the basal frame is set to "13 secs before first stim to 3 secs before first stim"
CutTailFrameNo=0;
LeastStimInterval=100;%In frame
BGIndThre=0.55;

AutoDetectTrialTime=1;% Set it to 1 -> This code will read the 7th character of your Trial Folder's name and determine the trial time. Set it to 0 to manually input the trial time below
ImageTimeMin=8;
ImageTimeSec=0;%Change here!!
PulseOn=0;

PesudoFirstStimTime=31;%Usually 31!

list_of_directories = {... 
    'F:\666ScriptTest2024Aug26\1_Gr43aOptoAct,IN1Imaging\200123'...
%     'J:\2PhoData\240712'...
%     'J:\2PhoData\240716'...
%     'J:\2PhoData\240720'...
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
        TempName=CurFolderlist(idx1).name;
        if TempName(1)=='M'||TempName(1)=='F'
            DataFolderList=[DataFolderList;{TempName}];
        elseif TempName(1)=='S'
            SyncDataFolderList=[SyncDataFolderList;{TempName}];
        end
    end
%---------Load Data--------------
    for i2=1: size(DataFolderList)
        Folder2=DataFolderList{i2};
        CurDataPath=strcat(Folder1,'\',Folder2);
%         CurrentSyncDataPath=strcat(Folder1,'\',Folder2)
       
       ExpName=Folder2;
       for i4=1:length(ExpName)
           if ExpName(i4)=='_'
               ExpName(i4)='>';
           end
       end
       
       if AutoDetectTrialTime==1
           if ExpName(7)=='4'
                ImageTimeMin=4;
                ImageTimeSec=0;
           elseif ExpName(7)=='8'
                ImageTimeMin=8;
                ImageTimeSec=0;
           end
       end
%---------Read xml-------------
        xmlpath=strcat(CurDataPath,'\',xmlname);
        [text1]=xml2struct_Joe(xmlpath);
        Timepoints=str2num(text1.ThorImageExperiment.Timelapse.Attributes.timepoints);
        ZEnabled=str2num(text1.ThorImageExperiment.Streaming.Attributes.zFastEnable);%If ZEnabled=1, then it's a ZT data. Vice versa.

        if ZEnabled==1
            cd(strcat(Folder1,'\',Folder2));
            if exist('ZProjCrop_LA','dir')
                TempFolder1=strcat(Folder1,'\',Folder2,'\ZProjCrop_LA')
            elseif exist('ZProjCrop_RA','dir')
                TempFolder1=strcat(Folder1,'\',Folder2,'\ZProjCrop_RA')
            elseif exist('ZProjCrop_CB','dir')
                TempFolder1=strcat(Folder1,'\',Folder2,'\ZProjCrop_CB')
            else
                TempFolder1=strcat(Folder1,'\',Folder2,'\ZProjected')
            end
            cd(TempFolder1);
            if exist ('ManualReged','dir')
                RegFolderName='ManualReged';
            elseif exist('TurboReged','dir')
                RegFolderName='TurboReged';
            elseif exist('Reg_Matlab_translation','dir')
                RegFolderName='Reg_Matlab_translation';
            elseif exist('Reg_Matlab_rigid','dir')
                RegFolderName='Reg_Matlab_rigid';
            elseif exist('PseudoReged','dir')
                RegFolderName='PseudoReged';
            end
            
            DataFolder=strcat(TempFolder1,'\',RegFolderName);
        else
            TempFolder1=strcat(Folder1,'\',Folder2);
            cd(TempFolder1);
            if exist('Reg_Matlab_translation','dir')
                RegFolderName='Reg_Matlab_translation';
            elseif exist('TurboReged','dir')
                RegFolderName='TurboReged';
            elseif exist('PseudoReged','dir')
                RegFolderName='PseudoReged';
            end
            
            DataFolder=strcat(Folder1,'\',Folder2,'\',RegFolderName);
        end
        cd(DataFolder);


%-------Read xlsx-------------

        [XlsxNum,XlsxText,XlsxAll]=xlsread(strcat(DataFolder,'\',RawFluoFileName));
        
        if CutTailFrameNo>0
            XlsxAll(size(XlsxAll,1)-CutTailFrameNo+1:size(XlsxAll,1),:)=[];
            XlsxNum(size(XlsxNum,1)-CutTailFrameNo+1:size(XlsxNum,1),:)=[];
        end
        
        BGColNo= find(strcmp([XlsxText], 'BG')); % change 'BG' to your background roi's name if it's not BG.
        ROIColNo=[1: size(XlsxAll,2)-1];
        ROIFluo=XlsxNum(:,ROIColNo);
        
        FrameNo=size(XlsxNum,1);

%-------Subtract BG-------------
    if BackGroundSubtractionOn1OrOff0==1
        BGFluo=XlsxNum(:,BGColNo);
        RepBGFluo=repmat(BGFluo, 1, size(ROIFluo,2));
        ROISubBGFluo1=ROIFluo-RepBGFluo;
    elseif BackGroundSubtractionOn1OrOff0==0
        BGFluo=zeros(size(XlsxNum,1),1);
        RepBGFluo=repmat(BGFluo, 1, size(ROIFluo,2));
        ROISubBGFluo1=ROIFluo-RepBGFluo;
    end

%-------Read Sync Data--------
        k=exist(strcat(Folder1,'\SyncData',Folder2));
        
        if k
            CurSyncFilePath=strcat(Folder1,'\SyncData',Folder2,'\');
            LoadSyncEpisode_CuiEdited_2020(ThorSyncFileName,CurSyncFilePath);
            
            %----------Read Sync xml, get stim time length-------
            SyncXml=xml2struct_Joe(xmlread(strcat(CurSyncFilePath,'ThorRealTimeDataSettings.xml')));
            StimLength=str2num(SyncXml.RealTimeDataSettings.DaqDevices.AcquireBoard{1, 3}.Bleach.Attributes.bleachTime)/1000;
            StimIdleTime=str2num(SyncXml.RealTimeDataSettings.DaqDevices.AcquireBoard{1, 3}.Bleach.Attributes.bleachIdleTime)/1000;
            StimIteration=SyncXml.RealTimeDataSettings.DaqDevices.AcquireBoard{1, 3}.Bleach.Attributes.bleachIteration;
            StimCycleNo=SyncXml.RealTimeDataSettings.DaqDevices.AcquireBoard{1, 3}.Bleach.Attributes.cycle;
            
            if exist('BleachOut')==0
                BleachOut=Bleach_Out;
            end
            LightOnInd=BleachOut(1:10000:end);
            timeInd=time(1:10000:end);

            %----Convert time in sync data to frame no of imaging data----------
            FrameToTimeRatio=time(end)/Timepoints;
            TimeToFrameRatio=Timepoints/time(end);
            LightOnList1=find(BleachOut);
            if isempty(LightOnList1)
                LightOnList1=round((PesudoFirstStimTime/time(end))*length(BleachOut));
            end
            FirstOn1=LightOnList1(1);
            FirstOnTime=time(FirstOn1);
            FirstOnFrame=floor(FirstOnTime*TimeToFrameRatio);
            
            %-------Get Basal Frame Numbers--------
            BasalFEndFrame=floor(FirstOnFrame-BalsalFEndTime*TimeToFrameRatio);
            BasalFStartTime=FirstOnTime-BasalFrameTime-BalsalFEndTime;
            BasalFStartFrame=round(BasalFStartTime*TimeToFrameRatio);
            BasalFrameVec=zeros(1,Timepoints);
            BasalFrameVec(BasalFStartFrame:BasalFEndFrame)=1;
        else
            BleachOut=zeros(Timepoints,1);
            %----Convert time in sync data to frame no of imaging data----------
            TotalTimeSec=ImageTimeMin*60+ImageTimeSec;
            
            FrameToTimeRatio=TotalTimeSec/Timepoints;
            TimeToFrameRatio=Timepoints/TotalTimeSec;
            
            FirstOnTime=round(PesudoFirstStimTime);
            FirstOnFrame=round(FirstOnTime*TimeToFrameRatio);
            
            BasalFEndFrame=floor(FirstOnFrame-BalsalFEndTime*TimeToFrameRatio);
            BasalFStartTime=FirstOnTime-BasalFrameTime-BalsalFEndTime;
            BasalFStartFrame=round(BasalFStartTime*TimeToFrameRatio);
            
            BasalFrameVec=zeros(1,Timepoints);
            BasalFrameVec(BasalFStartFrame:BasalFEndFrame)=1;
            
        end
       %% --------------Calculate Basal F--------
       BasalFluo=ROISubBGFluo1(find(BasalFrameVec), :);
       BasalF= mean(BasalFluo);
%        BasalF=abs(BasalF);
       %% ---------------Calculate dF/F--------
       RepBasalF=repmat(BasalF,size(ROISubBGFluo1,1),1);
       DeltaF=ROISubBGFluo1-RepBasalF;
       dFF=DeltaF./RepBasalF;
%        dFF=ROISubBGFluo1./RepBasalF;
%        dFF=dFF-1;
        InvertedDFFRowList=[];
       for i3=1:size(DeltaF,1)
           if DeltaF(i3)>0&&dFF(i3)<0
               dFF(i3)=-dFF(i3);
               InvertedDFFRowList=[InvertedDFFRowList,i3];
               print1=strcat('Abnormal dFF detected at ',num2str(i3),'/',num2str(size(DeltaF,1)),'inversed(- to +)')
           elseif DeltaF(i3)<0&&dFF(i3)>0
               dFF(i3)=-dFF(i3);
               InvertedDFFRowList=[InvertedDFFRowList,i3];
               print1=strcat('Abnormal dFF detected at ',num2str(i3),'/',num2str(size(DeltaF,1)),'inversed(+ to -)')
           end
       end
       
       %% -------Write raw dFF Result--------
       %--------Get light on frames no-----
        stepsize1=length(BleachOut)/Timepoints;
%         LightOnListForFrames=BleachOut(1:stepsize1:end);
        
        LightOnFramesNo=round(find(BleachOut)/stepsize1);
        LightOnFramesNo=unique(LightOnFramesNo);
        %-----Fine tuning of stim start time,edited 200221------
        MinBG=min(BGFluo);
        MaxBG=max(BGFluo);
        BGThre=(MaxBG-MinBG)*BGIndThre+MinBG;
        warn=0;
        BGThorSyncMismatchNo=0;
        StimStartFrameNo=[];
%         StimEndFrameNo=[];
        BGInd=find(BGFluo>BGThre);
        for i=1:length(LightOnFramesNo)
            if i==1|LightOnFramesNo(i)-LightOnFramesNo(i-1)>LeastStimInterval;
                StimStartFrameNo=[StimStartFrameNo,LightOnFramesNo(i)];
%                 if i>1
%                 StimEndFrameNo=[StimEndFrameNo,LightOnFramesNo(i-1)];
%                 end
            end
        end
%         StimEndFrameNo=[StimEndFrameNo,LightOnFramesNo(end)];
        StimStartFrameNo2=StimStartFrameNo;
%         StimEndFrameNo2=StimEndFrameNo;
        if FineTuningLightOnFrame==1
            for i=1:length(StimStartFrameNo)
                    if BGFluo(StimStartFrameNo2(i))< BGThre
                        ForwardCount1=0;
                        BackwardCount1=0;
                        while (StimStartFrameNo2(i)+ForwardCount1)<length(BGFluo) & BGFluo(StimStartFrameNo2(i)+ForwardCount1)<BGThre
                            ForwardCount1=ForwardCount1+1;
                        end
                        while (StimStartFrameNo2(i)+BackwardCount1)>0 & BGFluo(StimStartFrameNo2(i)+BackwardCount1)<BGThre
                            BackwardCount1=BackwardCount1-1;
                        end
                        if abs(BackwardCount1)<abs(ForwardCount1)
                            while BGFluo(StimStartFrameNo2(i)+BackwardCount1)>BGThre
                                BackwardCount1=BackwardCount1-1;
                            end
                            CorrValue1=BackwardCount1;
                        else
                            CorrValue1=ForwardCount1;
                        end
                        StimStartFrameNo2(i)=StimStartFrameNo2(i)+CorrValue1;
                        BGThorSyncMismatchNo=BGThorSyncMismatchNo+abs(CorrValue1);
                        if warn==0
                            warn=1;
                        end
                    end

                    if BGFluo(StimStartFrameNo2(i)-1)>BGThre
                        while BGFluo(StimStartFrameNo2(i)-1)>BGThre
                            StimStartFrameNo2(i)=StimStartFrameNo2(i)-1;
                            BGThorSyncMismatchNo=BGThorSyncMismatchNo+1;
                        end
                        if warn==0
                            warn=1;
                        end
                    end

    %                 if BGFluo(StimEndFrameNo2(i))<BGThre
    %                     while BGFluo(StimEndFrameNo2(i))<BGThre
    %                         StimEndFrameNo2(i)=StimEndFrameNo2(i)-1;
    %                         BGThorSyncMismatchNo=BGThorSyncMismatchNo+1;
    %                     end
    %                     if warn==0
    %                         warn=1;
    %                     end
    %                 end
    %                 if BGFluo(StimEndFrameNo2(i))>BGThre
    %                     while BGFluo(StimEndFrameNo2(i))>BGThre
    %                         StimEndFrameNo2(i)=StimEndFrameNo2(i)+1;
    %                         BGThorSyncMismatchNo=BGThorSyncMismatchNo+1;
    %                     end
    %                     if warn==0
    %                         warn=1;
    %                     end
    %                 end
            end
        end
        
        LightOnFramesNo2=[];
        LightOnListForFrames2=zeros(FrameNo,1);
        for i=1:length(StimStartFrameNo2)
            if BGFluo(StimStartFrameNo2(i)+ceil(StimLength*TimeToFrameRatio))>BGThre
                LightOnFramesNo2=[LightOnFramesNo2,StimStartFrameNo2(i):StimStartFrameNo2(i)+ceil(StimLength*TimeToFrameRatio)];
                LightOnListForFrames2(StimStartFrameNo2(i):StimStartFrameNo2(i)+ceil(StimLength*TimeToFrameRatio))=1;
            else
                LightOnFramesNo2=[LightOnFramesNo2,StimStartFrameNo2(i):StimStartFrameNo2(i)+ceil(StimLength*TimeToFrameRatio)-1];
                LightOnListForFrames2(StimStartFrameNo2(i):StimStartFrameNo2(i)+ceil(StimLength*TimeToFrameRatio)-1)=1;
            end
        end
        LightOnFramesNo2=LightOnFramesNo2';
%         if warn==1
%             warndlg(strcat('Thor Sync Bleach Out delayed by ',num2str(BGThorSyncMismatchNo),' frames. Manually correct light on frame number of ', CurSyncFilePath,' !'));
%         end

        %-----------Above:Fine tuning of stim start time,edited 200221------

        %-----Write xlsx-------
        NewXlsxText2=[XlsxText(ROIColNo)];
        NewXlsxText2=[NewXlsxText2,{'LightOn'}];
        NewXlsxNum2=[dFF,LightOnListForFrames2];
        NewXlsxAll2=[NewXlsxText2; num2cell(NewXlsxNum2)];
        WriteOnPage2=[{'BG-ThorSync Mismatch No'};num2cell(BGThorSyncMismatchNo)];
        WriteOnPage3part1=[{'ThorSyncLightOnFrames'};num2cell(LightOnFramesNo)];
        WriteOnPage3part2=[{'BGCorrectedLightOnFrames'};num2cell(LightOnFramesNo2)];
        
        FolderDateInd1=strfind(Folder1,'\');
        FolderDate=Folder1(FolderDateInd1(end)+1:FolderDateInd1(end)+6);
        
%         xlswrite(strcat(Folder1,'\',Folder2,'\Raw_dFF-',FolderDate,Folder2,'.xlsx'), NewXlsxAll2);
        %--------Initialization, clear previously written xlsx data----------
        BigBlank=cell(2000,100);
        xlswrite(strcat(Folder1,'\',Folder2,'\Raw_dFFL','.xlsx'), BigBlank,1,'A1');
        xlswrite(strcat(Folder1,'\',Folder2,'\Raw_dFFL','.xlsx'), BigBlank,2,'A1');
        xlswrite(strcat(Folder1,'\',Folder2,'\Raw_dFFL','.xlsx'), BigBlank,3,'A1');
        %--------Write Xlsx---------
        xlswrite(strcat(Folder1,'\',Folder2,'\Raw_dFFL','.xlsx'), NewXlsxAll2,1,'A1');
        xlswrite(strcat(Folder1,'\',Folder2,'\Raw_dFFL','.xlsx'), WriteOnPage2,2,'A1');
        xlswrite(strcat(Folder1,'\',Folder2,'\Raw_dFFL','.xlsx'), WriteOnPage3part1,3,'A1');
        xlswrite(strcat(Folder1,'\',Folder2,'\Raw_dFFL','.xlsx'), WriteOnPage3part2,3,'B1');
        
        ToAddToRawFluo=[{'LightOn'};num2cell(LightOnListForFrames2)];
        ToWriteToXlsxNew=[XlsxAll,ToAddToRawFluo];
        cd(Folder1);
        if ~exist('RawFluo', 'dir')
            mkdir('RawFluo')
        end
        
        %--------Initialization, clear previously written xlsx data----------
        xlswrite(strcat(Folder1,'\RawFluo','\RegFluoDatL-',FolderDate,Folder2,'.xlsx'),BigBlank,1,'A1');
        xlswrite(strcat(Folder1,'\RawFluo','\RegFluoDatL-',FolderDate,Folder2,'.xlsx'), BigBlank,2,'A1');
        xlswrite(strcat(Folder1,'\RawFluo','\RegFluoDatL-',FolderDate,Folder2,'.xlsx'), BigBlank,3,'A1');
        %--------Write Xlsx---------
        xlswrite(strcat(Folder1,'\RawFluo','\RegFluoDatL-',FolderDate,Folder2,'.xlsx'),ToWriteToXlsxNew,1,'A1');
        xlswrite(strcat(Folder1,'\RawFluo','\RegFluoDatL-',FolderDate,Folder2,'.xlsx'), WriteOnPage2,2,'A1');
        xlswrite(strcat(Folder1,'\RawFluo','\RegFluoDatL-',FolderDate,Folder2,'.xlsx'), WriteOnPage3part1,3,'A1');
        xlswrite(strcat(Folder1,'\RawFluo','\RegFluoDatL-',FolderDate,Folder2,'.xlsx'), WriteOnPage3part2,3,'B1');
        
        save(strcat(Folder1,'\',Folder2,'\RawdFF&CalcInfo(L)',FolderDate,Folder2,'.mat'), 'ROIFluo','BGFluo','ROISubBGFluo1','BasalFrameTime',...
            'BasalFrameVec','BasalFluo','BasalF','RepBasalF','DeltaF','dFF','InvertedDFFRowList','LightOnListForFrames2','LightOnFramesNo2','LightOnFramesNo','BGThorSyncMismatchNo','BGThre','BGIndThre');
       
    %% -------4. Plot and save figures&Data-----------        
       cd(Folder1);
       mkdir('dFF&Plots');
       cd(strcat(Folder1,'\',Folder2));
    % -------------Convert Frames into time, interpolate-------------
    if k
        TotalTimeSec=round(time(end));
        FPS=TimeToFrameRatio;
%         Newx=[0:FPS:floor(FrameNo-FPS)]';
        Newx=[0:FPS:(FrameNo-mod(FrameNo,FPS))]';%Cui changed this line at 07022019
%         FinalTimeLength=ceil(TotalTimeSec-(1/FPS));
        FinalTimeLength=size(Newx,1);
        Finalx=[0:1:(FinalTimeLength-1)];
        
        InterpolatedDFF1=interp1((1:FrameNo), dFF, Newx, 'linear');
        
        %--------Below: new Light on detector, edited 200221----
        TimeToFrameRatio2=FrameNo/FinalTimeLength;
%         LightOnRowsNo2=round(LightOnFramesNo2./TimeToFrameRatio2);
%         LightOnRowsNo2=unique(LightOnRowsNo2);
        
        StimStartTime=StimStartFrameNo2./TimeToFrameRatio2;
%         %-------Stim time length detector-------
%         if length(LightOnFramesNo2)<35
%             StimLength=1;
%         elseif length(LightOnFramesNo2)<350
%             if sum(diff(LightOnFramesNo2))>70
%                 StimLength=10;
%             else
%                 StimLength=60;
%             end
%         elseif length(LightOnFramesNo2)<750
%             StimLength=60;
%         end
%         %-------Stim time length detector end-------
        LightOnRowsNo2=[];
        if StimLength==1
            for i=1:length(StimStartTime)
                    LightOnRowsNo2=[LightOnRowsNo2,ceil(StimStartTime(i))-1:ceil(StimStartTime(i))];
            end
            PulseOn=0;
        elseif StimLength>1
            for i=1:length(StimStartTime)
            LightOnRowsNo2=[LightOnRowsNo2,ceil(StimStartTime(i))-1:ceil(StimStartTime(i))+StimLength-1];
            end
            PulseOn=0;
        elseif StimLength<1
            PulseOn=1;
        end
        LightOnBars2=zeros(size(Finalx));
        LightOnBars2(LightOnRowsNo2)=1;
        LightOnBars2=logical(LightOnBars2);
        %--------Above: new Light on detector, edited 200221----
    else
        FPS=TimeToFrameRatio;
%         Newx=[0:FPS:floor(FrameNo-FPS)]';
        Newx=[0:FPS:(FrameNo-mod(FrameNo,FPS))]';%Cui changed this line at 07022019
%         FinalTimeLength=ceil(TotalTimeSec-(1/FPS));
        FinalTimeLength=size(Newx,1);
        Finalx=[0:1:(FinalTimeLength-1)];

        
        InterpolatedDFF1=interp1((1:FrameNo), dFF, Newx, 'linear');
        LightOnBars2=zeros(length(Finalx),1);
        LightOnRowsNo2=[];
    end
        

       %--------plot interpolated figure
       fig1=figure;
       yyaxis right
       if PulseOn==0
           b2=bar(Finalx,LightOnBars2, 1,'r');
           b2.FaceAlpha=0.3;
           ylabel('Optogenetic Stimulation');
           ylim([0,1]);
       elseif PulseOn==1
           for j=1:str2num(StimCycleNo)
            for i=1:str2num(StimIteration)
                IteStimStart=StimStartTime(j)+((i-1)*(StimLength+StimIdleTime));
                IteStimEnd=IteStimStart+StimLength;
                xb1=[IteStimStart IteStimStart IteStimEnd IteStimEnd];
                yb1=[0 1 1 0];
                b1=patch(xb1,yb1,'r');
                b1.FaceAlpha=0.3;
                b1.EdgeAlpha=0;
                b1.EdgeColor='none';
            end
           end
       end
       
       yyaxis left
       
    for i=1:size(InterpolatedDFF1,2)
        p1=plot(Finalx,InterpolatedDFF1(:,i),'-','Color',SetColorSpec{i},'LineWidth',1.5);
        hold on
    end
       xlabel('Time(s)')
       ylabel('dF/F')       
       legend(NewXlsxText2(ROIColNo));       
       xlim([0, TotalTimeSec]);
       
       set(fig1, 'Units', 'Inches', 'Position', [0, 0, 12, 3.5], 'PaperUnits', 'Inches', 'PaperSize', [12, 3.5]);

       tit2=strcat('InterpRespL-',FolderDate,'-',ExpName);
       tit3=strcat('InterpRespL-',FolderDate,'-',Folder2);
       title(tit2);
       savefig(strcat(Folder1,'\',Folder2,'\',tit3,'.fig'));
       savefig(strcat(Folder1,'\dFF&Plots\',tit3,'.fig'));
       
       set(fig1, 'Units', 'Inches', 'Position', [0, 0, 12, 3.5], 'PaperUnits', 'Inches', 'PaperSize', [12, 3.5]);
       
%        cd(list_of_directories{directory_idx});
       print(fig1, strcat(Folder1,'\',Folder2,'\',tit3),'-dpng','-r0');
       
       print(fig1, strcat(Folder1,'\dFF&Plots\',tit3,'.png'),'-dpng','-r0');
       print(fig1, strcat(Folder1,'\dFF&Plots\',tit3,'.svg'),'-dsvg','-r0');
       
       %% -------Write interpolated dFF Result--------
        NewXlsxText2=[XlsxText(ROIColNo),{'LightOn'}];
        if size(LightOnBars2,1)<size(LightOnBars2,2)
            LightOnBars2=LightOnBars2';
        end
        NewXlsxNum2=[InterpolatedDFF1,LightOnBars2];
        NewXlsxAll2=[NewXlsxText2; num2cell(NewXlsxNum2)];
        
        xlswrite(strcat(Folder1,'\',Folder2,'\Int_dFF-',FolderDate,Folder2,'.xlsx'), NewXlsxAll2);
%         xlswrite(strcat(Folder1,'\',Folder2,'\IntdFFL-','.xlsx'), NewXlsxAll2);
        
        xlswrite(strcat(Folder1,'\dFF&Plots\IntdFFL-',FolderDate,Folder2,'.xlsx'), NewXlsxAll2);
        
        save(strcat(Folder1,'\',Folder2,'\IntdFF&CalcInfo(L)-',FolderDate,Folder2,'.mat'), 'ROIFluo','BGFluo','ROISubBGFluo1','FPS','BasalFrameTime',...
            'BasalFrameVec','BasalFluo','BasalF','RepBasalF','DeltaF','dFF','InvertedDFFRowList','LightOnBars2','LightOnRowsNo2');
        save(strcat(Folder1,'\dFF&Plots\IntdFF&CalcInfo(L)-',FolderDate,Folder2,'.mat'), 'ROIFluo','BGFluo','ROISubBGFluo1','FPS','BasalFrameTime',...
            'BasalFrameVec','BasalFluo','BasalF','RepBasalF','DeltaF','dFF','InvertedDFFRowList','LightOnBars2','LightOnRowsNo2');
        
        print1=strcat('dFF Plotting Progress: ', num2str(i2), ' / ', num2str(size(DataFolderList)))
        
        clear BleachOut Bleach_Out BleachComplete FitHz FrameCounter FrameIn FrameOut Hz PiezoMonitor Pockels1Monitor time 
        
    end    
end
