%----Batch Registering--------
clear all
clc
%% ---------Adjust before use------------
GetFixedFrameBeforeStart=1;
ChooseFixedFrame=0;
DoAutoFixedFrame=1;
AutoFixedFrameNo=345;

RunRegistration=1;
UseChoosedFixedFrame=0;
UseAutoFixedFrame=1;

UseAdjustedFixedImgForReg=0;

xmlname='Experiment.xml';
ProjFolderName='ZProjected';
TransformType='rigid'; % Change if needed!, translation, rigid
list_of_directories = {...
%     'J:\2PhoData\240709'...
    'J:\2PhoData\240712'...
    'J:\2PhoData\240716'...
    'J:\2PhoData\240720'...
%     'D:\2PhoData\231210'...
%     'J:\2PhoData\231119'...
%     'J:\2PhoData\231120'...
%     'J:\2PhoData\231121'...
%     'J:\2PhoData\231122'...
%     'J:\2PhoData\231123'...
%     'J:\2PhoData\231124'...
%     'D:\2PhoData\230517(CDG2ActDurIng,NRC'...
%     'D:\2PhoData\230518(IN1-CDG2'...
    };

%% ----------Choose fixed frames------------
k=10;% k is the statistics of the total trial number

if GetFixedFrameBeforeStart==1
if ChooseFixedFrame==1
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

        for Folder2Ind=1:size(DataFolderList)

            %-----Read xml to check is it ZT or Z or T data-----
            Folder2=DataFolderList{Folder2Ind};
            CurrentDataPath=strcat(Folder1,'\',Folder2);
            XMLDir=CurrentDataPath;
    %         cd(XMLDir)

            xmlpath=[XMLDir '\' xmlname];
            [text1]=xml2struct(xmlpath);
            Name=text1.ThorImageExperiment.Name.Attributes.name;
            Date=text1.ThorImageExperiment.Date.Attributes.date;
            Notes=text1.ThorImageExperiment.ExperimentNotes.Attributes.text;
            Timepoints=str2num(text1.ThorImageExperiment.Timelapse.Attributes.timepoints)
            ZEnabled=str2num(text1.ThorImageExperiment.Streaming.Attributes.zFastEnable);%If ZEnabled=1, then it's a ZT data. Vice versa.
            if ZEnabled==1
                ZSteps=str2num(text1.ThorImageExperiment.ZStage.Attributes.steps)
                ZStepSizeUM=str2num(text1.ThorImageExperiment.ZStage.Attributes.stepSizeUM);
            end
            XPixel=str2num(text1.ThorImageExperiment.LSM.Attributes.pixelX);
            YPixel=str2num(text1.ThorImageExperiment.LSM.Attributes.pixelY);

            if ZEnabled==1
                CurrentDataPath=strcat(CurrentDataPath,'\',ProjFolderName);
            else
                CurrentDataPath=CurrentDataPath;
            end
                FlyDataRegistrationGUI_GetFixedFrameOnly(CurrentDataPath);
        end    
    end
end

if DoAutoFixedFrame==1
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

        for Folder2Ind=1:size(DataFolderList)
            
            %-----Read xml to check is it ZT or Z or T data-----
            Folder2=DataFolderList{Folder2Ind};
            CurrentDataPath=strcat(Folder1,'\',Folder2);
            XMLDir=CurrentDataPath;
    %         cd(XMLDir)

            xmlpath=[XMLDir '\' xmlname];
            [text1]=xml2struct_Joe(xmlpath);
            Name=text1.ThorImageExperiment.Name.Attributes.name;
            Date=text1.ThorImageExperiment.Date.Attributes.date;
            Notes=text1.ThorImageExperiment.ExperimentNotes.Attributes.text;
            Timepoints=str2num(text1.ThorImageExperiment.Timelapse.Attributes.timepoints)
            ZEnabled=str2num(text1.ThorImageExperiment.Streaming.Attributes.zFastEnable);%If ZEnabled=1, then it's a ZT data. Vice versa.
            if ZEnabled==1
                ZSteps=str2num(text1.ThorImageExperiment.ZStage.Attributes.steps)
                ZStepSizeUM=str2num(text1.ThorImageExperiment.ZStage.Attributes.stepSizeUM);
            end
            XPixel=str2num(text1.ThorImageExperiment.LSM.Attributes.pixelX);
            YPixel=str2num(text1.ThorImageExperiment.LSM.Attributes.pixelY);

            %-------If it's ZT data, move CurrentDataPath to CurrentDataPath\ProjFolderName
            if ZEnabled==1
                CurrentDataPath=strcat(CurrentDataPath,'\',ProjFolderName);
            else
                CurrentDataPath=CurrentDataPath;
            end
            TifFileList=[];
            cd(CurrentDataPath);
            TifFileList =dir ('*.tif');  
            
            FixedImg=imread(TifFileList(AutoFixedFrameNo).name);
%             figure;
%             imshow(imadjust(FixedImg));
            
            k=k+1;
            
            titstr=strcat('Fixed Frame of-', CurrentDataPath, '-Fr No:', num2str(AutoFixedFrameNo));
            title(titstr);
            NewFolderName=strcat('AutoFixedFrame');
            mkdir(NewFolderName);
            SelectedFixedFrameFileName=TifFileList(AutoFixedFrameNo).name;
            SaveFilePathAndName=strcat(CurrentDataPath,'\',NewFolderName,'\',SelectedFixedFrameFileName);
    %             SaveFilePath=SaveFilePath{1};
    %         cd (strcat(CurrentDataPath,'\',NewFolderName));
            imwrite(FixedImg,SaveFilePathAndName);
        end
    end
end
end
%% ----------Run registration--------
if RunRegistration==1
    
%         %-------Send email to report progress-------
%     setpref('Internet','SMTP_Server','smtp.gmail.com');
%     setpref('Internet','E_mail','dbzd666@gmail.com');
%     setpref('Internet','SMTP_Username','dbzd666@gmail.com');
%     setpref('Internet','SMTP_Password','1xxwhgzsdznnys7t');
%     props = java.lang.System.getProperties;
%     props.setProperty('mail.smtp.auth','true');
%     props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
%     props.setProperty('mail.smtp.socketFactory.port','465');
%     
%     sendmail('faithoftrue@gmail.com',strcat('Reg Started, in total ',num2str(k),'trials to be reged.')) ;
%     
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
    
    for Folder2Ind=1:size(DataFolderList)
        
        
        %-----Read xml to check is it ZT or Z or T data-----
        Folder2=DataFolderList{Folder2Ind};
        CurrentDataPath=strcat(Folder1,'\',Folder2);
        XMLDir=CurrentDataPath;
%         cd(XMLDir)

        xmlpath=[XMLDir '\' xmlname];
        [text1]=xml2struct_Joe(xmlpath);
        Name=text1.ThorImageExperiment.Name.Attributes.name;
        Date=text1.ThorImageExperiment.Date.Attributes.date;
        Notes=text1.ThorImageExperiment.ExperimentNotes.Attributes.text;
        Timepoints=str2num(text1.ThorImageExperiment.Timelapse.Attributes.timepoints)
        ZEnabled=str2num(text1.ThorImageExperiment.Streaming.Attributes.zFastEnable);%If ZEnabled=1, then it's a ZT data. Vice versa.
        if ZEnabled==1
            ZSteps=str2num(text1.ThorImageExperiment.ZStage.Attributes.steps)
            ZStepSizeUM=str2num(text1.ThorImageExperiment.ZStage.Attributes.stepSizeUM);
        end
        XPixel=str2num(text1.ThorImageExperiment.LSM.Attributes.pixelX);
        YPixel=str2num(text1.ThorImageExperiment.LSM.Attributes.pixelY);
        %-------If it's ZT data, move CurrentDataPath to CurrentDataPath\ProjFolderName
        if ZEnabled==1
            CurrentDataPath=strcat(CurrentDataPath,'\',ProjFolderName);
        else
            CurrentDataPath=CurrentDataPath;
        end
        
        %---------read tif files to register-------
        cd(CurrentDataPath);
%         TifFileList=[];
        if ZEnabled==1
            TifFileList =dir ('*.tif');  
        else
            TifFileList =dir ('*001*.tif');  %!!!!!!!!!!!!!!Change if tif file name changed!!!!!!!!!!!!
        end
        TifList=struct2cell(TifFileList);
        TifList=TifList(1,:);
        TifList=TifList';
        ImageNum=size(TifList,1);%Change here!!!!!!!
%         ImageNum=10;
        
        for i=1:ImageNum
            if i==1
                print1='reading tifs...'
            end
%             if UseAdjustedImgForReg==0
                TStack(:,:,i)=imread(TifList{i});
%             elseif UseAdjustedImgForReg==1
%                 TStack(:,:,i)=imadjust(imread(TifList{i}));
        end
        %-----Load Fixed image-----
        if UseChoosedFixedFrame==1
            FixedImagePath=strcat(CurrentDataPath,'\FixedFrame');
        elseif UseAutoFixedFrame==1
            FixedImagePath=strcat(CurrentDataPath,'\AutoFixedFrame');
        end
        cd (FixedImagePath);
        FixedFrameName =dir ('*.tif');  %!!!!!!!!!!!!!!Change if tif file name changed!!!!!!!!!!!!
        FixedFrameName=FixedFrameName(1).name;
        if UseAdjustedFixedImgForReg==0
            FixedImg=imread(FixedFrameName,'tif');
        elseif UseAdjustedFixedImgForReg==1
            FixedImg=imadjust(imread(FixedFrameName,'tif'));
        end
        %-------Do registration----------
        cd(CurrentDataPath);
        [optimizer,metric] = imregconfig("multimodal");%  Change between monomodal and multimodal depending on need. Change export function too!
        for i=1:ImageNum
%             CurrentRegImg=i;
            if mod(i,250)==0
            print1=strcat('Registering...',num2str(i),'/',num2str(ImageNum))
            end
            moving=TStack(:,:,i);
            
            RegisteredStack(:,:,i)= imregister(moving, FixedImg, TransformType, optimizer, metric); % Change 'similarity' to others?Change export function too!
        end
        %---------Save registered data-------
        NewRegFolderName=strcat('Reg_Matlab_',TransformType);
        mkdir(NewRegFolderName);
        for j=1:ImageNum
            ImgToWrite=RegisteredStack(:,:,j);
            OutputImgFileName=strcat('Reged_ZProj_T_',num2str(j,'%04d'));
            OutputPath=strcat(CurrentDataPath,'\',NewRegFolderName,'\');
            imwrite(ImgToWrite,strcat(OutputPath,OutputImgFileName,'.tif'));
        end

        SavingFileName='RegistrationParameters.mat';
        SelectedFixedFrameFileName=FixedFrameName;
        Imregconfig='monomodal'; % Change if needed!
        save(strcat(CurrentDataPath,'\',NewRegFolderName,'\',SavingFileName),'SelectedFixedFrameFileName','Imregconfig','TransformType');
        
        
%         %-------Send email to report progress-------
%         setpref('Internet','SMTP_Server','smtp.gmail.com');
%         setpref('Internet','E_mail','dbzd666@gmail.com');
%         setpref('Internet','SMTP_Username','dbzd666@gmail.com');
%         setpref('Internet','SMTP_Password','1xxwhgzsdznnys7t');
%         props = java.lang.System.getProperties;
%         props.setProperty('mail.smtp.auth','true');
%         props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
%         props.setProperty('mail.smtp.socketFactory.port','465');
%         
%         k=k-1;
%         texttobesent=strcat('Reg',num2str(directory_idx),'/',num2str(numel(list_of_directories)),' Folder -',num2str(Folder2Ind),'/',num2str(size(DataFolderList,1)),'Data Sub-folder Finished!',num2str(k),'Trials Left');
%         sendmail('faithoftrue@gmail.com',texttobesent) ;
        clear RegisteredStack TStack;
    end
    
end
end