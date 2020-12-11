function [data2]=gsr(data,isbrain)
% perform GSR

% IN:
%   data: oi.nVx oi.nVy contrast frames data
%   isbrain: binary mask

% OUT:
%   data2: oi.nVx oi.nVy contrast frames data, w/GSR

[nVx, nVy, con, T]=size(data);

data=reshape(data,nVx*nVy,con,T);
gs=squeeze(mean(data(isbrain==1,:,:),1)); %find the global signal
[data2]=regcorr(data,gs); %regress
data2=real(reshape(data2,nVx, nVy, con, T));
        
end