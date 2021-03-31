function [fhandle]=visualize_nodes(same_nodes,opp_nodes,isbrain2,oi)
% plot bilat FC

% IN
%   same_nodes: Node FC maps oi.nVx x oi.nVy x contrast, same hemi
%   opp_nodes: Node FC maps oi.nVx x oi.nVy x contrast, opp hemi
%   isbrain2: oi.nVx x oi.nVy binary mask signifying brain regions
%   oi: optical instrument properties

% OUT:
%   fhandle: figure handle
    
    ha=tight_subplot(2,length(oi.con_num),[0.01 0.03],[0.1 0.01],[0.01 0.01]);
    fhandle=gcf;
    for d=1:length(oi.con_num) %loop through contrasts

        axes(ha(2*d-1))
        imagesc(same_nodes(:,:,d).*isbrain2); colormap jet;
        hold on; colorbar; axis square;
        axis image off
        
        title(['Same nodes contrast ' num2str(oi.con_num(d))]);
        
        axes(ha(2*d))
        imagesc(opp_nodes(:,:,d).*isbrain2); colormap jet;
        hold on; colorbar; axis square;
        axis image off

        title(['Opp nodes contrast ' num2str(oi.con_num(d))]);

    end
end