% Get CropROI and MidgutROI from the picture; calculate Crop size; extract
% average BlueRatio and max BlueRatio from both ROI, calculate their ration
%% --Don't forget write code to deduct air bubble size and measure food ingestion volume!
clear all
clc 
%----------Adjustable Arguments-----------
SkipROIDrawing=1;%If you have already drawed manual ROI ('ROISelectionData' folder already exist), then the code will skip ROI drawing part
YesToAll=1;

InputHSVC1Min=0.55;% for ROI detector Color Hue Min, usually 0.55
InputHSVC1Max=0.7;% for ROI detector Color Hue Max, usually 0.7
ReverseMask1OrNot0=1;

BluePixelDetectorHueMin=0.338;%For Brilliant Blue Only detector Hue Min, SHOULD BE CONSISTENT FOR ALL SAMPLE IMAGES!! Usually 0.338
BluePixelDetectorHueMax=0.704;%For Brilliant Blue Only detector Hue Min, SHOULD BE CONSISTENT FOR ALL SAMPLE IMAGES!! Usually 0.704
SaturationMin=0.175;%For Brilliant Blue Only detector Saturation Min, SHOULD BE CONSISTENT FOR ALL SAMPLE IMAGES!! Usually 0.175
CMin=0.825;%For Brilliant Blue Only detector (Brighness)Value Min, SHOULD BE CONSISTENT FOR ALL SAMPLE IMAGES!! Usually 0.825
ThresholdRatio=0.5;%Ususally 0.5
FilterSize1=15;%usually set it to 15
FilterSize2=15;%usually set it to 15
BinThreshold=0.8;%usually set it to 0.8

list_of_directories = {...
    'J:\CropData\OD-IN1xTNT\G1-WxIN1'...
    'J:\CropData\OD-IN1xTNT\G2-WxTNT'...
    'J:\CropData\OD-IN1xTNT\G3-TNTxIN1(new)'...
%     'J:\CropData\OD-Gr43axRprC\RprCxGr43a'...
%     'J:\CropData\OD-Gr43axRprC\WxGr43a'...
%     'J:\CropData\OD-Gr43axRprC\WxRprC'...
%     'J:\CropData\OD-Gut2\WxGut2'...
%     'J:\CropData\OD-Gut2\TNTxGut2'...
    };

