% Stream Z Projection, 0416ver
clear all
clc 
%----------Adjustable Arguments-----------
ProjectionType=1;        %1-MaxProjection, 2-MeanProjection
WriteMultiPageTiff=0;   % Set this to 0 if you want to write separate tif images
WriteSeparateTiff=1;    % Set this to 0 if you want to write multipage tif images
list_of_directories = {...
    'D:\2PhoData\230702'...
%     'E:\CXY\220106'...
%     'D:\2PhoData\210929'...
%     'D:\2PhoData\210930'...
%     'G:\2PhoData\210915'...
    };
% XMLDir='E:\Data-2019\190324(Dh44,ZT)\M1T1-ZT-Dh44_CsChrimson,IN1_GCaMP6s, St, 10mA10s-filterOn';
% DataDir='E:\Data-2019\190324(Dh44,ZT)\M1T1-ZT-Dh44_CsChrimson,IN1_GCaMP6s, St, 10mA10s-filterOn';
% TrialTRange=

%% -------Read xml, get z step number-----------

        %-------Send email to report progress-------
%     setpref('Internet','SMTP_Server','smtp.gmail.com');
%     setpref('Internet','E_mail','dbzd666@gmail.com');
%     setpref('Internet','SMTP_Username','dbzd666@gmail.com');
%     setpref('Internet','SMTP_Password','THAUMA666');
%     props = java.lang.System.getProperties;
%     props.setProperty('mail.smtp.auth','true');
%     props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
%     props.setProperty('mail.smtp.socketFactory.port','465');
%     
%     sendmail('xc358@cornell.edu','Z Projection Started') ;
    
