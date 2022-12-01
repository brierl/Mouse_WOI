function [all_contrasts_f]=OIS_GCaMP_Filter(all_contrasts2,high,low)
% butterworth filter data

% IN: 
%   all_contrasts2: processed data, pixels x pixels x contrasts x frames
%   high: highpass filter double
%   low: lowpass filter double

% OUT:
%   all_contrasts2: processed filtered data, pixels x pixels x contrasts x
%       frames

all_contrasts_f=zeros(size(all_contrasts2));
all_contrasts_f_temp=zeros(size(all_contrasts2));

    for c=1:size(all_contrasts2,3)

        [all_contrasts_f_temp(:,:,c,:)]=highpass(all_contrasts2(:,:,c,:),high,16.8); %framerate is 16.8
        [all_contrasts_f(:,:,c,:)]=lowpass(all_contrasts_f_temp(:,:,c,:),low,16.8); %framerate is 16.8
        clear all_contrasts_f_temp

    end

end