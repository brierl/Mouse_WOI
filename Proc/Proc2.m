function [all_contrasts]=Proc2(all_contrasts,isbrain)
% perform spatial smoothing and GSR

% IN:
%   all_contrasts: oi.nVx x oi.nVy x contrast x frames data
%   isbrain: binary mask oi.nVx x oi.nVy

% OUT:
%   all_contrasts: oi.nVx x oi.nVy x contrast x frames data, smoothed, w/GSR

    % Spatial smoothing
    all_contrasts=smoothimage(all_contrasts,5,1.2);

    % Global signal regression (regress the mean time series across the brain from all time
    %series)
    all_contrasts=gsr(all_contrasts, isbrain);                                             

end