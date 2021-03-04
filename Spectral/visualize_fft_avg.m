function [fhandle]=visualize_fft_avg(fft_avg,fft_std,oi,f)
% plots spatially avg'd average fft across mice

% IN:
%   fft_avg: data fft per contrast per group
%   fft_std: data fft per contrast per group standard deviation
%       across mice
%   oi: optical instrument properties
%   f: x-axis frequency in hz

% OUT:
%   fhandle: figure handle

figure(1)
ha=tight_subplot(1,length(oi.con_num),[0.1 0.03],[0.1 0.1],[0.1 0.1]);  
fhandle=gcf;
% plot data, errorbars are standard deviations
for d=1:length(oi.con_num)
    axes(ha(d));
    for q=1:size(fft_avg,3)
        errorbar(f(1:length(f)-1),fft_avg(1:1:length(f)-1,d,q),fft_std(1:1:length(f)-1,d,q)); hold on; %average of all brain pixels power
    end
    title(['Avg power per pixel, contrast ' num2str(oi.con_num(d))])
    xlabel('Hz');
    ylabel('Power');
    ylim([1E-10 1E2]);
    set(gca,'YScale','log');
end
