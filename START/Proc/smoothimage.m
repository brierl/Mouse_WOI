function [data2]=smoothimage(data,gbox,gsigma)
% smooth with Gaussian filter

[nVy, nVx, cnum, T]=size(data);

% Gaussian box filter center
x0=ceil(gbox/2);
y0=ceil(gbox/2);

% Make Gaussian filter
G=zeros(gbox);
for x=1:gbox
    for y=1:gbox
        G(x,y)=exp((-(x-x0)^2-(y-y0)^2)/(2*gsigma^2));
    end
end

% Normalize Gaussian to 1
G=G/sum(sum(G));

% Initialize
data2=zeros(nVx,nVy,cnum,T);

% Convolve data with filter
for c=1:cnum
    for t=1:T
        data2(:,:,c,t)=conv2(squeeze(data(:,:,c,t)),G,'same');
    end
end

end