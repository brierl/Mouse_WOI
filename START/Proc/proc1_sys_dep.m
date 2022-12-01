function [all_contrasts,WL]=proc1_sys_dep(frames,dark)
% 1 of 2 main processing scripts (follow with proc2.m). Process data, system dependent part...

% IN: 
%   frames: pixels x pixels x frames data from load_data.m
%   dark: ambient light, pixels x pixels frame to subtract from raw data

% OUT:
%   all_contrasts: pixels x pixels x contrast x frames, processed data
%   WL: mouse specific WL

    % Get optical properties (Extinction/absorption coefficients, etc)
    disp('Getting Optical Properties')
    [op, E]=getop();

    % Dark frame subtraction
    [raw_nodark]=subtract_dark_ois(frames,dark);

    % make image data reshapeable into frames per light source channel
    [~, ~, L]=size(raw_nodark);
    L2=L-rem(L,4); %4 for number of LEDs therefore light channels
    raw_nodark_rs=raw_nodark(:,:,1:L2);

    % Reshape the data, adding a dimension for individiual LS channels
    raw_nd_rs_rs=reshape(raw_nodark_rs,size(raw_nodark_rs,1),size(raw_nodark_rs,2),4,[]); %4 for number of ls
    
    % Cut off bad first set of frames
    rawdata_f=raw_nd_rs_rs(:,:,:,11:(end-10)); % newer data we decided we can dump more frames
    clear raw_nd_rs_rs raw_nodark raw_nodark_rs

    % Make white light image ("normal"-looking picture of the skull)
    frameone=double(rawdata_f(:,:,:,2));
    WL(:,:,1)=frameone(:,:,2)/max(max(frameone(:,:,2)));
    WL(:,:,2)=frameone(:,:,3)/max(max(frameone(:,:,3)));
    WL(:,:,3)=frameone(:,:,4)/max(max(frameone(:,:,4)));
    
    % detrend in space and time
    [fulldetrend]=detrend_ois(rawdata_f);
    
    rawdata_ois=real(fulldetrend(:,:,[2:4],:)); %grab hgb light sources, Culver systems fire BGYR so are ls 2-4
    
    % "Process" the data--procPixel used for oximetry
    disp('Processing Hgb Pixels')
    [datahb]=procPixel(rawdata_ois,op, E, 3); %3 for number of ls used for oximetry, on our system there are 3 (GYR)
    datahb(isnan(datahb))=0;
    datahb(isinf(datahb))=0;
    
    fluor=real(double(squeeze(fulldetrend(:,:,1,:)))); %grab emission channel (excitation light source), is first channel (BGYR)

    % log mean GCaMP data, uncorrected for hgb                
    fluor_lm=logmean_fluor(fluor);
    fluor_lm(isnan(fluor_lm))=0;
    fluor_lm(isinf(fluor_lm))=0;

    %excitation emission hemoglobin correction of gcamp data (Ma, Hillman
    %et al., 2016)
    %mean normalize
    [fluornorm]=mean_normalize(fluor);

    %correct for hemoglobin
    [fluorcorr]=hgb_correction(fluornorm,datahb,op);

    % log mean GCaMP data                   
    fluorcorr_lm=logmean_fluor(fluorcorr);
    fluorcorr_lm(isnan(fluorcorr_lm))=0;
    fluorcorr_lm(isinf(fluorcorr_lm))=0;

    %concatanate data
    fluors=cat(4,fluorcorr_lm,fluor_lm);
    all_contrasts=real(cat(3,permute(fluors,[1 2 4 3]),datahb));
    
end

%% getop()
function [op, E, numls, ls]=getop()

[lambda1, Hb]=getHb; % read prahl ext coeff file
[ls,lambda2]=getLS(); % get light source spectra
   
op.HbT=76*10^-3; % uM concentration
op.sO2=0.71; % Oxygen saturation (%/100)
op.BV=0.1; % blood volume (%/100)

op.nin=1.4; % Internal Index of Refraction
op.nout=1; % External Index of Refraction
op.c=3e10/op.nin; % Speed of Light in the Medium
op.musp=10; % Reduced Scattering Coefficient

numls=size(ls,2);

for n=1:numls                                                            
    
    % Interpolate from Spectrometer Wavelengths to Reference Wavelengths
    ls{n}.lspower=interp1(lambda2,ls{n}.spectrum,lambda1,'pchip');
    
    % Normalize
    ls{n}.lspower=ls{n}.lspower/max(ls{n}.lspower);
    
    % Zero Out Noise
    ls{n}.lspower(ls{n}.lspower<0.01)=0;
    
    % Normalize
    ls{n}.lspower=ls{n}.lspower/sum(ls{n}.lspower);
    
    % Absorption Coeff.
    op.mua(n)=sum((Hb(:,1)*op.HbT*op.sO2+Hb(:,2)*op.HbT*(1-op.sO2)).*ls{n}.lspower);
    
    % Diffusion Coefficient
    op.gamma(n)=sqrt(op.c)/sqrt(3*(op.mua(n)+op.musp));
    op.dc(n)=1/(3*(op.mua(n)+op.musp));
    
    % Spectroscopy Matrix
    E(n,1)=sum(Hb(:,1).*ls{n}.lspower);
    E(n,2)=sum(Hb(:,2).*ls{n}.lspower);
    
    % Differential Pathlength Factors
    op.dpf(n)=(op.c/op.musp)*(1/(2*op.gamma(n)*sqrt(op.mua(n)*op.c)))*(1+(3/op.c)*op.mua(n)*op.gamma(n)^2);

end
    %if ever do RCaMP imaging, change ex-em Hb indices
    op.exLSextcoeff(1)=Hb(103,1);% 454nm ex
    op.exLSextcoeff(2)=Hb(103,2);
    op.emLSextcoeff(1)=Hb(132,1);% 512nm em
    op.emLSextcoeff(2)=Hb(132,2);
   
end


function [lambda, Hb]=getHb

    data=dlmread('prahl_extinct_coef.txt'); % list of extinction coefficients

    lambda=data(:,1);
    c=log(10)/10^3; % convert: (1) base-10 to base-e and (2) M^-1 to mM^-1
    Hb=c*squeeze(data(:,2:3));

end

%% getLS()
function [ls, lambda]=getLS()
    
    ls{1}.name='190122_Mightex_530nm_Pol_OIS3'; % OIS3
    ls{2}.name='190122_Mightex_590nm_Pol_OIS3'; % OIS3
    ls{3}.name='190122_Mightex_625nm_Pol_OIS3'; % OIS3
    
    numls=size(ls,2);
    % Read in LED spectra data from included text files
    for n=1:numls

            fid=fopen([ls{n}.name, '.txt']);
            temp=textscan(fid,'%f %f','headerlines',17);
            fclose(fid);
            lambda=temp{1};
            ls{n}.spectrum=abs(temp{2});

    end

end