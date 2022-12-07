function [FWHM]=FWHM_ParDer(all_contrasts,nVx,isbrain)

% script to calculate the spatial partial derivative FWHM for RFT cluster
% thresholding

% IN:
%   all_contrasts: fully processed broadfield data is loaded to calculate
%       spatial partial derivative
%   nVx: number of pixels in 1 dimension
%   isbrain: binary brain mask

% OUT:
%   FWHM: number of pixels in the FWHM

isbrain(isbrain==0)=NaN;

con1=squeeze(all_contrasts(:,:,1,96)).*isbrain; % grab hgb corr gcamp and random frame, apply mask
con1_n=normalize(con1); % normalize data

[Ix, Iy] = gradient(con1_n); % calc partial derivatives across FOV
Ixx=reshape(Ix,nVx*nVx,[]);
Iyy=reshape(Iy,nVx*nVx,[]);

V=nancov(Ixx,Iyy); % calc covariance of partial derivatives
FWHM=power(4*log(2),0.5)/power(det(V),0.25); % calc FWHM