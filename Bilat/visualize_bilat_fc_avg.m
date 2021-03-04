function [fhandle]=visualize_bilat_fc_avg(R,Rstd,isbrain2_aff,WL,WL_factor,mice,q,oi)
% plotting function for avg figures

% IN:
%   R: oi.nVx x oi.nVy x contrast x group num avg bilat FC maps
%   Rstd: oi.nVx x oi.nVy x contrast x group num std bilat FC maps
%   isbrain2_aff: oi.nVx x oi.nVy binary mask signifying brain regions, group
%       avg
%   WL: group white light image for plotting on
%   WL_factor: factor for plotting WL without weird black bar at the top...
%   mice: struct with mouse filename and processing info
%   q: index for which bandpass settings to use
%   oi: optical instrument properties

% OUT:
%   handle: figure handle (1xnum groups)
        
    % get rid of NaNs... otherwise overlaymouse will error
    R(isnan(R))=0;
    Rstd(isnan(Rstd))=0;
    
    % plot maps 
    for i=1:size(R,4) %loop through groups
        figure(i)  
        fhandle(i)=gcf;
        ha=tight_subplot(1,length(oi.con_num)*2,[0.01 0.03],[0.1 0.01],[0.01 0.01]);  
        for d=1:length(oi.con_num) %loop through contrasts
            
                %plot avg values
                axes(ha(1+(d-1)*2));
                Im2=overlaymouse(R(:,:,d,i),WL, isbrain2_aff,'jet',-1,1,WL_factor);
                imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
                hold on;
                axis image off

                title(['contrast ' num2str(oi.con_num(d)) ' avg']);

                %plot std values
                axes(ha(2+(d-1)*2));
                Im2=overlaymouse(Rstd(:,:,d,i),WL, isbrain2_aff,'jet',-1,1,WL_factor);
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