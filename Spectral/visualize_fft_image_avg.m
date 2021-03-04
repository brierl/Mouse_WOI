function [fhandle]=visualize_fft_image_avg(fft_avg_image,fft_std_image,isbrain2_aff,WL,WL_factor,mice,q,oi)
% plotting function for avg figures

% IN:
%   fft_avg_image: oi.nVx x oi.nVy x contrast x group num avg FFT maps
%   fft_std_image: oi.nVx x oi.nVy x contrast x group num std FFT maps
%   isbrain2_aff: oi.nVx x oi.nVy binary mask signifying brain regions, group
%       avg
%   WL: group white light image for plotting on
%   WL_factor: factor for plotting WL without weird black bar at the top...
%   mice: struct with mouse filename and processing info
%   q: index for which bandpass settings to use
%   oi: optical instrument properties

% OUT:
%   handle: figure handle (1xnum groups)
    
    if strcmp(char(mice(1).bandstr(q)),'pt4-4pt0')
        scale1=-5; scale2=-3;
    elseif strcmp(char(mice(1).bandstr(q)),'pt08-pt4')
        scale1=-4; scale2=-2;
    elseif strcmp(char(mice(1).bandstr(q)),'pt009-pt08')
        scale1=-4; scale2=-2;
    else
        scale1=-4; scale2=-2;
    end
    
    % plot maps 
    for i=1:size(fft_avg_image,4) %loop through groups
        figure(i)  
        fhandle(i)=gcf;
        ha=tight_subplot(1,length(oi.con_num)*2,[0.01 0.03],[0.1 0.01],[0.01 0.01]);  
        for d=1:length(oi.con_num) %loop through contrasts
            
                %plot avg values
                axes(ha(1+(d-1)*2));
                Im2=overlaymouse(log10(fft_avg_image(:,:,d,i)),WL, isbrain2_aff,'jet',scale1,scale2,WL_factor);
                imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
                hold on;
                axis image off

                title(['contrast ' num2str(oi.con_num(d)) ' avg']);

                %plot std values
                axes(ha(2+(d-1)*2));
                Im2=overlaymouse(log10(fft_std_image(:,:,d,i)),WL, isbrain2_aff,'jet',scale1,scale2,WL_factor);
                imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
                hold on;
                axis image off

                title(['contrast ' num2str(oi.con_num(d)) ' std']);

        end
        clear ha
        annotation('textbox', [0.03 0.9 1 0.1], ...
        'String', ['group ' num2str(i) ' band ' char(mice(1).bandstr(q))], ...
        'EdgeColor', 'none', ...
        'FontSize', 12, ...
        'FontWeight','bold')
    end

end