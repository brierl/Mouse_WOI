function [fhandle]=visualize_fc_node_avg(same,same_std,opp,opp_std,isbrain2_aff,WL,WL_factor,mice,q,oi)
% plotting function for avg figures

% IN:
%   same: oi.nVx x oi.nVy x contrast x group, same hemi
%   same_std: std oi.nVx x oi.nVy x contrast x group across mice, same hemi
%   opp: oi.nVx x oi.nVy x contrast x group, opp hemi
%   opp_std: std oi.nVx x oi.nVy x contrast x group across mice, opp hemi
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
    same(isnan(same))=0;
    same_std(isnan(same_std))=0;
    opp(isnan(opp))=0;
    opp_std(isnan(opp_std))=0;
    
    % plot maps 
    for i=1:size(same,4) %loop through groups
        figure(i)  
        fhandle(i)=gcf;
        ha=tight_subplot(2,length(oi.con_num)*2,[0.01 0.03],[0.1 0.01],[0.01 0.01]);  
        for d=1:length(oi.con_num) %loop through contrasts
            
                %plot avg values
                axes(ha(1+(d-1)*4));
                Im2=overlaymouse(same(:,:,d,i),WL, isbrain2_aff,'jet',min(min(same(:,:,d,i))),max(max(same(:,:,d,i))),WL_factor);
                imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
                hold on;
                axis image off

                title(['same contrast ' num2str(oi.con_num(d)) ' avg']);

                %plot std values
                axes(ha(2+(d-1)*4));
                Im2=overlaymouse(same_std(:,:,d,i),WL, isbrain2_aff,'jet',min(min(same_std(:,:,d,i))),max(max(same_std(:,:,d,i))),WL_factor);
                imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
                hold on;
                axis image off

                title(['same contrast ' num2str(oi.con_num(d)) ' std']);
                
                %plot avg values
                axes(ha(3+(d-1)*4));
                Im2=overlaymouse(opp(:,:,d,i),WL, isbrain2_aff,'jet',min(min(opp(:,:,d,i))),max(max(opp(:,:,d,i))),WL_factor);
                imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
                hold on;
                axis image off

                title(['opp contrast ' num2str(oi.con_num(d)) ' avg']);

                %plot std values
                axes(ha(4+(d-1)*4));
                Im2=overlaymouse(opp_std(:,:,d,i),WL, isbrain2_aff,'jet',min(min(opp_std(:,:,d,i))),max(max(opp_std(:,:,d,i))),WL_factor);
                imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
                hold on;
                axis image off

                title(['opp contrast ' num2str(oi.con_num(d)) ' std']);

        end
        clear ha
        annotation('textbox', [0.03 0.9 1 0.1], ...
        'String', ['group ' num2str(i) ' band ' char(mice(1).bandstr(q))], ...
        'EdgeColor', 'none', ...
        'FontSize', 12, ...
        'FontWeight','bold')
    end

end