function [all_contrasts2,isbrain2]= Affine(all_contrasts,isbrain,I)
% Perform Affine transform on data and mask

% IN:
%   all_contrasts: processed data in mouse space, pixels x pixels x
%       contrast x frames
%   isbrain: mask, pixels x pixels
%   I: specific mouse landmarks from seeds file

% OUT:
%   all_contrasts2: affine transformed processed data, pixels x pixels x
%       contrast x frames
%   isbrain2: affine transformed mask, pixels x pixels

%% Reference Space (Paxinos Atlas used for reference)

RMAS(1)=64*(156/128);         %Reference mouse Mid Anterior Suture x (156/128) correction term from our system pixels = 156 and original affine script written when pixels = 128
RMAS(2)=19*(156/128);         %Reference mouse y
RLam(1)=64*(156/128);         %Reference mouse Lambda x
RLam(2)=114*(156/128);        %Reference mouse y
RB(1)=mean([RMAS(1) RLam(1)]); %bisecting x
RB(2)=mean([RMAS(2) RLam(2)]); %bisecting y
R3(1)=RB(1)+RB(2)/2;    %Third point x, center point plus half dist between suture and lambda
R3(2)=RB(2);            %Third point y,  same y coord as biscenting point

%% Input Mouse Coordinates
MLam=I.tent;        %original clicked lambda
MMAS=I.OF;          %original clicked anterior suture

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

all_contrasts2= imtransform(all_contrasts,T,'XData',[1 156], 'YData',[1 156], 'Size', [156 156]); %156 for pixels in FOV
isbrain2=imtransform(isbrain, T, 'XData',[1 156], 'YData', [1 156], 'Size', [156 156]);
isbrain2(abs(isbrain2)>0)=1; % binarize in case Affine.m made non-binary

end