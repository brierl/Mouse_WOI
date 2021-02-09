function [R,Rstd,R_ms_group,Rs,Rsstd,Rs_ms_group,isbrain2_aff]=FC_AVG(group_index,mice,q,oi)
% script to avg fc using z transform 

% IN:
%   group_index: rows corresponding to excel file group separation
%   mice: struct holding filename and processing information for mouse
%   q: index into mice.bandstr to grab correct bandpass
%   oi: optical instrument properties

% OUT:
%   R: oi.nVx x oi.nVy x seeds x contrast x group
%   Rstd: std oi.nVx x oi.nVy x seeds x contrast x group across mice
%   R_ms_group: each cell index is a group. oi.nVx x oi.nVy x seeds x
%       contrast x mice
%   Rs: seed x seed x contrast x group
%   Rsstd: std seed x seed x contrast x group across mice
%   Rs_ms_group: each cell index is a group. seeds x seeds x
%       contrast x mice
%   isbrain2_aff: group avg mask, oi.nVx x oi.nVy
   
    k=1;
    % loop through mice
    for i=1:length(mice)
    
        j=1;     
        % loop through runs for each mouse
        for n=mice(i).runs
            Z_R=real(atanh(cell2mat(struct2cell(load([mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_FC.mat'],'R_Data'))))); % seed wise
            Z_Rs=real(atanh(cell2mat(struct2cell(load([mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_FC.mat'],'Rs_Data'))))); % matrices
            R_perrun(:,:,:,:,j)=Z_R;
            Rs_perrun(:,:,:,j)=Z_Rs;
            j=j+1; clear Z_R Z_Rs;
        end
        
        % load mask, put in array of all masks
        load([mice(i).savename num2str(n) '-Affine_GSR_BroadBand.mat'],'isbrain2')
        isbrain2(isbrain2==0)=NaN;
        isbrainall(:,:,i)=isbrain2;
        
        % avg within mouse
        R_perms{k}=nanmean(R_perrun.*isbrain2,5); 
        Rs_perms{k}=nanmean(Rs_perrun,4); 
        
        k=k+1;
        
    end
    
    % sort mice into respective groups
    if length(group_index)~=0 %if only one group
        
        for i=1:(length(group_index)+1) %if more than one group
            if i==1
                R_ms_group{i}=cat(5,R_perms{1:group_index(i)});
                Rs_ms_group{i}=cat(4,Rs_perms{1:group_index(i)});
            elseif i==(length(group_index)+1)
                R_ms_group{i}=cat(5,R_perms{group_index(i-1)+1:end}); 
                Rs_ms_group{i}=cat(4,Rs_perms{group_index(i-1)+1:end}); 
            else
                R_ms_group{i}=cat(5,R_perms{group_index(i-1)+1:group_index(i)}); 
                Rs_ms_group{i}=cat(4,Rs_perms{group_index(i-1)+1:group_index(i)}); 
            end
        end
    
    else
        
        R_ms_group{1}=cat(5,R_perms{:});
        Rs_ms_group{1}=cat(4,Rs_perms{:});
        
    end
    
    %make symmetrical group avg mask
    [isbrain2_aff]=make_sym_mask(isbrainall,oi);
        
    % avg across mice for each group
    for i=1:length(R_ms_group)
        R(:,:,:,:,i)=tanh(nanmean(cat(5,R_ms_group{i}),5));        
        Rstd(:,:,:,:,i)=tanh(nanstd(cat(5,R_ms_group{i}),[],5));
        Rs(:,:,:,i)=tanh(nanmean(cat(4,Rs_ms_group{i}),4));        
        Rsstd(:,:,:,i)=tanh(nanstd(cat(4,Rs_ms_group{i}),[],4));
    end
                
end           