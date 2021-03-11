function [tmap,p1,h1]=FC_e_Matrix_ttest(ematrix_ms_group,group_index,mice,oi)
% script to perform ttest on enriched FC matrices.
% only tests 1 or 2 groups at a time.

% IN:
%   ematrix_ms_group: each cell index is a group. seeds x seeds x
%       contrast x mice. enriched version.
%   group_index: indices from excel file signifying separate groups
%   mice: struct containing mouse processing and filename info
%   oi: optical instrument properties

% OUT:
%   tmap: t-values. seeds x seeds x contrasts
%   h1: significance (uncorrected) for p<0.05. 1=sig 0=ns. seeds x seeds x
%       contrasts
%   p1: p-values (uncorrected) per seed. seeds x seeds x contrasts
    
    % loop through seeds
    for f=1:size(ematrix_ms_group{1},1)
        for g=1:size(ematrix_ms_group{1},2)
                
            if length(group_index)==0 % if only 1 group, 1-sample t-test
                
                for w=1:length(oi.con_num) %loop through contrasts
                    if nansum(~isnan(ematrix_ms_group{1}(f,g,w,:)))<2
                        h1(f,g,w)=NaN;
                        p1(f,g,w)=NaN;
                        tmap(f,g,w)=NaN;
                    else
                        [h1(f,g,w),p1(f,g,w),~,stats]=ttest(ematrix_ms_group{1}(f,g,w,:));
                        tmap(f,g,w)=stats.tstat;
                        clear stats
                    end
                end
                
            elseif length(group_index)==1 %if 2 groups
                
                if strcmp(mice(1).test, '2-sample')
                    for w=1:length(oi.con_num) %loop through contrasts
                        if nansum(~isnan(ematrix_ms_group{1}(f,g,w,:)))<2 || nansum(~isnan(ematrix_ms_group{2}(f,g,w,:)))<2
                            h1(f,g,w)=NaN;
                            p1(f,g,w)=NaN;
                            tmap(f,g,w)=NaN;
                        else
                            [h1(f,g,w),p1(f,g,w),~,stats]=ttest2(ematrix_ms_group{1}(f,g,w,:),ematrix_ms_group{2}(f,g,w,:));
                            tmap(f,g,w)=stats.tstat;
                            clear stats
                        end
                    end
                        
                elseif strcmp(mice(1).test, 'paired')
                    for w=1:length(oi.con_num) %loop through contrasts
                        if nansum(~isnan(ematrix_ms_group{1}(f,g,w,:)))<2 || nansum(~isnan(ematrix_ms_group{2}(f,g,w,:)))<2
                            h1(f,g,w)=NaN;
                            p1(f,g,w)=NaN;
                            tmap(f,g,w)=NaN;
                        else
                            [h1(f,g,w),p1(f,g,w),~,stats]=ttest(ematrix_ms_group{1}(f,g,w,:),ematrix_ms_group{2}(f,g,w,:));
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
    
end                          