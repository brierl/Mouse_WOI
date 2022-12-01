function [FWHM]=FWHM_ParDer(file,nVx)

% script to calculate the spatial partial derivative FWHM for RFT cluster
% thresholding

% IN:
%   file: output of Proc2.m of fully processed broadfield data is loaded to calculate
%       spatial partial derivative

% OUT:
%   FWHM: number of pixels in the FWHM

load(file,'all_contrasts_fp','isbrain2')
isbrain2(isbrain2==0)=NaN;

con1=squeeze(all_contrasts_fp(:,:,1,96)).*isbrain2; % grab hgb corr gcamp and random frame, apply mask
con1_n=normalize(con1); % normalize data

[Ix, Iy] = gradient(con1_n); % calc partial derivatives across FOV
Ixx=reshape(Ix,nVx*nVx,[]);
Iyy=reshape(Iy,nVx*nVx,[]);

V=nancov(Ixx,Iyy); % calc covariance of partial derivatives
FWHM=power(4*log(2),0.5)/power(det(V),0.25); % calc FWHM