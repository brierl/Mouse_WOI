function [SVR_m,SVR_s,SVR_ms_group,isbrain2_aff]=SVR_AVG(group_index,mice,q,oi)

% script to calculate SVR prediction weight matrices per seed used in FC analysis 

% IN:
%   group_index: rows corresponding to excel file group separation
%   mice: struct holding filename and processing information for mouse
%   q: index into mice.bandstr to grab correct bandpass
%   oi: optical instrument properties

% OUT:
%   SVR_m: average SVR maps pix x pix x seeds x contrast x group
%   SVR_s: std for SVR maps pix x pix x seeds x contrast x group across mice
%   SVR_ms_group: cell containing individual mouse average SVR maps. 
%       Cell number corresponds to group number. pix x pix x seeds x contrast x mousenum
%   isbrain2_aff: group avg mask, oi.nVx x oi.nVy
    
    k=1;
    % loop through mice
    for i=1:length(mice)

        j=1;
        % loop through runs for each mouse
        for n=mice(i).runs
        
            load([mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_SVR.mat'],'SVR1')
            SVR_perrun(:,:,:,:,j)=SVR1;
            j=j+1;
            clear SVR1
        
        end
        
        % load mask, put in array of all masks
        load([mice(i).savename num2str(n) '-Affine_GSR_BroadBand.mat'],'isbrain2')
        isbrain2(isbrain2==0)=NaN;
        isbrainall(:,:,i)=isbrain2;
        
        % average within mouse
        SVR_perms(:,:,:,:,k)=nanmean(SVR_perrun.*isbrain2,5);
        
        k=k+1;
    
    end

    % sort mice into respective groups
    if length(group_index)~=0
        for i=1:(length(group_index)+1)
            if i==1
                SVR_ms_group{i}=SVR_perms(:,:,:,:,1:group_index(i));
            elseif i==(length(group_index)+1)
                SVR_ms_group{i}=SVR_perms(:,:,:,:,group_index(i-1)+1:end); 
            else
                SVR_ms_group{i}=SVR_perms(:,:,:,:,group_index(i-1)+1:group_index(i));
            end
        end
    else
        SVR_ms_group{1}=SVR_perms;
    end
    
    %make symmetrical group avg mask
    [isbrain2_aff]=make_sym_mask(isbrainall,oi);
    
    % average across mice for each group
    for i=1:length(SVR_ms_group)
        SVR_m(:,:,:,:,i)=nanmean(SVR_ms_group{i},5);
        SVR_s(:,:,:,:,i)=nanstd(SVR_ms_group{i},[],5);
    end
    
end