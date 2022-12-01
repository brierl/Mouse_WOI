function [fluorcorr]=hgb_correction(fluornorm,datahb,op)
% correct fluorescence for hemoglobin confound. Would need red ext
% coefficients if were to ever do RCaMP imaging... change getop.m

% IN:
%   fluornorm: fluorescence data, pixels x pixels x frames
%   datahb: hemoglobin data
%   op: optical properties

% OUT:
%   fluorcorr: corrected fluorescence data, pixels x pixels x frames
    
    exmua_init(:,:,1,:)=op.exLSextcoeff(1).*datahb(:,:,1,:); %ext coeff x oxy
    exmua_init(:,:,2,:)=op.exLSextcoeff(2).*datahb(:,:,2,:); %ext coeff x deoxy
    exmua_f=squeeze(exmua_init(:,:,1,:)+exmua_init(:,:,2,:)); %combine
    emmua_init(:,:,1,:)=op.emLSextcoeff(1).*datahb(:,:,1,:); %ext coeff x oxy
    emmua_init(:,:,2,:)=op.emLSextcoeff(2).*datahb(:,:,2,:); %ext coeff x deoxy
    emmua_f=squeeze(emmua_init(:,:,1,:)+emmua_init(:,:,2,:)); %combine

    fluorcorr=fluornorm./((exp(-(exmua_f.*(.056)+emmua_f.*(.057))))); %ex-em correction

end