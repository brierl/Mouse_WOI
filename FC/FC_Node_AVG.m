function [same,same_std,same_ms_group,opp,opp_std,opp_ms_group,isbrain2_aff]=FC_Node_AVG(group_index,mice,q,oi)
% script to avg bilat fc using z transform 

% IN:
%   group_index: rows corresponding to excel file group separation
%   mice: struct holding filename and processing information for mouse
%   q: index into mice.bandstr to grab correct bandpass
%   oi: optical instrument properties

% OUT:
%   same: oi.nVx x oi.nVy x contrast x group, same hemi
%   same_std: std oi.nVx x oi.nVy x contrast x group across mice, same hemi
%   same_ms_group: each cell index is a group. oi.nVx x oi.nVy x
%       contrast x mice, same hemi
%   opp: oi.nVx x oi.nVy x contrast x group, opp hemi
%   opp_std: std oi.nVx x oi.nVy x contrast x group across mice, opp hemi
%   opp_ms_group: each cell index is a group. oi.nVx x oi.nVy x
%       contrast x mice, opp hemi
%   isbrain2_aff: group avg mask, oi.nVx x oi.nVy
   
    k=1;
    % loop through mice
    for i=1:length(mice)
    
        j=1;     
        % loop through runs for each mouse
        for n=mice(i).runs
            Z_same=real(cell2mat(struct2cell(load([mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_NodeFC.mat'],'same_nodes'))));
            Z_opp=real(cell2mat(struct2cell(load([mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_NodeFC.mat'],'opp_nodes'))));
            same_perrun(:,:,:,j)=Z_same;
            opp_perrun(:,:,:,j)=Z_opp;
            j=j+1; clear Z_same Z_opp;
        end
        
        % load mask, put in array of all masks
        load([mice(i).savename num2str(n) '-Affine_GSR_BroadBand.mat'],'isbrain2')
        isbrain2(isbrain2==0)=NaN;
        isbrainall(:,:,i)=isbrain2;
        
        % avg within mouse
        same_perms{k}=nanmean(same_perrun.*isbrain2,4); 
        opp_perms{k}=nanmean(opp_perrun.*isbrain2,4); 
        
        k=k+1;
        
    end
    
    % sort mice into respective groups
    if length(group_index)~=0 %if only one group
        
        for i=1:(length(group_index)+1) %if more than one group
            if i==1
                same_ms_group{i}=cat(4,same_perms{1:group_index(i)});
                opp_ms_group{i}=cat(4,opp_perms{1:group_index(i)});
            elseif i==(length(group_index)+1)
                same_ms_group{i}=cat(4,same_perms{group_index(i-1)+1:end}); 
                opp_ms_group{i}=cat(4,opp_perms{group_index(i-1)+1:end}); 
            else
                same_ms_group{i}=cat(4,same_perms{group_index(i-1)+1:group_index(i)}); 
                opp_ms_group{i}=cat(4,opp_perms{group_index(i-1)+1:group_index(i)}); 
            end
        end
    
    else
        
        same_ms_group{1}=cat(4,same_perms{:});
        opp_ms_group{1}=cat(4,opp_perms{:});
        
    end
    
    %make symmetrical group avg mask
    [isbrain2_aff]=make_sym_mask(isbrainall,oi);
        
    % avg across mice for each group
    for i=1:length(same_ms_group)
        same(:,:,:,i)=nanmean(cat(4,same_ms_group{i}),4);        
        same_std(:,:,:,i)=nanstd(cat(4,same_ms_group{i}),[],4);
        opp(:,:,:,i)=nanmean(cat(4,opp_ms_group{i}),4);        
        opp_std(:,:,:,i)=nanstd(cat(4,opp_ms_group{i}),[],4);
    end
                
end           