for directory_idx  = 1:numel(list_of_directories)
    Folder1=list_of_directories{directory_idx};
    cd(Folder1);
    disp(sprintf('Processing %s',list_of_directories{directory_idx}));
    
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

        for i2=1:size(DataFolderList)
            Folder2=DataFolderList{i2};
            CurrentDataPath=strcat(Folder1,'\',Folder2)

        XMLDir=CurrentDataPath;
        DataDir=CurrentDataPath;
        cd(XMLDir)

        xmlname='Experiment.xml';
        xmlpath=[XMLDir '\' xmlname];
        [text1]=xml2struct(xmlpath);
        Name=text1.ThorImageExperiment.Name.Attributes.name;
        Date=text1.ThorImageExperiment.Date.Attributes.date;
        Notes=text1.ThorImageExperiment.ExperimentNotes.Attributes.text;
        Timepoints=str2num(text1.ThorImageExperiment.Timelapse.Attributes.timepoints)
        ZSteps=str2num(text1.ThorImageExperiment.ZStage.Attributes.steps)
        ZStepSizeUM=str2num(text1.ThorImageExperiment.ZStage.Attributes.stepSizeUM);
        XPixel=str2num(text1.ThorImageExperiment.LSM.Attributes.pixelX);
        YPixel=str2num(text1.ThorImageExperiment.LSM.Attributes.pixelY);
        ZEnabled=str2num(text1.ThorImageExperiment.Streaming.Attributes.zFastEnable);
        ChBEnabled=str2num(text1.ThorImageExperiment.PMT.Attributes.enableB);
        %% ---------Read images, integrate-----------
        if ZEnabled==1
            TempFileList=struct2cell(dir(CurrentDataPath));
%             if sum(find(strcmp('ZProjected',TempFileList)))==0 %If the folder"ZProjected" is not present...
            if WriteMultiPageTiff==0
                mkdir('ZProjected');
            elseif WriteMultiPageTiff==1
                mkdir('ZProj-MultPageTiff');
            end

            cd(DataDir)
            % TempImageStack=uint16(zeros(YPixel,XPixel,ZSteps));
            % ZProjectedFrame=uint16(zeros(YPixel,XPixel));
            for TNum=1:Timepoints
            ZStackForThisT=[];
                for ZNum=1:ZSteps
                    %-------for each image, GET TIF file name,001ver-------
                        if ZNum<10
                            if TNum<10
                                imgname=strcat('ChanA_001_001_00',num2str(ZNum),'_00',num2str(TNum),'.tif');
                            elseif TNum<100
                                imgname=strcat('ChanA_001_001_00',num2str(ZNum),'_0',num2str(TNum),'.tif');
                            elseif TNum>=100
                                imgname=strcat('ChanA_001_001_00',num2str(ZNum),'_',num2str(TNum),'.tif');
                            else
                                warndlg('Timpoints number Too Large, change image reading program');
                            end
                        elseif ZNum<100
                            if TNum<10
                                imgname=strcat('ChanA_001_001_0',num2str(ZNum),'_00',num2str(TNum),'.tif');
                            elseif TNum<100
                                imgname=strcat('ChanA_001_001_0',num2str(ZNum),'_0',num2str(TNum),'.tif');
                            elseif TNum>=100
                                imgname=strcat('ChanA_001_001_0',num2str(ZNum),'_',num2str(TNum),'.tif');
                            else
                                warndlg('Timpoints number Too Large, change image reading program');
                            end
                        elseif ZNum>=100
                            if TNum<10
                                imgname=strcat('ChanA_001_001_',num2str(ZNum),'_00',num2str(TNum),'.tif');
                            elseif TNum<100
                                imgname=strcat('ChanA_001_001_',num2str(ZNum),'_0',num2str(TNum),'.tif');
                            elseif TNum>=100
                                imgname=strcat('ChanA_001_001_',num2str(ZNum),'_',num2str(TNum),'.tif');
                            else
                                warndlg('Timpoints number Too Large, change image reading program');
                            end
%                         elseif ZNum<10000
%                             if TNum<10
%                                 imgname=strcat('ChanA_001_001_',num2str(ZNum),'_000',num2str(TNum),'.tif');
%                             elseif TNum<100
%                                 imgname=strcat('ChanA_0001_0001_',num2str(ZNum),'_00',num2str(TNum),'.tif');
%                             elseif TNum<1000
%                                 imgname=strcat('ChanA_0001_0001_',num2str(ZNum),'_0',num2str(TNum),'.tif');
%                             elseif TNum<10000
%                                 imgname=strcat('ChanA_0001_0001_',num2str(ZNum),'_',num2str(TNum),'.tif');
%                             else
%                                 warndlg('Timpoints number Too Large, change image reading program');
%                             end
                        else
                            warndlg('Z Steps Number Too Large, change image reading program');
                        end
                    %--------Read each Image, store them in temp stack--------
                    ZStackForThisT(:,:,ZNum)=imread(imgname);
                end
                %-----------Calculate Projection-------------
                if ProjectionType==1
                    ZProjectedFrame=max(ZStackForThisT,[], 3);
                elseif ProjectionType==2
                    ZProjectedFrame=mean(ZStackForThisT,3);
                else
                    warndlg('Wrong Z Projection Type Input, please check!');
                end
                %-------creat file name to write, and write!-------
                if WriteMultiPageTiff==1
                    OutputPath=strcat(XMLDir, '\ZProj-MultPageTiff\');
                    if ProjectionType==1
                        OutputFrameName=strcat('MaxZProj_',Folder2);
                    elseif ProjectionType==2
                        OutputFrameName=strcat('MeanZProj_',Folder2);
                    else
                        warndlg('Wrong Z Projection Type Input, please check!');
                    end
                    OutputF=strcat(OutputPath, OutputFrameName,'.tif');
%                     CommentString=strcat('Time: ',Date, ', File Name:',Name,', Z Projected Frame No:', TNum, ', Exp Notes:',Notes);
                    imwrite(uint16(ZProjectedFrame), OutputF, 'tif','writemode','append');
                end
                if WriteSeparateTiff==1
                    if ProjectionType==1
                        OutputPath=strcat(XMLDir, '\ZProjected\');
                        OutputFrameName=strcat('MaxZProj_',num2str(TNum,'%04d'),'.tif');
                    elseif ProjectionType==2
                        OutputPath=strcat(XMLDir, '\ZProjected\');
                        OutputFrameName=strcat('MeanZProj_',num2str(TNum,'%04d'),'.tif');
                    else
                        warndlg('Wrong Z Projection Type Input, please check!');
                    end
                    OutputF=strcat(OutputPath, OutputFrameName);
%                     CommentString=strcat('Time: ',Date, ', File Name:',Name,', Z Projected Frame No:', TNum, ', Exp Notes:',Notes);
                    imwrite(uint16(ZProjectedFrame), OutputF, 'tif');
                end
            %     figure;
            %     imagesc(ZProjectedFrame)
                if mod(TNum,200)==0
                    str=strcat('Finished-', num2str(TNum),'/ ', num2str(Timepoints))
                end
%             end
            end
        %------------If Channel B is also there, do the same with ChB----------
        if ChBEnabled==1
            cd(DataDir)
            mkdir ('ZProjectedB');
            for TNum=1:Timepoints
            ZStackForThisT=[];
                for ZNum=1:ZSteps
                    %-------for each image, GET TIF file name,001ver-------
                        if ZNum<10
                            if TNum<10
                                imgname=strcat('ChanB_001_001_00',num2str(ZNum),'_00',num2str(TNum),'.tif');
                            elseif TNum<100
                                imgname=strcat('ChanB_001_001_00',num2str(ZNum),'_0',num2str(TNum),'.tif');
                            elseif TNum>=100
                                imgname=strcat('ChanB_001_001_00',num2str(ZNum),'_',num2str(TNum),'.tif');
                            else
                                warndlg('Timpoints number Too Large, change image reading program');
                            end
                        elseif ZNum<100
                            if TNum<10
                                imgname=strcat('ChanB_001_001_0',num2str(ZNum),'_00',num2str(TNum),'.tif');
                            elseif TNum<100
                                imgname=strcat('ChanB_001_001_0',num2str(ZNum),'_0',num2str(TNum),'.tif');
                            elseif TNum>=100
                                imgname=strcat('ChanB_001_001_0',num2str(ZNum),'_',num2str(TNum),'.tif');
                            else
                                warndlg('Timpoints number Too Large, change image reading program');
                            end
                        elseif ZNum>=100
                            if TNum<10
                                imgname=strcat('ChanB_001_001_',num2str(ZNum),'_00',num2str(TNum),'.tif');
                            elseif TNum<100
                                imgname=strcat('ChanB_001_001_',num2str(ZNum),'_0',num2str(TNum),'.tif');
                            elseif TNum>=100
                                imgname=strcat('ChanB_001_001_',num2str(ZNum),'_',num2str(TNum),'.tif');
                            else
                                warndlg('Timpoints number Too Large, change image reading program');
                            end
%                         elseif ZNum<10000
%                             if TNum<10
%                                 imgname=strcat('ChanB_001_001_',num2str(ZNum),'_000',num2str(TNum),'.tif');
%                             elseif TNum<100
%                                 imgname=strcat('ChanB_0001_0001_',num2str(ZNum),'_00',num2str(TNum),'.tif');
%                             elseif TNum<1000
%                                 imgname=strcat('ChanB_0001_0001_',num2str(ZNum),'_0',num2str(TNum),'.tif');
%                             elseif TNum<10000
%                                 imgname=strcat('ChanB_0001_0001_',num2str(ZNum),'_',num2str(TNum),'.tif');
%                             else
%                                 warndlg('Timpoints number Too Large, change image reading program');
%                             end
                        else
                            warndlg('Z Steps Number Too Large, change image reading program');
                        end
                    %--------Read each Image, store them in temp stack--------
                    ZStackForThisT(:,:,ZNum)=imread(imgname);
                end
                %-----------Calculate Projection-------------
                if ProjectionType==1
                    ZProjectedFrame=max(ZStackForThisT,[], 3);
                elseif ProjectionType==2
                    ZProjectedFrame=mean(ZStackForThisT,3);
                else
                    warndlg('Wrong Z Projection Type Input, please check!');
                end
                %-------creat file name to write, and write!-------
                if WriteMultiPageTiff==1
                    OutputPath=strcat(XMLDir, '\ZProj-MultPageTiff\');
                    if ProjectionType==1
                        OutputFrameName=strcat('MaxZProjB_',Folder2);
                    elseif ProjectionType==2
                        OutputFrameName=strcat('MeanZProjB_',Folder2);
                    else
                        warndlg('Wrong Z Projection Type Input, please check!');
                    end
                    OutputF=strcat(OutputPath, OutputFrameName,'.tif');
%                     CommentString=strcat('Time: ',Date, ', File Name:',Name,', Z Projected Frame No:', TNum, ', Exp Notes:',Notes);
                    imwrite(uint16(ZProjectedFrame), OutputF, 'tif','writemode','append');
                end
                if WriteSeparateTiff==1
                    if ProjectionType==1
                        OutputPath=strcat(XMLDir, '\ZProjectedB\');
                        OutputFrameName=strcat('MaxZProj_',num2str(TNum,'%04d'),'.tif');
                    elseif ProjectionType==2
                        OutputPath=strcat(XMLDir, '\ZProjectedB\');
                        OutputFrameName=strcat('MeanZProj_',num2str(TNum,'%04d'),'.tif');
                    else
                        warndlg('Wrong Z Projection Type Input, please check!');
                    end
                    OutputF=strcat(OutputPath, OutputFrameName);
%                     CommentString=strcat('Time: ',Date, ', File Name:',Name,', Z Projected Frame No:', TNum, ', Exp Notes:',Notes);
                    imwrite(uint16(ZProjectedFrame), OutputF, 'tif');
                end
            %     figure;
            %     imagesc(ZProjectedFrame)
                if mod(TNum,200)==0
                    str=strcat('Finished Channel B-', num2str(TNum),'/ ', num2str(Timepoints))
                end
%             end
            end
        end
        end
    end
end



% Step2_BatchRegistration;