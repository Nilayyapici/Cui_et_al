%-----This Code will plot the averaged dFF response across 1st bout dFF
%cuts. Notice that because this code will assume each excel file only
%contains 1 dFF trace from 1 fly and assign a color to that trace of that
%fly so !!!please make sure the .xlsx flies in input path only contains ONE
%DFF TRACE OF THAT FLY!!!----------
clear all
clc

Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3=1;%set this to 1 usually, or set it to 2 if want to align trials to opto stim offset. 
PlotROI3OrNo1=1;%If set t1 1, plot ROI3(the midgut roi), if set to 0, not plot ROI3
PlotIngestionBout1OrNot0=1;%Set 1 to enable plotting of ingestion bout. Set to 0 to disable.
%------------------------
YLimSetting=[-5, 60];%-5,20, or -2, 16; or -4,16; -5,60, or -4,8
XLimSetting=[-6,5];
YStepSize=5;
XTickStepSize=1;%in seconds
BoutIndicatorMaxYHeightRatio=0.2;
PlotTimeBeforeStimOnset=6;%In second, 6 for optogenetic with fluo food ingestion trial, 50 for 8m food ingestion trial, 20 for 4m food ingestion trial.
PlotTimeAfterStimOnset=6;%In second, 6 for optogenetic with fluo food ingestion trial, 300 for 8m food ingestion trial, 140 for 4m food ingestion trial.
XFontSize=20;
YFontSize=20;
%-----------Check Above for chages!!!------------
list_of_directories = {...
        'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig6(CS,IN1TNT,CEM\Fig6g(ATR+,OptoIng\CEM,IngWithOpto(Exp)'...
        'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig6(CS,IN1TNT,CEM\Fig6i(ATR-,OptoIng\CEM,IngWithOpto(NRC)'...
%         'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\111FluoXlsx\CDG2,IngWithOpto(3groups)\CDG2,IngWithOpto(NRC)'...
%         'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\111FluoXlsx\CDG2,IngWithOpto(3groups)\CDG2,IngWithOpto(Exp)'...
%     'G:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\IN1_TNTFluoFoodIng\WxTNT\Outlier(Excluded)'...
%         'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\111FluoXlsx\CDG2,IngWithOpto(3groups)\CDG2,IngWithOpto(NRC)'...
%         'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\111FluoXlsx\CDG2,IngWithOpto(3groups)\CDG2,IngWithOpto(Exp)'...
%         'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\CDG2,IngWithOpto(3groups)\CDG2,IngWithOpto(NRC)'...
%         'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\CDG2,IngWithOpto(3groups)\CDG2,IngWithOpto(Exp)'...
%         'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\CDG2,IngWithOpto(3groups)\CDG2,IngWithOpto(NoRedLight)'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\CS,Fasted,UL100mM&1MSucFluoFoodIng\1M'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\CS,Fasted,UL100mM&1MSucFluoFoodIng\100mM\OutlierExcluded(InUse)'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\IN1_TNTFluoFoodIng\WxIN1'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\IN1_TNTFluoFoodIng\WxTNT'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\IN1_TNTFluoFoodIng\IN1xTNT'...
};

