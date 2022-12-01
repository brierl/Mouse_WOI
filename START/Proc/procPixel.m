function [data_dot]=procPixel(data,op,E,numls_ois)
% logmean then perform spectroscopy

% IN:
%   data: pixels x pixels x light source channel (numls_ois) x time
%   op: optical properties
%   E: spectroscopy matrix
%   numls_ois: number of light sources 

% OUT:
%   data_dot: pixels x pixels x contrast x time. contrast=1=oxy
%       contrast=2=deoxy

    data=logmean(data);
    
    for c=1:numls_ois
        data(:,:,c,:)=squeeze(data(:,:,c,:))/op.dpf(c); %divide differential path length factor
    end
    
    %spectroscopy
    data_dot=dotspect(data,E(1:numls_ois,:));

end