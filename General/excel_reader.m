function [mice,group_index]=excel_reader(database, excelrows)
% read excel file with mice info

% IN: 
%   database: excel file name
%   excelrows: rows to process/read in

% OUT:
%   mice: struct containing all necessary filename info and processing options
%       mice(ii) indexes through all mice in excelrows
%   group_index: find dividing rows between groups of mice, used to sort
%       mice into respective groups in averaging scripts

    ii=1;
    % loop through mice
    for i=excelrows
        
        % grab filename info
        [~, ~, raw]=xlsread(database,1, ['A',num2str(i),':AA',num2str(i)]); % read in excel row
        mice(ii).date=num2str(raw{1}); % date
        mice(ii).msd=raw{2}; % mouse name
        mice(ii).rawloc=raw{8}; % raw data main directory path
        mice(ii).saveloc=raw{9}; % saved data main directory path
        mice(ii).type=raw{3}; % imaging run type, e.g. fc or stim
        mice(ii).group=raw{6}; % group name
        mice(ii).time=raw{7}; % timepoint
        mice(ii).info.temp_ds=raw{10}; % temporal downsample factor option
        mice(ii).info.spat_ds=raw{11}; % spatial downsample factor option
        mice(ii).path=[mice(ii).rawloc, mice(ii).date, '\']; % mouse specific raw data path
        mice(ii).savepath=[mice(ii).saveloc, mice(ii).date, '\']; % mouse specific saved data path
        mice(ii).outname=[mice(ii).savepath mice(ii).group mice(ii).time]; % group average save name
        mice(ii).maskname=[mice(ii).path mice(ii).date '-' mice(ii).msd '-mask']; % mask file name
        mice(ii).seedname=[mice(ii).path mice(ii).date '-' mice(ii).msd '-seeds']; % seed file name
        mice(ii).filename=[mice(ii).path, mice(ii).date '-' mice(ii).msd '-' mice(ii).type]; % full mouse specific raw data root name
        mice(ii).savename=[mice(ii).savepath mice(ii).date '-' mice(ii).msd '-' mice(ii).type]; % full mouse specific saved data root name
        % grab run numbers... matlab is weird if there's only one run
        if ischar(raw{4})==1
            mice(ii).runs=str2num(raw{4});
        else
            mice(ii).runs=raw{4};
        end
        % grab which imaging system, make sure image_system_info.m updated
        mice(ii).sys=raw{5};
        % grab which hemodynamic correction to run
        mice(ii).info.hgb_corr=raw{27};
        % grab bandpasses to filter data, default no filter
        mice(ii).filtop=raw{17};
        if strcmp(mice(ii).filtop,'yes')
            mice(ii).bandstr=split(string(raw{19}),","); 
            mice(ii).bandnum=str2num(raw{18});
        else
            mice(ii).bandstr="BroadBand";
            mice(ii).bandnum=[NaN NaN];
        end
        % grab t-test type, alpha
        mice(ii).test=raw{20};
        mice(ii).alpha=raw{21};
        % grab stim info
        mice(ii).info.baseline=raw{12}; % seconds before stim in a block
        mice(ii).info.stim=raw{13}; % seconds of stim in a block
        mice(ii).info.BL2=raw{14}; % seconds after stim in a block
        mice(ii).info.hzstim=raw{15}; % frequency of stims
        mice(ii).info.thresh=raw{16}; % threshold for finding activation area
        
        mice(ii).info.fft_block=raw{25}; %seconds for fft block
        
        ii=ii+1;
        
    end
    
    % find dividing rows between groups of mice for averaging later
    group_index=find(diff(excelrows)~=1);

end