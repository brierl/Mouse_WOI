function [fluorcorr]=hgb_correction(fluornorm,hem_corrnorm,datahb,corr,op)
% correct fluorescence for hemoglobin confound. Would need red ext
% coefficients if were to ever do RCaMP imaging... change getop.m

% IN:
%   gcamp6norm: fluorescence data, oi.nVx x oi.nVy x time
%   greennorm: hgb imaging channel closest to fluorescence wavelength
%       oi.nVx x oi.nVy x time
%   datahb: hemoglobin data
%   corr: correction option. default is ex-em (Ma, Hillman et al., 2016)
%   op: optical properties

% OUT:
%   gcamp6corr: corrected fluorescence data, oi.nVx x oi.nVy x time
    
    if strcmp(corr, 'ratio')
        fluorcorr=fluornorm./hem_corrnorm; %ratiometric correction
    else
        exmua_init(:,:,1,:)=op.exLSextcoeff(1).*datahb(:,:,1,:); %ext coeff x oxy
        exmua_init(:,:,2,:)=op.exLSextcoeff(2).*datahb(:,:,2,:); %ext coeff x deoxy
        exmua_f=squeeze(exmua_init(:,:,1,:)+exmua_init(:,:,2,:)); %combine
        emmua_init(:,:,1,:)=op.emLSextcoeff(1).*datahb(:,:,1,:); %ext coeff x oxy
        emmua_init(:,:,2,:)=op.emLSextcoeff(2).*datahb(:,:,2,:); %ext coeff x deoxy
        emmua_f=squeeze(emmua_init(:,:,1,:)+emmua_init(:,:,2,:)); %combine

        fluorcorr=fluornorm./((exp(-(exmua_f.*(.056)+emmua_f.*(.057))))); %ex-em correction
    end

end