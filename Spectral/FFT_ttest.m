function [h1,p1]=FFT_ttest(fft_ms_group,group_index,oi,mice)
% perform a ttest at each frequency of fft, on 1 or 2 groups only

% IN:
%   fft_ms_group: Each cell index is a group. data fft per contrast per
%       mouse
%   group_index: rows corresponding to excel file group separation
%   oi: optical instrument properties

% OUT:
%   h1: significance h1=1 for p<0.05 else h1=0. frequency x contrast
%   p1: p-value frequency x contrast

% loop through number of frames per epoch
for g=1:size(fft_ms_group{1},1)
                
    if length(group_index)==0 % 1-sample t-test
        for w=1:length(oi.con_num)
            [h1(g,w),p1(g,w)]=ttest(fft_ms_group{1}(g,w,:));
        end
       
    elseif length(group_index)==1
        if strcmp(mice.test, '2-sample')
            for w=1:length(oi.con_num)
                [h1(g,w),p1(g,w)]=ttest2(fft_ms_group{1}(g,w,:),fft_ms_group{2}(g,w,:));
            end
            
        elseif strcmp(mice.test, 'paired')
            for w=1:length(oi.con_num)
                [h1(g,w),p1(g,w)]=ttest(fft_ms_group{1}(g,w,:),fft_ms_group{2}(g,w,:));
            end
            
        else
            disp('column X should be 2-sample or paired')
        end
    else
            disp('need to submit only 1 or 2 groups of mice')
    end
                
end