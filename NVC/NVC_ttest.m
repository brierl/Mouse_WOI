function [tmap1,p1,h1,h1_cc_rs,tmap2,p2,h2,h2_cc_rs]=NVC_ttest(maxR_ms_group,Lag_maxr_ms_group,group_index,isbrain2_aff,thresh,mice)
% script to perform pixel-wise ttest on bilat FC maps, uses cluster extent
% threshold for significance. Only tests 1 or 2 groups at a time.

% IN:
%   maxR_ms_group: each cell index is a group. oi.nVx x oi.nVy x
%       contrast x mice max corr
%   Lag_maxr_ms_group: each cell index is a group. oi.nVx x oi.nVy x
%       contrast x mice lag for max corr
%   group_index: rows corresponding to excel file group separation
%   isbrain2_aff: group avg mask, oi.nVx x oi.nVy
%   thresh: cluster size threshold
%   mice: struct holding filename information for mouse
%   oi: optical instrument properties

% OUT:
%   tmap1: pixel wise t-values per seed, oi.nVx oi.nVy contrast corr
%   h1: pixel wise significance (uncorrected) for p<0.05. 1=sig
%       0=ns. oi.nVx oi.nVy contrast corr
%   p1: pixel wise p-value (uncorrected). oi.nVx oi.nVy contrast corr
%   h1_cc_rs: pixel wise significance for p<mice.alpha. 1=sig 0=ns.
%       oi.nVx oi.nVy contrast corr
%   tmap2: pixel wise t-values per seed, oi.nVx oi.nVy contrast lags
%   h2: pixel wise significance (uncorrected) for p<0.05. 1=sig
%       0=ns. oi.nVx oi.nVy contrast lags
%   p2: pixel wise p-value (uncorrected). oi.nVx oi.nVy contrast lags
%   h2_cc_rs: pixel wise significance for p<mice.alpha. 1=sig 0=ns.
%       oi.nVx oi.nVy contrast lags

    isbrain2_aff(isnan(isbrain2_aff))=0;
    for i=1:length(maxR_ms_group)
        maxR_ms_group{i}=maxR_ms_group{i}.*isbrain2_aff;
        Lag_maxr_ms_group{i}=Lag_maxr_ms_group{i}.*isbrain2_aff;
    end
    % loop through pixels
    for f=1:size(maxR_ms_group{1},1)
        for g=1:size(maxR_ms_group{1},2)
                
            if length(group_index)==0 % if only 1 group, 1-sample t-test
                if nansum(~isnan(maxR_ms_group{1}(f,g,:)) & maxR_ms_group{1}(f,g,:)~=0)<2 
                    h1(f,g)=NaN;
                    p1(f,g)=NaN;
                    tmap1(f,g)=NaN;
                    h2(f,g)=NaN;
                    p2(f,g)=NaN;
                    tmap2(f,g)=NaN;
                else
                    [h1(f,g),p1(f,g),~,stats]=ttest(maxR_ms_group{1}(f,g,:),'alpha',mice(1).alpha);
                    tmap1(f,g)=stats.tstat;
                    clear stats
                    [h2(f,g),p2(f,g),~,stats]=ttest(Lag_maxr_ms_group{1}(f,g,:),'alpha',mice(1).alpha);
                    tmap2(f,g)=stats.tstat;
                    clear stats
                end

            elseif length(group_index)==1 %if 2 groups
                if strcmp(mice(1).test, '2-sample')
                    if nansum(~isnan(maxR_ms_group{1}(f,g,:)) & maxR_ms_group{1}(f,g,:)~=0)<2 || nansum(~isnan(maxR_ms_group{2}(f,g,:)) & maxR_ms_group{2}(f,g,:)~=0)<2
                        h1(f,g)=NaN;
                        p1(f,g)=NaN;
                        tmap1(f,g)=NaN;
                        h2(f,g)=NaN;
                        p2(f,g)=NaN;
                        tmap2(f,g)=NaN;
                    else
                        [h1(f,g),p1(f,g),~,stats]=ttest2(maxR_ms_group{1}(f,g,:),maxR_ms_group{2}(f,g,:),'alpha',mice(1).alpha);
                        tmap1(f,g)=stats.tstat;
                        clear stats
                        [h2(f,g),p2(f,g),~,stats]=ttest2(Lag_maxr_ms_group{1}(f,g,:),Lag_maxr_ms_group{2}(f,g,:),'alpha',mice(1).alpha);
                        tmap2(f,g)=stats.tstat;
                        clear stats
                    end

                elseif strcmp(mice(1).test, 'paired')
                    if nansum(~isnan(maxR_ms_group{1}(f,g,:)) & maxR_ms_group{1}(f,g,:)~=0)<2 || nansum(~isnan(maxR_ms_group{2}(f,g,:)) & maxR_ms_group{2}(f,g,:)~=0)<2
                        h1(f,g)=NaN;
                        p1(f,g)=NaN;
                        tmap1(f,g)=NaN;
                        h2(f,g)=NaN;
                        p2(f,g)=NaN;
                        tmap2(f,g)=NaN;
                    else
                        [h1(f,g),p1(f,g),~,stats]=ttest(maxR_ms_group{1}(f,g,:),maxR_ms_group{2}(f,g,:),'alpha',mice(1).alpha);
                        tmap1(f,g)=stats.tstat;
                        clear stats
                        [h2(f,g),p2(f,g),~,stats]=ttest(Lag_maxr_ms_group{1}(f,g,:),Lag_maxr_ms_group{2}(f,g,:),'alpha',mice(1).alpha);
                        tmap2(f,g)=stats.tstat;
                        clear stats
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
    h1_cc=zeros(size(maxR_ms_group{1},1)*size(maxR_ms_group{1},2),1);

    % find clusters
    CC = bwconncomp(temp);

    for i=1:CC.NumObjects %loop through clusters

        % keep cluster if size>thresh
        if length(CC.PixelIdxList{1,i})>thresh
            h1_cc(CC.PixelIdxList{1,i})=1;
        end

    end
    clear CC

    h1_cc_rs=reshape(h1_cc,size(maxR_ms_group{1},1),size(maxR_ms_group{1},2));
    
    h2(isnan(h2))=0;
    temp=logical(h2.*isbrain2_aff); %h1 with applied mask
    % initialize a mask for clusters with size>thresh
    h2_cc=zeros(size(Lag_maxr_ms_group{1},1)*size(Lag_maxr_ms_group{1},2),1);

    % find clusters
    CC = bwconncomp(temp);

    for i=1:CC.NumObjects %loop through clusters

        % keep cluster if size>thresh
        if length(CC.PixelIdxList{1,i})>thresh
            h2_cc(CC.PixelIdxList{1,i})=1;
        end

    end
    clear CC

    h2_cc_rs=reshape(h2_cc,size(Lag_maxr_ms_group{1},1),size(Lag_maxr_ms_group{1},2));
  
end   