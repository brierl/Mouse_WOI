function [fhandle]=visualize_svr_ttest(tmap,p1,h1,h1_cc_rs,isbrain2_aff,WL_aff,WL_factor,mice,q,oi)
% plot function for ttest FC map outputs

% IN:
%   tmap: t-values oi.nVx, oi.nVy, seeds, contrasts
%   h1: pixel wise significance (uncorrected) for p<0.05. 1=sig
%       0=ns. oi.nVx, oi.nVy, seeds, contrasts
%   p1: pixel wise p-value (uncorrected). oi.nVx, oi.nVy, seeds, contrasts
%   h1_cc_rs: pixel wise significance for p<mice.alpha. 1=sig 0=ns. 
%       oi.nVx, oi.nVy, seeds, contrasts
%   isbrain2_aff: group mask, oi.nVy x oi.nVy
%   WL_aff: group white light image
%   mice: struct containing mouse filename and processing info
%   q: index to grab correct bandpass
%   oi: optical instrument properties

% OUT:
%   fhandle: handle for figures, for saving.
    
    % need to get rid of NaN in seed regions
    tmap(isnan(tmap))=0;
    p1(isnan(p1))=0;
    % plot t-maps
    figure(1)
    fhandle(1,1)=gcf;
    ha=tight_subplot(length(oi.con_num),floor(size(h1,3)/2),[0.01 0.03],[0.1 0.01],[0.01 0.01]);    
    for d=1:length(oi.con_num) %loop through contrasts
        for s=1:floor(size(h1,3)/2) %loop through half of seeds

            axes(ha(s+floor(size(h1,3)/2)*(d-1)));
            Im2=overlaymouse(tmap(:,:,s,d),WL_aff, isbrain2_aff,'jet',-6,6,WL_factor);
            imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
            hold on;
            axis image off

            if s==1
                title(['contrast ' num2str(oi.con_num(d)) ' tmaps']);
            end

        end
    end
    annotation('textbox', [0.03 0.9 1 0.1], ...
    'String', ['band ' char(mice(1).bandstr(q))], ...
    'EdgeColor', 'none', ...
    'FontSize', 12, ...
    'FontWeight','bold')
    
    % plot p-maps (uncorrected)
    figure(2)
    fhandle(1,2)=gcf;
    ha=tight_subplot(length(oi.con_num),floor(size(h1,3)/2),[0.01 0.03],[0.1 0.01],[0.01 0.01]); 
    for d=1:length(oi.con_num) %loop through contrasts
        for s=1:floor(size(h1,3)/2) %loop through half of seeds

            axes(ha(s+floor(size(h1,3)/2)*(d-1)));
            Im2=overlaymouse(p1(:,:,s,d),WL_aff, isbrain2_aff.*h1(:,:,s,d),'jet',0,0.05,WL_factor);
            imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
            hold on;
            axis image off

            if s==1
                title(['contrast ' num2str(oi.con_num(d)) ' pmaps']);
            end

        end
    end
    annotation('textbox', [0.03 0.9 1 0.1], ...
    'String', ['band ' char(mice(1).bandstr(q))], ...
    'EdgeColor', 'none', ...
    'FontSize', 12, ...
    'FontWeight','bold')

    % plot p-maps. Only clusters surviving cluster size threshold will
    % visualize
    figure(3)
    fhandle(1,3)=gcf;
    ha=tight_subplot(length(oi.con_num),floor(size(h1,3)/2),[0.01 0.03],[0.1 0.01],[0.01 0.01]);    
    for d=1:length(oi.con_num) %loop through contrasts
        for s=1:floor(size(h1,3)/2) %loop through half of seeds

            axes(ha(s+floor(size(h1,3)/2)*(d-1)));
            Im2=overlaymouse(p1(:,:,s,d),WL_aff, isbrain2_aff.*h1_cc_rs(:,:,s,d),'jet',0,0.05,WL_factor);
            imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
            hold on;
            axis image off

            if s==1
                title(['contrast ' num2str(oi.con_num(d)) ' p cc']);
            end

        end
    end
    annotation('textbox', [0.03 0.9 1 0.1], ...
    'String', ['band ' char(mice(1).bandstr(q))], ...
    'EdgeColor', 'none', ...
    'FontSize', 12, ...
    'FontWeight','bold')

end