function [fhandle]=visualize_nvc_ttest(tmap1,p1,h1,h1_cc_rs,tmap2,p2,h2,h2_cc_rs,isbrain2_aff,WL_aff,WL_factor,mice,q,oi)
% plot function for ttest NVC map outputs

% IN:
%   tmap1: t-values oi.nVx, oi.nVy, contrasts corr
%   h1: pixel wise significance (uncorrected) for p<0.05. 1=sig
%       0=ns. oi.nVx, oi.nVy, contrasts corr
%   p1: pixel wise p-value (uncorrected). oi.nVx, oi.nVy, contrasts corr
%   h1_cc_rs: pixel wise significance for p<mice.alpha. 1=sig 0=ns. 
%       oi.nVx, oi.nVy, contrasts corr 
%   tmap2: t-values oi.nVx, oi.nVy, contrasts lags
%   h2: pixel wise significance (uncorrected) for p<0.05. 1=sig
%       0=ns. oi.nVx, oi.nVy, contrasts lags
%   p2: pixel wise p-value (uncorrected). oi.nVx, oi.nVy, contrasts lags
%   h2_cc_rs: pixel wise significance for p<mice.alpha. 1=sig 0=ns. 
%       oi.nVx, oi.nVy, contrasts lags
%   isbrain2_aff: group mask, oi.nVy x oi.nVy
%   WL_aff: group white light image
%   WL_factor: factor for plotting WL without weird black bar at the top...
%   mice: struct containing mouse filename and processing info
%   q: index to grab correct bandpass
%   oi: optical instrument properties

% OUT:
%   fhandle: handle for figures, for saving.

    % plot t-maps
    figure(1)
    fhandle(1,1)=gcf;
    ha=tight_subplot(1,1,[0.01 0.03],[0.1 0.01],[0.01 0.01]);    

    axes(ha(1));
    Im2=overlaymouse(tmap1,WL_aff, isbrain2_aff,'jet',-6,6,WL_factor);
    imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
    hold on;
    axis image off

    annotation('textbox', [0.03 0.9 1 0.1], ...
    'String', ['band ' char(mice(1).bandstr(q))], ...
    'EdgeColor', 'none', ...
    'FontSize', 12, ...
    'FontWeight','bold')

    % plot t-maps
    figure(4)
    fhandle(1,4)=gcf;
    ha=tight_subplot(1,1,[0.01 0.03],[0.1 0.01],[0.01 0.01]);    

    axes(ha(1));
    Im2=overlaymouse(tmap2,WL_aff, isbrain2_aff,'jet',-6,6,WL_factor);
    imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
    hold on;
    axis image off

    annotation('textbox', [0.03 0.9 1 0.1], ...
    'String', ['band ' char(mice(1).bandstr(q))], ...
    'EdgeColor', 'none', ...
    'FontSize', 12, ...
    'FontWeight','bold')
    
    % plot p-maps (uncorrected)
    figure(2)
    fhandle(1,2)=gcf;
    ha=tight_subplot(1,1,[0.01 0.03],[0.1 0.01],[0.01 0.01]); 

    axes(ha(1));
    Im2=overlaymouse(p1,WL_aff, isbrain2_aff.*h1,'jet',0,0.05,WL_factor);
    imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
    hold on;
    axis image off

    annotation('textbox', [0.03 0.9 1 0.1], ...
    'String', ['band ' char(mice(1).bandstr(q))], ...
    'EdgeColor', 'none', ...
    'FontSize', 12, ...
    'FontWeight','bold')

    % plot p-maps (uncorrected)
    figure(5)
    fhandle(1,5)=gcf;
    ha=tight_subplot(1,1,[0.01 0.03],[0.1 0.01],[0.01 0.01]); 

    axes(ha(1));
    Im2=overlaymouse(p2,WL_aff, isbrain2_aff.*h2,'jet',0,0.05,WL_factor);
    imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
    hold on;
    axis image off

    annotation('textbox', [0.03 0.9 1 0.1], ...
    'String', ['band ' char(mice(1).bandstr(q))], ...
    'EdgeColor', 'none', ...
    'FontSize', 12, ...
    'FontWeight','bold')

    % plot p-maps. Only clusters surviving cluster size threshold will
    % visualize
    figure(3)
    fhandle(1,3)=gcf;
    ha=tight_subplot(1,1,[0.01 0.03],[0.1 0.01],[0.01 0.01]);    

    axes(ha(1));
    Im2=overlaymouse(p1,WL_aff, isbrain2_aff.*h1_cc_rs,'jet',0,0.05,WL_factor);
    imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
    hold on;
    axis image off

    annotation('textbox', [0.03 0.9 1 0.1], ...
    'String', ['band ' char(mice(1).bandstr(q))], ...
    'EdgeColor', 'none', ...
    'FontSize', 12, ...
    'FontWeight','bold')

    % plot p-maps. Only clusters surviving cluster size threshold will
    % visualize
    figure(6)
    fhandle(1,6)=gcf;
    ha=tight_subplot(1,1,[0.01 0.03],[0.1 0.01],[0.01 0.01]);    

    axes(ha(1));
    Im2=overlaymouse(p2,WL_aff, isbrain2_aff.*h2_cc_rs,'jet',0,0.05,WL_factor);
    imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:));
    hold on;
    axis image off

    annotation('textbox', [0.03 0.9 1 0.1], ...
    'String', ['band ' char(mice(1).bandstr(q))], ...
    'EdgeColor', 'none', ...
    'FontSize', 12, ...
    'FontWeight','bold')

end