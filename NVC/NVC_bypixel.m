function [corroxyg6,lagsoxyg6,r,all_lags]=NVC_bypixel(all_contrasts2,isbrain2,oi,mice)

% script to calculate lags between gcamp and oxy per pixel to acheive 
% maximum correlation between the 2 contrasts. Uses transfer function

% IN:
%   all_contrasts2: oi.nVx, oi.nVy, contrast, time. processed data
%   isbrain2: pixel x pixel binary mask signifying brain regions
%   oi: optical instrument properties
%   mice: struct containing all filename and processing info for a mouse

% OUT:
%   corroxyg6: pixels x frame shifts correlations between contrast 1 and 2
%   lagsoxyg6: pixels x frame lag shifts to create corroxyg6
%   r: pixels x pixels image of maximum correlation between contrasts 1 and
%       2 post lag shift
%   all_lags: pixels x pixels image of lag shifts necessary to create
%       maximum correlation (r) in seconds

if length(oi.con_num)~=2
    disp('submit 2 and only 2 contrasts for nvc analysis')
else
    gcamp=all_contrasts2(:,:,oi.con_num(1),:); % or contrast 1
    oxy=all_contrasts2(:,:,oi.con_num(2),:); % or contrast 2
    straceGCAMPc=real(reshape(gcamp,oi.nVx*oi.nVy,[]));
    straceOxy=real(reshape(oxy,oi.nVx*oi.nVy,[]));
    
    % loop through all pixels, find cross correlation
    for q=1:oi.nVx*oi.nVy
        [corroxyg6(q,:), lagsoxyg6(q,:)]=xcorr(straceGCAMPc(q,:), straceOxy(q,:),(oi.framerate/mice.info.temp_ds)*5,'coeff'); % search for corr in 5 sec window
    end
    
    interp_spline=zeros(oi.nVx,oi.nVy,((oi.framerate/mice.info.temp_ds)*10+1)*mice.interp); % make matrix for interpolation
    interp_points=linspace(-(oi.framerate/mice.info.temp_ds)*5,(oi.framerate/mice.info.temp_ds)*5,((oi.framerate/mice.info.temp_ds)*10+1)*mice.interp); % shifts for interpolation
    corr=reshape(corroxyg6,oi.nVx,oi.nVy,[]);
    lags=reshape(lagsoxyg6,oi.nVx,oi.nVy,[]);

    % loop through pixels
    for k=1:oi.nVx
        for q=1:oi.nVy
            if isbrain2(k,q)==1 % if within mask
                % isolate pixel
                x=squeeze(lags(k,q,:));
                y=squeeze(corr(k,q,:));
                interp_spline(k,q,:)=spline(x,y,interp_points); % interpolate lags 
                [r(k,q), t(k,q)]=max(interp_spline(k,q,:),[],3); % find max corr and lag
                all_lags(k,q)=(interp_points(1,t(k,q)))/(oi.framerate/mice.info.temp_ds); % convert to seconds
            else % not within mask
                interp_spline(k,q,:)=NaN;
                r(k,q)=NaN;
                t(k,q)=NaN;
                all_lags(k,q)=NaN;
            end
        end
    end
    
end
                