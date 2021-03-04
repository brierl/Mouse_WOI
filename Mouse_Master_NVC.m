clear
%%
% wrapper function to run nvc analysis

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

%%%NVC

%calculate nvc per mouse, per run, for each bandpass filter setting. Visualize results
for i=1:length(mice) % loop through mice
    for n=mice(i).runs % loop through runs for each mouse
        for q=1:length(mice(i).bandstr) % loop through different bandpass filter options
            % check if analysis is already done
            if exist([mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_NVC.mat'], 'file') == 2
                disp(['NVC already done for ',mice(i).savename,num2str(n),' ',char(mice(i).bandstr(q))])
            else  
                disp('calculating NVC...')
                load([mice(i).savename,num2str(n),'-Affine_GSR_BroadBand.mat'],'isbrain2') % load mask
                load([mice(i).savename num2str(n) '-Affine_GSR_' char(mice(i).bandstr(q)) '.mat'],'all_contrasts2') % load data to run NVC on
                [corroxyg6,lagsoxyg6,r,all_lags]=NVC_bypixel(all_contrasts2,isbrain2,oi,mice(i)); %%%SCRIPT
                % save nvc
                save([mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_NVC'],'corroxyg6','lagsoxyg6','r','all_lags');
                
                [fhandle]=visualize_nvc(corroxyg6,lagsoxyg6,r,all_lags,isbrain2,oi,seedcenter,mice(i)); % visualize nvc maps
                output=[mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_NVC.jpg'];
                print (fhandle,'-djpeg', '-r300',output); %save image
                close all
                
            end
        end
    end
end

%average nvc across runs within a mouse, then across mice, then across groups. For each bandpass
%filter setting. Visualize results.
for q=1:length(mice(1).bandstr) % loop through different bandpass filter options
    disp('averaging nvc maps...')

    [max_rs_corr,max_stds_corr,maxR_ms_group,max_rs_lags,max_stds_lags,Lag_maxr_ms_group,rs_corr,stds_corr,R_ms_group,rs_lags,stds_lags,Lag_ms_group,isbrain2_aff]=AVG_NVC(group_index,mice,q,oi); % NVC average script
    % save avg NVC variables
    save([mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_AvgNVC'],'max_rs_corr','max_stds_corr','maxR_ms_group','max_rs_lags','max_stds_lags','Lag_maxr_ms_group','rs_corr','stds_corr','R_ms_group','rs_lags','stds_lags','Lag_ms_group') %R_ms_group maxR_ms_group z values, rest r values
    save([mice(1).outname '-mask'],'isbrain2_aff') %save group mask
    
    [fhandle]=visualize_nvc_avg(max_rs_corr,max_stds_corr,max_rs_lags,max_stds_lags,rs_corr,stds_corr,rs_lags,isbrain2_aff,WL,WL_factor,mice,q,oi,seedcenter); %visualize avg NVC
    for i=1:size(max_rs_corr,3) % must loop through the handles and save a .jpg per mouse group
        output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_AvgNVC_group' num2str(i) '.jpg'];
        print (fhandle(1,i),'-djpeg', '-r300',output); %save image
    end
    close all

end

% perform pixel wise t-testing (one sample or between groups) for each
% bandpass filter setting. Visualize results
for q=1:length(mice(1).bandstr) % loop through different bandpass filter options
    disp('performing t-tests on nvc maps...')
    
    % load data, group mask
    load([mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_AvgNVC'],'maxR_ms_group','Lag_maxr_ms_group') %z, time values
    load([mice(1).outname '-mask'],'isbrain2_aff') %group mask
    
    % find threshold for cluster sizes
    thresh=cluster_threshold([mice(1).savename num2str(min(mice(1).runs)) '-Affine_GSR_BroadBand.mat'],oi.nVx,mice(1).alpha);
    [tmap1,p1,h1,h1_cc_rs,tmap2,p2,h2,h2_cc_rs]=NVC_ttest(maxR_ms_group,Lag_maxr_ms_group,group_index,isbrain2_aff,thresh,mice); %perform pixel-wise t-tests
    %save NVC map stats
    save([mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_AvgNVC_ttest'],'tmap1','p1','h1','h1_cc_rs','tmap2','p2','h2','h2_cc_rs','thresh')

    [fhandle]=visualize_nvc_ttest(tmap1,p1,h1,h1_cc_rs,tmap2,p2,h2,h2_cc_rs,isbrain2_aff,WL,WL_factor,mice,q,oi); %visualize NVC stats
    output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_NVC_corr_tmaps.jpg'];
    print (fhandle(1,1),'-djpeg', '-r300',output); %save tmaps
    output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_NVC_corr_pmaps.jpg'];
    print (fhandle(1,2),'-djpeg', '-r300',output); %save pmaps
    output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_NVC_corr_corr_pmaps.jpg'];
    print (fhandle(1,3),'-djpeg', '-r300',output); %save cluster corrected pmaps
    output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_NVC_lags_tmaps.jpg'];
    print (fhandle(1,4),'-djpeg', '-r300',output); %save tmaps
    output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_NVC_lags_pmaps.jpg'];
    print (fhandle(1,5),'-djpeg', '-r300',output); %save pmaps
    output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_NVC_lags_corr_pmaps.jpg'];
    print (fhandle(1,6),'-djpeg', '-r300',output); %save cluster corrected pmaps
    close all

end
