clear
%%
% wrapper function to run bilateral fc analysis

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

%%%BILAT

%calculate bilat FC per mouse, per run, for each bandpass filter setting. Visualize results
for i=1:length(mice) % loop through mice
    for n=mice(i).runs % loop through runs for each mouse
        for q=1:length(mice(i).bandstr) % loop through different bandpass filter options
            % check if analysis is already done
            if exist([mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_bilat_FC.mat'], 'file') == 2
                disp(['Bilat FC already done for ',mice(i).savename,num2str(n),' ',char(mice(i).bandstr(q))])
            else  
                disp('calculating Bilat FC maps...')
                load([mice(i).savename,num2str(n),'-Affine_GSR_BroadBand.mat'],'isbrain2') % load mask
                load([mice(i).savename num2str(n) '-Affine_GSR_' char(mice(i).bandstr(q)) '.mat'],'all_contrasts2') % load data to run bilat FC on
                [BiCorIm]=calc_bilateral(all_contrasts2,isbrain2,oi); %%%SCRIPT
                % save bilat FC
                save([mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_bilat_FC'],'BiCorIm');
                
                [fhandle]=visualize_bilat(BiCorIm,isbrain2,oi); % visualize bilat FC maps
                output=[mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_bilat_FC.jpg'];
                print (fhandle,'-djpeg', '-r300',output); %save image
                close all
                
            end
        end
    end
end

%average bilat FC across runs within a mouse, then across mice, then across groups. For each bandpass
%filter setting. Visualize results.
for q=1:length(mice(1).bandstr) % loop through different bandpass filter options
    disp('averaging bilat FC maps...')

    [R,Rstd,R_ms_group,isbrain2_aff]=BILAT_FC_AVG(group_index,mice,q,oi); %Bilat FC average script
    % save avg bilat FC variables
    save([mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_AvgBilatFC'],'R','Rstd','R_ms_group') %R Rstd r values, R_ms_group z values
    save([mice(1).outname '-mask'],'isbrain2_aff') %save group mask
    
    [fhandle]=visualize_bilat_fc_avg(R,Rstd,isbrain2_aff,WL,WL_factor,mice,q,oi); %visualize avg bilat FC maps
    for i=1:size(R,4) % must loop through the handles and save a .jpg per mouse group
        output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_AvgBilatFC_group' num2str(i) '.jpg'];
        print (fhandle(1,i),'-djpeg', '-r300',output); %save image
    end
    close all

end

% perform pixel wise t-testing (one sample or between groups) for each
% bandpass filter setting. Visualize results
for q=1:length(mice(1).bandstr) % loop through different bandpass filter options
    disp('performing t-tests on bilat FC maps...')
    
    % load data, group mask
    load([mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_AvgBilatFC'],'R_ms_group') %z values
    load([mice(1).outname '-mask'],'isbrain2_aff') %group mask
    
    % find threshold for cluster sizes
    thresh=cluster_threshold([mice(1).savename num2str(min(mice(1).runs)) '-Affine_GSR_BroadBand.mat'],oi.nVx,mice(1).alpha);
    [tmap,p1,h1,h1_cc_rs]=BILAT_FC_ttest(R_ms_group,group_index,isbrain2_aff,thresh,mice,oi); %perform pixel-wise t-tests
    %save bilat FC map stats
    save([mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_AvgBilatFC_ttest'],'tmap','p1','h1','h1_cc_rs','thresh')

    [fhandle]=visualize_bilat_fc_ttest(tmap,p1,h1,h1_cc_rs,isbrain2_aff,WL,WL_factor,mice,q,oi); %visualize bilat FC stats
    output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_BILATFC_tmaps.jpg'];
    print (fhandle(1,1),'-djpeg', '-r300',output); %save tmaps
    output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_BILATFC_pmaps.jpg'];
    print (fhandle(1,2),'-djpeg', '-r300',output); %save pmaps
    output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_BILATFC_corr_pmaps.jpg'];
    print (fhandle(1,3),'-djpeg', '-r300',output); %save cluster corrected pmaps
    close all

end
