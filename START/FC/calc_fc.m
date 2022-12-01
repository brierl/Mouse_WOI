function [R_Data,Rs_Data]=calc_fc(all_contrasts2,isbrain2,seedcenter)
% script to calculate fc

% IN:
%   all_contrasts2: pixels, pixels, contrast, frames. Fully processed data
%   isbrain2: pixel x pixel binary mask signifying brain regions
%   seedcenter: seed numbers x 2; x,y coordinates file for seed centers

% OUT:
%   R_Data: FC maps pixels x pixels x seed x contrast
%   Rs_Data: seed by seed FC matrix per contrast

    %set seed diameter
    mm=10;
    mpp=mm/156; %pixels in one direction = 156
    seedradmm=0.25;
    seedradpix=seedradmm/mpp;

    % make image P with numbered seeds in clusters
    [P,xp]=burnseeds(seedcenter,seedradpix,isbrain2);
    P=fliplr(P);

    % make seed traces, then FC maps, then FC matrices
    for i=1:size(all_contrasts2,3) % number of contrasts to loop through
        strace=P2strace(P,squeeze(all_contrasts2(:,:,i,:)),xp); 
        R_Data(:,:,:,i)=strace2R(strace,squeeze(all_contrasts2(:,:,i,:)),xp); 
        Rs_Data(:,:,i)=normr(strace)*normr(strace)';
        clear strace
    end
    
    % normr doesn't spit out NaNs... so black out seeds outside FOV
    for i=1:size(seedcenter,1)
        if xp(1,i)~=1
            Rs_Data(i,:,:)=NaN;
            Rs_Data(:,i,:)=NaN;
        end
    end
    
    %will sort matrix into networks if using 26 seed set. Otherwise will do
    %nothing
    [Rs_Data]=matrix_makeover(Rs_Data);

    clear all_contrasts2

end