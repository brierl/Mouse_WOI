function [fhandle]=visualize_fc_avg(R,Rstd,isbrain2_aff,seedcenter,WL,WL_factor,mice,q,oi)
% plotting function for avg figures

% IN:
%   R: oi.nVx x oi.nVy x seed x contrast x group num avg FC maps
%   Rstd: oi.nVx x oi.nVy x seed x contrast x group num std FC maps
%   isbrain2_aff: oi.nVx x oi.nVy binary mask signifying brain regions, group
%       avg
%   seedcenter: seed numbers x 2 x,y coordinates file for seed centers
%   WL: group white light image for plotting on
%   WL_factor: factor for plotting WL without weird black bar at the top...
%   mice: struct with mouse filename and processing info
%   q: index for which bandpass settings to use
%   oi: optical instrument properties

% OUT:
%   handle: figure handle (1xnum groups)
    
    % plot maps 
    for i=1:size(R,5) %loop through groups
        figure(i)  
        fhandle(i)=gcf;
        ha=tight_subplot(length(oi.con_num)*2,floor(size(R,3)/2),[0.01 0.03],[0.1 0.01],[0.01 0.01]);  
        for d=1:length(oi.con_num) %loop through contrasts
            for s=1:floor(size(R,3)/2) %loop through half of seeds

                %plot avg values
                axes(ha(s+floor(size(R,3)/2)*(d-1)*2));
                Im2=overlaymouse(R(:,:,s,d,i),WL, isbrain2_aff,'jet',-1,1,WL_factor);
                imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
                hold on;
                plot(seedcenter(s,1)-oi.plot_factor,seedcenter(s,2)-oi.plot_factor,'k.','MarkerSize',7);
                axis image off

                if s==1
                    title(['contrast ' num2str(oi.con_num(d))]);
                end

                %plot std values
                axes(ha(s+floor(size(R,3)/2)*(2*d-1)));
                Im2=overlaymouse(Rstd(:,:,s,d,i),WL, isbrain2_aff,'jet',-1,1,WL_factor);
                imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
                hold on;
                plot(seedcenter(s,1)-oi.plot_factor,seedcenter(s,2)-oi.plot_factor,'k.','MarkerSize',7);
                axis image off

                if s==1
                    title(['contrast ' num2str(oi.con_num(d)) ' std']);
                end

            end
        end
        clear ha
        annotation('textbox', [0.03 0.9 1 0.1], ...
        'String', ['group ' num2str(i) ' band ' char(mice(1).bandstr(q))], ...
        'EdgeColor', 'none', ...
        'FontSize', 12, ...
        'FontWeight','bold')
    end

end