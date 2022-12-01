function [BiCorIm]=calc_bilateral(all_contrasts2,isbrain2)

% script to calculate bilateral connectivity per run

% IN:
%   all_contrasts2: pixels, pixels, contrast, frames. processed data
%   isbrain2: pixel x pixel binary mask signifying brain regions

% OUT:
%   BiCorIm: bilateral FC map. pixels x pixels x contrast

    % make bilateral seeds
    [SeedsUsed]=CalcRasterSeedsUsed(isbrain2);
    % calc r maps
    for i=1:size(all_contrasts2,3)
        [R_LR]=fcManySeed(squeeze(all_contrasts2(:,:,i,:)), SeedsUsed, isbrain2);
        % organize into images
        BiCorIm(:,:,i)=CalcBilateral(R_LR, SeedsUsed, isbrain2);
    end
    
end