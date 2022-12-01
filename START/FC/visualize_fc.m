function [fhandle]=visualize_fc(R_Data,isbrain2,seedcenter)
% plot FC

% IN
%   R_Data: FC maps pixels x pixels x seed x contrast
%   isbrain2: pixels x pixels binary mask signifying brain regions
%   seedcenter: seed numbers x 2 x,y coordinates file for seed centers

% OUT:
%   handle: figure handle
    
    ha=tight_subplot(size(R_Data,4),floor(size(seedcenter,1)/2),[0.01 0.03],[0.1 0.01],[0.01 0.01]);
    fhandle=gcf;
    for d=1:size(R_Data,4) %loop through contrasts
        for s=1:floor(size(seedcenter,1)/2) %loop through half as many total seeds

            axes(ha(s+floor(size(seedcenter,1)/2)*(d-1)))
            imagesc(R_Data(:,:,s,d).*isbrain2,[-1 1]); colormap jet;
            hold on;
            plot(seedcenter(s,1),seedcenter(s,2),'k.','MarkerSize',7);
            axis image off
            hold off;

            if s==1 %write title over first seed
                title(['contrast ' num2str(d)]);
            end

        end
    end
end