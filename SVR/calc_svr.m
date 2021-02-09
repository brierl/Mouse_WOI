function [SVR1]=calc_svr(all_contrasts2,isbrain2,seedcenter,oi)

% script to calculate SVR prediction weight matrices per seed used in FC analysis 

% IN:
%   all_contrasts2: oi.nVx, oi.nVy, contrast, time. processed data
%   isbrain2: pixel x pixel binary mask signifying brain regions
%   seedcenter: seed numbers x 2 x,y coordinates file for seed centers
%   oi: optical instrument properties

% OUT:
%   SVR1: weight maps pix x pix x seeds x contrasts
            
    isbrain2(isbrain2==0)=NaN; % Need to get rid of non-brain regions below
    % apply mask, isolate user specified contrasts
    all_contrasts2=all_contrasts2(:,:,oi.con_num,:).*isbrain2;

    % assign seed size
    mm=10;
    mpp=mm/oi.nVx;
    seedradmm=0.25;
    seedradpix=seedradmm/mpp;

    % make image P with numbered seeds in clusters
    [P]=burnseeds(seedcenter,seedradpix,isbrain2);
    P(P==0)=NaN; % need to get rid of non-seed regions below
    P=fliplr(P).*isbrain2; % apply mask

    % make a list of seed numbers within the FOV from the mask
    check=unique(P);
    check2=isnan(check);
    for p=1:length(check)
        if check2(p)==0
            seeds(p)=check(p);
        end
    end

    % loop through contasts specified in oi.con_num
    for ii=1:size(all_contrasts2,3)
        % make an SVR map for each seed
        for j=1:size(seedcenter,1)

            % check if seed inside FOV
            if ismember(j,seeds)

                roi=NaN(oi.nVx);
                xroi=NaN(oi.nVx);

                roi(P==j)=1; % find seed region
                y1=squeeze(all_contrasts2(:,:,ii,:)).*roi; % isolate seed region in gcamp data
                y1=normalize(squeeze(nanmean(squeeze(nanmean(y1,1)),1))); % normalize

                xroi(P~=j)=1; % find all non-seed regions
                xroi=xroi.*isbrain2; % only keep non-seed regions within the mask

                x1=squeeze(all_contrasts2(:,:,ii,:)).*xroi; % isolate non-seed regions in gcamp data
                loc_x1=find(~isnan(xroi)); % find non-seed region indices
                x1=x1(~isnan(x1)); % extract non-seed region data, get rid of NaNs
                x1=reshape(x1,nansum(nansum(xroi)),[]); % reshape for SVR

                Mdl1 = fitrsvm(x1',y1','KernelFunction','linear'); % perform SVR on GCaMP data, use non-parametric kernel functions
                weights=Mdl1.Beta; % prediction weights saved in .Beta
                weight_map=zeros(oi.nVx,oi.nVy); 
                weight_map=reshape(weight_map,oi.nVx*oi.nVy,[]);
                weight_map(loc_x1)=weights; % assign weights to non-seed region indices
                weight_map=reshape(weight_map,oi.nVx,oi.nVy,[]);
                SVR1(:,:,j,ii)=weight_map;

                clear roi xroi y1 x1 Mdl1 weights weight_map

            else
                % if seed outside FOV
                SVR1(:,:,j,ii)=NaN(oi.nVx,oi.nVy);

            end
        end
    end

end

