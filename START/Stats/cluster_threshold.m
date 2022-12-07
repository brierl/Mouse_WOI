function [threshold]=cluster_threshold(all_contrasts,alpha,isbrain)
% script to calculate cluster based threshold for significance (RFT) using
% a pixel wise false error rate of 0.001

% IN:
%   all_contrasts: fully processed broadfield data is loaded to calculate
%       spatial partial derivative
%   alpha: probability alpha, the overall FWE
%   isbrain: binary brain mask

% OUT:
%   threshold: cluster size threshold in number of pixels

N=size(all_contrasts,1)*size(all_contrasts,2); % number of pixels
FWHM=FWHM_ParDer(all_contrasts,size(all_contrasts,1),isbrain); % from spatial partial derivatives
% FWHM=FWHM_SpAut(file,pix_x); % from spatial autocorrelation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Zth=linspace(2.5,5,500); % Zth=3.09 at i=119, where p_pixel=0.001
Rtotal=N/(power(FWHM,2)); % total number of resolution elements in a 2D image
i=1;
for Z=Zth
    E(i)=Rtotal*(4*log(2))*power((2*pi),-3/2)*Z*exp(power(Z,2)*-1/2); % expected Euler characteristic
    i=i+1;
end

K=linspace(1,500,500); % sweep cluster size threshold
i=1;

for Z=Zth

    Beta=gamma(2)*power(Z,2)*(4*log(2))/(2*pi*power(FWHM,2));
    prob=1-exp(-1*E(i)*exp(-1*Beta*K)); % P(nmax>k)

    prob_thresh_pt05(i)=(1/Beta)*log((-1*E(i))/log(1-0.05)); % K for alpha=0.05      prob_thresh_pt05(119) at command line to find K for Zth=3.09
    prob_thresh_pt1(i)=(1/Beta)*log((-1*E(i))/log(1-0.1)); % K for alpha=0.1
    prob_thresh_pt01(i)=(1/Beta)*log((-1*E(i))/log(1-0.01)); % K for alpha=0.01
    prob_thresh_pt001(i)=(1/Beta)*log((-1*E(i))/log(1-0.001)); % K for alpha=0.001
    i=i+1;
    
    clear Beta prob

end

% select correct threshold for user specified alpha
if alpha==0.05
    threshold=prob_thresh_pt05(119);
elseif alpha==0.01
    threshold=prob_thresh_pt01(119);
elseif alpha==0.001
    threshold=prob_thresh_pt001(119);
elseif alpha==0.1
    threshold=prob_thresh_pt1(119);
else
    disp('pick an alpha of 0.05 0.01 0.001 or 0.1')
end