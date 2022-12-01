function [raw_nodark]=subtract_dark_ois(rawdata,dark)
% subtract a dark frame from an image stack

% IN: 
%   rawdata: image stack, pixels x pixels x frames
%   dark: dark frame, pixels x pixels

% OUT:
%   raw_nodark: image stack with dark frame subtracted

    %initialize
    raw_nodark=zeros(size(rawdata,1), size(rawdata,2), size(rawdata,3));
    % Subtract dark/background frame (ie no lights)
    for z=1:size(rawdata,3)
        raw_nodark(:,:,z)=abs(rawdata(:,:,z)-dark);
    end
    clear rawdata

end