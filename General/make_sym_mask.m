function [isbrain2_aff]=make_sym_mask(isbrainall,oi)
% create symmetrical, group mask, oi.nVx/2 is the center of the image

% IN: 
%   isbrainall: oi.nVx x oi.nVy x n matrix of masks for n mice
%   oi: optical instrument properties

% OUT:
%   isbrain2_aff: group symmetrical mask, oi.nVx x oi.nVy

    % more conservative method
    isbrain1_aff=ones(oi.nVx,oi.nVy); %initialize

    %multiply through all masks
    for i=1:size(isbrainall,3)
        isbrain1_aff=isbrain1_aff.*isbrainall(:,:,i);
    end

%     % more liberal method
%     isbrain1_aff=nanmean(isbrainall,3);

    isbrain2_aff=NaN(oi.nVx,oi.nVy); %initialize

    %center around oi.nVx/2
    for t=1:oi.nVx
        for v=1:oi.nVy-1
            isbrain2_aff(t,(oi.nVy-v))=isbrain1_aff(t,v).*isbrain1_aff(t,(oi.nVy-v));
        end
    end

end