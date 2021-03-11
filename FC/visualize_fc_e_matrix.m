function [fhandle]=visualize_fc_e_matrix(ematrix,mice,q,oi)
% plotting function for avg FC matrices

% IN: 
%   ematrix: avg seeds x seeds x contrast x group across mice
%   mice: struct containing mouse processing and filename info
%   q: index to grab correct bandpass
%   oi: optical instrument properties

% OUT:
%   fhandle: figure handle for saving

    % plot data
    for i=1:size(ematrix,4) %loop through groups
        figure(i)  
        fhandle(i)=gcf;
        ha=tight_subplot(length(oi.con_num),1,[0.1 0.03],[0.1 0.1],[0.1 0.1]);  
        
        for d=1:length(oi.con_num) %loop through contrasts

            %plot avg values
            axes(ha(d));
            imagesc(ematrix(:,:,d,i),[-1 1]); colormap jet;
            hold on;
            title(['contrast ' num2str(oi.con_num(d))])

        end
    
    annotation('textbox', [0.03 0.9 1 0.1], ...
    'String', ['group ' num2str(i) ' band ' char(mice(1).bandstr(q))], ...
    'EdgeColor', 'none', ...
    'FontSize', 12, ...
    'FontWeight','bold')
    end

end