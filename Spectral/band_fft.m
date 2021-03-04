function [avgfft_band]=band_fft(avgfft_acrossEpochs,mice,q)

% plot image fft of data

% IN:
%   avgfft_acrossEpochs: power pixel x pixel x freq x contrast
%   isbrain2: pixel x pixel binary mask signifying brain regions
%   mice: struct containing processing and filename information
%   q: index for which bandpass currently grabbing

% OUT:
%   avgfft: avg power pixel x pixel x contrast over specified band

    % grab highpass and lowpass
    hp=mice.bandnum(q,1)*mice.info.fft_block+1;
    if isnan(mice.bandnum(q,2))
        lp=size(avgfft_acrossEpochs,3);
    else
        lp=mice.bandnum(q,2)*mice.info.fft_block+1;
    end
    % average over highpass:lowpass
    avgfft_band=squeeze(nanmean(avgfft_acrossEpochs(:,:,hp:lp,:),3));
                