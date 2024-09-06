%-----This Code will plot the averaged dFF response across 1st bout dFF
%cuts. Notice that because this code will assume each excel file only
%contains 1 dFF trace from 1 fly and assign a color to that trace of that
%fly so !!!please make sure the .xlsx flies in input path only contains ONE
%DFF TRACE OF THAT FLY!!!----------
clear all
clc

PlotFromFluoData=1;%Make sure this is correct!!!!
YLimSetting=[-0.2, 0.5];%[-0.2, 0.5] for Gut13.[-0.2, 0.05] for CDG
BoutIndicatorMaxYHeightRatio=0.2;%0.2 for Gut13. 0.2 for CDG
FigureWidth=5;%for figures in manuscript, set to 5. For regular plotting, set to 12.
FigureHeight=3.5;
PlotTimeBeforeStimOnset=50;%In second, 30 for 8m Gr43a ingestion imaging trial, 50 for 8m CEM ingestion imaging trial, 20 for regular 4m trial. 50 for regular single bout 8m trial.
PlotTimeAfterStimOnset=50;%In second, 30 for 8m Gr43a ingestion imaging trial, 50 for 8m CEM ingestion imaging trial, 20 for regular 4m trial. 300 for regular single bout 8m trial.
        PulseOn=0;
        XFontSize=20;
        YFontSize=20;
SetColorSpec={[0, 0, 1];[0,1,0];[0.6, 0.8250, 0.280];[0.9290, 0.6940, 0.5250];[0.4940, 0.6840, 0.5560];[0.75, 0.5, 0.75];...
    [0.660, 0.8740, 0.480];[0, 0.5, 0.16];[0.5010, 0.7450, 0.9330];[0.6350, 0.0780, 0.2840];[0.6350, 0.0780, 0.55];[0.6350, 0.0780, 0.3];[0.6350, 0.2, 0.55];[0.6350, 0.2780, 0.65];[0.9350, 0.0780, 0.55];...
    [0.8350, 0.780, 0.55];[0.8500, 0.6250, 0.280];[0.6, 0.6250, 0.980];...
    [0.22 0.63 0.11];[0.65 0.22 0.743];[0.33 0.62 0.33];[0.47 0.69 0.96]};


