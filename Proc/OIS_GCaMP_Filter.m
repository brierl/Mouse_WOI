function [all_contrasts_f]=OIS_GCaMP_Filter(all_contrasts2,high,low,mice,oi)
% butterworth filter data

% IN: 
%   all_contrasts2: processed data, oi.nVx x oi.nVy x contrasts x time
%   high: highpass filter
%   low: lowpass filter
%   mice: struct containing mouse filename and processing info
%   oi: optical instrument properties

% OUT:
%   all_contrasts2: processed filtered data, oi.nVx x oi.nVy x contrasts x time

all_contrasts_f=zeros(size(all_contrasts2));
all_contrasts_f_temp=zeros(size(all_contrasts2));

    for c=1:size(all_contrasts2,3)

        [all_contrasts_f_temp(:,:,c,:)]=highpass(all_contrasts2(:,:,c,:),high,oi.framerate/mice.info.temp_ds);
        [all_contrasts_f(:,:,c,:)]=lowpass(all_contrasts_f_temp(:,:,c,:),low,oi.framerate/mice.info.temp_ds);
        clear all_contrasts_f_temp

    end

end