function [fft_avg,fft_std,fft_ms_group]=FFT_AVG(group_index,mice)

% plot spatially avg fft of gcamp data
% Run after processing data and calculateFFT

% IN:
%   group_index: rows corresponding to excel file group separation
%   mice: struct holding filename and processing information for mouse

% OUT:
%   fft_avg: data fft per contrast per group
%   fft_std: data fft per contrast per group standard deviation
%       across mice
%   fft_ms_group: Each cell index is a group. data fft per contrast per
%       mouse

k=1;
% loop through mice
for i=1:length(mice)

    j=1;
    % loop through runs for each mouse
    for n=mice(i).runs
        
        load([mice(i).savename,num2str(n),'-Affine_GSR_BroadBand_FFT.mat'],'avgfft_acrossEpochsPixels')
        fft_perrun(:,:,j)=avgfft_acrossEpochsPixels;
        j=j+1;
        clear avgfft_acrossEpochsPixels
        
    end
    
        % average within mouse
        fft_perms(:,:,k)=nanmean(fft_perrun,3); clear fft_perrun;
        k=k+1;

end

% sort mice into respective groups
if length(group_index)~=0
    for i=1:(length(group_index)+1)
        if i==1
            fft_ms_group{i}=fft_perms(:,:,1:group_index(i));
        elseif i==(length(group_index)+1)
            fft_ms_group{i}=fft_perms(:,:,group_index(i-1)+1:end);
        else
            fft_ms_group{i}=fft_perms(:,:,group_index(i-1)+1:group_index(i)); 
        end
    end
else
    fft_ms_group{1}=fft_perms;
end

% average across mice, pixels, and epochs for each group
for i=1:length(fft_ms_group)
    
    fft_avg(:,:,i)=squeeze(nanmean(fft_ms_group{i},3));
    fft_std(:,:,i)=squeeze(nanstd(fft_ms_group{i},[],3));
    
end

end