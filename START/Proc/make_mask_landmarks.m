function [I,seedcenter]=make_mask_landmarks(frame5, mask_savename, lmark_savename)
% create mask and mark landmarks (used for affine transform) for each mouse
% landmarks also used to create seed set (can be used for FC analysis)

% IN: 
%   frame5: frame from first run of a mouse, normalized and loaded in load_data.m, used to click/find landmarks
%   mask_savename: string filename for binary mask e.g., 'mask_mouse1'
%   lmark_savename: string filename for landmark file e.g., 'lmark_mouse1'

% OUT:
%   isbrain: binary pixels x pixels file of brain, non-brain regions in FOV
%   I: mouse space landmark locations
%   seedcenter: mouse space seeds

    % make mask, frame will pop-up
    disp('click to trace around brain... double click to make mask...')
    isbrain=double(roipoly(frame5));
    save([mask_savename '.mat'],'isbrain');
    pause(0.5); close all;

    % program will ask you to click anterior suture, then lambda,
    % will display a set of 16 seeds, if it looks good, click yes. If
    % want to re-do, click no and it will let you try again.

    % frame will ask you to click on landmarks as prompted by the MATLAB
    % command line. Based on those landmarks, seeds will appear within each
    % cortical region. Symmetry of seeds is based on accuracy of landmark
    % selection. Can try multiple times.
    g=1;
    while g==1 % true until user selects they are happy with seeds
        
        % create seeds
        [I,seedcenter]=MakeSeedsMouseSpace(frame5);
  
        % plot seeds
        for f=1:size(seedcenter,1)
            hold on;
            plot(seedcenter(f,1),seedcenter(f,2),'ko','MarkerFaceColor','k')
        end
        
        % menu appear
        choice = menu('Happy with Seeds?','Yes','No');            
        pause(0.5);  
        
        if choice==1 % if yes
            g=2; % while loop now false
        end
        
    end
    
    save([lmark_savename '.mat'],'I', 'seedcenter');
    pause(0.5); close all;

end

function [I, seedcenter]=MakeSeedsMouseSpace(WL)
% make seeds for each mouse. Called by make_mask_landmarks.m
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
    [Seeds, L]=Seeds_PaxinosSpace; % Atlas space 16 seed map
    
    F=fieldnames(Seeds);
    numf=numel(F);
    
    
    %% Transform atlas seeds to mouse space
    adist=norm(L.of-L.tent);    %Paxinos Space
    idist=norm(OF-T);           %Mouse Space
    
    aa=atan2(L.of(1)-L.tent(1),L.of(2)-L.tent(2)); %Angle in Paxinos Space
    ia=atan2(OF(1)-T(1),OF(2)-T(2)); %Angle in Mouse Space
    da=ia-aa; %Mouse-Paxinos
    
    pixmm=idist/adist; %Mouse/Pax
    R=[cos(da) -sin(da) ; sin(da) cos(da)];
    
    I.bregma=pixmm*(L.bregma*R);
    I.tent=pixmm*(L.tent*R);
    I.OF=pixmm*(L.of*R);
    
    t=T-I.tent; %translation=mouse-Paxinos
    
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

function [Seeds, L]=Seeds_PaxinosSpace

% reference seed coordinates in Paxinos space

% Seeds (x,y)
% L landmarks (x,y)

    Seeds.R.Olf=[0.72 3.8];
    Seeds.R.Fr=[1.3 3.3];
    Seeds.R.Cing=[0.3 1.8];
    Seeds.R.M=[1.5 2];
    Seeds.R.SS=[3.2 -0.5];
    Seeds.R.Ret=[0.5 -2.1];
    Seeds.R.V=[2.4 -4];
    Seeds.R.Aud=[4.2 -2.7];
    
    Seeds.L.Olf=[-0.72 3.8];
    Seeds.L.Fr=[-1.3 3.3];
    Seeds.L.Cing=[-0.3 1.8];
    Seeds.L.M=[-1.5 2];
    Seeds.L.SS=[-3.2 -0.5];
    Seeds.L.Ret=[-0.5 -2.1];
    Seeds.L.V=[-2.4 -4];
    Seeds.L.Aud=[-4.2 -2.7];
    
    L.bregma=[0 0];
    L.tent=[0 -3.9];
    L.of=[0 3.525];

end