for directory_idx  = 1:numel(list_of_directories)
    CurrentDir=list_of_directories{directory_idx};
    cd(CurrentDir);
    Folder1=list_of_directories{directory_idx};
    disp(sprintf('Processing %s',Folder1));
    CurFolderlist=dir(Folder1);
    
    DataFolderList=[];
    SyncDataFolderList=[];
    %% ----------Plot Averaged Response--------
    if Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==1
        CurDir2=strcat(CurrentDir,'\IngAdded\BindFFSegIo');
    elseif Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==2
        CurDir2=strcat(CurrentDir,'\IngAdded\BindFFSegIf');
    elseif Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==3
        CurDir2=strcat(CurrentDir,'\IngAdded\BindFFSegOf');
    end
    cd(CurDir2);
    DataList2=dir('*.xlsx');
    XlsxTitleToWrite=[];
    dFFG1=[];
    dFFG2=[];
    dFFG3=[];
    OptoInd=[];
    IngInd=[];
    for i3=1:length(DataList2)
        %------Read Data-------
        CurDataPath=strcat(CurDir2,'\',DataList2(i3).name);
        [XlsxNum2,XlsxText2,XlsxAll2]=xlsread(CurDataPath);
        
        XlsxTitleToWrite=[XlsxTitleToWrite,{DataList2(i3).name}];
        dFFToAddToAlldFF=XlsxNum2(:,1:end-1);
        dFFG1=[dFFG1,dFFToAddToAlldFF(:,1)];
        dFFG2=[dFFG2,dFFToAddToAlldFF(:,2)];
        dFFG3=[dFFG3,dFFToAddToAlldFF(:,3)];
        
        OptoInd=[OptoInd,XlsxNum2(:,end-1)];
        IngInd=[IngInd,XlsxNum2(:,end)];
        %-------Note: I suddenly realize I will need to normalize all fluo
        %here maybe??? Fix it later---------
        
    end
    
    
        %--------Plot----------
    mkdir ('Plots');
    cd(strcat(CurDir2,'\Plots'));
    
        fig1=figure;
        PlotTimeSec=size(dFFG1,1);
        left_color = [.1 .1 1];
        right_color = [0 0 0];
        Finalx=[0-PlotTimeBeforeStimOnset:0+PlotTimeAfterStimOnset-1];
        set(fig1,'defaultAxesColorOrder',[left_color; right_color]);
    
    if PlotIngestionBout1OrNot0==1
        yyaxis right
        StepRatio=1/size(IngInd,2);
        AllIndLength=sum(IngInd);
        [sorted,sortRefNo]=sort(AllIndLength,'descend');
    for i=1:size(sortRefNo,2)
        IndToPlot=IngInd(:,sortRefNo(i));
        stimtime=sum(IndToPlot);
        HeightToPlot=(StepRatio*i)*BoutIndicatorMaxYHeightRatio;
        xb1=[0 0 stimtime stimtime];
        yb1=[0 HeightToPlot HeightToPlot 0];
        b1=patch(xb1,yb1,'k');
        hold on
        b1.FaceAlpha=0.15;
        b1.EdgeAlpha=0;
        b1.EdgeColor='none';
    end    
    ylabel('Ingestion Bout');
    ylim([0,1]);
    
    end
       yyaxis left

        p1=plot(Finalx,dFFG1(:,:),'-','Color',[0.7, 0.7, 1],'LineWidth',1);
        hold on
        p2=plot(Finalx,mean(dFFG1,2),'-','Color',[0.2, 0.2, 1],'LineWidth',2);
        p3=plot(Finalx,dFFG2(:,:),'-','Color',[0.7, 1, 0.7],'LineWidth',1);
        p4=plot(Finalx,mean(dFFG2,2),'-','Color',[0.2, 1, 0.2],'LineWidth',2);
        p5=plot(Finalx,dFFG3(:,:),'-','Color','#ebd534','LineWidth',1);
        p6=plot(Finalx,mean(dFFG3,2),'-','Color','#ebc034','LineWidth',2);
    
       xlabel('Time(s)');
       ylabel('\DeltaF/F');
       
%     XLimSetting=[min(Finalx),max(Finalx)];
    xlim(XLimSetting);
    xticks(min(Finalx):XTickStepSize:max(Finalx));
    set(fig1, 'Units', 'Inches', 'Position', [0, 0, 5, 3.5], 'PaperUnits', 'Inches', 'PaperSize', [12, 3.5]);
       
    savefig(strcat('SeparateTrials','.fig'));
    print(fig1, 'SeparateTrials','-dpng','-r0');
    print(fig1, 'SeparateTrials','-dsvg','-r0');

       
       %------Plot Mean+-dFF------
    fig2=figure;
    hax2=axes;
    PlotTimeSec=size(dFFG1,1);
    left_color = [.1 .1 1];
    right_color = [0 0 0];
    Finalx=[0-PlotTimeBeforeStimOnset:0+PlotTimeAfterStimOnset-1];
    set(fig2,'defaultAxesColorOrder',[left_color; right_color]);
    
    if PlotIngestionBout1OrNot0==1
        yyaxis (hax2,'right');

        StepRatio=1/size(IngInd,2);
        AllIndLength=sum(IngInd);
        [sorted,sortRefNo]=sort(AllIndLength,'descend');
        for i=1:size(sortRefNo,2)
                IndToPlot=IngInd(:,sortRefNo(i));
                stimtime=sum(IndToPlot);
                HeightToPlot=(StepRatio*i)*BoutIndicatorMaxYHeightRatio;
                xb1=[0 0 stimtime stimtime];
                yb1=[0 HeightToPlot HeightToPlot 0];
                b1=patch(xb1,yb1,'k');
                hold on
                b1.FaceAlpha=0.15;
                b1.EdgeAlpha=0;
                b1.EdgeColor='none';
        end    
    ylabel('Ingestion Bout');
    ylim([0,1]);
    
    end

    yyaxis (hax2,'left');
    MeandFFG1=mean(dFFG1,2);
    SEMOfResponseG1=std(dFFG1,[],2)./sqrt(size(dFFG1,2));
    MeandFFG2=mean(dFFG2,2);
    SEMOfResponseG2=std(dFFG2,[],2)./sqrt(size(dFFG2,2));
    MeandFFG3=mean(dFFG3,2);
    SEMOfResponseG3=std(dFFG3,[],2)./sqrt(size(dFFG3,2));

    s1=shadedErrorBar(Finalx,MeandFFG1,SEMOfResponseG1,'lineProps','m-');
    hold on
    s1.mainLine.LineWidth=2;
    s2=shadedErrorBar(Finalx,MeandFFG2,SEMOfResponseG2,'lineProps','g-');
    s2.mainLine.LineWidth=2;
    if PlotROI3OrNo1==1
        s3=shadedErrorBar(Finalx,MeandFFG3,SEMOfResponseG3,'lineProps','y-');
        set(s3.edge,'Color','#ebd534');
        s3.mainLine.Color = '#ebd534';
        s3.mainLine.LineWidth=2;
        s3.patch.FaceColor = '#ebc034';
       legend('ROI1(Foregut)','ROI2(CropDuct)','ROI3(Proven)');       
    else
       legend('ROI1(Foregut)','ROI2(CropDuct)');       
    end

%     plot(Finalx,MeandFF,'k-','LineWidth',1.5);
    xlabel('Time(s)','FontSize',XFontSize)
    ylabel('\DeltaF/F','FontSize',YFontSize);
       xlabel('Time(s)')
       ylabel('dF/F')       
    ylim(YLimSetting);
    yticks(YLimSetting(1):YStepSize:YLimSetting(2));
%     XLimSetting=[min(Finalx),max(Finalx)];
    xlim(XLimSetting);
    xticks(min(Finalx):XTickStepSize:max(Finalx));

    set(fig2, 'Units', 'Inches', 'Position', [0, 0, 5, 3.5], 'PaperUnits', 'Inches', 'PaperSize', [12, 3.5]);    
    hax2.YAxis(1).Color='k';
    hax2.YAxis(2).Color='k';
    hax2.YAxis(2).Visible='off';
    set(gca,'TickDir','out');
    set(gca,'box','off');

    SEMFigFileName=strcat('Mean dFF Response +-SEM,Y',num2str(YLimSetting(1)),'-',num2str(YLimSetting(2)));
    savefig(strcat(SEMFigFileName,'.fig'));
    print(fig2, strcat(SEMFigFileName,'.png'),'-dpng','-r0');
    print(fig2, strcat(SEMFigFileName,'.svg'),'-dsvg','-r0');

    %-----------Calculate peak dFF after time 0 (for ing onset) or time -1 (for opto offset)----------
    if Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==1
        PeakdFFStartCoutingX=PlotTimeBeforeStimOnset+1;
    elseif Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==2||Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==3
        PeakdFFStartCoutingX=PlotTimeBeforeStimOnset;
    end

    MaxdFFG1=max(dFFG1(PeakdFFStartCoutingX:end,:));
    MaxdFFG2=max(dFFG2(PeakdFFStartCoutingX:end,:));
    MaxdFFG3=max(dFFG3(PeakdFFStartCoutingX:end,:));

    MindFFG1=min(dFFG1(PeakdFFStartCoutingX:end,:));
    MindFFG2=min(dFFG2(PeakdFFStartCoutingX:end,:));
    MindFFG3=min(dFFG3(PeakdFFStartCoutingX:end,:));

    CompdFFG1=abs(MaxdFFG1)-abs(MindFFG1);
    CompdFFG2=abs(MaxdFFG2)-abs(MindFFG2);
    CompdFFG3=abs(MaxdFFG3)-abs(MindFFG3);
    [AnyReversalG1,ReversalLocationG1]=find(CompdFFG1<0);
    [AnyReversalG2,ReversalLocationG2]=find(CompdFFG2<0);
    [AnyReversalG3,ReversalLocationG3]=find(CompdFFG3<0);

    PeakdFFG1=MaxdFFG1;
    if size(AnyReversalG1)>0
        PeakdFFG1(ReversalLocationG1)=MindFFG3(ReversalLocationG1);
    end
    PeakdFFG2=MaxdFFG2;
    if size(AnyReversalG2)>0
        PeakdFFG2(ReversalLocationG2)=MindFFG3(ReversalLocationG2);
    end
    PeakdFFG3=MaxdFFG3;
    if size(AnyReversalG3)>0
        PeakdFFG3(ReversalLocationG3)=MindFFG3(ReversalLocationG3);
    end

%% ---------Save plotted data and calculated max, min and peak dFF------
    XlsxDataToWriteP1=num2cell(dFFG1);
    AllContentToWriteP1=[XlsxTitleToWrite;XlsxDataToWriteP1];
    XlsxDataToWriteP2=num2cell(dFFG2);
    AllContentToWriteP2=[XlsxTitleToWrite;XlsxDataToWriteP2];
    XlsxDataToWriteP3=num2cell(dFFG3);
    AllContentToWriteP3=[XlsxTitleToWrite;XlsxDataToWriteP3];

    XlsxDataToWriteP4=num2cell(IngInd);
    AllContentToWriteP4=[XlsxTitleToWrite;XlsxDataToWriteP4];

    VerticalXlsxTitleToWrite=XlsxTitleToWrite';
    HeaderP5=[{'NameOfTrial'},{'PeakdFFG1(Foregut)'},{'PeakdFFG2(CropDuct)'},{'PeakdFFG3(Proventriculus)'},...
        {'MaxdFFG1(Foregut)'},{'MaxdFFG2(CropDuct)'},{'MaxdFFG3(Proventriculus)'},...
        {'MindFFG1(Foregut)'},{'MindFFG2(CropDuct)'},{'MindFFG3(Proventriculus)'}];
    NumToWriteP5=[num2cell(PeakdFFG1'),num2cell(PeakdFFG2'),num2cell(PeakdFFG3'),...
        num2cell(MaxdFFG1'),num2cell(MaxdFFG2'),num2cell(MaxdFFG3'),...
        num2cell(MindFFG1'),num2cell(MindFFG2'),num2cell(MindFFG3')];
    AllToWriteP5=[HeaderP5;VerticalXlsxTitleToWrite,NumToWriteP5];

    OutputFileName=strcat('PlottedData.xlsx');
    writecell(AllContentToWriteP1,OutputFileName,'Sheet','G1-Foregut','Range','A1');
    writecell(AllContentToWriteP2,OutputFileName,'Sheet','G2-CropDuct','Range','A1');
    writecell(AllContentToWriteP3,OutputFileName,'Sheet','G3-Proven','Range','A1');
    writecell(AllContentToWriteP4,OutputFileName,'Sheet','IngOrOptoInd','Range','A1');
    writecell(AllToWriteP5,OutputFileName,'Sheet','Stat','Range','A1');

    save ('PlotInfo');
    
    end    
        