for directory_idx  = 1:numel(list_of_directories)

    %% -------Read tif----------
    CurrentFolder=list_of_directories{directory_idx};
    cd(CurrentFolder);
    disp(sprintf('Processing %s',list_of_directories{directory_idx}));
    
    CurTifFilelist=dir('*.tif');
    for i=1:size(CurTifFilelist,1)
        CurrentFolder=list_of_directories{directory_idx};
        cd(CurrentFolder);
        CurTifImageFileName=CurTifFilelist(i).name;
        CurTifImage=imread(CurTifImageFileName);
        fig1=figure;
        CurrentFig=imshow(CurTifImage,[]);
        title(strcat(CurrentFolder,'\',CurTifImageFileName));
        fullfig(fig1);
%% --------Draw ROI for Crop--------
    %-------------Draw ROI-------------
        ROINo=2;

        ROIsizeByMMSq=[];
        NoOfBluePixelInROI=[];
        NoOfTotalPixelInROI=[];
        BlueRatioOfROI=[];
        for ROIi=1:ROINo
            %% -----------Manual Drawing of ROIs-------
            if SkipROIDrawing==0
                keepdrawing=1;
                while keepdrawing==1
                    if ROIi==1
                        title(strcat(CurrentFolder,'\',CurTifImageFileName,'; Please Draw Crop (1st ROI)'));
                    elseif ROIi==2
                        title(strcat(CurrentFolder,'\',CurTifImageFileName,'; Please Draw MidGut (2nd ROI)'));
                    else
                        title(strcat(CurrentFolder,'\',CurTifImageFileName,'; Please Draw ROI no.',num2str(ROIi)));
                    end
                    RoiManual=imfreehand();
                    ManualMask(:,:,ROIi) = createMask(RoiManual,CurrentFig); %Manually Draw ROI
                    ManualMaskedImageC1=CurTifImage(:,:,1);
                    ManualMaskedImageC1(~ManualMask(:,:,ROIi))=0;
                    ManualMaskedImageC2=CurTifImage(:,:,2);
                    ManualMaskedImageC2(~ManualMask(:,:,ROIi))=0;
                    ManualMaskedImageC3=CurTifImage(:,:,3);
                    ManualMaskedImageC3(~ManualMask(:,:,ROIi))=0;
                    ManualMaskedImage=cat(3,ManualMaskedImageC1,ManualMaskedImageC2,ManualMaskedImageC3);
                    fig2=figure;
                    ManualMaskedImageFig=imshow(ManualMaskedImage);
                    fullfig(fig2);
                    pause(1);
                    if YesToAll==0
                        ans=questdlg('Do you want to accept this as manual ROI?');
                    else
                        ans='Yes';
                    end
                    if strcmp(ans,'Yes')||YesToAll==1
                        keepdrawing=0;
                        IMGWritePath=strcat('ManualROI',num2str(ROIi),'OnlyImg');
                        mkdir(strcat('ManualROI',num2str(ROIi),'OnlyImg'));
                        imwrite(ManualMaskedImage,strcat(CurrentFolder,'\',IMGWritePath,'\',CurTifImageFileName(1:end-4),'-ManualROI',num2str(ROIi),'OnlyImg.tif'));
                        MaskToWrite=ManualMask(:,:,ROIi);
                        imwrite(MaskToWrite,strcat(CurrentFolder,'\',IMGWritePath,'\',CurTifImageFileName(1:end-4),'-ManualROI',num2str(ROIi),'Mask.tif'));
    %                     save('ManualMask')
                    else
                        keepdrawing=1;
                        delete (RoiManual);
                    end
                    close(fig2);
                end
            else
                load(strcat(CurrentFolder,'\ROISelectionData\ROISelectInfo-',CurTifImageFileName(1:end-4),'.mat'),'ManualMask','RoiManual');
                ManualMaskedImageC1=CurTifImage(:,:,1);
                ManualMaskedImageC1(~ManualMask(:,:,ROIi))=0;
                ManualMaskedImageC2=CurTifImage(:,:,2);
                ManualMaskedImageC2(~ManualMask(:,:,ROIi))=0;
                ManualMaskedImageC3=CurTifImage(:,:,3);
                ManualMaskedImageC3(~ManualMask(:,:,ROIi))=0;
                ManualMaskedImage=cat(3,ManualMaskedImageC1,ManualMaskedImageC2,ManualMaskedImageC3);
%                 fig2=figure;
%                 ManualMaskedImageFig=imshow(ManualMaskedImage);
%                 fullfig(fig2);
            end
        %% ---------Add adjustable color filter to manual ROI--------
        KeepAdjustMask=1;
        while KeepAdjustMask==1
            InputRGBImage=ManualMaskedImage;
            [ColorMask1,ColorMaskedImage] = CreateMaskHSV(InputRGBImage,InputHSVC1Min,InputHSVC1Max,ReverseMask1OrNot0);
            ColorAndManualMask=ColorMask1.*ManualMask(:,:,ROIi);
%                 imshow(ColorAndManualMask);
            title('Color Filtered Manual Mask');
            %% ---------Add K Average filter to mask to make it smooth-------
            %-----First, pick up all gut/crop pixels------
            int8ColorAndManualMask1=int8(ColorAndManualMask);
            SmoothedMask1=filter2(fspecial('average',FilterSize1),int8ColorAndManualMask1);%Kaverage Filter
            %Ask here do you want to adjust FilterSize, if not, add guassian filter to mask
            Mask2=logical(SmoothedMask1);
%                 imshow(Mask2);
            title(strcat('Filtered Manual Mask (Should Show Whole ROI), After Average Filter 1 , filter size ',num2str(FilterSize1)));
%                 imshowpair(SmoothedMask1,Mask2,'montage');
            %-----Second, remove all noise dots
            int8Mask2=int8(Mask2);
            SmoothedMask2=filter2(fspecial('average',FilterSize2),int8Mask2);%Kaverage Filter
            BinedSmoothedMask2=SmoothedMask2;
            BinedSmoothedMask2(BinedSmoothedMask2<BinThreshold)=0;

            FinalMask(:,:,ROIi)=logical(BinedSmoothedMask2);
            FinalMaskedImageC1=CurTifImage(:,:,1);
            FinalMaskedImageC1(~FinalMask(:,:,ROIi))=0;
            FinalMaskedImageC2=CurTifImage(:,:,2);
            FinalMaskedImageC2(~FinalMask(:,:,ROIi))=0;
            FinalMaskedImageC3=CurTifImage(:,:,3);
            FinalMaskedImageC3(~FinalMask(:,:,ROIi))=0;
            FinalMaskedImage=cat(3,FinalMaskedImageC1,FinalMaskedImageC2,FinalMaskedImageC3);
            fig3=figure;
            imshowpair(FinalMask(:,:,ROIi),FinalMaskedImage,'montage');
            fullfig(fig3);
            title(strcat('Color Filtered Manual Mask, After Thresholded Average Filter 2 , filter size ',num2str(FilterSize2)));
            %% ----Check ROI quality----
            pause(1);
            if YesToAll==0
                ans=questdlg('Do you want to accept this as Color Masked Final ROI?');
            else
                ans='Yes';
            end
            if strcmp(ans,'Yes')||YesToAll==1
                KeepAdjustMask=0;
                IMGWritePath=strcat('FinalManuROI',num2str(ROIi),'OnlyImg');
                mkdir(strcat('FinalManuROI',num2str(ROIi),'OnlyImg'));
                imwrite(FinalMaskedImage,strcat(CurrentFolder,'\',IMGWritePath,'\',CurTifImageFileName(1:end-4),'-FinalROI',num2str(ROIi),'OnlyImg.tif'));
                imwrite(FinalMask(:,:,ROIi),strcat(CurrentFolder,'\',IMGWritePath,'\',CurTifImageFileName(1:end-4),'-FinalROI',num2str(ROIi),'Mask.tif'));
            else
                KeepAdjustMask=1;

                prompt = {'Enter desired Color Filter Min Limit'};
                title2 = 'Color Filter Min Limit';
                definput = {num2str(InputHSVC1Min)};
                ans2 = inputdlg(prompt,title2,[1 40],definput);
                InputHSVC1Min=str2num(ans2{1});
                prompt = {'Enter desired Color Filter Max Limit'};
                title2 = 'Color Filter Max Limit';
                definput = {num2str(InputHSVC1Max)};
                ans2 = inputdlg(prompt,title2,[1 40],definput);
                InputHSVC1Max=str2num(ans2{1});
                prompt = {'Enter desired K average Filter Size 1 (For picking up all ommitted pixel)'};
                title2 = 'FilterSize1';
                definput = {num2str(FilterSize1)};
                ans2 = inputdlg(prompt,title2,[1 40],definput);
                FilterSize1=str2num(ans2{1});
                prompt = {'Enter desired K average Filter Size 2 (For eliminate all background dirts)'};
                title2 = 'FilterSize2';
                definput = {num2str(FilterSize2)};
                ans2 = inputdlg(prompt,title2,[1 40],definput);
                FilterSize2=str2num(ans2{1});
                prompt = {'Enter desired K average BinThreshold'};
                title2 = 'BinThreshold';
                definput = {num2str(BinThreshold)};
                ans2 = inputdlg(prompt,title2,[1 40],definput);
                BinThreshold=str2num(ans2{1});
            end
            close(fig3);
        end
%% ---------Extract Size Of ROI----------
%------Get ROI size, pixel size of ROI1 is Crop Size----
%------For my Keyence Setting 1, scale is 0.75488um/pixel----
        UmPerPixel=0.75488;
        AreaPerPixel=UmPerPixel*UmPerPixel;
        CurrentMask=FinalMask(:,:,ROIi);
        CurrentMaskAreaByPixel=sum(sum(CurrentMask));%=pixel number of current mask
        CurrentMaskAreaByUMSq=AreaPerPixel*CurrentMaskAreaByPixel;
        CurrentMaskAreaByMMSq=0.001*0.001*CurrentMaskAreaByUMSq;

        ROIsizeByMMSq=[ROIsizeByMMSq,CurrentMaskAreaByMMSq];

        %-------Save size data---------
        if i==1
            HeaderToWrite=[{'TifFileName'},{'ROI No.(1 is Crop, 2 is Midgut)'},{'SizeOfROIByMMSq'}];
            writecell(HeaderToWrite,strcat('ROI',num2str(ROIi),'SizeByMMSq.xls'),'WriteMode','append');
        end
        currenttime=datetime();
        RowToWrite=[{CurTifImageFileName},{num2str(ROIi)},{num2str(ROIsizeByMMSq(ROIi))}];
        writecell(RowToWrite,strcat('ROI',num2str(ROIi),'SizeByMMSq.xls'),'WriteMode','append');
%% ---------Extract Color Of ROI----------
% % %----Below are old failed design of BlueRatio detection, DO NOT USE, only for display--------
% % % ------Calculate BlueRatio using RGB values--------
% %     PureBlueImage=cat(3,zeros(size(FinalMaskedImageC1)),zeros(size(FinalMaskedImageC1)),ones(size(FinalMaskedImageC1)).*255);
% %     % imshow(PureBlueImage);
% %     DesiredColorVal=[0 0 1];
% %     BlueDistMatrix=ones(size(FinalMaskedImageC1)).*sqrt(3);
% %     [xa,ya]=find(FinalMask(:,:,ROIi));
% %     BlueRatioVector=ones(size(xa)).*sqrt(3);%Initialization, set all measurment to the maximum possible value
% %     
% %     DoubleFinalMaskedImageC1=im2double(FinalMaskedImageC1);%Once it's double, Value range is 0-1. Before convert to double, value range is 0-255
% %     DoubleFinalMaskedImageC2=im2double(FinalMaskedImageC2);
% %     DoubleFinalMaskedImageC3=im2double(FinalMaskedImageC3);
% %     
% %     for i1=1:size(xa,1)
% %         C1ColorVal=DoubleFinalMaskedImageC1(xa(i1),ya(i1));
% %         C2ColorVal=DoubleFinalMaskedImageC1(xa(i1),ya(i1));
% %         C3ColorVal=DoubleFinalMaskedImageC1(xa(i1),ya(i1));
% %         CurrentDistToPureBlue=sqrt((C1ColorVal-DesiredColorVal(1)).^2+...
% %             (C2ColorVal-DesiredColorVal(2)).^2+...
% %             (C3ColorVal-DesiredColorVal(3)).^2);
% %         BlueRatioVector(i1,1)=CurrentDistToPureBlue;
% %         BlueDistMatrix(xa(i1),ya(i1))=CurrentDistToPureBlue;
% %     end
% %     fig4=figure;
% %     imshow(BlueDistMatrix,[]);
% %     savefig(fig4,strcat('BlueDistMatrixROI',num2str(ROIi),'.fig'));
% %     close;
% % %----Above are old failed design of BlueRatio detection, DO NOT USE, only for display--------
%-----Use this HSV BlueRatio detector instead-------

    KeepAdjustColorMask=1;
    while KeepAdjustColorMask==1
        InputRGBImage=FinalMaskedImage;
        [BlueOnlyMask,BlueOnlyMaskedImage] = CreateHSVMaskForBlueOnly(InputRGBImage,BluePixelDetectorHueMin,BluePixelDetectorHueMax,SaturationMin,CMin);
    
        BlueOnlyFig=figure;
        imshowpair(BlueOnlyMask(:,:),BlueOnlyMaskedImage,'montage');
        title(strcat('Blue Only Mask, filter size ',num2str(FilterSize2)));
        fullfig(BlueOnlyFig);
        pause(1);
        if YesToAll==0
            ans=questdlg('Do you want to accept this as Color Masked Final ROI?');
        else
            ans='Yes';
        end
        
        if strcmp(ans,'Yes')||YesToAll==1
            KeepAdjustColorMask=0;
            IMGWritePath=strcat('BlueOnlyROI',num2str(ROIi),'OnlyImg');
            mkdir(strcat('BlueOnlyROI',num2str(ROIi),'OnlyImg'));
            imwrite(BlueOnlyMaskedImage,strcat(CurrentFolder,'\',IMGWritePath,'\',CurTifImageFileName(1:end-4),'-BlueOnlyROI',num2str(ROIi),'OnlyImg.tif'));
            MaskToWrite=BlueOnlyMask;
            imwrite(MaskToWrite,strcat(CurrentFolder,'\',IMGWritePath,'\',CurTifImageFileName(1:end-4),'-BlueOnlyROI',num2str(ROIi),'Mask.tif'));
        else
            prompt = {'Enter desired BLUE ONLY Filter Min Limit'};
            title2 = 'BluePixelDetectorHueMin';
            definput = {num2str(BluePixelDetectorHueMin)};
            ans2 = inputdlg(prompt,title2,[1 40],definput);
            BluePixelDetectorHueMin=str2num(ans2{1});
            prompt = {'Enter desired BLUE ONLY Filter Max Limit'};
            title2 = 'BluePixelDetectorHueMax';
            definput = {num2str(BluePixelDetectorHueMax)};
            ans2 = inputdlg(prompt,title2,[1 40],definput);
            BluePixelDetectorHueMax=str2num(ans2{1});
            prompt = {'Enter desired Saturation MIN Limit'};
            title2 = 'Saturation Min';
            definput = {num2str(SaturationMin)};
            ans2 = inputdlg(prompt,title2,[1 40],definput);
            SaturationMin=str2num(ans2{1});
        end
        close(BlueOnlyFig);
    end

%------Calculate Number of blue pixel-----
    NoOfBluePixelInROI=[NoOfBluePixelInROI,sum(sum(BlueOnlyMask))];
    NoOfTotalPixelInROI=[NoOfTotalPixelInROI,sum(sum(FinalMask(:,:,ROIi)))];
    BlueRatioOfROI=[BlueRatioOfROI,NoOfBluePixelInROI(ROIi)./NoOfTotalPixelInROI(ROIi)];
%------StoreBlueRatioResult for Each ROI---
    if i==1
        HeaderToWrite=[{'TifFileName'},{'ROI No.(1 is Crop, 2 is Midgut)'},{'BlueRatioOfROI'},{'NoOfBluePixelInROI'},{'NoOfTotalPixelInROI'}];
        writecell(HeaderToWrite,strcat('ROI',num2str(ROIi),'BlueRatio.xls'),'WriteMode','append');
    end
    currenttime=datetime();
    RowToWrite=[{CurTifImageFileName},{num2str(ROIi)},{num2str(BlueRatioOfROI(ROIi))},{num2str(NoOfBluePixelInROI(ROIi))},{num2str(NoOfTotalPixelInROI(ROIi))}];
    writecell(RowToWrite,strcat('ROI',num2str(ROIi),'BlueRatio.xls'),'WriteMode','append');
end
%% ----All ROI separate processing finished here------
    if ROINo==2 %If there are 2 ROI in total
    %% ------Calculate Size Ratio and BlueRatio of two ROI, store data-----
    %--------Calculate Size Ratio: Size of ROI1/Size of ROI2-----
        SizeRatioROI1vROI2=ROIsizeByMMSq(1)/ROIsizeByMMSq(2);
    %--------Calculate BlunessRatio: BlueRatio of ROI1/BlueRatio of ROI2------
        BlueRatioROI1vROI2=BlueRatioOfROI(1)/BlueRatioOfROI(2);
        %-----Store Ratio data-----
        if i==1
            HeaderToWrite=[{'TifFileName'},{'SizeRatio,ROI1/ROI2'},{'BlueRatio,ROI1/ROI2'}...
            ,{'ROI1SizeByMM^2'},{'ROI2SizeByMM^2'}...
            ,{'BlueRatioOfROI1(NoOfBluePixelInROI1/NoOfTotalPixelInROI1)'},{'NoOfBluePixelInROI1'},{'NoOfTotalPixelInROI1'}...
            ,{'BlueRatioOfROI2(NoOfBluePixelInROI2/NoOfTotalPixelInROI2)'},{'NoOfBluePixelInROI2'},{'NoOfTotalPixelInROI2'}];
            writecell(HeaderToWrite,strcat('SizeAndBlueRatioOfAllImgs.xls'),'WriteMode','append');
        end
    RowToWrite=[{CurTifImageFileName},{num2str(SizeRatioROI1vROI2)},{num2str(BlueRatioROI1vROI2)}...
    ,{num2str(ROIsizeByMMSq(1))},{num2str(ROIsizeByMMSq(2))}...
    ,{num2str(BlueRatioOfROI(1))},{num2str(NoOfBluePixelInROI(1))},{num2str(NoOfTotalPixelInROI(1))}...
    ,{num2str(BlueRatioOfROI(2))},{num2str(NoOfBluePixelInROI(2))},{num2str(NoOfTotalPixelInROI(2))}];
    writecell(RowToWrite,strcat('SizeAndBlueRatioOfAllImgs.xls'),'WriteMode','append');
        
    end
%% ------Store ROI selection data after finish all ROI-----
    mkdir('ROISelectionData');
    save(strcat(CurrentFolder,'\ROISelectionData\ROISelectInfo-',CurTifImageFileName(1:end-4),'.mat'),...
        'CurTifImage','','RoiManual', ...
        'ManualMask','ColorMask1','InputHSVC1Min','InputHSVC1Max', ...
        'FinalMask','FilterSize1','FilterSize2','BinThreshold',...
        'BluePixelDetectorHueMin','BluePixelDetectorHueMax','SaturationMin','CMin');  
    mkdir('ROIDrawing');
    cd(strcat(CurrentFolder,'\ROIDrawing'));
    savefig(strcat('ROIDrawings-',CurTifImageFileName(1:end-4),'.fig'));
    %---Clear variables----
    clearvars -except InputHSVC1Min InputHSVC1Max ThresholdRatio ReverseMask1OrNot0 ...
FilterSize1 FilterSize2 BinThreshold list_of_directories directory_idx ...
CurrentFolder CurTifFilelist i BluePixelDetectorHueMin BluePixelDetectorHueMax SaturationMin SkipROIDrawing YesToAll CMin
    close;
    end
end