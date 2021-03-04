function [fhandle]=visualize_bilat(BiCorIm,isbrain2,oi)
% plot bilat FC

% IN
%   BiCorIm: Bilat FC maps oi.nVx x oi.nVy x contrast
%   isbrain2: oi.nVx x oi.nVy binary mask signifying brain regions
%   oi: optical instrument properties

% OUT:
%   fhandle: figure handle
    
    ha=tight_subplot(1,length(oi.con_num),[0.01 0.03],[0.1 0.01],[0.01 0.01]);
    fhandle=gcf;
    for d=1:length(oi.con_num) %loop through contrasts

        axes(ha(d))
        imagesc(BiCorIm(:,:,d).*isbrain2,[-1 1]); colormap jet;
        hold on;
        axis image off

        title(['contrast ' num2str(oi.con_num(d))]);

    end
end