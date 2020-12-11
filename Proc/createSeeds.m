function [I,seedcenter]=createSeeds(frameall)
% create seeds for each mouse

% IN: 
%   frameall: frame from first run of a mouse, used to click/find landmarks

% OUT:
%   I: mouse space landmark locations
%   seedcenter: mouse space seeds

% (c) 2020 Washington University in St. Louis
% All Rights Reserved

    g=1;
    while g==1 % true until user selects they are happy with seeds
        
        % create seeds
        [I,seedcenter]=MakeSeedsMouseSpace(frameall);
  
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
end