function [raw_nd_rs]=temporal_ds_ois(raw_nodark,mice,oi)
% resample data temporally

% IN:
%   raw_nodark: oi.nVx x oi.nVy x frames image stack with dark frame
%       subtracted
%   mice: struct containing mice filename and processing info
%   oi: optical instrument properties

% OUT:
%   raw_nd_rs: oi.nVx x oi.nVy x frames image stack temporally downsampled

    temp=reshape(raw_nodark,oi.nVx*oi.nVy*oi.numls,[]); % initialize so second dim is frames per LS
    % temporally downsample
    raw_nd_rs=resample(permute(temp,[2 1]),power(10,oi.fp),mice.info.temp_ds*power(10,oi.fp));
    raw_nd_rs=permute(raw_nd_rs,[2 1]); %reshape
    raw_nd_rs=reshape(raw_nd_rs,oi.nVx,oi.nVy,[]); %reshape
    clear raw_nodark
    
end