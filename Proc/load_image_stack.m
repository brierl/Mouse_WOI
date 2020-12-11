function [rawdata,dark]=load_image_stack(run,dark,mice,n,oi)
% load an image stack and resize. Supports .tif or .mat

% IN:
%   run: filename for run to be processed
%   dark: dark frame
%   mice: struct containing mouse filename and processing settings
%   n: run number
%   oi: optical instrument properties

% OUT:
%   rawdata: resized image stack. oi.nVx x oi.nVy x frames
%   dark: dark frame (flipped if image stack was .tif)

    disp('Loading Data');
    disp('Mouse');  mice.msd 
    disp('Run'); n
        
    ext=dir([run,'.*']); %find filetype extension
    filetype=ext.name(end-2:end); % save only letters after '.'

    if ~isempty(filetype) && ~(strcmp(filetype,'tif') || strcmp(filetype,'mat'))
        error('** only supports the loading of .mat, and .tif files **')
    else
        if exist([run,'.tif']) %if .tif
            rawdata=readtiff([run,'.',filetype]);
            rawdata=fliplr(rawdata); %EMCCD spools as .tif and fliplr 
            dark=fliplr(dark);
        elseif exist([run,'.mat'])
            rawdata=cell2mat(struct2cell(load([run,'.',filetype])));
        end
    end

    % if images are smaller than oi.pixels, pad images
    if size(rawdata,1)<oi.npixels
        rawdata=padarray(rawdata,[abs(size(rawdata,1)-oi.npixels)/2 abs(size(rawdata,1)-oi.npixels)/2],'both'); % pad data to increase size if acquired with fewer than 156 pixels^2
    end
    
    % spatially downsample image stack
    rawdata = imresize(rawdata,1/mice.info.spat_ds);
    rawdata=double(rawdata); 
    
    % make image data reshapeable into frames per LS channel for later
    [~, ~, L]=size(rawdata);
    L2=L-rem(L,oi.numls*mice.info.temp_ds);
    rawdata=rawdata(:,:,1:L2);

end