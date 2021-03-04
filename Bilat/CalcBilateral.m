function [BiCorIm]=CalcBilateral(R_LR,SeedsUsed,isbrain)

nVx=size(isbrain,1);
numseeds=size(R_LR,1);
bilatdiag=numseeds/2;
BiCorIm=zeros(nVx,nVx);

j=1;
m=bilatdiag;

% move LHS seeds back to LHS, RHS to RHS
for n=1:bilatdiag
    m=m+1;
    BiCorIm(SeedsUsed(j,2),SeedsUsed(j,1))=R_LR(m,n);
    BiCorIm(SeedsUsed(j+1,2),SeedsUsed(j+1,1))=R_LR(m,n);
    j=j+2;
end

end
