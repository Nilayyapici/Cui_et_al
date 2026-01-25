%-----This Code will plot the averaged dFF response across 1st bout dFF
%cuts. Notice that because this code will assume each excel file only
%contains 1 dFF trace from 1 fly and assign a color to that trace of that
%fly so !!!please make sure the .xlsx flies in input path only contains ONE
%DFF TRACE OF THAT FLY!!!----------
clear all
clc

Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3=1;%set this to 1 usually, or set it to 2 if want to align trials to opto stim offset. 
PlotROI3OrNo=0;%If set t1 1, plot ROI3(the midgut roi), if set to 0, not plot ROI3
PlotIngestionBout1OrNot0=1;%Set 1 to enable plotting of ingestion bout. Set to 0 to disable.
PlotSeparateIngBouts=1;
SaveOverlayBarPlot=0;%If you want to overlay a var plot to the line plot, set it to 1. Otherwise set it to 0.

TimeResolutionOnExcel=1;%Check this!! This need to be consistent with the Time Resolution setting used in PlotAvgIngResp_part1_FluoSegCutter_reNormalize_ForOptoIng.m
dFFAUCCalcTimeStart=0;
dFFAUCCalcTimeStop=110;
%------------------------
YLimSetting=[-5, 60];%-5,20, or -2, 16; or -4,16; -5,60, or -4,8
XLimSetting=[-10, 110];% For CEM>Chr, set to [-6, 5]. For IN1>Chr, set to [-10, 110]
YStepSize=5;
XTickStepSize=10;%in seconds
BoutIndicatorMaxYHeightRatio=0.2;
PlotTimeBeforeStimOnset=10;%In second, 6 for CEM>Chrimson optogenetic with fluo food ingestion trial, 10s for IN1>Chrimson trials.
PlotTimeAfterStimOnset=110;%In second, 6 for CEM>Chrimson optogenetic with fluo food ingestion trial, 110s for IN1>Chrimson trials.
XFontSize=20;
YFontSize=20;
%-----------Check Above for chages!!!------------
list_of_directories = {...
    'C:\Users\zjucx\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\111FluoXlsx,WithBGSub\IN1Chr_OptoWithIng\ATR+'...
    'C:\Users\zjucx\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\111FluoXlsx,WithBGSub\IN1+_OptoWithIng\ATR+'...
%     'C:\Users\zjucx\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\111FluoXlsx,WithBGSub\+Chr_OptoWithIng\ATR+'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\111FluoXlsx,WithBGSub\CEM,IngWithOpto(ATR+Exp)'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\111FluoXlsx,WithBGSub\CEM,IngWithOpto(ATR-Cont)'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\111FluoXlsx,WithBGSub\+Chr_OptoWithIng\ATR+'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\111FluoXlsx,WithBGSub\IN1+_OptoWithIng\ATR+'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\111FluoXlsx,WithBGSub\IN1Chr_OptoWithIng\ATR+'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\111FluoXlsx,WithBGSub\IN1Chr_OptoWithIng\NRC'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\PiezoKO'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\Wiso'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\MsR1Mut84524'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\MyoMut84523'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\PiezoKO'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\CS,UL50mMNaCl'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\CS,UL300mMSucralose'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\CS,Fasted,UL100mM&1MSucFluoFoodIng\100mM\OutlierExcluded(InUse)'...
%     'C:\Users\Yapici\Dropbox\Worki\AvgdFFData-Current\IngstionDFF\222FluoXlsx,NoBGSub\CS,Fasted,UL100mM&1MSucFluoFoodIng\1M'...
%         'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig6(CS,IN1TNT,CEM\Fig6g(ATR+,OptoIng\CEM,IngWithOpto(Exp)'...
%         'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig6(CS,IN1TNT,CEM\Fig6i(ATR-,OptoIng\CEM,IngWithOpto(NRC)'...
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
    
    
        %% --------Plot separate traces----------
    mkdir ('Plots');
    cd(strcat(CurDir2,'\Plots'));
    
        fig1=figure;
        PlotTimeSec=size(dFFG1,1);
        left_color = [.1 .1 1];
        right_color = [0 0 0];
        Finalx=[0-PlotTimeBeforeStimOnset:TimeResolutionOnExcel:0+PlotTimeAfterStimOnset-TimeResolutionOnExcel];
        set(fig1,'defaultAxesColorOrder',[left_color; right_color]);
    
    if PlotIngestionBout1OrNot0==1
        yyaxis right
        if PlotSeparateIngBouts==1
            StepRatio=1/size(IngInd,2);
            AllIndLength=floor((sum(IngInd)-1)*TimeResolutionOnExcel);
            [sorted,sortRefNo]=sort(AllIndLength,'descend');
            for i=1:size(sortRefNo,2)
                    IndToPlot=IngInd(:,sortRefNo(i));
                    IngDurationToPlot=floor((sum(IndToPlot)-1)*TimeResolutionOnExcel);
                    HeightToPlot=(StepRatio*i)*BoutIndicatorMaxYHeightRatio;
                    xb1=[0 0 IngDurationToPlot IngDurationToPlot]; 
                    yb1=[0 HeightToPlot HeightToPlot 0];
                    b1=patch(xb1,yb1,'k');
                    hold on
                    b1.FaceAlpha=0.15;
                    b1.EdgeAlpha=0;
                    b1.EdgeColor='none';
            end    

        elseif PlotSeparateIngBouts==0
            xb2=[-0.5 -0.5 max(Finalx) max(Finalx)]; 
            yb2=[0 1 1 0];
            ylim ([0,1]);
    
            b2=patch(xb2,yb2,'k');
            hold on
            b2.FaceAlpha=0.15;
            b2.EdgeAlpha=0;
            b2.EdgeColor='none';
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
    set(fig1, 'Units', 'Inches', 'Position', [0.5, 0.5, 5, 3.5], 'PaperUnits', 'Inches', 'PaperSize', [12, 3.5]);
       
    savefig(strcat('SeparateTrials','.fig'));
    print(fig1, 'SeparateTrials','-dpng','-r0');
    print(fig1, 'SeparateTrials','-dsvg','-r0');

    %% --------Plot heatmap ------

    % ------ Create a colormap transitioning from blue to red ------
    
    % Define the number of colors in the colormap
    num_colors = 256; % Or choose any desired number
    
    % Create linear spaces for each color channel (Red, Green, Blue)
    % Blue-to-white transition
    blue_to_white = [linspace(0, 1, num_colors/2)', linspace(0, 1, num_colors/2)', ones(num_colors/2, 1)];
    % White-to-red transition
    white_to_red = [ones(num_colors/2, 1), linspace(1, 0, num_colors/2)', linspace(1, 0, num_colors/2)'];
    
    % Combine the transitions to create the full blue-white-red colormap
    bluewhitered_cmap = [blue_to_white; white_to_red];

    %----------Plot Esophagus Fluorescence (Group1)-------
    fig4=figure;   
    hax4=axes;
    left_color = [.1 .1 1];
    right_color = [0 0 0];
    set(fig4,'defaultAxesColorOrder',[left_color; right_color]);
    hmG1=imagesc(dFFG1');
    xticks([(((PlotTimeBeforeStimOnset/2)/TimeResolutionOnExcel)+0.5),...
        ((PlotTimeBeforeStimOnset+PlotTimeAfterStimOnset/2)/TimeResolutionOnExcel+0.5)]);  % Set tick position at the center of the split
    xticklabels({'Before Ingestion', 'After Ingestion'});  % Label x-axis
    hax4.TickDir = 'out';
    yticks(linspace(1,size(dFFG1,2),size(dFFG1,2)));
    hax4.TickLength = [0 0];
    hold on;  % Keep the current plot
    line([PlotTimeBeforeStimOnset/TimeResolutionOnExcel+0.5, PlotTimeBeforeStimOnset/TimeResolutionOnExcel+0.5], [0, size(dFFG2,2)+0.5], 'Color', 'w', 'LineStyle', '--', 'LineWidth', 2);
    
    colormap(bluewhitered_cmap);
    caxis([0 30]);
    colorbar;
    
    title('Heatmap of Oesophagus dF/F Before and After Ingestion');
    xlabel('Ingestion Phase');
    ylabel('Fly#');

    set(fig4, 'Units', 'Inches', 'Position', [0.5, 0.5, 5, 3.5], 'PaperUnits', 'Inches', 'PaperSize', [12, 3.5]);
    savefig(strcat('HeatMap_Eso','.fig'));
    print(fig4, 'HeatMap_Eso','-dpng','-r0');
    print(fig4, 'HeatMap_Eso','-dsvg','-r0');

    %----------Plot Crop Duct Fluorescence (Group2)-------
    fig3=figure;   
    hax3=axes;
    left_color = [.1 .1 1];
    right_color = [0 0 0];
    set(fig3,'defaultAxesColorOrder',[left_color; right_color]);
    hmG2=imagesc(dFFG2');
    
    xticks([(((PlotTimeBeforeStimOnset/2)/TimeResolutionOnExcel)+0.5),...
        ((PlotTimeBeforeStimOnset+PlotTimeAfterStimOnset/2)/TimeResolutionOnExcel+0.5)]);  % Set tick position at the center of the split
    xticklabels({'Before Ingestion', 'After Ingestion'});  % Label x-axis
    hax3.TickDir = 'out';
    yticks(linspace(1,size(dFFG2,2),size(dFFG2,2)));
    hax3.TickLength = [0 0];
    hold on;  % Keep the current plot
    line([PlotTimeBeforeStimOnset/TimeResolutionOnExcel+0.5, PlotTimeBeforeStimOnset/TimeResolutionOnExcel+0.5], [0, size(dFFG2,2)+0.5], 'Color', 'w', 'LineStyle', '--', 'LineWidth', 2);
    
    colormap(bluewhitered_cmap);
    caxis([0 30]);
    colorbar;

    title('Heatmap of Crop Duct dF/F Before and After Ingestion');
    xlabel('Ingestion Phase');
    ylabel('Fly#');

    set(fig3, 'Units', 'Inches', 'Position', [0.5, 0.5, 5, 3.5], 'PaperUnits', 'Inches', 'PaperSize', [12, 3.5]);
    savefig(strcat('HeatMap_CropDuct','.fig'));
    print(fig3, 'HeatMap_CropDuct','-dpng','-r0');
    print(fig3, 'HeatMap_CropDuct','-dsvg','-r0');

       %% ------Plot Mean+-dFF------
    fig2=figure;
    hax2=axes;
    PlotTimeSec=size(dFFG1,1);
    left_color = [.1 .1 1];
    right_color = [0 0 0];
    Finalx=[0-PlotTimeBeforeStimOnset:TimeResolutionOnExcel:0+PlotTimeAfterStimOnset-TimeResolutionOnExcel];
    set(fig2,'defaultAxesColorOrder',[left_color; right_color]);
    
    if PlotIngestionBout1OrNot0==1
        yyaxis (hax2,'right');

        if PlotSeparateIngBouts==1
            StepRatio=1/size(IngInd,2);
            AllIndLength=floor((sum(IngInd)-1)*TimeResolutionOnExcel);
            [sorted,sortRefNo]=sort(AllIndLength,'descend');
            for i=1:size(sortRefNo,2)
                    IndToPlot=IngInd(:,sortRefNo(i));
                    IngDurationToPlot=floor((sum(IndToPlot)-1)*TimeResolutionOnExcel);
                    HeightToPlot=(StepRatio*i)*BoutIndicatorMaxYHeightRatio;
                    xb1=[0 0 IngDurationToPlot IngDurationToPlot]; 
                    yb1=[0 HeightToPlot HeightToPlot 0];
                    b1=patch(xb1,yb1,'k');
                    hold on
                    b1.FaceAlpha=0.15;
                    b1.EdgeAlpha=0;
                    b1.EdgeColor='none';
            end    

        elseif PlotSeparateIngBouts==0
            xb2=[-0.5 -0.5 max(Finalx) max(Finalx)]; 
            yb2=[0 1 1 0];
            ylim ([0,1]);
    
            b2=patch(xb2,yb2,'k');
            hold on
            b2.FaceAlpha=0.15;
            b2.EdgeAlpha=0;
            b2.EdgeColor='none';
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
    if PlotROI3OrNo==1
        s3=shadedErrorBar(Finalx,MeandFFG3,SEMOfResponseG3,'lineProps','y-');
        set(s3.edge,'Color','#ebd534');
        s3.mainLine.Color = '#ebd534';
        s3.mainLine.LineWidth=2;
        s3.patch.FaceColor = '#ebc034';
       legend('ROI1(Oesopha)','ROI2(CropDuct)','ROI3(Proven)');       
    else
       legend('ROI1(Oesopha)','ROI2(CropDuct)');       
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

    set(fig2, 'Units', 'Inches', 'Position', [0.5, 0.5, 5, 3.5], 'PaperUnits', 'Inches', 'PaperSize', [12, 3.5]);    
    hax2.YAxis(1).Color='k';
    hax2.YAxis(2).Color='k';
    hax2.YAxis(2).Visible='off';
    set(gca,'TickDir','out');
    set(gca,'box','off');

    SEMFigFileName=strcat('Mean dFF Response +-SEM,Y',num2str(YLimSetting(1)),'-',num2str(YLimSetting(2)));
    savefig(strcat(SEMFigFileName,'.fig'));
    print(fig2, strcat(SEMFigFileName,'.png'),'-dpng','-r0');
    print(fig2, strcat(SEMFigFileName,'.svg'),'-dsvg','-r0');

    %--------Add bar plot----------
    if SaveOverlayBarPlot==1
        if PlotROI3OrNo==0
            BarPlotValues=[mean(dFFG1,2),mean(dFFG2,2)];
            bp1=bar(Finalx,BarPlotValues);
            bp1(1).FaceColor='m';
            bp1(2).FaceColor='g';  
           legend('ROI1(Oesopha)','ROI2(CropDuct)','ROI1(Oesopha)','ROI2(CropDuct)');       
        elseif PlotROI3OrNo==1
            BarPlotValues=[mean(dFFG1,2),mean(dFFG2,2),mean(dFFG3,2)];
            bp1=bar(Finalx,BarPlotValues);
            bp1(1).FaceColor='m';
            bp1(2).FaceColor='g';
            bp1(3).FaceColor='#ebd534'; 
           legend('ROI1(Oesopha)','ROI2(CropDuct)','ROI3(Proven)','ROI1(Oesopha)','ROI2(CropDuct)','ROI3(Proven)');    
        end
    
        SEMFigFileName2=strcat('BarPlot_MeanDFFResponse+-SEM_Y',num2str(YLimSetting(1)),'-',num2str(YLimSetting(2)));
        savefig(strcat(SEMFigFileName2,'.fig'));
        print(fig2, strcat(SEMFigFileName2,'.png'),'-dpng','-r0');
        print(fig2, strcat(SEMFigFileName2,'.svg'),'-dsvg','-r0');
    end

    %-----------Calculate peak dFF after time 0 (for ing onset) or time -1 (for opto offset)----------
    DataRowsBeforeStimOnset=PlotTimeBeforeStimOnset/TimeResolutionOnExcel;
    if Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==1
        PeakdFFStartCoutingX=DataRowsBeforeStimOnset+1;
    elseif Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==2||Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==3
        PeakdFFStartCoutingX=DataRowsBeforeStimOnset;
    end
    %-------------- Get segments to be calculated-----------
    SegmentToBeIncludedForCalc_G1=dFFG1(DataRowsBeforeStimOnset+dFFAUCCalcTimeStart/TimeResolutionOnExcel+1:...
        DataRowsBeforeStimOnset+(dFFAUCCalcTimeStart+dFFAUCCalcTimeStop)/TimeResolutionOnExcel,:);
    SegmentToBeIncludedForCalc_G2=dFFG2(DataRowsBeforeStimOnset+dFFAUCCalcTimeStart/TimeResolutionOnExcel+1:...
        DataRowsBeforeStimOnset+(dFFAUCCalcTimeStart+dFFAUCCalcTimeStop)/TimeResolutionOnExcel,:);
    SegmentToBeIncludedForCalc_G3=dFFG3(DataRowsBeforeStimOnset+dFFAUCCalcTimeStart/TimeResolutionOnExcel+1:...
        DataRowsBeforeStimOnset+(dFFAUCCalcTimeStart+dFFAUCCalcTimeStop)/TimeResolutionOnExcel,:);

    MaxdFFG1=max(SegmentToBeIncludedForCalc_G1);
    MaxdFFG2=max(SegmentToBeIncludedForCalc_G2);
    MaxdFFG3=max(SegmentToBeIncludedForCalc_G3);

    MindFFG1=min(SegmentToBeIncludedForCalc_G1);
    MindFFG2=min(SegmentToBeIncludedForCalc_G2);
    MindFFG3=min(SegmentToBeIncludedForCalc_G3);

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

    %---------Calculate AUC for each ROI----------
    AUC_G1=trapz(SegmentToBeIncludedForCalc_G1);
    AUC_G2=trapz(SegmentToBeIncludedForCalc_G2);
    AUC_G3=trapz(SegmentToBeIncludedForCalc_G3);

%---------Calculate Persistency 6 (1st falling edge time post-peak - 1st rising edge time post-ing onset) for each ROI of each fly-----------
    [Persistency6_G1, Thresholds_G1, FirstPeakMask_G1]=computePersistency6(dFFG1,IngInd,TimeResolutionOnExcel,0.5);
    [Persistency6_G2, Thresholds_G2, FirstPeakMask_G2]=computePersistency6(dFFG2,IngInd,TimeResolutionOnExcel,0.5);
    [Persistency6_G3, Thresholds_G3, FirstPeakMask_G3]=computePersistency6(dFFG3,IngInd,TimeResolutionOnExcel,0.5);

%% ---------Save plotted data and calculated max, min and peak dFF, and AUC------
    
    VerticalXlsxTitleToWrite=XlsxTitleToWrite';

    %---------Write all the statistics (Including peak, AUC, Persistency 6)----------
    HeaderP5=[{'NameOfTrial'},{'PeakdFFG1(Oesophagus)'},{'PeakdFFG2(CropDuct)'},{'PeakdFFG3(Proventriculus)'},...
        {'MaxdFFG1(Oesophagus)'},{'MaxdFFG2(CropDuct)'},{'MaxdFFG3(Proventriculus)'},...
        {'MindFFG1(Oesophagus)'},{'MindFFG2(CropDuct)'},{'MindFFG3(Proventriculus)'},...
        {strcat('AUC_',num2str(dFFAUCCalcTimeStart),'-',num2str(dFFAUCCalcTimeStop),'s_G1(Oesophagus)')},...
        {strcat('AUC_',num2str(dFFAUCCalcTimeStart),'-',num2str(dFFAUCCalcTimeStop),'s_G2(CropDuct)')},...
        {strcat('AUC_',num2str(dFFAUCCalcTimeStart),'-',num2str(dFFAUCCalcTimeStop),'s_G3(Proventriculus)')}];
    NumToWriteP5=[num2cell(PeakdFFG1'),num2cell(PeakdFFG2'),num2cell(PeakdFFG3'),...
        num2cell(MaxdFFG1'),num2cell(MaxdFFG2'),num2cell(MaxdFFG3'),...
        num2cell(MindFFG1'),num2cell(MindFFG2'),num2cell(MindFFG3'),...
        num2cell(AUC_G1'),num2cell(AUC_G2'),num2cell(AUC_G3')];
    AllToWriteP5=[HeaderP5;VerticalXlsxTitleToWrite,NumToWriteP5];

        %--------Write Persistency in a separete page of Excel sheet-------
    HeaderP6=[{'NameOfTrial'},{'Persistency6(1stPeakWidth)_G1(Oesophagus)'},...
        {'Persistency6(1stPeakWidth)_G2(CropDuct)'},{'Persistency6(1stPeakWidth)_G3(Proventriculus)'}];
    NumToWriteP6=[num2cell(Persistency6_G1),num2cell(Persistency6_G2),num2cell(Persistency6_G3)];
    AllToWriteP6=[HeaderP6;VerticalXlsxTitleToWrite,NumToWriteP6];
        
        %--------Write FirstPeakMasks for Persistency 6 in separete pages of Excel sheet-------   
    ZerosForPeakMasks=zeros(DataRowsBeforeStimOnset,size(FirstPeakMask_G1,2));

    NumToWriteP7=num2cell(FirstPeakMask_G1);
    AllToWriteP7=[XlsxTitleToWrite;NumToWriteP7];
    
    NumToWriteP8=num2cell(FirstPeakMask_G2);
    AllToWriteP8=[XlsxTitleToWrite;NumToWriteP8];

    NumToWriteP9=num2cell(FirstPeakMask_G3);
    AllToWriteP9=[XlsxTitleToWrite;NumToWriteP9];

    OutputFileName_Stats=strcat('Stats.xlsx');
    writecell(AllToWriteP5,OutputFileName_Stats,'Sheet','Peak&AUC','Range','A1');
    writecell(AllToWriteP6,OutputFileName_Stats,'Sheet','Persistency6','Range','A1');
    writecell(AllToWriteP7,OutputFileName_Stats,'Sheet','FirstPeakMask_G1','Range','A1');
    writecell(AllToWriteP8,OutputFileName_Stats,'Sheet','FirstPeakMask_G2','Range','A1');
    writecell(AllToWriteP9,OutputFileName_Stats,'Sheet','FirstPeakMask_G3','Range','A1');

    %---------Write all plotted data points----------
    XlsxDataToWriteP1=num2cell(dFFG1);
    AllContentToWriteP1=[XlsxTitleToWrite;XlsxDataToWriteP1];
    XlsxDataToWriteP2=num2cell(dFFG2);
    AllContentToWriteP2=[XlsxTitleToWrite;XlsxDataToWriteP2];
    XlsxDataToWriteP3=num2cell(dFFG3);
    AllContentToWriteP3=[XlsxTitleToWrite;XlsxDataToWriteP3];

    XlsxDataToWriteP4=num2cell(IngInd);
    AllContentToWriteP4=[XlsxTitleToWrite;XlsxDataToWriteP4];

    OutputFileName_PlottedData=strcat('PlottedData.xlsx');
    writecell(AllContentToWriteP1,OutputFileName_PlottedData,'Sheet','G1-Esophagus','Range','A1');
    writecell(AllContentToWriteP2,OutputFileName_PlottedData,'Sheet','G2-CropDuct','Range','A1');
    writecell(AllContentToWriteP3,OutputFileName_PlottedData,'Sheet','G3-Proven','Range','A1');
    if Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==1
        writecell(AllContentToWriteP4,OutputFileName_PlottedData,'Sheet','IngOnset','Range','A1');
    elseif Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==2
        writecell(AllContentToWriteP4,OutputFileName_PlottedData,'Sheet','IngOffset','Range','A1');
    elseif Time0AlignedToIngOnset1OrIngOffset2OrOptoOffset3==3
        writecell(AllContentToWriteP4,OutputFileName_PlottedData,'Sheet','Opto','Range','A1');
    end
    

    save ('PlotInfo');

    end    
        


%% -------Calculate Fly Persistency 6 (1st falling edge time post-peak - 1st rising edge time post-ing onset)-----------
function [Persistency6, Thresholds, PeakMaskMatrix] = computePersistency6(...
    dataMatrix, IngInd, FrameInterval, PersistencyThresholdFactor)

    [nRows, nFlies] = size(dataMatrix);

    % Preallocate outputs
    Persistency6 = zeros(nFlies, 1);
    Thresholds = zeros(nFlies, 1);
    PeakMaskMatrix = false(nRows, nFlies);  % Full length mask

    for i = 1:nFlies
        trace = dataMatrix(:, i);
        ingestionMask = logical(IngInd(:, i));

        % Skip if no ingestion recorded
        if ~any(ingestionMask)
            Persistency6(i) = NaN;
            Thresholds(i) = NaN;
            continue;
        end

        % --- Define ingestion trace and threshold ---
        ingestionTrace = trace(ingestionMask);
        MaxVal = max(ingestionTrace);
        threshold = MaxVal * PersistencyThresholdFactor;
        Thresholds(i) = threshold;

        % --- Find ingestion onset (first time ingestion == 1) ---
        onsetIdx = find(ingestionMask, 1);  % First ingestion frame

        % Extract trace from ingestion onset to end
        postOnsetTrace = trace(onsetIdx:end);
        aboveThresh = postOnsetTrace > threshold;

        % --- Find rising edge: first upward crossing after onset ---
        padded = [0; aboveThresh(:)];
        edgeDiff = diff(padded);
        riseIdx = find(edgeDiff == 1, 1);  % relative to postOnsetTrace

        % --- Find peak position in post-onset trace ---
        [~, peakIdx] = max(abs(postOnsetTrace));

        % --- Find falling edge after peak ---
        allFallIdx = find(edgeDiff == -1);
        fallAfterPeak = allFallIdx(allFallIdx - 1 > peakIdx);


        if ~isempty(riseIdx) && ~isempty(fallAfterPeak)
            fallIdx = fallAfterPeak(1);
            durationFrames = fallIdx - riseIdx;
            Persistency6(i) = durationFrames * FrameInterval;

            % Map back to global frame index
            globalRise = onsetIdx + riseIdx - 1;
            globalFall = onsetIdx + fallIdx - 1;  
            PeakMaskMatrix(globalRise:globalFall, i) = true;
        else
            Persistency6(i) = NaN;
        end
    end
    PeakMaskMatrix=int8(PeakMaskMatrix);
end

