%-------Fly Data processing 2-after batch registration: Batch Extraction, single ROI ver---------

clear all
clc
xmlname='Experiment.xml';
UseMeanProjOrMaxProj='mean';% Input 'mean' for mean t-projection, 'max' for max t-projection
ThresholdRatio=0.5;

list_of_directories = {...
    'F:\666ScriptTest2024Aug26\1_Gr43aOptoAct,IN1Imaging\200123'...
%     'G:\2PhoData\240802'...
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
%        elseif TempName(1)=='S'
%            SyncDataFolderList=[SyncDataFolderList;{TempName}];
        end
    end
        
%-------1. Generate Max Projection of Registered data--------
    for i3=1:size(DataFolderList)
        Folder2=DataFolderList{i3};
        CurDataPath=strcat(Folder1,'\',Folder2);
                %---------Read xml-------------
        xmlpath=strcat(CurDataPath,'\',xmlname);
        [text1]=xml2struct_Joe(xmlpath);
        Timepoints=str2num(text1.ThorImageExperiment.Timelapse.Attributes.timepoints);
        ZEnabled=str2num(text1.ThorImageExperiment.Streaming.Attributes.zFastEnable);%If ZEnabled=1, then it's a ZT data. Vice versa.

        if ZEnabled==1
            cd(strcat(Folder1,'\',Folder2));
            if exist('ZProjCrop_LA','dir')
                DataFolder=strcat(Folder1,'\',Folder2,'\ZProjCrop_LA')
            elseif exist('ZProjCrop_RA','dir')
                DataFolder=strcat(Folder1,'\',Folder2,'\ZProjCrop_RA')
            elseif exist('ZProjCrop_CB','dir')
                DataFolder=strcat(Folder1,'\',Folder2,'\ZProjCrop_CB')
            else
                DataFolder=strcat(Folder1,'\',Folder2,'\ZProjected')
            end
        else
            DataFolder=strcat(Folder1,'\',Folder2)
        end
        cd(DataFolder);
        
        if exist('TurboReged','dir')
            Answer1='T';
        elseif exist('Reg_Matlab_translation','dir')||exist('Reg_Matlab_rigid','dir')
            Answer1='M';
        else
            Answer1='N'
        end
%         Answer1=inputdlg(strcat('Use Turbo reg (type T) or Matlba reg(M) or Raw data(R) for',Folder1,'\',Folder2,'?'));
%         Answer1=Answer1{1};
        if Answer1=='T'||Answer1=='t'
            List1=dir(DataFolder);
            for i=1:size(List1,1)
                if List1(i).isdir==1
                    TempName=List1(i).name;
                    if size(TempName,2)>=5
                        if strcmp(TempName(1:2),'Tu')
                            Folder3=TempName;
                        end
                    end
                end
            end
            RegStackPath=strcat(DataFolder,'\',Folder3);
        elseif Answer1=='M'||Answer1=='m'
            List1=dir(DataFolder);
            for i=1:size(List1,1)
                if List1(i).isdir==1
                    TempName=List1(i).name;
                    if size(TempName,2)>=10
                        if strcmp(TempName(1:10),'Reg_Matlab')
                            Folder3=TempName;
                        end
                    end
                end
            end
            RegStackPath=strcat(DataFolder,'\',Folder3);
        elseif Answer1=='R'||Answer1=='r'
            RegStackPath=DataFolder;
        elseif Answer1=='N'%N means manual registered
            RegStackPath=strcat(DataFolder,'\ManualReged');
        end
                    
        cd(RegStackPath);
        if Answer1=='R'||Answer1=='r'
            RegTifList=dir ('*ChanA_0*.tif');
        else
            RegTifList=dir ('*.tif');
        end
        RegImageNum=size(RegTifList,1);
        RegStack=[];
        for i=1:RegImageNum
            RegStack(:,:,i)=imread(RegTifList(i).name);
%             ReadingProgress=strcat(num2str(i),'/',num2str(RegImageNum))
            if mod(i,200)==0
                print=strcat('Reading...',num2str(i),'/',num2str(RegImageNum))
            end
        end
        
        if strcmp(UseMeanProjOrMaxProj,'mean')
            MeanOrMaxProjOfReg= mean(RegStack,3);
        elseif strcmp(UseMeanProjOrMaxProj,'max')
            MeanOrMaxProjOfReg= max(RegStack,[],3);
        end
        MeanOrMaxProjOfReg=uint16(MeanOrMaxProjOfReg);
        AdjustedMeanOrMaxProjOfReg=imadjust(MeanOrMaxProjOfReg);
        
        figtemp1=figure;
        fullfig(figtemp1);
        imshow(AdjustedMeanOrMaxProjOfReg);
        if strcmp(UseMeanProjOrMaxProj,'mean')
            mkdir('MeanProjOfReg');
            imwrite(AdjustedMeanOrMaxProjOfReg,strcat(RegStackPath,'\MeanProjOfReg\AdjustedMeanProjOfReg.tif'));
        elseif strcmp(UseMeanProjOrMaxProj,'max')
            mkdir('MaxProjOfReg');
            imwrite(AdjustedMeanOrMaxProjOfReg,strcat(RegStackPath,'\MaxProjOfReg\AdjustedMaxProjOfReg.tif'));
        end
        
        %-----Remove Balck Border Before Processing
        OriginalMeanOrMaxProjCopy=AdjustedMeanOrMaxProjOfReg;
%         [row1,col1]=find(AdjustedMeanOrMaxProjOfReg==0)
        
        WholeImgBinarizeMask=imbinarize(AdjustedMeanOrMaxProjOfReg);
        
        AdjustedMeanOrMaxProjOfReg(~WholeImgBinarizeMask)=max(max(AdjustedMeanOrMaxProjOfReg));
        SecondLowestValue=min(min(AdjustedMeanOrMaxProjOfReg));
        AdjustedMeanOrMaxProjOfReg(~WholeImgBinarizeMask)=SecondLowestValue;
        
        AdjustedMeanOrMaxProjOfReg=imadjust(AdjustedMeanOrMaxProjOfReg);
        
        figtemp2=figure;
        fullfig(figtemp2);
        imshow(AdjustedMeanOrMaxProjOfReg);
        
        ans1=questdlg('Do you want to use this Dark Border Removed Proj Image?');
        if strcmp(ans1,'Yes')
            ZeroPixelsRemovedBeforeDrawROIOrNot=1;
            if strcmp(UseMeanProjOrMaxProj,'mean')
                mkdir('DarkBorderRemovedMeanProjOfReg');
                imwrite(AdjustedMeanOrMaxProjOfReg,strcat(RegStackPath,'\DarkBorderRemovedMeanProjOfReg\DarkBorderRemovedAdjustedMeanProjOfReg.tif'));
            elseif strcmp(UseMeanProjOrMaxProj,'max')
                mkdir('DarkBorderRemovedMaxProjOfReg');
                imwrite(AdjustedMeanOrMaxProjOfReg,strcat(RegStackPath,'\DarkBorderRemovedMaxProjOfReg\DarkBorderRemovedAdjustedMaxProjOfReg.tif'));
            end
        else
            ZeroPixelsRemovedBeforeDrawROIOrNot=0;
            AdjustedMeanOrMaxProjOfReg=OriginalMeanOrMaxProjCopy;
            close(figtemp2);
        end
        save('DarkBorderRemovalInfo.mat', 'OriginalMeanOrMaxProjCopy','WholeImgBinarizeMask','ZeroPixelsRemovedBeforeDrawROIOrNot');
 %% ---------Input number of ROI and ROI Name Prefix------
        prompt = {'Enter Number of ROIs'};
        title2 = 'Number of ROIs';
        definput = {num2str(2)};
        ans2 = inputdlg(prompt,title2,[1 40],definput);
        ROINo=str2num(ans2{1});
        
        prompt = {'Enter ROI Name Prefix'};
        title2 = 'ROI Name Prefix';
        definput = {'CB'};
        ans2 = inputdlg(prompt,title2,[1 40],definput);
        ROIPrefix=ans2{1};
            
                
        if strcmp(ans1,'Yes')
            close(figtemp2);
            close(figtemp1);
        else
            close(figtemp1);
        end
        
        %% --------Drawing ROI , Single Arbor ver
        fig3=figure;
        CurrentFig=imshow(AdjustedMeanOrMaxProjOfReg,[]);
        fullfig(fig3);
        %-------------Draw ROI-------------
        for ROIi=1:ROINo
            keepdrawing=1;
            while keepdrawing==1
                title(strcat('ZT Projection of ',RegStackPath,'! Please Draw Arbor!'));
                ArManual=imfreehand();
                ArMask(:,:,ROIi) = createMask(ArManual,CurrentFig); %select Ar
                ArOnly=AdjustedMeanOrMaxProjOfReg;
                ArOnly(~ArMask(:,:,ROIi))=0;
                MinValInsideMask=min(min(ArOnly));
                MaxValInsideMask=max(max(ArOnly));

                ArThreshold=MinValInsideMask+(MaxValInsideMask-MinValInsideMask)*ThresholdRatio;
                [r1,c1]=find(ArOnly<ArThreshold);
                ThresholdedArOnlyImg=ArOnly;
                for i=1:size(r1,1)
                    ThresholdedArOnlyImg(r1(i),c1(i))=0;
                end
                ThresholdedArOnlyImg=uint16(ThresholdedArOnlyImg);

                fig1=figure;
                imshow(ThresholdedArOnlyImg,[]);
                fullfig(fig1);

                ans=questdlg(strcat('Current Thre Ratio:',num2str(ThresholdRatio),'. Do you want to accept this as ROI?'));
                if strcmp(ans,'Yes')
                    keepdrawing=0;
                    ArMask(:,:,ROIi)=logical(ThresholdedArOnlyImg);
                    IMGWritePath=strcat('Thresholded',num2str(ROIi),'OnlyImg');
                    mkdir(strcat('Thresholded',num2str(ROIi),'OnlyImg'));
                    imwrite(ThresholdedArOnlyImg,strcat(RegStackPath,'\',IMGWritePath,'\ThresholdedROI',num2str(ROIi),'OnlyImg.tif'));
                else
                    keepdrawing=1;
                    delete (ArManual);
                    prompt = {'Enter desired Threshold Ratio'};
                    title2 = 'Threshold Ind Value';
                    definput = {num2str(ThresholdRatio)};
                    ans2 = inputdlg(prompt,title2,[1 40],definput);
                    ThresholdRatio=str2num(ans2{1});
                end
                close;
            end
        end
        %---------Draw BG------------
        keepdrawing=1;
        while keepdrawing==1
%             BGManual=imellipse();
            title(strcat('ZT Projection of ',RegStackPath,'! Please Draw BG!'));
            BGManual=imfreehand();
            BGMask = createMask(BGManual,CurrentFig); %Draw BG
            BGOnly=AdjustedMeanOrMaxProjOfReg;
            BGOnly(~BGMask)=0;
            BGOnlyBinImg=BGOnly;
            
            fig1=figure;
            imshow(BGOnlyBinImg,[]);
            fullfig(fig1);

            ans=questdlg('Do you want to accept this as Background?');
            if strcmp(ans,'Yes')
                keepdrawing=0;
                BGMask=logical(BGOnlyBinImg);
            else
                keepdrawing=1;
                delete (BGManual);
            end
            close;
        end
            save(strcat(RegStackPath,'\ROISelectionData.mat'),'AdjustedMeanOrMaxProjOfReg','UseMeanProjOrMaxProj','ArManual','ArMask','ArThreshold','ThresholdRatio','BGManual','BGMask');  
            savefig('ROIDrawings.fig');
            close;
            %------------Extract fluo data, Single Arbor Ver---------------
        if ~exist('ArMask')
            load('ROISelectionData.mat');
        end
    %--------Extrat ROI fluo, store in ArFluo-----------
        ArFluo=NaN(RegImageNum,ROINo);
        BGFluo=NaN(RegImageNum,1);
        for i=1:RegImageNum
            for ROIi=1:ROINo
                CurrentFrame=RegStack(:,:,i);
%                 figure;
%                 h2=imshow(CurrentFrame,[]);
%                 delete(h2);
                ArFluoImg=double(CurrentFrame).*double(ArMask(:,:,ROIi));
                SumAr=sum(sum(ArFluoImg));
                ArCount=sum(sum(double(ArMask(:,:,ROIi))));
                ArFluo(i,ROIi)=SumAr/ArCount;
                if mod(i,400)==0
                    print=strcat('Extracting ROI No.',num2str (ROIi),'...',num2str(i),'/',num2str(RegImageNum))
                end
            end
        %-----Extract BGFluo, store in BGFluo--------
        BGFluoImg=double(CurrentFrame).*double(BGMask);
        SumBG=sum(sum(BGFluoImg));
        BGCount=sum(sum(double(BGMask)));
        BGFluo(i,1)=SumBG/BGCount;
        end
        
        
        FolderDateInd1=strfind(Folder1,'\');
        FolderDate=Folder1(FolderDateInd1(end)+1:FolderDateInd1(end)+6);
        
        cd(Folder1);
        if ~exist('RawFluo','dir')
            mkdir('RawFluo');
        end
        cd(RegStackPath);
       %-----------Write into Xlsx-------
        save(strcat(RegStackPath,'\RegFluoDatL-',FolderDate,Folder2,'.mat'),'ArFluo','BGFluo'); 
        XlsxHeading=[];
        for i=1:ROINo
            XlsxHeading=[XlsxHeading,{strcat(ROIPrefix,num2str(i))}];
        end
        XlsxHeading=[XlsxHeading,{'BG'}];
        XlsxNum=[ArFluo,BGFluo];
        ToWriteInXlsx=[XlsxHeading; num2cell(XlsxNum)];
        xlswrite(strcat(RegStackPath,'\RegFluoDatL.xlsx'),ToWriteInXlsx);
        xlswrite(strcat(Folder1,'\RawFluo','\RegFluoDatL-',FolderDate,Folder2,'.xlsx'),ToWriteInXlsx);
        
        rawfluofig=figure;
        plot(ArFluo,'b');
        hold on
        plot(BGFluo,'r');
        YLimits=[min(min(BGFluo)),max(max(ArFluo))];
        ylim(YLimits);
        tit3=strcat('Raw Fluo of-',Folder1,'\',Folder2);
        title(tit3);
        set(rawfluofig, 'Units', 'Inches', 'Position', [0, 0, 12, 3.5], 'PaperUnits', 'Inches', 'PaperSize', [12, 3.5]);

        savefig(strcat(Folder1,'\',Folder2,'\','RawFluo','.fig'));

        
        clearvars -except xmlname UseMeanProjOrMaxProj ThresholdRatio list_of_directories directory_idx Folder1 CurFolderlist DataFolderList SyncDataFolderList i3
    
        end
end
