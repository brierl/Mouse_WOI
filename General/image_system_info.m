function [oi,seedcenter,WL]=image_system_info(seedcenter,WL,mice)
% get image system specific info. Updated for OIS3 design 156 x 156 sCMOS
% camera design and OIS2 128 x 128 EMCCD design

% IN:
%   seedcenter: seed number x 2 matrix of x,y coordinate seed centers. Default seed file plotted for
%       128x128 EMCCD camera, so needs to be modified for other settings
%   WL: white light image. Default WL is off 128 x 128 EMCCD camera
%   mice: struct of mouse filename and processing info.

% OUT:
%   oi: optical instrument specific properties
%   seedcenter: seedcenter resized for camera used by imaging system
%   WL: white light resized for camera used by imaging system

%%% REFERENCE IF STRCMP(SYS,'fcOIS3') SECTION FOR EXPLANATION OF VARIABLES
%%% NEEDED TO BE DEFINED IF ADDING NEW IMAGING SYSTEM. IF VARIABLE IS N/A
%%% SET VARIABLE=[];

    sys=mice(1).sys; % which system
 
    if strcmp(sys, 'fcOIS3')
        oi.numls=4; % total number of light sources
        oi.numls_ois=3; % number of light sources used for hemoglobin imaging
        oi.em_pos=1; % position of emission light source if gcamp imaging
        oi.ois_pos=[2:4]; % position of OIS light sources if hemoglobin imaging
        oi.hem_corr_pos=2; % if ratiometric hgb correction... position of light source used for correction
        oi.framerate=16.8; % framerate per light source
        oi.fp=1; % floating points on oi.framerate... used for resampling data
        % oi.con_num is/are the indices in the variable all_contrasts* 3rd
        % dimension to choose contrasts to plot when averaging. Averaging
        % scripts output avg and std across mice so recommended to plot no
        % more than 2 contrasts at a time to decrease clutter. If only 1
        % contrast, oi.con_num=1; Else, if hgb imaging only
        % oi.con_num=1=oxy, oi.con_num=2=deoxy. If gcamp+oxy imaging,
        % oi.con_num=1=gcamp corrected, oi.con_num=2=gcamp uncorrected,
        % oi.con_num=3=oxy, oi.con_num=4=deoxy.
        oi.con_num=[1 3];
        % light source spectra file names
        oi.ls{1}.name='190122_Mightex_530nm_Pol_OIS3'; % OIS3
        oi.ls{2}.name='190122_Mightex_590nm_Pol_OIS3'; % OIS3
        oi.ls{3}.name='190122_Mightex_625nm_Pol_OIS3'; % OIS3
        oi.npixels=156; % 1 dimensional number of pixels
        oi.colors={[0 0 1],[0 1 0],[1 1 0],[1 0 0]}; %RGB to match light sources
        oi.FOV=10; %in mm

    elseif strcmp(sys, 'fcOIS2')
        oi.numls=4;
        oi.numls_ois=3;
        oi.em_pos=1;
        oi.ois_pos=[2:4];
        oi.hem_corr_pos=2;
        oi.framerate=16.8;
        oi.fp=1;
        oi.con_num=[1 3];
        oi.ls{1}.name='131029_Mightex_530nm_NoBPFilter'; % OIS2
        oi.ls{2}.name='140801_ThorLabs_590nm_NoPol'; % OIS2
        oi.ls{3}.name='140801_ThorLabs_625nm_NoPol'; % OIS2   
        oi.npixels=128;
        oi.colors={[0 0 1],[0 1 0],[1 1 0],[1 0 0]};
        oi.FOV=10;
        
    end
    
    % 1 dimensional number of pixels in processed image
    oi.nVx=oi.npixels/mice(1).info(1).spat_ds;
    oi.nVy=oi.npixels/mice(1).info(1).spat_ds;

    % replot seedcenters if widened FOV. using WL as check... if change WL,
    % find new check...
    if size(WL,1)<oi.npixels
        seedcenter=(seedcenter+abs(size(WL,1)-oi.npixels)/2);
    end
    % resize seeds for processed data
    seedcenter=seedcenter.*(1/mice(1).info.spat_ds);
    
    % plotting adjustment necessary when plotting on WL (AVG scripts) if
    % not using full WL FOV (which is 10mm...)
    if oi.FOV<10
        oi.plot_factor=10; %pixels to crop out on either side of white light
    else
        oi.plot_factor=0;
    end

    % resize WL from 128 to match oi.npixels, downsample if applicable
    if size(WL,1)~=oi.npixels
        WL=imresize(WL,oi.npixels/size(WL,1));
    end
    % resize WL for processed data
    WL=imresize(WL,1/mice(1).info.spat_ds);

    

end