clear
%%
% wrapper function to run processing

%%%EDIT THIS SECTION, RUN TO SET PATHS AND EXCELFILE DATABASE

home='C:\Box\Culver_OIS_Toolbox_LMB\GitHub5_ForGit\'; % EDIT path to software
addpath(genpath(home))

database='GitHubDataSheet.xlsx'; %EDIT name of excel sheet with mice
excelrows=[3 4]; %EDIT lines corresponding to mice to process from excel sheet

%%%
%%

%%%ALWAYS EDIT/RUN THIS SECTION, GRABS BASIC MOUSE AND OPTICAL INSTRUMENT INFO NEEDED IN ALL FOLLOWING SECTIONS

[mice,group_index]=excel_reader(database,excelrows); %reads excel sheet, make struct "mice" with necessary filename info

seedcenter=cell2mat(struct2cell(load('Seeds-R01-Revised','seedcenter'))); %final seeds for FC analysis
WL=cell2mat(struct2cell(load('GOOD_AFF_WL'))); %final WL for plotting

[oi,seedcenter,WL]=image_system_info(seedcenter,WL,mice); %grab optical instrument specific properties

WL_factor=3*floor(oi.npixels/size(WL,1))/mice(1).info.spat_ds; %factor for plotting WL without weird black bar at the top...change if ever change WL...

%%%
%% 

%%%PROC
% Data pre-processing as described in Wright et al., 2017 and Brier et al.,
% 2019. First for loop checks if mask and seeds are made for each mouse, if
% not, make them...

for i=1:length(mice) % loop through mice
        
    % check if mask already exists
    if exist([mice(i).maskname '.mat'], 'file') == 2
        disp(['Mask already made for ' mice(i).date '-' mice(i).msd])
    % check if mask is already made as a .tif--OLD WAY, convert to new .mat
    elseif exist([mice(i).maskname '.tif'], 'file') == 2
        disp(['Mask already made for ' mice(i).date '-' mice(i).msd])
        [isbrain]=convert_mask([mice(i).maskname '.tif']); % convert .tif --> .mat
        save([mice(i).maskname '.mat'],'isbrain');
    else
        fcrun1=[mice(i).filename num2str(min(mice(i).runs))]; % find first run per mouse
        [frameall]=load_frame(fcrun1,oi); % load one frame
        disp('click to trace around brain... double click to make mask...')
        isbrain=double(roipoly(frameall));
        save([mice(i).maskname '.mat'],'isbrain');
        pause(0.5); close all;
    end

    % check if seeds already exist
    if exist([mice(i).seedname '.mat'], 'file') == 2
        disp(['Seeds already made for ' mice(i).date '-' mice(i).msd])
    else
        check=exist('frameall'); % if not running right after createMask, will need to load frame
        if check==0
            fcrun1=[mice(i).filename num2str(min(mice(i).runs))]; % filename for first run of a mouse
            [frameall]=load_frame(fcrun1,oi); % load frame from filename
        end
        % createSeeds will ask you to click anterior suture, then lambda,
        % will display a set of 16 seeds, if it looks good, click yes. If
        % want to re-do, click no and it will let you try again.
        [I,seedcenter_ms]=createSeeds(frameall);
        save([mice(i).seedname '.mat'],'I', 'seedcenter_ms');
        pause(0.5); close all;
    end

end

% process data and filter
% loops through mice
for i=1:length(mice)
    % loop through runs per mouse
    for n=mice(i).runs
        
        % check if BroadBand proc done already
        if exist([mice(i).savename,num2str(n),'-Affine_GSR_BroadBand.mat'], 'file') == 2
            disp(['BroadBand Proc already done for ' mice(i).savename num2str(n)])
        else
            isbrain=imresize(cell2mat(struct2cell(load(mice(i).maskname,'isbrain'))),(1/mice(i).info.spat_ds)); % load mask
            isbrain(isbrain~=1)=0; % rebinarize bc imresize will undo that...
            % load dark frame. Default is a 128x128 frame... hence the hard
            % coded 128 below.
            dark=imresize(single(imread('Dark.tif')),(oi.npixels/128)*(1/mice(i).info.spat_ds));
            % load data
            [rawdata,dark]=load_image_stack([mice(i).filename,num2str(n)],dark,mice(i),n,oi);
            % process data, system dependent 
            [rawdata_f,fulldetrend,all_contrasts,WL_ms]=Proc1_sys_dep(rawdata,dark,mice(i),oi); 
            % process data, smoothing, GSR
            [all_contrasts]=Proc2(all_contrasts,isbrain);
            % Affine transform
            Landmarks=cell2mat(struct2cell(load(mice(i).seedname,'I'))); % these were clicked landmarks during createSeeds
            Landmarks.tent=Landmarks.tent*(1/mice(i).info.spat_ds);
            Landmarks.OF=Landmarks.OF*(1/mice(i).info.spat_ds);
            [all_contrasts2,isbrain2]= Affine(all_contrasts,isbrain,Landmarks,mice(i),oi);
            % Save the data
            mkdir([mice(i).savepath]);
            save([mice(i).savename,num2str(n),'-Affine_GSR_BroadBand'],'-v7.3','all_contrasts2','isbrain2','WL_ms','mice','rawdata_f','fulldetrend');
            
            % qc check on data
            [fhandle]=check_qc(rawdata_f,fulldetrend,isbrain2,mice(i),oi);
            output=[mice(i).savename,num2str(n),'-Affine_GSR_BroadBand_DataQC.jpg'];
            print (fhandle,'-djpeg', '-r300',output); %save image
            close all
        end
            
        if strcmp(mice(i).filtop,'yes') %if you want filtering...
            for k=1:length(mice(i).bandstr) %loop through bandpass options
                % prep filter
                band=strcat('Affine_GSR_',mice(i).bandstr(k));
                band=char(band); %string for filtered data label
                hp=mice(i).bandnum(k,1); %highpass
                lp=mice(i).bandnum(k,2); %lowpass

                % check if filtering already done
                if exist([mice(i).savename,num2str(n),'-',band,'.mat'], 'file') == 2
                    disp([band ' Proc already done for ' mice(i).date '-' mice(i).msd])
                else
                    disp('Filtering Data...')
                    % if running directly after BroadBand proc, no need to
                    % re-load data
                    check=exist('all_contrasts2');
                    if check==0
                        % if only running filter, need to load data
                        load([mice(i).savename,num2str(n),'-Affine_GSR_BroadBand.mat'],'all_contrasts2','isbrain2')
                    end    
                    % butterworth filter
                    [all_contrasts2]=OIS_GCaMP_Filter(all_contrasts2,hp,lp,mice(i),oi);
                    %save filtered data
                    save([mice(i).savename,num2str(n),'-',band,'.mat'],'-v7.3','all_contrasts2');
                    % qc filtered data
                    for con_num=oi.con_num %loop through user specified contrasts
                        [fhandle,rmsc]=check_mvmt(squeeze(all_contrasts2(:,:,con_num,:)),isbrain2,mice(i),oi);
                        save([mice(i).savename,num2str(n),'-',band,'_rms_contrast',num2str(con_num),'.mat'],'rmsc');
                        output=[mice(i).savename,num2str(n),'-',band,'_MvMt_contrast' num2str(con_num) '.jpg'];
                        print (fhandle,'-djpeg', '-r300',output); %save image
                        close all
                    end
                    clear all_contrasts2 isbrain2 % NEED TO CLEAR so new data will get loaded for next mouse
                end
            end
        end
    end
end
