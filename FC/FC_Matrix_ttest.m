function [tmap,p1,h1]=FC_Matrix_ttest(Rs_ms_group,group_index,mice,oi)
% script to perform ttest on FC matrices and apply Bonferroni correction.
% only tests 1 or 2 groups at a time.

% IN:
%   Rs_ms_group: each cell index is a group. seeds x seeds x
%       contrast x mice
%   group_index: indices from excel file signifying separate groups
%   mice: struct containing mouse processing and filename info
%   oi: optical instrument properties

% OUT:
%   tmap: t-values. seeds x seeds x contrasts
%   h1: significance (uncorrected) for p<0.05. 1=sig 0=ns. seeds x seeds x
%       contrasts
%   p1: p-values (uncorrected) per seed. seeds x seeds x contrasts
    
    % make diagonals 1 or stats will error
    for i=1:length(Rs_ms_group)
        for f=1:size(Rs_ms_group{i},1)
            for g=1:size(Rs_ms_group{i},2)
                if f==g
                    Rs_ms_group{i}(f,g,:,:)=1;
                end
            end
        end
    end
    
    % loop through seeds
    for f=1:size(Rs_ms_group{1},1)
        for g=1:size(Rs_ms_group{1},2)
                
            if length(group_index)==0 % if only 1 group, 1-sample t-test
                
                for w=1:length(oi.con_num) %loop through contrasts
                    if nansum(~isnan(Rs_ms_group{1}(f,g,w,:)))<2
                        h1(f,g,w)=NaN;
                        p1(f,g,w)=NaN;
                        tmap(f,g,w)=NaN;
                    else
                        [h1(f,g,w),p1(f,g,w),~,stats]=ttest(Rs_ms_group{1}(f,g,w,:));
                        tmap(f,g,w)=stats.tstat;
                        clear stats
                    end
                end
                
            elseif length(group_index)==1 %if 2 groups
                
                if strcmp(mice(1).test, '2-sample')
                    for w=1:length(oi.con_num) %loop through contrasts
                        if nansum(~isnan(Rs_ms_group{1}(f,g,w,:)))<2 || nansum(~isnan(Rs_ms_group{2}(f,g,w,:)))<2
                            h1(f,g,w)=NaN;
                            p1(f,g,w)=NaN;
                            tmap(f,g,w)=NaN;
                        else
                            [h1(f,g,w),p1(f,g,w),~,stats]=ttest2(Rs_ms_group{1}(f,g,w,:),Rs_ms_group{2}(f,g,w,:));
                            tmap(f,g,w)=stats.tstat;
                            clear stats
                        end
                    end
                        
                elseif strcmp(mice(1).test, 'paired')
                    for w=1:length(oi.con_num) %loop through contrasts
                        if nansum(~isnan(Rs_ms_group{1}(f,g,w,:)))<2 || nansum(~isnan(Rs_ms_group{2}(f,g,w,:)))<2
                            h1(f,g,w)=NaN;
                            p1(f,g,w)=NaN;
                            tmap(f,g,w)=NaN;
                        else
                            [h1(f,g,w),p1(f,g,w),~,stats]=ttest(Rs_ms_group{1}(f,g,w,:),Rs_ms_group{2}(f,g,w,:));
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
    
    % black out diagonal
    for f=1:size(Rs_ms_group{1},1)
        for g=1:size(Rs_ms_group{1},2)
            if f==g
                tmap(f,g,:)=NaN;
                p1(f,g,:)=NaN;
                h1(f,g,:)=NaN;
            end
        end
    end
    
end                          