function [fhandle]=visualize_fc_ttest_matrix(tmap,p1,q,mice,oi)
% plotting function for FC matrices, stats results

% IN:
%   tmap: t-values, seeds x seeds x contrasts
%   p1: p-values (uncorrected), seeds x seeds x contrasts
%   q: index to grab correct bandpass
%   mice: struct containing filename and processing info for each mouse
%   oi: optical instrument properties

% OUT: 
%   fhandle: figure handle for saving

    % bonferroni correction factor
    bfc=size(tmap,1)*size(tmap,1)/2-size(tmap,1)/2;
    % plot data
    figure(1)
    fhandle=gcf;
    ha=tight_subplot(length(oi.con_num),3,[0.1 0.03],[0.1 0.1],[0.1 0.1]);          
           
    for w=1:length(oi.con_num) %loop through contrasts
        %plot tmap
        axes(ha(1+3*(w-1)));
        imagesc(tmap(:,:,w),[-6 6]); colormap jet;
        hold on; colorbar;
        title(['contrast ' num2str(oi.con_num(w)) ' tmap'])

        %plot pmaps
        axes(ha(2+3*(w-1)));
        imagesc(p1(:,:,w),[0 0.05]); colormap jet;
        hold on; colorbar;
        title(['contrast ' num2str(oi.con_num(w)) ' pmap'])

        %plot pmaps with bonferroni correction
        axes(ha(3+3*(w-1)));
        imagesc(p1(:,:,w),[0 0.05/bfc]); colormap jet;
        hold on; colorbar;
        title(['contrast ' num2str(oi.con_num(w)) ' pmap bc'])
    end
    
    annotation('textbox', [0.03 0.9 1 0.1], ...
    'String', ['band ' char(mice(1).bandstr(q))], ...
    'EdgeColor', 'none', ...
    'FontSize', 12, ...
    'FontWeight','bold')

end