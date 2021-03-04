clear
%%
% wrapper function to run spectral analysis

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

%%%FFT

%calculate FFT per mouse, per run. Visualize results. Create bandpass
%topoplots per bandpass. Visualize results.
for i=1:length(mice) % loop through mice
    for n=mice(i).runs % loop through runs for each mouse
        % check if analysis is already done
        if exist([mice(i).savename,num2str(n),'-Affine_GSR_BroadBand_FFT.mat'], 'file') == 2
            disp(['FFT already done for ',mice(i).savename,num2str(n)])
        else  
            disp('calculating FFT...')
            load([mice(i).savename,num2str(n),'-Affine_GSR_BroadBand.mat'],'all_contrasts2','isbrain2') % load data, mask 
            [avgfft_acrossEpochs,avgfft_acrossEpochsPixels,f]=calc_fft(all_contrasts2,isbrain2,oi,mice(i)); %%%SCRIPT
            % save FFT
            save([mice(i).savename,num2str(n),'-Affine_GSR_BroadBand_FFT'],'avgfft_acrossEpochs','f','avgfft_acrossEpochsPixels');

            [fhandle]=visualize_fft(avgfft_acrossEpochs,f,avgfft_acrossEpochsPixels,oi); % visualize FFT
            output=[mice(i).savename,num2str(n),'-Affine_GSR_BroadBand_FFT.jpg'];
            print (fhandle,'-djpeg', '-r300',output); %save image
            close all

        end
        
        for q=1:length(mice(i).bandstr) %loop through bandpasses to create band specific topoplots
            % check if analysis is already done
            if exist([mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_FFT_image.mat'], 'file') == 2
                disp(['FFT image already done for ',mice(i).savename,num2str(n),' ',char(mice(i).bandstr(q))])
            else 
                check=exist('avgfft_acrossEpochs');
                if check==0
                    % if only running band_fft, need to load FFT
                    load([mice(i).savename,num2str(n),'-Affine_GSR_BroadBand_FFT.mat'],'avgfft_acrossEpochs')
                    load([mice(i).savename,num2str(n),'-Affine_GSR_BroadBand.mat'],'isbrain2')
                end 
                disp('banding fft... rock on...')
                [avgfft_band]=band_fft(avgfft_acrossEpochs,mice(i),q); %%%SCRIPT
                % save FFT images
                save([mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_FFT_image'],'avgfft_band');
                
                [fhandle]=visualize_fft_image(avgfft_band,isbrain2,oi); % visualize FFT images
                output=[mice(i).savename,num2str(n),'-Affine_GSR_',char(mice(i).bandstr(q)),'_FFT_image.jpg'];
                print (fhandle,'-djpeg', '-r300',output); %save image
                close all
            end
        end
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Average together FFTs across mice
disp('averaging FFTs...')

[fft_avg,fft_std,fft_ms_group]=FFT_AVG(group_index,mice); %FFT average script
% save avg FFT variables
save([mice(1).outname '-Affine_GSR_BroadBand_AvgFFT'],'fft_avg','fft_std','fft_ms_group')

load([mice(1).savename,num2str(min(mice(1).runs)),'-Affine_GSR_BroadBand_FFT'],'f'); %x-axis for plotting frequency (hz)

[fhandle]=visualize_fft_avg(fft_avg,fft_std,oi,f); %visualize avg FFT
output=[mice(1).outname '-Affine_GSR_BroadBand_AvgFFT.jpg'];
print (fhandle,'-djpeg', '-r300',output); %save image
close all

%average FFT maps across runs within a mouse, then across mice, then across groups. For each bandpass
%filter setting. Visualize results.
for q=1:length(mice(1).bandstr) % loop through different bandpass filter options
    disp('averaging FFT maps...')

    [fft_avg_image,fft_std_image,fft_image_ms_group,isbrain2_aff]=FFT_MAP_AVG(group_index,mice,q,oi); %FFT map average script
    % save avg FFT map variables
    save([mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_AvgFFT_image'],'fft_avg_image','fft_std_image','fft_image_ms_group')
    save([mice(1).outname '-mask'],'isbrain2_aff') %save group mask
    
    [fhandle]=visualize_fft_image_avg(fft_avg_image,fft_std_image,isbrain2_aff,WL,WL_factor,mice,q,oi); %visualize avg FFT maps
    for i=1:size(fft_avg_image,4) % must loop through the handles and save a .jpg per mouse group
        output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_AvgFFT_image_group' num2str(i) '.jpg'];
        print (fhandle(1,i),'-djpeg', '-r300',output); %save image
    end
    close all

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform ttests between groups of mice
disp('calculating ttest on FFTs...')

% Load avg FFT variables
load([mice(1).outname '-Affine_GSR_BroadBand_AvgFFT'],'fft_ms_group')

[h1,p1]=FFT_ttest(fft_ms_group,group_index,oi,mice(1)); %FFT ttest script
% save ttest FFT variables
save([mice(1).outname '-Affine_GSR_BroadBand_ttestFFT'],'h1','p1')

load([mice(1).savename,num2str(min(mice(1).runs)),'-Affine_GSR_BroadBand_FFT'],'f'); %x-axis for plotting frequency (hz)

[fhandle]=visualize_fft_avg_ttest(fft_avg,fft_std,oi,h1,f); %visualize ttest FFT
output=[mice(1).outname '-Affine_GSR_BroadBand_ttestFFT.jpg'];
print (fhandle,'-djpeg', '-r300',output); %save image
close all

% perform pixel wise t-testing (one sample or between groups) for each
% bandpass filter setting. Visualize results
for q=1:length(mice(1).bandstr) % loop through different bandpass filter options
    disp('performing t-tests on FFT maps...')
    
    % load data, group mask
    load([mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_AvgFFT_image'],'fft_image_ms_group') %z values
    load([mice(1).outname '-mask'],'isbrain2_aff') %group mask
    
    % find threshold for cluster sizes
    thresh=cluster_threshold([mice(1).savename num2str(min(mice(1).runs)) '-Affine_GSR_BroadBand.mat'],oi.nVx,mice(1).alpha);
    [tmap,p1,h1,h1_cc_rs]=FFT_MAP_ttest(fft_image_ms_group,group_index,isbrain2_aff,thresh,mice,oi); %perform pixel-wise t-tests
    %save FFT map stats
    save([mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_AvgFFT_image_ttest'],'tmap','p1','h1','h1_cc_rs','thresh')

    [fhandle]=visualize_fft_map_ttest(tmap,p1,h1,h1_cc_rs,isbrain2_aff,WL,WL_factor,mice,q,oi); %visualize FFT map stats
    output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_FFT_tmaps.jpg'];
    print (fhandle(1,1),'-djpeg', '-r300',output); %save tmaps
    output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_FFT_pmaps.jpg'];
    print (fhandle(1,2),'-djpeg', '-r300',output); %save pmaps
    output=[mice(1).outname '-Affine_GSR_' char(mice(1).bandstr(q)) '_FFT_corr_pmaps.jpg'];
    print (fhandle(1,3),'-djpeg', '-r300',output); %save cluster corrected pmaps
    close all

end
