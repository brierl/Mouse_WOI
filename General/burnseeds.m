function [P,xp]=burnseeds(seedcenter,seedrad,isbrain)

% burnseeds takes in center pixels for each seed region (seedcenter) and
% radius for seeds (seedrad) and creates map of seeds (P) within brain
% regions as specified within the binary mask (isbrain) 

% xp denotes if a seed is within the masked FOV (1) or not (NaN)

[nVx,nVy]=size(isbrain);
numc=size(seedcenter,1);
isbrain=rot90(isbrain);

P=zeros(nVx,nVy);

for n=1:numc
    xc=seedcenter(n,1);
    yc=seedcenter(n,2);
    for x=1:nVx
        for y=1:nVy
            if norm([x y]-[xc yc])<=seedrad
                P(x,y)=n;
            end
        end
    end
    
    P=P.*isbrain;
    if sum(find(P==n))==0
        xp(n)=NaN;
    else
        xp(n)=1;
    end
end

P=rot90(P,3); 

end