list_of_directories = {...
'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig4(GutLineIngImg)\Fig4d(GutLineIngImg\EN2\Gut2'...
'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig4(GutLineIngImg)\Fig4d(GutLineIngImg\EN3\Gut3'...
'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig4(GutLineIngImg)\Fig4d(GutLineIngImg\EN10\Gut10'...
'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig4(GutLineIngImg)\Fig4d(GutLineIngImg\EN11\Gut11'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\PotentialRev\Gr43a,1MFructose'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\PotentialRev\Gr43a,50mMNaCl'...
%     'J:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),RefedWS,1MSuc\OutExc'...
%     'J:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,1MSuc'...
%     'J:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,100mMSuc'...
%     'J:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),RefedWS,1MSuc\Outlier(240119M4T3CB3)Excluded'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,1MSuc'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),St,100mMSuc'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\Gr43a\Gr43a(PG),RefedWS,1MSuc'...
%     'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\GutLines\Gut2'...
%     'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\GutLines\Gut3'...
%     'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\GutLines\Gut4'...
%     'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\GutLines\Gut10'...
%     'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\GutLines\Gut11'...
%     'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\GutLines\Gut13'...
%     'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\CDG2,RefedWS,Fluo'...
%     'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\CDG2,1MSuc,Fasted,Fluo(ContFor100mMSuc),NoBGSub'...
%     'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\CDG2,100mMSuc,Fasted,Fluo,NoBGSub'...
%     'H:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\GutLines\Gut13'...
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
    if PlotFromFluoData==0
        CurDir2=strcat(CurrentDir,'\1stBoutCuts');
    elseif PlotFromFluoData==1
        CurDir2=CurrentDir;
    end

    CurDir2=strcat(CurrentDir,'\IngAdded\BindFFSeg');

    cd(CurDir2);
    DataList2=dir('*.xlsx');
    AlldFF=[];
    AllMeandFFFromEachFly=[];
    AllInd=[];
    XlsxTitleToWrite=[];
    AllROIdFFFromAllFly=[];
    XlsxTitleForEachROI=[];
    for i3=1:length(DataList2)
        %------Read Data-------
        CurDataPath=strcat(CurDir2,'\',DataList2(i3).name);
        XlsxTitleToWrite=[XlsxTitleToWrite,{DataList2(i3).name}];
        [XlsxNum2,XlsxText2,XlsxAll2]=xlsread(CurDataPath);
        
        dFFToAddToAlldFF=XlsxNum2(:,1:end-1);

        AllROIdFFFromAllFly=[AllROIdFFFromAllFly,dFFToAddToAlldFF];
        for k=1:size(XlsxText2,2)-1
            TitleToAdd=strcat(XlsxText2{1,k},'-',DataList2(i3).name);
            XlsxTitleForEachROI=[XlsxTitleForEachROI,{TitleToAdd}];
        end

        MeandFFOfThisFly=mean(dFFToAddToAlldFF,2);
        AlldFF=[AlldFF,dFFToAddToAlldFF];
        AllMeandFFFromEachFly=[AllMeandFFFromEachFly,MeandFFOfThisFly];
        
        IndicatorToAdd=XlsxNum2(:,end);
        AllInd=[AllInd,IndicatorToAdd];
    end
    
    mkdir('Plots');
        %--------Plot separate trials's averages----------
        fig1=figure;
        PlotTimeSec=size(AllMeandFFFromEachFly,1);
        left_color = [.1 .1 1];
        right_color = [0 0 0];
        Finalx=[0-PlotTimeBeforeStimOnset:0+PlotTimeAfterStimOnset-1];
        set(fig1,'defaultAxesColorOrder',[left_color; right_color]);
    
        yyaxis right
        StepRatio=1/size(AllInd,2);
        AllIndLength=sum(AllInd);
        [sorted,sortRefNo]=sort(AllIndLength,'descend');
    for i=1:size(sortRefNo,2)
        IndToPlot=AllInd(:,sortRefNo(i));
        stimtime=sum(IndToPlot);
        HeightToPlot=(StepRatio*i)*BoutIndicatorMaxYHeightRatio;
        xb1=[0 0 stimtime stimtime];
        yb1=[0 HeightToPlot HeightToPlot 0];
        b1=patch(xb1,yb1,'k');
        hold on
        b1.FaceColor=SetColorSpec{sortRefNo(i)};
        b1.FaceAlpha=0.15;
        b1.EdgeAlpha=0;
        b1.EdgeColor='none';
    end
    
%        legend;       
    ylabel('Proboscis Touching');
    ylim([0,1]);
    
       yyaxis left
    for i=1:size(AllMeandFFFromEachFly,2)
        p1=plot(Finalx,AllMeandFFFromEachFly(:,i),'-','Color',SetColorSpec{i},'LineWidth',1.5);
        hold on
    end
       xlabel('Time(s)')
       ylabel('\DeltaF/F')       
%        xlim([-30:330]);
       
       set(fig1, 'Units', 'Inches', 'Position', [0, 0, 12, 3.5], 'PaperUnits', 'Inches', 'PaperSize', [12, 3.5]);
   
       cd(strcat(CurDir2,'\Plots'));
    savefig(strcat('SeparateTrials','.fig'));
    print(fig1, 'SeparateTrials','-dpng','-r0');
    print(fig1, 'SeparateTrials','-dsvg','-r0');

    AllSingleROIdFFToWrite=num2cell(AllROIdFFFromAllFly);
    XlsxToWrite1=[XlsxTitleForEachROI;AllSingleROIdFFToWrite];
    xlswrite('PlottedData-SeparateDFFfromAllROI.xlsx',XlsxToWrite1);
       
       %------Plot Mean+-dFF------
       
        MeandFF=mean(AllMeandFFFromEachFly,2);
        SEMOfResponse=std(AllMeandFFFromEachFly,[],2)./sqrt(size(AllMeandFFFromEachFly,2));
        fig2=figure;
        PlotTimeSec=size(AllMeandFFFromEachFly,1);
%     left_color = [.1 .1 1];
    left_color = [0 0 0];
    right_color = [0 0 0];
    Finalx=[0-PlotTimeBeforeStimOnset:0+PlotTimeAfterStimOnset-1];
    set(fig2,'defaultAxesColorOrder',[left_color; right_color]);

        yyaxis right
        StepRatio=1/size(AllInd,2);
        AllIndLength=sum(AllInd);
        [sorted,sortRefNo]=sort(AllIndLength,'descend');
for i=1:size(sortRefNo,2)
        IndToPlot=AllInd(:,sortRefNo(i));
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
    
       
%     ylabel('Proboscis Touching');
    ylim([0,1]);
    ax1 = gca;                   % gca = get current axis
    ax1.YAxis(2).Visible = 'off';   % remove y-axis
    yticks([]);

       yyaxis left
    s=shadedErrorBar(Finalx,MeandFF,SEMOfResponse,'lineProps','k');
    hold on
    plot(Finalx,MeandFF,'k-','LineWidth',1.5);
    xlabel('Time(s)','FontSize',XFontSize)
    ylabel('\DeltaF/F','FontSize',YFontSize);
       xlabel('Time(s)')
       ylabel('dF/F')       
%        xlim([-30:330]);
    ylim(YLimSetting);
       
   set(fig2, 'Units', 'Inches', 'Position', [0, 0, FigureWidth, FigureHeight], 'PaperUnits', 'Inches', 'PaperSize', [12, 3.5]);
   set(gca,'TickDir','out');
   cd(strcat(CurDir2,'\Plots'));
    SEMFigFileName=strcat('Mean dFF Response +-SEM,Y',num2str(YLimSetting(1)),'-',num2str(YLimSetting(2)));
    savefig(strcat(SEMFigFileName,'.fig'));
    print(fig2, strcat(SEMFigFileName,'.png'),'-dpng','-r0');
    print(fig2, strcat(SEMFigFileName,'.svg'),'-dsvg','-r0');

    NumToWrite=num2cell(AllMeandFFFromEachFly);
    XlsxToWrite2=[XlsxTitleToWrite;NumToWrite];
    xlswrite(strcat('PlottedData-',SEMFigFileName,'.xlsx'),XlsxToWrite2);

    MatFileName=strcat('PlotInfo-',SEMFigFileName,'.mat');
    save (MatFileName);
    end    
        

