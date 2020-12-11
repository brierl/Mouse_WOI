function [FWHM]=FWHM_SpAut(file,nVx)

% script to calculate the spatial autocorrelation FWHM for RFT cluster
% thresholding

% IN:
%   file: first mouse BroadField processing data is loaded to calculate
%       spatial autocorrelation

% OUT:
%   FWHM: number of pixels in the FWHM

load(file,'all_contrasts2','isbrain2')
isbrain2(isbrain2==0)=NaN;

con1=squeeze(all_contrasts2(:,:,1,96)).*isbrain2; % grab hgb corr gcamp and random frame, apply mask
con1_rs=reshape(con1,nVx*nVx,[]);

% loop through pixels
for j=1:nVx
    for i=1:nVx
    
        blank=NaN(nVx,nVx);
        blank(j:nVx,i:nVx)=con1(1:(nVx-j+1),1:(nVx-i+1)); % make shifted image
    
        shift=reshape(blank,nVx*nVx,[]);

        corrs(j,i)=corr(con1_rs,shift,'rows','complete'); % calc spatial autocorrelation
    
        clear blank shift
    
    end
end

thresh=max(max(corrs))/sqrt(2); % threshold for FWHM
corrs(corrs<thresh)=0; % get rid of corrs below threshold
[row, col]=find(corrs==0); % find y FWHM
[row2, col2]=find(corrs'==0); % find x FWHM
if row(1)>row2(1) % use bigger FWHM to be safe
    row_f(1)=row(1);
else
    row_f(1)=row2(1);
end

FWHM=2*(row_f(1)-1);