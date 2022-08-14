# Mouse_WOI
Mouse wide-field optical imaging processing toolbox

This software is to be used to process mesoscopic mouse wide-field optical data. Assumes that data is an image stack, pixels x pixels x frames. Please contact Lindsey Brier with any questions/potential bugs: brierl@wustl.edu. Last updated 8/22 . Being currently updated for high resolution scans.

## GitHub5 (version 5)
Mouse_Master*.m:  Wrapper scripts that perform various types of analysis. Each begin the same, Mouse_Master_Proc.m is used as an example:

To get started, edit line 7 to be the path to the main directory of the software. 

Edit line 10 to excel file name (excel file explained below).

Edit line 11 to rows within the excel file to process.

image_system_info.m on line 23 is set up for imaging systems ‘fcOIS3’ and ‘fcOIS2’… Specify in System field in excel file, explained below. If you want to run data off a different imaging system, edit image_system_info.m with new optical instrument properties (outlined in image_system_info.m).

Extras:  
Seeds-R01-Revised.mat: 26 Canonical seeds corresponding to Olfactory, Frontal, Cingulate, Motor, Somatosensory, Retrosplenial, Visual, Auditory, and Parietal cortices.  
GOOD_AFF_WL.mat: White light image for overlaying results. Affine transformed.

Sample data available at: https://data.mendeley.com/datasets/v3jwyg7rcx/1

Sample excel data sheet included in repository: GitHubDataSheet.xlsx

Excel file:  
Date: YYMMDD format   
Mouse: Alphanumeric name per mouse   
Session_Type: ‘fc’ for resting state or ‘stim’  
Run: imaging run numbers. Separate by commas e.g. 1,2,3…  
System: Imaging system data is collected on. E.g. ‘fcOIS3’ or ‘fcOIS2’  
Group: Save name stem for group averaged data  
Time: If applicable, for baseline or x hours post   
Binned_Data_Location: User computer binned raw data path  
Save_Location:  User computer saved data path after processing  

Temp DS: temporal downsample factor. Example=2  
Spat DS: spatial downsample factor. Example =2  
Baseline time: seconds in a stim block before stim is presented. Example =5  
Stim time: seconds in a stim block while stim is presented. Example =5  
Recovery time: seconds in a stim block after a stim is presented. Example =10  
hz stims: frequency of stimulation. Example =2  
stim thresh: fraction of max activation during stimulation to threshold image to isolate activation area. Example =0.75  
filt?: filter data, options either yes or no. Example =yes  
bandnum: doubles specify highpass/lowpass for each bandpass filter. Example = [0.4 4.0; 0.009 0.08]  
bandstr: strings, comma separated, to label data after bandpass filtering. Need a string for each bandnum pair. Example =pt4-4pt0,pt009-pt08  
ttest: type of ttest code will perform. Options either 2-sample or paired. Code will recognize if only one group is being analyzed and will perform 1-sample. Example =2-sample  
alpha: p<alpha will be regarded statistically significant (uncorrected for multiple comparisons). Example =0.05. Same alpha used for FWER in cluster based analysis.
Vid fr: framerate for video playback. Example =16.8  
quality: video quality. Example =25  
Vid frames: selected frames to put in video, ; separated. Example =1;500  
Length block (s): seconds per epoch for FFT calculation. Example =10  
StD cutoff: number of standard deviations above the mean to threshold GVTD trace. Example =1  
Option: Hgb correction option. Options either ratio or ex-em. Example =ex-em  
Value: Z(r) threshold used for node calculation. Example =0.3

Notes:  
***For averaging purposes (later), format excel documents so all mice that are going to be averaged together are in sequential lines. Mice in different groups should be separated by at least one line.  
Currently being updated to include movie scripts...***

### Function List (All wrappers):   
1.	excel_reader.m  
2.	image_system_info.m

