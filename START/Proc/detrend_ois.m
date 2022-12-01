function [fulldetrend]=detrend_ois(rawdata_f)
% detrend spatially and temporally

% IN: 
%   rawdata_f: image stack pixels x pixels x ls x frames

% OUT:
%   fulldetrend: detrended image stack pixels x pixels x ls x frames

    [nVx,nVy,C,T]=size(rawdata_f); % nVx and nVy are pixels x pixels, C is light source channels, T is time

    % New De-trending test: linear temporal de-trend by pixel, followed by spatial detrend
    rawdata_rs = reshape(rawdata_f,nVy*nVx*C,T); % Reshape to apply matlab detrend function
    
    warning('Off');

    timetrend = single(zeros(size(rawdata_rs))); % initializing
    for ii=1:size(rawdata_rs,1)
        timetrend(ii,:)=polyval(polyfit(1:T, rawdata_rs(ii,:), 4), 1:T); % This is doing a 4th order fit (polyfit), then evaluating at each time (polyval)
    end
    
    warning('On');
    timetrend = reshape(timetrend,nVy,nVx,C,T); % Pixel-wise fits
    timedetrend=bsxfun(@rdivide,rawdata_f,timetrend); % apply

    spattrend=bsxfun(@rdivide,nanmean(timedetrend,4),nanmean(nanmean(nanmean(timedetrend,4)))); % spatial detrend
    fulldetrend=bsxfun(@rdivide,timedetrend,spattrend); % apply
    
end