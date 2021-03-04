function [max_rs_corr,max_stds_corr,maxR_ms_group,max_rs_lags,max_stds_lags,Lag_maxr_ms_group,rs_corr,stds_corr,R_ms_group,rs_lags,stds_lags,Lag_ms_group,isbrain2_aff]=AVG_NVC(group_index,mice,q,oi)

% script to avg max corr (r) between gcamp and oxy using z transform and avg
% shift (s) needed to provide max corr  

% IN:
%   group_index: rows corresponding to excel file group separation
%   mice: struct holding filename and processing information for mouse
%   q: index into mice.bandstr to grab correct bandpass
%   oi: optical instrument properties

% OUT:
%   max_rs_corr: pixels x pixels x group avg max correlation per group
%   max_stds_corr: pixels x pixels x group std max correlation per group
%   maxR_ms_group: each cell index is a group. pixels x pixels x mouse avg
%       max correlation
%   max_rs_lags: pixels x pixels x group avg lag shift per group
%   max_stds_lags: pixels x pixels x group std lag shift per group
%   Lag_maxr_ms_group: each cell index is a group. pixels x pixels x mouse avg
%       lag shift
%   rs_corr: pixels x shifts x group avg correlation
%   stds_corr: pixels x shifts x group std correlation
%   R_ms_group: each cell index is a group. pixels x shifts x mouse avg
%       correlations
%   rs_lags: pixels x shifts x group
%   stds_lags: pixels x shifts x group stds
%   Lag_ms_group: each cell index is a group. pixels x shifts x mouse
%   isbrain2_aff: group avg mask, oi.nVx x oi.nVy
        
    k=1;
    % loop through mice
    for i=1:length(mice)
        
        j=1;   
        % loop through runs for each mouse
        for n=mice(i).runs

            load([mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_NVC'],'corroxyg6','lagsoxyg6','r','all_lags')
            maxr_perrun(:,:,j)=real(atanh(r));
            lags_maxr_perrun(:,:,j)=all_lags;
            r_perrun(:,:,j)=real(atanh(corroxyg6));
            lags_perrun(:,:,j)=lagsoxyg6;
            j=j+1;
            
        end
        
        % load mask, put in array of all masks
        load([mice(i).savename num2str(n) '-Affine_GSR_BroadBand.mat'],'isbrain2')
        isbrain2(isbrain2==0)=NaN;
        isbrainall(:,:,i)=isbrain2;
        isbrain2_rs=reshape(isbrain2,oi.nVx*oi.nVy,[]);
        
        % avg within mouse
        maxr_perms(:,:,k)=nanmean(maxr_perrun.*isbrain2,3); clear maxr_perrun
        lags_maxr_perms(:,:,k)=nanmean(lags_maxr_perrun.*isbrain2,3); clear lags_maxr_perrun
        r_perms(:,:,k)=nanmean(r_perrun.*isbrain2_rs,3); clear r_perrun
        lags_perms(:,:,k)=nanmean(lags_perrun.*isbrain2_rs,3); clear lags_perrun

        k=k+1;
        
    end

    % sort mice into respective groups
    if length(group_index)~=0
        for i=1:(length(group_index)+1)
            if i==1
                maxR_ms_group{i}=maxr_perms(:,:,1:group_index(i));
                Lag_maxr_ms_group{i}=lags_maxr_perms(:,:,1:group_index(i));
                R_ms_group{i}=r_perms(:,:,1:group_index(i));
                Lag_ms_group{i}=lags_perms(:,:,1:group_index(i));
            elseif i==(length(group_index)+1)
                maxR_ms_group{i}=maxr_perms(:,:,group_index(i-1)+1:end);
                Lag_maxr_ms_group{i}=lags_maxr_perms(:,:,group_index(i-1)+1:end);
                R_ms_group{i}=r_perms(:,:,group_index(i-1)+1:end);
                Lag_ms_group{i}=lags_perms(:,:,group_index(i-1)+1:end);
            else
                maxR_ms_group{i}=maxr_perms(:,:,group_index(i-1)+1:group_index(i)); 
                Lag_maxr_ms_group{i}=lags_maxr_perms(:,:,group_index(i-1)+1:group_index(i)); 
                R_ms_group{i}=r_perms(:,:,group_index(i-1)+1:group_index(i)); 
                Lag_ms_group{i}=lags_perms(:,:,group_index(i-1)+1:group_index(i)); 
            end
        end
    else
        maxR_ms_group{1}=maxr_perms;
        Lag_maxr_ms_group{1}=lags_maxr_perms;
        R_ms_group{1}=r_perms;
        Lag_ms_group{1}=lags_perms;
    end
    
    %make symmetrical group avg mask
    [isbrain2_aff]=make_sym_mask(isbrainall,oi);

    % avg/std across mice for each group
    for i=1:length(maxR_ms_group)
        max_rs_corr(:,:,i)=tanh(nanmean(maxR_ms_group{i},3));
        max_rs_lags(:,:,i)=mean(Lag_maxr_ms_group{i},3);
        rs_corr(:,:,i)=tanh(nanmean(R_ms_group{i},3));
        rs_lags(:,:,i)=mean(Lag_ms_group{i},3);
        
        max_stds_corr(:,:,i)=tanh(std(maxR_ms_group{i},[],3));
        max_stds_lags(:,:,i)=std(Lag_maxr_ms_group{i},[],3);
        stds_corr(:,:,i)=tanh(std(R_ms_group{i},[],3));
        stds_lags(:,:,i)=std(Lag_ms_group{i},[],3);
    end

end