function [ematrix_ms_group,ematrix]=prep_matrix_simple(Rs_ms_group,oi,regions)
% script to turn averaged FC matrices into "enriched" version 

% IN:
%   Rs_ms_group: each cell index is a group. seeds x seeds x
%       contrast x mice
%   oi: optical instrument properties
%   regions: cell containing seed numbers per cortical region

% OUT:
%   ematrix_ms_group: each cell index is a group. seeds x seeds x
%       contrast x mice. enriched
%   ematrix: seed x seed x contrast x group. enriched

for i=1:length(Rs_ms_group) %loop through groups
    matrix_ms_group{i}=NaN(length(regions),length(regions),length(oi.con_num),size(Rs_ms_group{i},4)); %initialize matrix with condensed regions
    for ii=1:length(oi.con_num) %loop through contrasts
        for j=1:length(regions) %loop through cortical regions one axis
            for k=1:length(regions) %loop through cortical regions one axis
                matrix_ms_group{i}(j,k,ii,:)=squeeze(nanmean(nanmean(Rs_ms_group{i}(regions{j},regions{k},ii,:),2),1)); %average over cortical region
            end
        end
    end
end

for i=1:length(Rs_ms_group) %loop through groups
    ematrix_ms_group{i}=NaN(size(Rs_ms_group{i},1),size(Rs_ms_group{i},2),length(oi.con_num),size(Rs_ms_group{i},4)); %initialize matrix where cortical surface area is correlated to matrix surface area
    for ii=1:length(oi.con_num) %loop through contrasts
        for j=1:length(regions) %loop through cortical regions one axis
            for jj=1:length(regions) %loop through cortical regions one axis
                for k=regions{j} %loop through surface area for region
                    for kk=regions{jj} %loop through surface area for region
                        ematrix_ms_group{i}(k,kk,ii,:)=matrix_ms_group{i}(j,jj,ii,:); %expand cortical regions to fill correct surface area
                    end
                end
            end
        end   
    end
end

for i=1:length(Rs_ms_group) %loop through groups
    ematrix(:,:,:,i)=tanh(nanmean(ematrix_ms_group{i},4)); %average across groups
end

end
