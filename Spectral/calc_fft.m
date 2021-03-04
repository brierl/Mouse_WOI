function [avgfft_acrossEpochs,avgfft_acrossEpochsPixels,f]=calc_fft(all_contrasts2,isbrain2,oi,mice)

% calculates fft of data

% IN:
%   all_contrasts2: oi.nVx, oi.nVy, contrast, time. processed data
%   isbrain2: pixel x pixel binary mask signifying brain regions
%   oi: optical instrument properties
%   mice: struct containing processing and filename information

% OUT:
%   avgfft_acrossEpochs: power pixel x pixel x freq x contrast
%   avgfft_acrossEpochsPixels: power freq x contrast
%   f: frequency in hz, x axis for plotting later

% create variables for number of epochs and frames per epoch and total
% frames
numepo = floor((size(all_contrasts2,4)/(oi.framerate/mice.info.temp_ds))/mice.info.fft_block);
framesPerBlock=floor(mice.info.fft_block*(oi.framerate/mice.info.temp_ds));
numframes=numepo*framesPerBlock;

% figure out the scale for Hz
f = (oi.framerate/mice.info.temp_ds)*(0:(framesPerBlock/2))/framesPerBlock;
isbrain2(isbrain2==0)=NaN; % clear out zeros to spatially average

j=1;
for i=oi.con_num
    
    data=real(squeeze(all_contrasts2(:,:,i,:)));

    % apply mask
    data=data.*isbrain2;
    % sort data pixels x frames per epoch x epochs
    dataTime=reshape(data(:,:,1:numframes),oi.nVx*oi.nVy,framesPerBlock,numepo);
    % create a hanning window and apply it
    win=hann(framesPerBlock)'; 
    dataTimeHann=bsxfun(@times,dataTime,win);
    
    FFTdata=fft(dataTimeHann,[],2); %get the FFT
    FFTdata=abs(FFTdata).^2; %get the power
    FFTdata_rs=reshape(FFTdata,[oi.nVx, oi.nVy, framesPerBlock, numepo]); % reshape to images
    
    avgfft_acrossEpochs(:,:,:,j)=squeeze(nanmean(squeeze(FFTdata_rs),4));
    avgfft_acrossEpochsPixels(:,j)=squeeze(nanmean(squeeze(nanmean(squeeze(avgfft_acrossEpochs(:,:,:,j)),1)),1));
    j=j+1;
    
end
