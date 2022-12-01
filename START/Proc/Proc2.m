function [all_contrasts_fp]=Proc2(all_contrasts,isbrain)
% perform spatial smoothing and GSR, optical system independent steps

% IN:
%   all_contrasts: pixels x pixels x contrast x frames data
%   isbrain: binary mask pixels x pixels

% OUT:
%   all_contrasts_fp: pixels x pixels x contrast x frames data, smoothed, w/GSR

    % Spatial smoothing
    all_contrasts_sm=smoothimage(all_contrasts,5,1.2);

    % Global signal regression (regress the mean time series across the brain from all time
    %series)
    all_contrasts_fp=gsr(all_contrasts_sm, isbrain);                                             

end