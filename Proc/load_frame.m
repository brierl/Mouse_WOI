function [frameall]=load_frame(fcrun1,oi)
% loads a frame from the first run for a mouse

% IN: 
%   fcrun1: the filename for the first run for a mouse
%   oi: optical instrument properties

% OUT:
%   frameall: the fifth frame of the image stack normalized to maximum
%       intensity
        
    ext=dir([fcrun1,'.*']); % find filename extension
    filetype=ext.name(end-2:end); % save letters after '.'

    if ~isempty(filetype) && ~(strcmp(filetype,'tif') || strcmp(filetype,'mat'))
        error('** only supports the loading of .mat, and .tif files **')
    else
        if exist([fcrun1,'.tif']) %if .tif
            frame=readtiff([fcrun1,'.',filetype]);
            frame=fliplr(frame); %EMCCD spool as .tif and fliplr
        elseif exist([fcrun1,'.mat']) %if .mat
            frame=cell2mat(struct2cell(load([fcrun1,'.',filetype])));
        end
    end

    % normalize
    frameall=frame(:,:,5)./max(max(frame(:,:,5)));

    % if frame smaller than oi.npixels, pad frame
    if size(frameall,1)<oi.npixels
        frameall=padarray(frameall,[abs(size(frameall,1)-oi.npixels)/2 abs(size(frameall,1)-oi.npixels)/2],'both');
    end

end