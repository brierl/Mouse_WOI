function [R]=strace2R(strace,data,xp)

% strace2R takes in an average time trace from pixels within a seed region (strace) and
% calculates Pearson Corr Coeff (R) with all pixel time traces (data)

switch ndims(data)
    case 2
        [nVt,T]=size(data);
        
        nVx=sqrt(nVt);
        nVy=nVx;
    case 3
        [nVx,nVy,T]=size(data);
end

data=reshape(data,nVx*nVy,T);

[numc,~]=size(strace);

for i=1:numc
    if xp(i)==1
        Rnew(:,i)=normr(data)*normr(strace(i,:))';
    else
        Rnew(:,i)=NaN(nVx*nVy,1);
    end
end

R=reshape(Rnew,nVx,nVy,numc);

end