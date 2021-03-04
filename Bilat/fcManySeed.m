function [R_seed]=fcManySeed(data, seeds, isbrain1)

nVx=size(isbrain1,1);

data=reshape(data,nVx*nVx,[]);

% set seed size
mm=10;
mpp=mm/nVx;
seedradmm=0.25;
seedradpix=seedradmm/mpp;

strace=zeros(size(seeds,1),size(data,2));

% loop through raster seed centers
for n=1:size(seeds,1)
    P=zeros(nVx,nVx);
    xc=seeds(n,1);
    yc=seeds(n,2);
    for y=1:nVx
        for x=1:nVx
            % make seeds of size specified above
            if norm([x y]-[xc yc])<=seedradpix
                P(y,x)=1;
            end
        end
    end
    P=P.*isbrain1;
    % assign to each seed center pixel the average time trace within the
    % seed created
    strace(n,:)=mean(data(P==1,:),1);
end

% make FC matrices using all pixels as seeds
R_seed=makeRs(data,strace);
length=size(seeds,1);
% re-shift matrices so the immediate off-diagonal has LHS-RHS paired r
% see loop in CalcBilateral.m)
map=[(1:2:length-1) (2:2:length)]; 
R_seed=R_seed(map, map);

end
