function [fhandle]=visualize_fft_image(avgfft_band,isbrain2,oi)
% plot FFT image

% IN
%   avgfft_band: FFT maps oi.nVx x oi.nVy x contrast
%   isbrain2: oi.nVx x oi.nVy binary mask signifying brain regions
%   oi: optical instrument properties

% OUT:
%   fhandle: figure handle
    
    ha=tight_subplot(1,length(oi.con_num),[0.01 0.03],[0.1 0.01],[0.01 0.01]);
    fhandle=gcf;
    for d=1:length(oi.con_num) %loop through contrasts

        axes(ha(d))
        imagesc(log10(avgfft_band(:,:,d).*isbrain2)); colormap jet; colorbar;
        hold on;
        axis image off

        title(['contrast ' num2str(oi.con_num(d))]);

    end
end