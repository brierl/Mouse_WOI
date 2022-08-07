function [tmap,p1,h1,h1_cc_rs]=BILAT_FC_ttest(R_ms_group,group_index,isbrain2_aff,thresh,mice,oi)
% script to perform pixel-wise ttest on bilat FC maps, uses cluster extent
% threshold for significance. Only tests 1 or 2 groups at a time.

% IN:
%   R_ms_group: each cell index is a group. oi.nVx x oi.nVy x
%       contrast x mice
%   group_index: rows corresponding to excel file group separation
%   isbrain2_aff: group avg mask, oi.nVx x oi.nVy
%   thresh: cluster size threshold
%   mice: struct holding filename information for mouse
%   oi: optical instrument properties

% OUT:
%   tmap: pixel wise t-values per seed, oi.nVx oi.nVy contrast
%   h1: pixel wise significance (uncorrected) for p<0.05. 1=sig
%       0=ns. oi.nVx oi.nVy contrast
%   p1: pixel wise p-value (uncorrected). oi.nVx oi.nVy contrast
%   h1_cc_rs: pixel wise significance for p<mice.alpha. 1=sig 0=ns.
%       oi.nVx oi.nVy contrast

    isbrain2_aff(isnan(isbrain2_aff))=0;
    for i=1:length(R_ms_group)
        R_ms_group{i}=R_ms_group{i}.*isbrain2_aff;
    end
    % loop through pixels
    for f=1:size(R_ms_group{1},1)
        for g=1:size(R_ms_group{1},2)
                
            if length(group_index)==0 % if only 1 group, 1-sample t-test
                for w=1:length(oi.con_num) %loop through contrasts
                    if nansum(~isnan(R_ms_group{1}(f,g,w,:)) & R_ms_group{1}(f,g,w,:)~=0)<2
                        h1(f,g,w)=NaN;
                        p1(f,g,w)=NaN;
                        tmap(f,g,w)=NaN;
                    else
                        [h1(f,g,w),p1(f,g,w),~,stats]=ttest(R_ms_group{1}(f,g,w,:),'alpha',mice(1).alpha);
                        tmap(f,g,w)=stats.tstat;
                        clear stats
                    end
                end

            elseif length(group_index)==1 %if 2 groups
                if strcmp(mice(1).test, '2-sample')
                    for w=1:length(oi.con_num) %loop through contrasts
                        if nansum(~isnan(R_ms_group{1}(f,g,w,:)) & R_ms_group{1}(f,g,w,:)~=0)<2 || nansum(~isnan(R_ms_group{2}(f,g,w,:)) & R_ms_group{2}(f,g,w,:)~=0)<2
                            h1(f,g,w)=NaN;
                            p1(f,g,w)=NaN;
                            tmap(f,g,w)=NaN;
                        else
                            [h1(f,g,w),p1(f,g,w),~,stats]=ttest2(R_ms_group{1}(f,g,w,:),R_ms_group{2}(f,g,w,:),'alpha',mice(1).alpha);
                            tmap(f,g,w)=stats.tstat;
                            clear stats
                        end
                    end

                elseif strcmp(mice(1).test, 'paired')
                    for w=1:length(oi.con_num) %loop through contrasts
                        if nansum(~isnan(R_ms_group{1}(f,g,w,:)) & R_ms_group{1}(f,g,w,:)~=0)<2 || nansum(~isnan(R_ms_group{2}(f,g,w,:)) & R_ms_group{2}(f,g,w,:)~=0)<2
                            h1(f,g,w)=NaN;
                            p1(f,g,w)=NaN;
                            tmap(f,g,w)=NaN;
                        else
                            [h1(f,g,w),p1(f,g,w),~,stats]=ttest(R_ms_group{1}(f,g,w,:),R_ms_group{2}(f,g,w,:),'alpha',mice(1).alpha);
                            tmap(f,g,w)=stats.tstat;
                            clear stats
                        end
                    end

                else
                    disp('column X should be 2-sample or paired')
                end
            else
                disp('need to submit only 1 or 2 groups of mice')
            end
                
        end
    end
      
    h1(isnan(h1))=0;
    temp=logical(h1.*isbrain2_aff); %h1 with applied mask
    % initialize a mask for clusters with size>thresh
    h1_cc=zeros(size(R_ms_group{1},1)*size(R_ms_group{1},2),length(oi.con_num));

    for w=1:length(oi.con_num) %loop through contrasts
        % find clusters
        CC = bwconncomp(temp(:,:,w));

        for i=1:CC.NumObjects %loop through clusters

            % keep cluster if size>thresh
            if length(CC.PixelIdxList{1,i})>thresh
                h1_cc(CC.PixelIdxList{1,i},w)=1;
            end

        end
        clear CC
    end

    h1_cc_rs=reshape(h1_cc,size(R_ms_group{1},1),size(R_ms_group{1},2),length(oi.con_num));
  
end  