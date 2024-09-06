%-----------use newly calculated dFF in A2 to plot average response curve
%of each stim (normalized to the fluo before each stim----20190723version
%----In this version, dFF will be re-calculated, and the normalization will
%be performed for each time of stimulation-------

clear all
clc

stimtime=10; %In second, Change here if need!!!
% XLimSetting=[-7 8];%This is X limit for 1s stimulation, usually [-7 8]
XLimSetting=[-10 20];%This is X limit for 10s stimulation, usually [-10 20]
TimeStartBeforeStim=10;%in seconds. Change here!! for 1s stim, set to 7, for 10s, set to 10
TimeStopAfterStim=10;%in seconds. Change here!! for 1s stim, set to 7, for 10s, set to 20
TimeAxisResolution=0.25;
YStep=0.5;
% YLimSetting=[-0.6 1.6];%change here!!!, this is the range for MY figure 1 (-0.5 to 1.5)
% YLimSetting=[-0.5 2.5];%change here!!!, this is the range for MY figure 2 (-0.5 to 2.5)
YLimSetting=[-0.6 0.6];%change here!!!, this is the range for inhibition line (-0.6 to 0.6)
% YLimSetting=[-0.4 1.4];%change here!!!, this is the range for GR64f (-0.4 to 1.4)
% YLimSetting=[-0.4 1]%Range for Matt's paper([0.4,1])
% YLimSetting=[-0.5 4]%this is the range for GR43a (-0.5 to 2.5)
% YLimSetting=[-0.5 2.5]%this is the range for all(-0.5 to 1.5)
% YLimSetting=[-1 .5]%Temp Y setting
UseBinnedData=1;% set to 1 if you want to use binned version of dFF, set to 0 if  you want to use interpolated version of dFF

AllFontSize=15;
TitleFontSize=18;
XFontSize=20;
YFontSize=20;
AutoLineColor=0;
SetColorSpec={[0.5, 0.6470, 0.7410];[0, 0, 1];[0.8500, 0.6250, 0.980];[0.9290, 0.6940, 0.5250];[0.4940, 0.6840, 0.5560];[0.75, 0.5, 0.75];...
    [0.4660, 0.9740, 0.8880];[0, 0.5, 0];[0.5010, 0.7450, 0.9330];[0.6350, 0.0780, 0.2840];[0.6350, 0.0780, 0.55];[0.6350, 0.0780, 0.3];[0.6350, 0.2, 0.55];[0.6350, 0.2780, 0.65];[0.9350, 0.0780, 0.55];[0.8350, 0.780, 0.55];[0.8500, 0.6250, 0.280];[0.6, 0.6250, 0.980]};
% SetColorSpec={[0.8, 0.8, 0.8];[0.8, 0.8, 0.8];[0.8, 0.8, 0.8];[0.8, 0.8, 0.8];[0.8, 0.8, 0.8];[0.8, 0.8, 0.8];[0.8, 0.8, 0.8];[0.8, 0.8, 0.8];[0.8, 0.8, 0.8];[0.8, 0.8, 0.8]};

list_of_directories = {...
    'F:\222Paper2024-mycopy\2_DataForFigs_Current\Fig5(IN1-CEM\Fig5e(IN1-CEM,10sOpto\Fig5e,left\IN1Chr,10s'...
%     'G:\My Drive\Worki\AvgdFFResponsePlot,Chec-Current\IN1 imaging\Starved\Wiso,St(p\1s'...
    };
GAL4Image0OrIN1Image1OrSelfActImg2=1;
% StimulatorName={'Gut1','Gut3','Gut4','Gut5','Gut6','Gut8','Gut9','Gut10','Gut11','Gut12','Gut15','Gut18','Gut20'};
% StimulatorName={'Gr43a(II)','Gr43aIIG4,ChaG80','Gr43a(III)'};%Make sure this sequence is in accordance with the input sequence of folders
StimulatorName={'IN1','Gr5a','Gr64a','Gr64d','Gr64f','Gr66a','Ir25a','ppk28','TMC','+'};%Make sure this sequence is in accordance with the input sequence of folders
ImagerName={'CEM','IN1','IN1','IN1','IN1','IN1','IN1','IN1','IN1','IN1','IN1','IN1','IN1','IN1','IN1','IN1','IN1','IN1','IN1'};
% ImagerName={'94A09','ilp2','IN1','IN1','IN1','IN1','IN1','IN1','IN1','IN1','IN1','IN1','IN1'};
%-----------Above: please change before each time of use------
% dFFFragment=zeros(FrameStartBeforeStim+FrameStopAfterStim+1,length(LightOnRowList));
for directory_idx  = 1:numel(list_of_directories)
    
    clear dFFResponseFragments FragmentToAdd;
    
    dFFResponseFragments=[];
    dFFResponseFragmentsTitles=[];
    if UseBinnedData==1
        CurrentDir=strcat(list_of_directories{directory_idx},'\BindFFSeg');
    else
        CurrentDir=strcat(list_of_directories{directory_idx},'\IntdFFSeg');
    end
    cd(CurrentDir);
    Folder1=list_of_directories{directory_idx};
    disp(sprintf('Processing %s',Folder1));
    XlsxList=dir('*.xlsx');
    
    TrialGroupNo=[];
    for idx1=1:size(XlsxList,1)
        
        print2=XlsxList(idx1).name
        [XlsxNum,XlsxTitle]=xlsread(XlsxList(idx1).name);
        StimIndColNo=find(strcmp(XlsxTitle,'LightOn'));
        StimIndCol=XlsxNum(:,StimIndColNo);
        dFF=XlsxNum;
        dFF(:,StimIndColNo)=[];
        LightOnRowList=find(StimIndCol==1);
        
        CurrentTrialName={XlsxList(idx1).name};
        TitleToWrite1=repmat(CurrentTrialName,1,size(XlsxTitle,2)-1);
        TitleToWrite2=XlsxTitle;
        TitleToWrite2(:,StimIndColNo)=[];
        TitleToWrite=[TitleToWrite1;TitleToWrite2];
        
        for i=1:size(TitleToWrite,2)
            TrialGroupNo=[TrialGroupNo,idx1];
        end
%         for i=1:length(LightOnRowList)
            FragmentToAdd=dFF;
%             if size(FragmentToAdd,1)<size(FragmentToAdd,2)
%                 FragmentToAdd=FragmentToAdd';
%             end
            dFFResponseFragments=[dFFResponseFragments, FragmentToAdd];
            dFFResponseFragmentsTitles=[dFFResponseFragmentsTitles,TitleToWrite];
%         end
        
%             print1=size(dFFFragment)
    end
    %--------Before Plot-----------
    MeandFFResponse=mean(dFFResponseFragments,2);
    SEMOfResponse=std(dFFResponseFragments,[],2)./sqrt(size(dFFResponseFragments,2));
    LightOnBars2=zeros(size(MeandFFResponse,1),1);
    LightOnBars2(LightOnRowList)=1;
    LightOnBars2=logical(LightOnBars2);
    FirstLightOn=min(find(LightOnBars2));
    dFFLength=size(MeandFFResponse,1);
    Finalx=((-1*FirstLightOn*TimeAxisResolution):TimeAxisResolution:...
        (-1*FirstLightOn*TimeAxisResolution)+(dFFLength*TimeAxisResolution));
    LightOnBars2=[NaN; LightOnBars2];
    dFFResponseFragments=[NaN(1,size(dFFResponseFragments,2)); dFFResponseFragments];
    MeandFFResponse=[NaN; MeandFFResponse];
    SEMOfResponse=[NaN; SEMOfResponse];
    
    mkdir('Plots');
    cd(strcat(CurrentDir,'\Plots'));
    
    XlsxToWrite=[dFFResponseFragmentsTitles; num2cell(dFFResponseFragments)];
    xlswrite('PlottedData.xlsx',XlsxToWrite);
    
    %----------Enable this part if you want to auto generate color code for
    %separate trial figures--------------
    if AutoLineColor==1
        ColorSpec=[];
        UniTrialGroup=unique(TrialGroupNo);
        for i=1:size(UniTrialGroup,2)
            colorno1=0.5+(UniTrialGroup(i)/UniTrialGroup(end))*0.5;
            colorno2=0.7+(1/UniTrialGroup(i))*0.3;
%             colorno3=0.6+(UniTrialGroup(i)/UniTrialGroup(end))*0.4;
            colorno3=0.5;
%             colorno3=0.2+(1/UniTrialGroup(i))*0.8;
            ColorSpecToAdd=[colorno1,colorno2,colorno3];
            ColorSpec=[ColorSpec; {ColorSpecToAdd}];
        end
    else 
        ColorSpec=SetColorSpec;
    end
    
    %% -----------SEM title plots------------
    %-------Plot single traces and then average------
    fig1=figure;
    hax1=axes;
    
    yyaxis right

    xb1=[0 0 stimtime stimtime];
    yb1=[0 1 1 0];
    b1=patch(xb1,yb1,'r');
    b1.FaceAlpha=0.15;
    b1.EdgeAlpha=0;
    b1.EdgeColor='none';
    
    ylabel('Optogenetic Stimulation');
    ylim([0,1]);
    set(gca,'fontsize',AllFontSize);

    yyaxis left
    hold on
%     p2=plot(Finalx,dFFResponseFragments,'-','Color',[0.8 0.8 0.8]);
    for i=1:size(TrialGroupNo,2)
        p2=plot(Finalx,dFFResponseFragments(:,i),'-','Color',ColorSpec{TrialGroupNo(i)});
    end
    plot(Finalx,MeandFFResponse,'k-','LineWidth',1.5);
    xlabel('Time(s)','FontSize',XFontSize)
    ylabel('\DeltaF/F','FontSize',YFontSize);
    xlim(XLimSetting);
    tit1='Mean \DeltaF/F with Single Traces';
    title(strcat('\color{magenta}',StimulatorName{directory_idx},'>Chrimson','\color{black}, \color[rgb]{0.07 0.58 0.28}',ImagerName{directory_idx},'>GCaMP6s'));

    hax1.YAxis(2).Visible='off';
    hax1.YAxis(1).Color='k';
    set(gca,'TickDir','out');
    set(gca,'box','off');
    
    savefig(strcat('Mean dFF Response, Single Traces Plot','.fig'));

    print(fig1, 'Mean dFF Response, Single Traces Plot','-dpng','-r0');
    print(fig1, 'Mean dFF Response, Single Traces Plot','-dsvg','-r0');
    print(fig1, 'Mean dFF Response, Single Traces Plot','-dpdf','-r0');
    %--------------Plot separate fly's data----------
    mkdir('SepFly');
    cd(strcat(CurrentDir,'\Plots\SepFly'));
    for j=1:max(TrialGroupNo)
    fig1=figure;
    hax1=axes;
    
    yyaxis right

    xb1=[0 0 stimtime stimtime];
    yb1=[0 1 1 0];
    b1=patch(xb1,yb1,'r');
    b1.FaceAlpha=0.15;
    b1.EdgeAlpha=0;
    b1.EdgeColor='none';
    
    ylabel('Optogenetic Stimulation');
    ylim([0,1]);
    set(gca,'fontsize',AllFontSize);

    yyaxis left
    hold on
    ThisFlyGroupNo=find(TrialGroupNo==j)
    for i=min(ThisFlyGroupNo):max(ThisFlyGroupNo)
        p2=plot(Finalx,dFFResponseFragments(:,i),'k-');
    end
        xlabel('Time(s)','FontSize',XFontSize)
    ylabel('\DeltaF/F','FontSize',YFontSize);
    xlim(XLimSetting);
    tit1='Mean \DeltaF/F with Single Traces';
    title(strcat('\color{magenta}',StimulatorName{directory_idx},'>Chrimson','\color{black}, \color[rgb]{0.07 0.58 0.28}',ImagerName{directory_idx},'>GCaMP6s'));

    hax1.YAxis(2).Visible='off';
    hax1.YAxis(1).Color='k';
    set(gca,'TickDir','out');
    set(gca,'box','off');
    
    savefig(strcat(strcat('Fly #',num2str(j)),'.fig'));
    print(fig1, strcat('Fly #',num2str(j)),'-dpng','-r0');
    print(fig1, strcat('Fly #',num2str(j)),'-dsvg','-r0');
    print(fig1, strcat('Fly #',num2str(j)),'-dpdf','-r0');
    end
    
    cd(strcat(CurrentDir,'\Plots'));
    %-------Plot Mean+-SEM-------
    fig2=figure;
    hax2=axes;
    yyaxis (hax2,'right')

    xb2=[0 0 stimtime stimtime];
    yb2=[0 1 1 0];
    b2=patch(xb2,yb2,'r');
    b2.FaceAlpha=0.15;
    b2.EdgeAlpha=0;
    b2.EdgeColor='none';
    ylabel('Optogenetic Stimulation');
    ylim([0,1]);
    set(gca,'fontsize',AllFontSize);

    yyaxis (hax2,'left');
    s=shadedErrorBar(Finalx,MeandFFResponse,SEMOfResponse,'lineProps','k');
    hold on
    plot(Finalx,MeandFFResponse,'k-','LineWidth',1.5);
    xlabel('Time(s)','FontSize',XFontSize)
    ylabel('\DeltaF/F','FontSize',YFontSize);
    tit2='Mean \DeltaF/F \pmSEM';
    title(strcat('\color{magenta}',StimulatorName{directory_idx},'>Chrimson','\color{black}, \color[rgb]{0.07 0.58 0.28}',ImagerName{directory_idx},'>GCaMP6s'));

    xlim(XLimSetting);
    ylim(YLimSetting);
    if YLimSetting(1)<0
        ytickLowerLim=YLimSetting(1)+mod(abs(YLimSetting(1)),YStep);
    else
        ytickLowerLim=YLimSetting(1)-mod(abs(YLimSetting(1)),YStep);
    end
    if YLimSetting(2)<0
        ytickUpperLim=YLimSetting(2)+mod(abs(YLimSetting(2)),YStep);
    else
        ytickUpperLim=YLimSetting(2)-mod(abs(YLimSetting(2)),YStep);
    end
    
    yticks([ytickLowerLim:YStep:ytickUpperLim]);

%     set(hax2(1),'YTick',YLimSetting(1):YStep:YLimSetting(2));

    hax2.YAxis(2).Visible='off';
    hax2.YAxis(1).Color='k';
    set(gca,'TickDir','out');
    set(gca,'box','off');
    
    savefig(strcat('Mean dFF Response +-SEM','.fig'));
    print(fig2, 'Mean dFF Response +-SEM','-dpng','-r0');
    print(fig2, 'Mean dFF Response +-SEM','-dsvg','-r0');
    print(fig2, 'Mean dFF Response +-SEM','-dpdf','-r0');
    
    save ('PlotInfo');
    %% --------Print No title figures--------
    cd(CurrentDir);
    mkdir('NoTitlePlots');
    cd(strcat(CurrentDir,'\NoTitlePlots'));
    
    XlsxToWrite=[dFFResponseFragmentsTitles; num2cell(dFFResponseFragments)];
    xlswrite('PlottedData.xlsx',XlsxToWrite);
    %-------Plot single traces and then average, colored------
    fig1=figure;
    hax1=axes;
    
    yyaxis right

    xb2=[0 0 stimtime stimtime];
    yb1=[0 1 1 0];
    b1=patch(xb1,yb1,'r');
    b1.FaceAlpha=0.15;
    b1.EdgeAlpha=0;
    b1.EdgeColor='none';
    
    ylabel('Optogenetic Stimulation');
    ylim([0,1]);
    set(gca,'fontsize',AllFontSize);

    yyaxis left
    hold on
      
    for i=1:size(TrialGroupNo,2)
        p2=plot(Finalx,dFFResponseFragments(:,i),'-','Color',ColorSpec{TrialGroupNo(i)});
    end
    plot(Finalx,MeandFFResponse,'k-','LineWidth',1.5);
    xlabel('Time(s)','FontSize',XFontSize)
    ylabel('\DeltaF/F','FontSize',YFontSize);
    xlim(XLimSetting);
    tit1='Mean \DeltaF/F with Single Traces';

    hax1.YAxis(2).Visible='off';
    hax1.YAxis(1).Color='k';
    set(gca,'TickDir','out');
    set(gca,'box','off');
    
    savefig(strcat('Mean dFF Response, Single Traces Plot','.fig'));

    print(fig1, 'Mean dFF Response, Single Traces Plot','-dpng','-r0');
    print(fig1, 'Mean dFF Response, Single Traces Plot','-dsvg','-r0');
    print(fig1, 'Mean dFF Response, Single Traces Plot','-dpdf','-r0');
    
    %-------Plot Mean+-SEM-------
    fig2=figure;
    hax2=axes;
    yyaxis (hax2,'right')

    xb2=[0 0 stimtime stimtime];
    yb2=[0 1 1 0];
    b2=patch(xb2,yb2,'r');
    b2.FaceAlpha=0.15;
    b2.EdgeAlpha=0;
    b2.EdgeColor='none';
    ylabel('Optogenetic Stimulation');
    ylim([0,1]);
    set(gca,'fontsize',AllFontSize);

    yyaxis (hax2,'left');
    s=shadedErrorBar(Finalx,MeandFFResponse,SEMOfResponse,'lineProps','k');
    hold on
    plot(Finalx,MeandFFResponse,'k-','LineWidth',1.5);
    xlabel('Time(s)','FontSize',XFontSize)
    ylabel('\DeltaF/F','FontSize',YFontSize);
    tit2='Mean \DeltaF/F \pmSEM';

    xlim(XLimSetting);
    ylim(YLimSetting);
    if YLimSetting(1)<0
        ytickLowerLim=YLimSetting(1)+mod(abs(YLimSetting(1)),YStep);
    else
        ytickLowerLim=YLimSetting(1)-mod(abs(YLimSetting(1)),YStep);
    end
    if YLimSetting(2)<0
        ytickUpperLim=YLimSetting(2)+mod(abs(YLimSetting(2)),YStep);
    else
        ytickUpperLim=YLimSetting(2)-mod(abs(YLimSetting(2)),YStep);
    end
    
    yticks([ytickLowerLim:YStep:ytickUpperLim]);
%     set(hax2(1),'YTick',YLimSetting(1):YStep:YLimSetting(2));

    hax2.YAxis(2).Visible='off';
    hax2.YAxis(1).Color='k';
    set(gca,'TickDir','out');
    set(gca,'box','off');
    
    savefig(strcat('Mean dFF Response +-SEM','.fig'));
    print(fig2, 'Mean dFF Response +-SEM','-dpng','-r0');
    print(fig2, 'Mean dFF Response +-SEM','-dsvg','-r0');
    print(fig2, 'Mean dFF Response +-SEM','-dpdf','-r0');

    save ('PlotInfo');
    %% --------Print "Avg+-SEM"/"Single Traces" title figures--------
    cd(CurrentDir);
    mkdir('SEMTitlePlots');
    cd(strcat(CurrentDir,'\SEMTitlePlots'));
    
    XlsxToWrite=[dFFResponseFragmentsTitles; num2cell(dFFResponseFragments)];
    xlswrite('PlottedData.xlsx',XlsxToWrite);
    %-------Plot single traces and then average------
    fig1=figure;
    hax1=axes;
    
    yyaxis right
    xb1=[0 0 stimtime stimtime];
    yb1=[0 1 1 0];
    b1=patch(xb1,yb1,'r');
    b1.FaceAlpha=0.15;
    b1.EdgeAlpha=0;
    b1.EdgeColor='none';
    
    ylabel('Optogenetic Stimulation');
    ylim([0,1]);
    set(gca,'fontsize',AllFontSize);

    yyaxis left
    hold on
%     p2=plot(Finalx,dFFResponseFragments,'-','Color',[0.8 0.8 0.8]);
    for i=1:size(TrialGroupNo,2)
        p2=plot(Finalx,dFFResponseFragments(:,i),'-','Color',ColorSpec{TrialGroupNo(i)});
    end
    plot(Finalx,MeandFFResponse,'k-','LineWidth',1.5);
    xlabel('Time(s)','FontSize',XFontSize);
    ylabel('\DeltaF/F','FontSize',YFontSize);
    % ylim([-0.2,0.8]);
%     xlim([min(Finalx),max(Finalx)]);
    xlim(XLimSetting);
    % ylim([min(MeandFFResponse),max(MeandFFResponse)]);
    tit1='Mean \DeltaF/F with Single Traces';
    title(tit1,'FontSize',TitleFontSize);
%     tit1v2=strcat(FolderTitle(directory_idx),'>Chrimson, IN1>GCaMP6s');
%     title(tit1v2);
%     title(strcat('\color{magenta}',FolderTitle{directory_idx},'>Chrimson','\color{black}, \color[rgb]{0.07 0.58 0.28}IN1>GCaMP6s'));

    hax1.YAxis(2).Visible='off';
    hax1.YAxis(1).Color='k';
    set(gca,'TickDir','out');
    set(gca,'box','off');
    
    savefig(strcat('Mean dFF Response, Single Traces Plot','.fig'));

    print(fig1, 'Mean dFF Response, Single Traces Plot','-dpng','-r0');
    print(fig1, 'Mean dFF Response, Single Traces Plot','-dsvg','-r0');
    print(fig1, 'Mean dFF Response, Single Traces Plot','-dpdf','-r0');
    %-------Plot Mean+-SEM-------
    fig2=figure;
    hax2=axes;
    yyaxis (hax2,'right')
    
    xb2=[0 0 stimtime stimtime];
    yb2=[0 1 1 0];
    b2=patch(xb2,yb2,'r');
    b2.FaceAlpha=0.15;
    b2.EdgeAlpha=0;
    b2.EdgeColor='none';
    ylabel('Optogenetic Stimulation');
    ylim([0,1]);
    set(gca,'fontsize',AllFontSize);

    yyaxis (hax2,'left');
    s=shadedErrorBar(Finalx,MeandFFResponse,SEMOfResponse,'lineProps','k');
    hold on
    plot(Finalx,MeandFFResponse,'k-','LineWidth',1.5);
    xlabel('Time(s)','FontSize',XFontSize);
    ylabel('\DeltaF/F','FontSize',YFontSize);
    tit2='Mean \DeltaF/F \pmSEM';
    title(tit2,'FontSize',TitleFontSize);

    xlim(XLimSetting);
    ylim(YLimSetting);
    if YLimSetting(1)<0
        ytickLowerLim=YLimSetting(1)+mod(abs(YLimSetting(1)),YStep);
    else
        ytickLowerLim=YLimSetting(1)-mod(abs(YLimSetting(1)),YStep);
    end
    if YLimSetting(2)<0
        ytickUpperLim=YLimSetting(2)+mod(abs(YLimSetting(2)),YStep);
    else
        ytickUpperLim=YLimSetting(2)-mod(abs(YLimSetting(2)),YStep);
    end
    
    yticks([ytickLowerLim:YStep:ytickUpperLim]);
%     set(hax2(1),'YTick',YLimSetting(1):YStep:YLimSetting(2));

    hax2.YAxis(2).Visible='off';
    hax2.YAxis(1).Color='k';
    set(gca,'TickDir','out');
    set(gca,'box','off');
    
    
    savefig(strcat('Mean dFF Response +-SEM','.fig'));
    print(fig2, 'Mean dFF Response +-SEM','-dpng','-r0');
    print(fig2, 'Mean dFF Response +-SEM','-dsvg','-r0');
    print(fig2, 'Mean dFF Response +-SEM','-dpdf','-r0');

    save ('PlotInfo');
end
