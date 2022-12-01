function [frames,frame5]=load_data(fcrun1)
% loads image stack and normalizes a single frame from the first run for a mouse. This frame is used
% to create a binary mask signaling brain and non-brain pixels within the
% FOV and seed coordinates to affine transform to common atlas space. 

% IN: 
%   fcrun1: string for the path and filename for the first run for a mouse. e.g.,
%       'dir1/dir2/filename'

% OUT:
%   frames: image stack
%   frame5: the fifth frame of the image stack normalized to maximum
%       intensity
        
    ext=dir([fcrun1,'.*']); % find filename extension
    filetype=ext.name(end-2:end); % save letters after '.'

    if ~isempty(filetype) && ~(strcmp(filetype,'tif') || strcmp(filetype,'mat'))
        error('** only supports the loading of .mat, and .tif files **')
    else
        if exist([fcrun1,'.tif']) %if .tif
            frames=readtiff([fcrun1,'.',filetype]);
            frames=fliplr(frames); %EMCCD spools as .tif and needs fliplr
        elseif exist([fcrun1,'.mat']) %if .mat
            frames=cell2mat(struct2cell(load([fcrun1,'.',filetype]))); %SCMOS spools as .mat and no fliplr needed
        end
    end

    % normalize
    frame5=frames(:,:,5)./max(max(frames(:,:,5)));

end