function [Rs, Rall]=makeRs(data,strace)

% Calculates functional connectivity maps (Rall) and matrix (Rs) using seed time traces
% (strace) and image stack data (data, images reshaped to pixels*pixels x time)

Rs=normr(strace)*normr(strace)';
Rall=normr(data)*normr(strace)';

end