function [all_contrasts2,isbrain2]= Affine(all_contrasts,isbrain,Landmarks,mice,oi)
% Perform Affine transform on data and mask

% IN:
%   all_contrasts: processed data in mouse space, oi.nVx x oi.nVy x contrast x time
%   isbrain: mask, oi.nVx x oi.nVy
%   Landmarks: specific mouse landmarks
%   mice: struct with mouse filename and processing info
%   oi: optical instrument properties

% OUT:
%   all_contrasts2: affine transformed processed data, oi.nVx x oi.nVy x contrast x time
%   isbrain2: affine transformed mask, oi.nVx x oi.nVy

%% Reference Space (Paxinos Atlas used for reference)

RMAS(1)=64*(oi.npixels/128)*(1/mice.info.spat_ds);         %Reference mouse Mid Anterior Suture x
RMAS(2)=19*(oi.npixels/128)*(1/mice.info.spat_ds);         %Reference mouse y
RLam(1)=64*(oi.npixels/128)*(1/mice.info.spat_ds);         %Reference mouse Lambda x
RLam(2)=114*(oi.npixels/128)*(1/mice.info.spat_ds);        %Reference mouse y
RB(1)=mean([RMAS(1) RLam(1)]); %bisecting x
RB(2)=mean([RMAS(2) RLam(2)]); %bisecting y
R3(1)=RB(1)+RB(2)/2;    %Third point x, center point plus half dist between suture and lambda
R3(2)=RB(2);            %Third point y,  same y coord as biscenting point

%% Input Mouse Coordinates
MLam=Landmarks.tent;        %original clicked lambda
MMAS=Landmarks.OF;          %original clicked anterior suture

MB(1)=mean([MMAS(1) MLam(1)]); %bisecting x
MB(2)=mean([MMAS(2) MLam(2)]); %bisecting y

Mang=atan2(MLam(1)-MB(1),(MLam(2)-MB(2))); %angle of bisector with respect to y axis

M3(1)=MB(1)+MB(2)/2*cos(-Mang);  %coordinates of third point, half the distance between midpoint and lambda (or anterior suture)
M3(2)=MB(2)+MB(2)/2*sin(-Mang);

%% Use coordinates to generate affine transform matrix
Refpoints=[RMAS 1; R3 1; RLam 1];
Mousepoints=[MMAS 1; M3 1; MLam 1];

W=Mousepoints\Refpoints;% transform matrix
W(1,3)=zeros;
W(2,3)=zeros;
W(3,3)=1;

%% Generate Affine transform struct and transform
% Xdata and Ydata specify output grid...
% using this centers the output image at the transformed midpoint
% now all output images will share a common anatomical center

T=maketform('affine',W);

all_contrasts2= imtransform(all_contrasts,T,'XData',[1 oi.nVx], 'YData',[1 oi.nVy], 'Size', [oi.nVx oi.nVy]);
isbrain2=imtransform(isbrain, T, 'XData',[1 oi.nVx], 'YData', [1 oi.nVy], 'Size', [oi.nVx oi.nVy]);
isbrain2(abs(isbrain2)>0)=1; % binarize in case Affine.m made non-binary

end