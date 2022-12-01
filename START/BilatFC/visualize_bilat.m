function [fhandle]=visualize_bilat(BiCorIm,isbrain2)
% plot bilat FC

% IN
%   BiCorIm: Bilat FC maps pixels x pixels x contrast
%   isbrain2: pixels x pixels binary mask signifying brain regions

% OUT:
%   fhandle: figure handle
    
    ha=tight_subplot(1,size(BiCorIm,3),[0.01 0.03],[0.1 0.01],[0.01 0.01]);
    fhandle=gcf;
    for d=1:size(BiCorIm,3) %loop through contrasts

        axes(ha(d))
        imagesc(BiCorIm(:,:,d).*isbrain2,[-1 1]); colormap jet;
        hold on;
        axis image off

        title(['contrast ' num2str(d)]);

    end
end