clear
%%
% wrapper function to run node fc analysis

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

%%%Node FC

%calculate node FC per mouse, per run, for each bandpass filter setting. Visualize results
for i=1:length(mice) % loop through mice
    for n=mice(i).runs % loop through runs for each mouse
        for q=1:length(mice(i).bandstr) % loop through different bandpass filter options
            % check if analysis is already done
            if exist([mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_NodeFC.mat'], 'file') == 2
                disp(['Node FC already done for ',mice(i).savename,num2str(n),' ',char(mice(i).bandstr(q))])
            else  
                disp('calculating Node FC maps and matrices...')
                load([mice(i).savename,num2str(n),'-Affine_GSR_BroadBand.mat'],'isbrain2') % load mask
                load([mice(i).savename num2str(n) '-Affine_GSR_' char(mice(i).bandstr(q)) '.mat'],'all_contrasts2') % load data to run FC on
                [same_nodes,opp_nodes]=calc_fc_node(all_contrasts2,isbrain2,oi,mice(i)); %%%SCRIPT
                % save FC
                save([mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_NodeFC'],'same_nodes','opp_nodes');
                
                [fhandle]=visualize_nodes(same_nodes,opp_nodes,isbrain2,oi); % visualize bilat FC maps
                output=[mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_NodeFC.jpg'];
                print (fhandle,'-djpeg', '-r300',output); %save image
                close all

            end
        end
    end
end

% average Node FC across runs within a mouse, then across mice, then across groups. For each bandpass
% filter setting. Visualize results. 
for q=1:length(mice(1).bandstr) % loop through different bandpass filter options
    disp('averaging Node FC maps...')

    [same,same_std,same_ms_group,opp,opp_std,opp_ms_group,isbrain2_aff]=FC_Node_AVG(group_index,mice,q,oi); %FC average script
    % save avg FC variables
    save([mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_AvgNodeFC'],'same','same_std','same_ms_group','opp','opp_std','opp_ms_group') %R Rstd r values, R_ms_group z values
    save([mice(1).outname '-mask'],'isbrain2_aff') %save group mask
    
    [fhandle]=visualize_fc_node_avg(same,same_std,opp,opp_std,isbrain2_aff,WL,WL_factor,mice,q,oi); %visualize avg node FC maps
    for i=1:size(same,4) % must loop through the handles and save a .jpg per mouse group
        output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_AvgNodeFC_group' num2str(i) '.jpg'];
        print (fhandle(1,i),'-djpeg', '-r300',output); %save image
    end
    close all

end

% perform pixel wise t-testing (one sample or between groups) for each
% bandpass filter setting. Visualize results
for q=1:length(mice(1).bandstr) % loop through different bandpass filter options
    disp('performing t-tests on FC node maps...')
    
    % load data, group mask
    load([mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_AvgNodeFC'],'same_ms_group','opp_ms_group') %z values
    load([mice(1).outname '-mask'],'isbrain2_aff') %group mask
    
    % find threshold for cluster sizes
    thresh=cluster_threshold([mice(1).savename num2str(min(mice(1).runs)) '-Affine_GSR_BroadBand.mat'],oi.nVx,mice(1).alpha);
    [tmap,p1,h1,h1_cc_rs,tmap2,p2,h2,h2_cc_rs]=FC_Node_ttest(same_ms_group,opp_ms_group,group_index,isbrain2_aff,thresh,mice,oi); %perform pixel-wise t-tests
    %save bilat FC map stats
    save([mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_AvgBilatFC_ttest'],'tmap','p1','h1','h1_cc_rs','thresh','tmap2','p2','h2','h2_cc_rs')

    [fhandle]=visualize_fc_node_ttest(tmap,p1,h1,h1_cc_rs,tmap2,p2,h2,h2_cc_rs,isbrain2_aff,WL,WL_factor,mice,q,oi); %visualize bilat FC stats
    output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_FC_Node_tmaps.jpg'];
    print (fhandle(1,1),'-djpeg', '-r300',output); %save tmaps
    output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_FC_Node_pmaps.jpg'];
    print (fhandle(1,2),'-djpeg', '-r300',output); %save pmaps
    output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_FC_Node_corr_pmaps.jpg'];
    print (fhandle(1,3),'-djpeg', '-r300',output); %save cluster corrected pmaps
    close all

end