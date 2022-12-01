function [SeedsUsed]=CalcRasterSeedsUsed(isbrain)

nVx=size(isbrain, 1);

Xdim=linspace(1,nVx/2-1,nVx/2-1); % nVx/2 is defined as the center of the image (in Proc\Affine.m). LHS 1:nVx/2-1
Ydim=linspace(1,nVx,nVx);

% make list of LHS pixels aka seeds
[X, Y]=meshgrid(Xdim, Ydim);
X1=reshape(X,[],1);
Y1=reshape(Y,[],1);
Seeds.L(:,:)=[X1 Y1];

Xdim=linspace(nVx-1,nVx-nVx/2+1,nVx/2-1); % nVx/2 is defined as the center of the image (in Proc\Affine.m). RHS nVx-nVx/2+1:end (end-1 to match size of LHS)
Ydim=linspace(1,nVx,nVx);

% make list of RHS pixels aka seeds
[X, Y]=meshgrid(Xdim, Ydim);
X1=reshape(X,[],1);
Y1=reshape(Y,[],1);
Seeds.R(:,:)=[X1 Y1];

Numseeds=size(Seeds.L,1);
RasterSeeds=zeros(2*Numseeds,2);

% make list of all pixels aka seeds. Alternate between LHS and RHS
for f=1:Numseeds
    RasterSeeds(2*f-1,1)=Seeds.R(f,1);
    RasterSeeds(2*f-1,2)=Seeds.R(f,2);
    RasterSeeds(2*f,1)=Seeds.L(f,1);
    RasterSeeds(2*f,2)=Seeds.L(f,2);
end

SeedsUsed=[];
m=1;

% make list of pixels/seeds and its symmetrical pair within mask
for n=1:2:size(RasterSeeds,1)-1
    if isbrain(RasterSeeds(n,2),RasterSeeds(n,1))==1 && isbrain(RasterSeeds(n+1,2),RasterSeeds(n+1,1))==1 
        SeedsUsed(m,:)=RasterSeeds(n,:); 
        SeedsUsed(m+1,:)=RasterSeeds(n+1,:); 
        m=m+2;
    end
end

end