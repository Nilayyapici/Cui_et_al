clear all
clc

HasOptoAndIngIndicator=0;%Change here!!!Set to 0 if it only has Ingestion indicator, 1 if it has both ingestion and optogenetic indicator
ImageTimeMin=8;%Change here!!
ImageTimeSec=0;%Change here!!
PlotROIAveragedFFOrNot=0;%1-Plot Average of all ROI, 0- Do Not Plot Average of all ROI
AlignToStim2OrNot1=1;
TotalTimeSec=ImageTimeMin*60+ImageTimeSec; %
TimeSecBeforeStim=50; 
TimeSecAfterStim=300; 
SetColorSpec={[0, 0, 1];[0,1,0];[0.6, 0.8250, 0.280];[0.9290, 0.6940, 0.5250];[0.4940, 0.6840, 0.5560];[0.75, 0.5, 0.75];...
    [0.660, 0.8740, 0.480];[0, 0.5, 0.16];[0.5010, 0.7450, 0.9330];[0.6350, 0.0780, 0.2840];[0.6350, 0.0780, 0.55];...
    [0.6350, 0.0780, 0.3];[0.6350, 0.2, 0.55];[0.6350, 0.2780, 0.65];[0.9350, 0.0780, 0.55];[0.8350, 0.780, 0.55];...
    [0.8500, 0.6250, 0.280];[0.6, 0.6250, 0.980];[0.6350, 0.2780, 0.9];[0.6350, 0.2780, 0.47];[0.3, 0.2780, 0.9];[0.6350, 0.7780, 0.9];[0.6350, 0.80, 0.9]};


list_of_directories = {...
    'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig6(CS,IN1TNT,CEM\Fig6b(CS,IngImg\right,HighSucrose\IngAdded\BindFFSeg'...
%         'G:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\222FluoXlsx,NoBGSub\CS,Fasted,UL100mM&1MSucFluoFoodIng\100mM\IngAdded'...
%         'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\CDG2,IngWithOpto(Exp)'...
%         'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\CDG2,IngWithOpto(NRC)'...
%         'G:\我的云端硬盘\Worki\AvgdFFResponsePlot,Chec-Current\IngstionDFF\Gut11'...
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

%-------Read xlsx-------------

        [XlsxNum,XlsxText,XlsxAll]=xlsread(CurDataPath);
        if HasOptoAndIngIndicator==0
    %         XlsxNum(1, :)=[];
            NewXlsxText2=XlsxText(1:end-1);
            ROIColNo=[1: size(XlsxAll,2)-1];
            ROIdFF=XlsxNum(:,ROIColNo);
            IngColData=XlsxNum(:,end);
        elseif HasOptoAndIngIndicator==1
            NewXlsxText2=XlsxText(1:end-2);
            ROIColNo=[1: size(XlsxAll,2)-2];
            ROIdFF=XlsxNum(:,ROIColNo);
            OptoColData=XlsxNum(:,end-1);
            IngColData=XlsxNum(:,end);
        end
        
        XlsxRowNo=size(XlsxNum,1);
    %% -------Plot and save figures&Data-----------        
if HasOptoAndIngIndicator==1
    LightOnBars1=OptoColData;
end
LightOnBars2=IngColData;
       if AlignToStim2OrNot1==1
        Finalx=[0:XlsxRowNo-1];
       elseif AlignToStim2OrNot1==2
        Finalx=[(-1)*TimeSecBeforeStim:TimeSecAfterStim-1];
       end
       %--------plot interpolated figure----------
   fig1=figure;
    left_color = [.1 .1 1];
    right_color = [0 0 0];
    set(fig1,'defaultAxesColorOrder',[left_color; right_color]);
       
       yyaxis right
           b2=bar(Finalx,LightOnBars2, 1,'k');
           b2.FaceAlpha=0.2;
           ylabel('Food Touching Proboscis');
           ylim([0,1]);
            hold on
        if HasOptoAndIngIndicator==1            
           b1=bar(Finalx,LightOnBars1, 1,'r');
           b1.FaceAlpha=0.2;
%            ylabel('Food Touching Proboscis');
%            ylim([0,1]);
        end
       
       yyaxis left
       if PlotROIAveragedFFOrNot==1
        for i=1:size(ROIdFF,2)
            p1=plot(Finalx,ROIdFF(:,i),'-','Color',SetColorSpec{i},'LineWidth',0.5);
            hold on
        end
        MeandFF=mean(ROIdFF,2);
        MeandFF=MeandFF';
        p2=plot(Finalx,MeandFF,'-','Color',[0 0 0],'LineWidth',1.5);
       else
        for i=1:size(ROIdFF,2)
            p1=plot(Finalx,ROIdFF(:,i),'-','Color',SetColorSpec{i},'LineWidth',1.5);
            hold on
        end
       end
       xlabel('Time(s)')
       ylabel('dF/F')       
       legend(NewXlsxText2);       
       if AlignToStim2OrNot1==1
       xlim([0, TotalTimeSec]);
       elseif AlignToStim2OrNot1==2
        xlim([(-1)*TimeSecBeforeStim, TimeSecAfterStim]);
       end
       
       set(fig1, 'Units', 'Inches', 'Position', [0, 0, 12, 3.5], 'PaperUnits', 'Inches', 'PaperSize', [12, 3.5]);
       
       
       ExpName=Folder2(1:end-5);
       
       for i4=1:15
           if ExpName(i4)=='_'
               ExpName(i4)='';
           end
       end
       for i4=15:length(ExpName)
           if ExpName(i4)=='_'
               ExpName(i4)='>';
           end
       end
       tit1=Folder2(1:end-5);
       tit2=strcat('IngDFFPlot-',ExpName);
       title(tit2);
       mkdir IngPlot
       savefig(strcat(Folder1,'\IngPlot\',tit1,'.fig'));
       
       print(fig1, strcat(Folder1,'\IngPlot\',tit1,'.png'),'-dpng','-r0');
       print(fig1, strcat(Folder1,'\IngPlot\',tit1,'.svg'),'-dsvg','-r0');
       
       save('PlotInfo')
       
    end    
end

