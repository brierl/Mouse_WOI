function [fft_avg_image,fft_std_image,fft_image_ms_group,isbrain2_aff]=FFT_MAP_AVG(group_index,mice,q,oi)
% script to avg FFT maps 

% IN:
%   group_index: rows corresponding to excel file group separation
%   mice: struct holding filename and processing information for mouse
%   q: index into mice.bandstr to grab correct bandpass
%   oi: optical instrument properties

% OUT:
%   fft_avg_image: oi.nVx x oi.nVy x contrast x group
%   fft_std_image: std oi.nVx x oi.nVy x contrast x group across mice
%   fft_image_ms_group: each cell index is a group. oi.nVx x oi.nVy x
%       contrast x mice
%   isbrain2_aff: group avg mask, oi.nVx x oi.nVy
   
    k=1;
    % loop through mice
    for i=1:length(mice)
    
        j=1;     
        % loop through runs for each mouse
        for n=mice(i).runs
            fft_run=real(cell2mat(struct2cell(load([mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_FFT_image.mat'],'avgfft_band'))));
            fft_perrun(:,:,:,j)=fft_run;
            j=j+1; clear Z_R;
        end
        
        % load mask, put in array of all masks
        load([mice(i).savename num2str(n) '-Affine_GSR_BroadBand.mat'],'isbrain2')
        isbrain2(isbrain2==0)=NaN;
        isbrainall(:,:,i)=isbrain2;
        % avg within mouse
        fft_perms{k}=nanmean(fft_perrun.*isbrain2,4); 
        
        k=k+1;
        
    end
    
    % sort mice into respective groups
    if length(group_index)~=0 %if only one group
        
        for i=1:(length(group_index)+1) %if more than one group
            if i==1
                fft_image_ms_group{i}=cat(4,fft_perms{1:group_index(i)});
            elseif i==(length(group_index)+1)
                fft_image_ms_group{i}=cat(4,fft_perms{group_index(i-1)+1:end}); 
            else
                fft_image_ms_group{i}=cat(4,fft_perms{group_index(i-1)+1:group_index(i)}); 
            end
        end
    
    else
        
        fft_image_ms_group{1}=cat(4,fft_perms{:});
        
    end
    
    %make symmetrical group avg mask
    [isbrain2_aff]=make_sym_mask(isbrainall,oi);
        
    % avg across mice for each group
    for i=1:length(fft_image_ms_group)
        fft_avg_image(:,:,:,i)=nanmean(cat(4,fft_image_ms_group{i}),4);        
        fft_std_image(:,:,:,i)=nanstd(cat(4,fft_image_ms_group{i}),[],4);
    end
                
end           