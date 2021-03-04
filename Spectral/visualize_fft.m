function [fhandle]=visualize_fft(avgfft_acrossEpochs,f,avgfft_acrossEpochsPixels,oi)
%plot broadband fft, spatially averaged

% IN:
%   avgfft_acrossEpochs: power pixel x pixel x freq x contrast
%   f: frequency in hz, x axis for plotting later
%   avgfft_acrossEpochsPixels: power freq x contrast
%   oi: optical instrument properties

% OUT:
%   fhandle: figure handle

    avgfft_acrossEpochs=reshape(avgfft_acrossEpochs,oi.nVx*oi.nVy,[],length(oi.con_num));
    figure(1);
    fhandle=gcf;
    ha=tight_subplot(1,length(oi.con_num),[0.1 0.03],[0.1 0.1],[0.1 0.1]);       
    % plot data
    for d=1:length(oi.con_num)
        
        axes(ha(d));
        semilogy(f(1:length(f)-1),squeeze(avgfft_acrossEpochs(:,1:length(f)-1,d))); hold on; %each individual pixel's power
        semilogy(f(1:length(f)-1),avgfft_acrossEpochsPixels(1:1:length(f)-1,d),'c','LineWidth',5); hold on; %average of all brain pixels power
        title(['Contrast ' num2str(oi.con_num(d)) ' power per pixel'])
        xlabel('Hz');
        ylabel('Power')
    
    end