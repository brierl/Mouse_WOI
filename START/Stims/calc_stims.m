function [traces, Acts]=calc_stims(all_contrasts2,isbrain2)
% script to determine activation area from stim experiments and output
% activation traces.

% IN:
%   all_contrasts2: pixels, pixels, contrast, frames. Fully processed data
%   isbrain2: pixel x pixel binary mask signifying brain regions

% OUT:
%   traces: contrast x frames. avg time trace durin stim in activation area
%   Acts: pixels x pixels x contrast. Image of temporal avg over stim
%       present blocks

    stimlength=20*16.8; %20*16.8 for 20 sec stim blocks framerate 16.8
    stimon=85; %frame that stim turns on 
    stimoff=168; %frame that stim turns off
    i=1;

    for c=[1 3] %contrast = 1 = gcamp. = 3 = oxy

        data=real(squeeze(all_contrasts2(:,:,c,:))); %loop through each contrast
    
        % dividing data into stim blocks, pad with frames of zeros to make
        % divisible
        temp=stimlength-rem(size(all_contrasts2,4),stimlength); 
        data(:,:,(size(data,3)+1):(size(data,3)+temp))=zeros(size(data,1),size(data,2),temp);
        data2=reshape(data,size(data,1),size(data,2),stimlength,size(data,3)/stimlength).*isbrain2; %pixels x pixels x stimlength x num of stim blocks, apply mask
    
        %subtract mean from data
        for b=1:size(data2,4)
            MeanFrame=squeeze(mean(data2(:,:,[1:(stimon-1) (stimoff+1):end],b),3));
            for t=1:size(data2, 3)
                data3(:,:,t,b)=squeeze(data2(:,:,t,b))-MeanFrame;
            end
        end
        
        AvgSig=mean(data3,4);
        
        %subtract mean from average
        MeanFrame=squeeze(mean(AvgSig(:,:,[1:(stimon-1) (stimoff+1):end]),3));
        for t=1:size(AvgSig, 3)
            AvgSig2(:,:,t)=squeeze(AvgSig(:,:,t))-MeanFrame;
        end
        
        AvgSig2(isnan(AvgSig2))=0;
        
        %plot mean activation area
        figure(1);
        imagesc(mean(AvgSig2(:,:,stimon:stimoff),3),[-5e-3 5e-3]);
        axis image off; colormap jet;
        title('Activation area')
        
        %find activation trace
        Actnew=mean(AvgSig2(:,:,stimon:stimoff),3);
        
        linemap = reshape(Actnew,size(data,1)*size(data,2),1);
        
        %find ROI
        maxforroi = max(linemap);
        disp(['max is ',num2str(maxforroi)]);
        thresh= 0.8*maxforroi; %threshold at 80% intensity
    
        Act2 = Actnew;
        Act2(Act2<thresh)=0;
    
        Act2 = logical(Act2);
               
        %plot binary figure where activation trace will be pulled
        figure(2);
        imagesc(Act2);
        axis image off;
        title(['Thresh=' num2str(0.8)])
        
        %reshape block averaged data 
        trace= reshape(AvgSig2,size(data,1)*size(data,2),stimlength);
    
        ROIx= Act2;
        ROI2 = reshape(ROIx,size(data,1)*size(data,2),1);
        ROImask = find(ROI2);
        indivROI = trace(ROImask,:); %apply thresholded binary mask
        traceROI=(mean(indivROI,1)); %avg across binary mask
        
        %plot response curve
        framelines= stimon:1/3:stimoff; %1/3 for 3hz stims
        seconds= linspace(0,stimlength,stimlength);
        
        figure(3)
        yyaxis left
        plot(seconds,traceROI,'k','linewidth',2); ylabel('contrast'); xlabel('Time (f)'); title('Group Average Stim'); hold on
        vline(framelines,'b');

        clear data data2 data3 AvgSig AvgSig2 ROIx ROI2 ROImask indivROI trace Act2 thresh maxforroi linemap
        disp('hit enter to clear figures and analyze next contrast')
        pause 
        close all
        
        %concatanate contrasts to output
        traces(i,:)=traceROI; clear traceROI
        Acts(:,:,i)=Actnew; clear Actnew
        i=i+1;

    end

end