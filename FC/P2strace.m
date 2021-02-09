function [strace]=P2strace(P,data,xp)

% P2strace takes in seed image (P) and data (data) and creates an average 
% time trace (strace) using pixels within the seed region. xp==1 means seed
% is within FOV

switch ndims(data)
    case 2
        [nVt,T]=size(data);
        
        nVx=sqrt(nVt);
        nVy=nVx;
    case 3
        [nVx,nVy,T]=size(data);
end

data=reshape(data,nVx*nVy,T);

numc=length(xp);

for n=1:numc
    
    if xp(n)==1
        k=find(P==n);
        strace(n,:)=mean(data(k,:),1);
    else
        strace(n,:)=NaN(1,T);
    end

end

end