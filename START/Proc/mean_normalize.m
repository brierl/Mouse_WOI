function [data2]=mean_normalize(data)
% mean normalize data (by time)

% IN:
%   data: pixels x pixels x time

% OUT:
%   data2: mean normalized pixels x pixels x time

data2=data./nanmean(data,3);
    
end