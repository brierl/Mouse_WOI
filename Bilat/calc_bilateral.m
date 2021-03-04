function [BiCorIm]=calc_bilateral(all_contrasts2,isbrain2,oi)

% script to calculate bilateral connectivity per run

% IN:
%   all_contrasts2: oi.nVx, oi.nVy, contrast, time. processed data
%   isbrain2: pixel x pixel binary mask signifying brain regions
%   oi: optical instrument properties

% OUT:
%   BiCorIm: bilateral FC map. pixels x pixels x contrast

    % make bilateral seeds
    [SeedsUsed]=CalcRasterSeedsUsed(isbrain2);
    j=1;
    % calc r maps
    for i=oi.con_num
        [R_LR]=fcManySeed(squeeze(all_contrasts2(:,:,i,:)), SeedsUsed, isbrain2);
        % organize into images
        BiCorIm(:,:,j)=CalcBilateral(R_LR, SeedsUsed, isbrain2);
        j=j+1;
    end
    
end
