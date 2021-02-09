function [fhandle]=visualize_fc_matrix(Rs_Data,oi)
% plotting function for FC matrices

% IN: 
%   Rs_Data: seeds x seeds x contrast FC matrix

% OUT:
%   fhandle: figure handle for saving

    % plot data
    figure(1)  
    fhandle=gcf;        
    ha=tight_subplot(1,length(oi.con_num),[0.1 0.03],[0.1 0.1],[0.1 0.1]);  

    for i=1:length(oi.con_num) %loop through contrasts

        axes(ha(i));
        imagesc(Rs_Data(:,:,i),[-1 1]); colormap jet;
        hold on;
        axis square;
        title(['contrast ' num2str(oi.con_num(i))])
    
    end

end