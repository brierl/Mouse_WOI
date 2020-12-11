# Mouse_WOI
Mouse wide-field optical imaging processing toolbox

This software is to be used to process mesoscopic mouse wide-field optical data. Assumes that data is an image stack, pixels x pixels x frames. Please contact Lindsey Brier with any questions/potential bugs: brierl@wustl.edu. Last updated 11/06/20 . Being currently updated for high resolution scans.

GitHub5\
Mouse_Master*.m:  Wrapper scripts that perform various types of analysis. Each begin the same, Mouse_Master_Proc.m is used as an example:
To get started, edit line 7 shown below to be the path to the main directory of the software. 
Edit line 10 to excel file name (excel file explained below).
Edit line 11 to rows within the excel file to process.
image_system_info.m on line 23 is set up for imaging systems ‘fcOIS3’ and ‘fcOIS2’… Specify in System field in excel file, explained below. If you want to run data off a different imaging system, edit image_system_info.m with new optical instrument properties (outlined in image_system_info.m).
Extras
Seeds-R01-Revised.mat: 26 Canonical seeds corresponding to Olfactory, Frontal, Cingulate, Motor, Somatosensory, Retrosplenial, Visual, Auditory, and Parietal cortices.
GOOD_AFF_WL.mat: White light image for overlaying results. Affine transformed.
Excel file:
Date: YYMMDD format
Mouse: Alphanumeric name per mouse
Session_Type: ‘fc’ for resting state or ‘stim’
Run: imaging run numbers. Separate by commas e.g. 1,2,3…
System: Imaging system data is collected on. E.g. ‘fcOIS3’ or ‘fcOIS2’. 
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
alpha: p<alpha will be regarded statistically significant (uncorrected for multiple comparisons). Example =0.05
Vid fr: framerate for video playback. Example =16.8
quality: video quality. Example =25
Vid frames: selected frames to put in video, ; separated. Example =1;500
Length block (s): seconds per epoch for FFT calculation. Example =10
StD cutoff: number of standard deviations above the mean to threshold GVTD trace. Example =1
Option: Hgb correction option. Options either ratio or ex-em. Example =ex-em
Notes:
***For averaging purposes (later), format excel documents so all mice that are going to be averaged together are in sequential lines. Mice in different groups should be separated by at least one line. ***
Function List (All wrappers): 
1.	excel_reader.m
2.	image_system_info.m
MOUSE_MASTER_PROC
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
1.	datacondition.m
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