#### MOUSE_MASTER_PROC
1.	convert_mask.m (optional)  
2.	load_frame.m  
a.	readtiff.m (optional)  
3.	roipoly.m (built-in MATLAB function, makes mask)  
4.	load_frame.m (optional)  
a.	readtiff.m (optional)  
5.	createSeeds.m  
a.	MakeSeedsMouseSpace.m  
i.	Seeds_PaxinosSpace.m  
6.	load_image_stack.m  
a.	readtiff.m (optional)  
7.	Proc1_sys_dep.m  
a.	getop.m  
i.	getHb.m  
ii.	getLS.m  
b.	subtract_dark_ois.m  
c.	temporal_ds_ois.m  
d.	detrend_ois.m  
e.	procPixel.m (if hgb imaging)  
i.	logmean.m  
ii.	dotspect.m  
iii.	datacondition.m  
f.	mean_normalize.m (if fluor imaging)  
g.	hgb_correction.m (if fluor imaging)  
h.	logmean_fluor.m (if fluor imaging)  
8.	Proc2  
a.	smoothimage.m  
b.	gsr.m  
i.	regcorr.m  
9.	Affine.m  
10.	checkqc.m  
11.	OIS_GCaMP_Filter.m  
a.	highpass.m  
b.	lowpass.m  
12.	check_mvmt.m  

#### MOUSE_MASTER_FC  
13.	calc_fc.m  
a.	burnseeds.m  
b.	P2strace.m  
c.	strace2R.m  
d.	normr.m  
e.	matrix_makeover.m  
14.	visualize_fc.m  
15.	visualize_fc_matrix.m  
16.	FC_AVG.m  
17.	visualize_fc_avg.m  
a.	overlaymouse.m  
18.	visualize_fc_avg_matrix.m  
19.	cluster_threshold.m  
a.	FWHM_ParDer.m  
20.	FC_ttest.m  
21.	visualize_fc_ttest.m  
a.	overlaymouse.m  
22.	FC_Matrix_ttest.m  
23.	visualize_fc_ttest_matrix.m  
24.	prep_matrix_simple.m  
25.	visualize_fc_e_matrix.m  
26.	FC_e_Matrix_ttest.m  
27.	visualize_fc_ttest_e_matrix.m  

#### MOUSE_MASTER_BILAT  
24.	calc_bilateral.m  
a.	CalcRasterSeedsUsed.m  
b.	fcManySeed.m  
i.	makeRs.m  
c.	CalcBilateral.m  
25.	visualize_bilat.m  
26.	BILAT_FC_AVG.m  
a.	make_sym_mask.m  
27.	visualize_bilat_fc_avg.m  
a.	overlaymouse.m  
28.	cluster_threshold.m  
a.	FWHM_ParDer.m  
29.	BILAT_FC_ttest.m  
30.	visualize_bilat_fc_ttest.m  
a.	overlaymouse.m

#### MOUSE_MASTER_SVR  
31.	calc_svr.m  
32.	visualize_svr.m  
33.	SVR_AVG.m  
34.	visualize_svr_avg.m  
a.	overlaymouse.m  
35.	cluster_threshold.m  
a.	FWHM_ParDer.m  
36.	SVR_ttest.m  
37.	visualize_svr_ttest.m  
a.	overlaymouse.m  

#### MOUSE_MASTER_SPECTRAL  
38.	calc_fft.m  
39.	visualize_fft.m  
40.	band_fft.m  
41.	visualize_fft_image.m  
42.	FFT_AVG.m  
43.	visualize_fft_avg.m  
44.	FFT_MAP_AVG.m  
45.	visualize_fft_image_avg.m  
a.	overlaymouse.m  
46.	FFT_ttest.m  
47.	visualize_fft_avg_ttest.m  
48.	cluster_threshold.m  
a.	FWHM_ParDer.m  
49.	FFT_MAP_ttest.m  
50.	visualize_fft_map_ttest.m  
a.	overlaymouse.m  

#### MOUSE_MASTER_NVC  
51.	NVC_bypixel.m  
52.	visualize_nvc.m  
53.	AVG_NVC.m  
54.	visualize_nvc_avg.m  
a.	overlaymouse.m  
55.	cluster_threshold.m  
a.	FWHM_ParDer.m  
56.	NVC_ttest.m  
57.	visualize_nvc_ttest.m  
a.	overlaymouse.m

#### MOUSE_MASTER_Node   
24.	calc_fc_node.m  
25.	visualize_nodes.m  
26.	FC_Node_AVG.m  
a.	make_sym_mask.m  
27.	visualize_fc_node_avg.m  
a.	overlaymouse.m  
28.	cluster_threshold.m  
a.	FWHM_ParDer.m  
29.	FC_Node_ttest.m  
30.	visualize_fc_node_ttest.m  
a.	overlaymouse.m
