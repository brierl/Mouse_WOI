function [I, seedcenter]=MakeSeedsMouseSpace(WL)
% make seeds for each mouse. Called by createSeeds.m
% This function calculates the locations of the predefinded seeds in atlas
% space and maps them to mouse space. "seedcenter" contains the locations
% of the seeds in mouse space, and I contains the landmark locations

% IN:
%   WL: mouse specific frame

% OUT:
%   I: mouse space landmark locations
%   seedcenter: mouse space seeds

%% GetLandmarks for mouse
WLfig=figure;

imagesc(WL); colormap gray;
axis image;

nVx=size(WL,1);
nVy=nVx;

disp('Click Anterior Midline Suture Landmark');
% save input
[x y]=ginput(1);
x=round(x);
y=round(y);

OF(1)=x;
OF(2)=y;

disp('Click Lambda');
% save input
[x y]=ginput(1);
x=round(x);
y=round(y);

T(1)=x;
T(2)=y;

%% Get Seeds according to Atlas Space 
[Seeds, L]=Seeds_PaxinosSpace;  % Atlas space 16 seed map

F=fieldnames(Seeds);
numf=numel(F);


%% Transform atlas seeds to mouse space
adist=norm(L.of-L.tent);    %Paxinos Space
idist=norm(OF-T);           %Mouse Space

aa=atan2(L.of(1)-L.tent(1),L.of(2)-L.tent(2));  %Angle in Paxinos Space
ia=atan2(OF(1)-T(1),OF(2)-T(2));                %Angle in Mouse Space
da=ia-aa;                           %Mouse-Paxinos

pixmm=idist/adist;                  %Mouse/Pax
R=[cos(da) -sin(da) ; sin(da) cos(da)];

I.bregma=pixmm*(L.bregma*R);
I.tent=pixmm*(L.tent*R);
I.OF=pixmm*(L.of*R);

t=T-I.tent;             %translation=mouse-Paxinos

I.bregma=I.bregma+t;
I.tent=I.tent+t;
I.OF=I.OF+t;

F=fieldnames(Seeds.R);
numf=numel(F);

% fill in I.Seeds struct with LHS and RHS seeds
for f=1:numf
    N=F{f};
    I.Seeds.R.(N)=round(pixmm*Seeds.R.(N)*R+I.bregma);
    I.Seeds.L.(N)=round(pixmm*Seeds.L.(N)*R+I.bregma);
end

seedcenter=zeros(2*numf,2);

% make matrix of LHS and RHS seeds, alternating
for f=0:numf-1
    N=F{f+1};
    seedcenter(2*(f+1)-1,1)=I.Seeds.R.(N)(1);
    seedcenter(2*(f+1)-1,2)=I.Seeds.R.(N)(2);
    seedcenter(2*(f+1),1)=I.Seeds.L.(N)(1);
    seedcenter(2*(f+1),2)=I.Seeds.L.(N)(2);
end

end


