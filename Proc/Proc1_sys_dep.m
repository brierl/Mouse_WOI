function [rawdata_f,fulldetrend,all_contrasts,WL]=Proc1_sys_dep(rawdata,dark,mice,oi)
% process data, system dependent mode...

% IN: 
%   rawdata: pixels x pixels x frames data from camera
%   dark: ambient light, frame to subtract from raw data
%   mice: struct containing mouse filename and processing info
%   oi: struct containing optical instrument information

% OUT:
%   rawdata_f: light levels. pixels x pixels x LS channel x time
%   fulldetrend: detrended data. pixels x pixels x LS channel x time
%       affine transformed
%   all_contrasts: pixels x pixels x contrast x frames, processed data
%   WL: mouse specific WL

    % Get optical properties (Extinction/absorption coefficients, etc)
    disp('Getting Optical Properties')
    [op, E]=getop(oi);

    % Dark frame subtraction
    [raw_nodark]=subtract_dark_ois(rawdata,dark);
    
    % Temporal downsample
    [raw_nd_rs]=temporal_ds_ois(raw_nodark,mice,oi);

    % Reshape the data, adding a dimension for individiual LS channels
    raw_nd_rs_rs=reshape(raw_nd_rs,oi.nVy,oi.nVx,oi.numls,[]);
    
    % Cut off bad first set of frames
    rawdata_f=raw_nd_rs_rs(:,:,:,11:(end-10)); % newer data we decided we can dump more frames
    clear raw_nd_rs_rs

    % Make white light image ("normal"-looking picture of the skull)
    frameone=double(rawdata_f(:,:,:,2));
    WL(:,:,1)=frameone(:,:,2)/max(max(frameone(:,:,2)));
    WL(:,:,2)=frameone(:,:,3)/max(max(frameone(:,:,3)));
    WL(:,:,3)=frameone(:,:,4)/max(max(frameone(:,:,4)));
    
    % detrend in space and time
    [fulldetrend]=detrend_ois(rawdata_f);
    
    % Separate light source channels for various processing
    if oi.numls_ois>1 %can do oximetry then...
        rawdata_ois=real(fulldetrend(:,:,oi.ois_pos,:)); %grab hgb light sources
        % "Process" the data--procPixel used for oximetry
        disp('Processing Hgb Pixels')
        [datahb]=procPixel(rawdata_ois,op, E, oi.numls_ois);

        datahb(isnan(datahb))=0;
        datahb(isinf(datahb))=0;
    else
        datahb=[]; %can't do oximetry...
    end
    
    if oi.numls-oi.numls_ois>0 %if there are light sources for not hgb... but for gcamp etc.
        fluor=real(double(squeeze(fulldetrend(:,:,oi.em_pos,:)))); %grab emission channel (excitation light source)

        % log mean GCaMP data                   
        fluor_lm=logmean_fluor(fluor);

        fluor_lm(isnan(fluor_lm))=0;
        fluor_lm(isinf(fluor_lm))=0;

        if oi.numls>1 %if you have more than just the excitation source, you can at least ratio correct gcamp, if not ex-em
            % NOTE IF YOU CAN'T DO OXIMETRY AND TRY TO DO EX-EM CORRECTION
            % SCRIPT WILL FAIL. 
            
            hem_corr=double(squeeze(fulldetrend(:,:,oi.hem_corr_pos,:))); %green for gcamp, red for rcamp etc.
            
            %mean normalize
            [fluornorm]=mean_normalize(fluor);
            [hem_corrnorm]=mean_normalize(hem_corr);

            %correct for hemoglobin
            [fluorcorr]=hgb_correction(fluornorm,hem_corrnorm,datahb,mice.info.hgb_corr,op);

            % log mean GCaMP data                   
            fluorcorr=logmean_fluor(fluorcorr);

            fluorcorr(isnan(fluorcorr))=0;
            fluorcorr(isinf(fluorcorr))=0;

            %concatanate data
            fluors=cat(4,fluorcorr,fluor_lm);
            all_contrasts=real(cat(3,permute(fluors,[1 2 4 3]),datahb));
        else
            all_contrasts=real(permute(fluor_lm,[1 2 4 3]));
        end
    else
        all_contrasts=real(datahb);
    end
    
end

%% getop()
function [op, E, numls, ls]=getop(oi)

[lambda1, Hb]=getHb; % read prahl ext coeff file
[ls,lambda2]=getLS(oi); % get light source spectra
   
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
function [ls, lambda]=getLS(oi)
    
    for i=1:length(oi.ls)
        ls{i}.name=oi.ls{i}.name; % light source spectra filename
    end
    
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
