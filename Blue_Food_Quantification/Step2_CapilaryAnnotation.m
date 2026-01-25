%% =======FDA Analysis Step 2_Get feeding volume===========

clear all
clc 
%----------Adjustable Arguments-----------

CapillaryOuterDiameterInMM=1;%Need to check!!!!
ImageDuplicateNo=2;%How many picture you took each time to record the referecen and fed capilary liquid length, usually 2
CapImgFolderName='Cap';
list_of_directories = {...
    'J:\CropData\OD-Gr43axRprC\RprCxGr43a'...
%     'J:\CropData\OD-Gr43axRprC\WxGr43a'...
%     'J:\CropData\OD-Gr43axRprC\WxRprC'...
%     'J:\CropData\OD-Gut2\WxGut2'...
%     'J:\CropData\OD-Gut2\TNTxGut2'...
    };

for directory_idx  = 1:numel(list_of_directories)

    %% -------Read tif----------
    CurrentFolder=strcat(list_of_directories{directory_idx},'\',CapImgFolderName);
    cd(CurrentFolder);
    disp(sprintf('Processing %s',list_of_directories{directory_idx}));
    
    CurImgFilelist=dir('*.jpg');
    ImageNumber=size(CurImgFilelist,1);
    RefLengthInAllImgByMM=zeros(1,ImageNumber);
    FeedLengthInAllImgByMM=zeros(1,ImageNumber);
    for ImageIndex=1:ImageNumber
        CurImageFileName=CurImgFilelist(ImageIndex).name;
        CurImage=imread(CurImageFileName);
        fig1=figure;
        CurrentFig=imshow(CurImage,[]);
        title(strcat(CurrentFolder,'\',CurImageFileName));
        fullfig(fig1);
%% --------Draw ROI for Crop--------
    %-------------Draw ROI-------------
        ROINo=4;
        MeasuredDistInThisImgByPixel=zeros(1,ROINo);
        for ROIi=1:ROINo
            keepdrawing=1;
            while keepdrawing==1
                if ROIi==1
                    title({strcat('Please click the upper and lower surface in the Reference Capillary,CurrentImage:',CurImageFileName,';',num2str(ImageIndex),'/',num2str(ImageNumber))});
                elseif ROIi==2
                    title({strcat('Please click the OUTER DIAMETER in the Reference Capillary,CurrentImage:',CurImageFileName,';',num2str(ImageIndex),'/',num2str(ImageNumber))});
                elseif ROIi==3
                    title({strcat('Please click the upper and lower surface in the Feeding Capillar,CurrentImage:',CurImageFileName,';',num2str(ImageIndex),'/',num2str(ImageNumber))});
                elseif ROIi==4
                    title({strcat('Please click the OUTER DIAMETER in the Feeding Capillary,CurrentImage:',CurImageFileName,';',num2str(ImageIndex),'/',num2str(ImageNumber))});
                else
                    title(strcat('Please Draw ROI no.',num2str(ROIi)));
                end
                [Refx1,Refy1] = ginput(2);
                hold on
                if ROIi==1||ROIi==3
                    ScaPlot=scatter(Refx1,Refy1,'filled','b');
                else
                    ScaPlot=scatter(Refx1,Refy1,'filled','r');
                end
                ans=questdlg('Do you want to accept this as manual measurement points?');
                if strcmp(ans,'Yes')
                    keepdrawing=0;
                else
                    keepdrawing=1;
                    delete(ScaPlot);
                end
            end
            %-----Calculate distancee between two clicked point-----
            DistBetwPoint=sqrt((Refy1(2)-Refy1(1)).^2+(Refx1(2)-Refx1(1)).^2);
            MeasuredDistInThisImgByPixel(1,ROIi)=DistBetwPoint;%Should be 1 by 4 matrix, 1st value is Ref Length, 2nd is Ref diameter, 3rd is feeding length, 4th is feeding diameter
        end%All ROI processing ended here
            savefig(fig1,strcat('Marked',CurImageFileName(1:end-5),'.fig'));
            close(fig1);
            %-----Convert to mm, Save measured Data-------
            RefCapLengthByPixel=MeasuredDistInThisImgByPixel(1);
            RefCapDiameterByPixel=MeasuredDistInThisImgByPixel(2);
            RefPixelPerMM=RefCapDiameterByPixel./CapillaryOuterDiameterInMM;
            RefCapLengthByMM=RefCapLengthByPixel./RefPixelPerMM;
            RefLengthInAllImgByMM(1,ImageIndex)=RefCapLengthByMM;

            FeedCapLengthByPixel=MeasuredDistInThisImgByPixel(3);
            FeedCapDiameterByPixel=MeasuredDistInThisImgByPixel(4);
            FeedPixelPerMM=FeedCapDiameterByPixel./CapillaryOuterDiameterInMM;
            FeedCapLengthByMM=FeedCapLengthByPixel./FeedPixelPerMM;
            FeedLengthInAllImgByMM(1,ImageIndex)=FeedCapLengthByMM;
            if ImageIndex==1
                HeaderToWrite=[{'ImageFileName'},...
                    {'RefCapilary-Distance between liquid surface By Pixel'},{'RefCapilary-Distance of Capillary Diameter By Pixel'},...
                    {'RefCapilary-Pixel/mm'},{'RefCapilary-Distance between liquid surface By mm'},...
                    {'FeedCapilary-Distance between liquid surface By Pixel'},{'FeedCapilary-Distance of Capillary Diameter By Pixel'},...
                    {'FeedCapilary-Pixel/mm'},{'FeedCapilary-Distance between liquid surface By mm'},...
                    ];
                writecell(HeaderToWrite,strcat('DistMeasure.xls'),'WriteMode','append');
            end
            RowToWrite=[{CurImageFileName},{num2str(RefCapLengthByPixel)},{num2str(RefCapDiameterByPixel)},...
                {num2str(RefPixelPerMM)},{num2str(RefCapLengthByMM)},...
                {num2str(FeedCapLengthByPixel)},{num2str(FeedCapDiameterByPixel)},...
                {num2str(FeedPixelPerMM)},{num2str(FeedCapLengthByMM)}];
            writecell(RowToWrite,strcat('DistMeasure.xls'),'WriteMode','append');
    end%All images processing eneded here
%------For every two image, get average liquid length for both ref and feed capillary------
    AveragedRefLengthInAllImgByMM=zeros(1,ImageNumber/ImageDuplicateNo);
    AveragedFeedLengthInAllImgByMM=zeros(1,ImageNumber/ImageDuplicateNo);
    for i=1:length(AveragedRefLengthInAllImgByMM)
        BinningStartFrameNo=(i-1)*ImageDuplicateNo+1;
        BinningStopFrameNo=i*ImageDuplicateNo;
        AveragedRefLengthInAllImgByMM(1,i)=mean(RefLengthInAllImgByMM(BinningStartFrameNo:BinningStopFrameNo));
        AveragedFeedLengthInAllImgByMM(1,i)=mean(FeedLengthInAllImgByMM(BinningStartFrameNo:BinningStopFrameNo));
    end

%-----Deduct change of Ref length from change of fed length, get real feeding volume----
    LengthChangeOfAllRefCap=zeros(1,length(AveragedRefLengthInAllImgByMM)/2);
    LengthChangeOfAllFeedCap=zeros(1,length(AveragedFeedLengthInAllImgByMM)/2);
    FinalFeedingVolume=zeros(1,length(AveragedRefLengthInAllImgByMM)/2);
    for j=1:length(FinalFeedingVolume)
        RefCapLengthBeforeFeed=AveragedRefLengthInAllImgByMM((j-1)*2+1);
        RefCapLengthAfterFeed=AveragedRefLengthInAllImgByMM((j)*2);
        LengthChangeOfAllRefCap(1,j)=RefCapLengthBeforeFeed-RefCapLengthAfterFeed;
        
        FeedCapLengthBeforeFeed=AveragedFeedLengthInAllImgByMM((j-1)*2+1);
        FeedCapLengthAfterFeed=AveragedFeedLengthInAllImgByMM((j)*2);
        LengthChangeOfAllFeedCap(1,j)=FeedCapLengthBeforeFeed-FeedCapLengthAfterFeed;

        FinalFeedingVolume(1,j)=LengthChangeOfAllFeedCap(1,j)-LengthChangeOfAllRefCap(1,j);
    end
    %------Write Final Feeding Volume From all recorded images(4 img per fly)-----
    FirstImageNameList=[];
    for i2=1:length(FinalFeedingVolume)
        ImageNameToAdd=CurImgFilelist((i2-1)*2*ImageDuplicateNo+1).name;
        FirstImageNameList=[FirstImageNameList;{ImageNameToAdd}];
    end

        HeaderToWrite=[{'FirstImageName(OfAllImagesOftheSameFly)'},...
            {'FinalFeedingLengthChange(mm)'},{'ChangeOfAveragedReferenceCapilaryLength'},{'ChangeOfAveragedFeedCapLength'}];
        writecell(HeaderToWrite,strcat('FinalFeedingVolumeMeasure.xls'),'WriteMode','append');
    RowToWrite=[FirstImageNameList,num2cell(FinalFeedingVolume'),num2cell(LengthChangeOfAllRefCap'),...
        num2cell(LengthChangeOfAllFeedCap')];
    writecell(RowToWrite,strcat('FinalFeedingVolumeMeasure.xls'),'WriteMode','append');

end