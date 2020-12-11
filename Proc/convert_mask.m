function [isbrain]=convert_mask(mask_file)
% if a mask has been previously made using an old pipeline, it's likely
% saved as a .tif. This script load the .tif and outputs a matrix to be
% saved as a .mat

% IN: 
%   mask_file: mask file name

% OUT:
%   isbrain: oi.npixels x oi.npixels binary mask

    mask=imread(mask_file);
    isbrain=zeros(size(mask)); %initialize
    isbrain(mask==255)=1; %.tif==255 are brain regions
    
end