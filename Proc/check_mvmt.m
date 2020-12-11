function [fhandle,rmsc]=check_mvmt(contrast,isbrain2,mice,oi)  
% qc imaging data, looks at GVTD

% IN:
%   contrast: oi.nVx x oi.nVy x time
%   isbrain2: mask oi.nVx x oi.nVy
%   mice: struct containing mouse filename and processing info
%   oi: optical instrument properties

% OUT:
%   fhandle: figure handle
        
        fhraw=figure('Units','inches','Position',[15 3 10 7], 'PaperPositionMode','auto','PaperOrientation','Landscape');
        set(fhraw,'Units','normalized','visible','on');
        
        plotedit on
        fhandle=gcf;
        isbrain_rs=logical(reshape(isbrain2,oi.nVx*oi.nVy,[]));       
       
        %% pixels by time
        
        % create x-axis, ticks
        t=floor(linspace(0,(length(contrast)+1)/(oi.framerate/mice.info.temp_ds),10)*(oi.framerate/mice.info.temp_ds));
        tl=floor(linspace(0,(length(contrast)+1)/(oi.framerate/mice.info.temp_ds),10));
        
        contrast=reshape(contrast,oi.nVx*oi.nVy,[]);
        
        % subtract mean
        con_mc=contrast-mean(contrast,2);
        
        % subtract frame by frame
        for i=1:size(contrast,2)-1    
           diff_c(:,i)=contrast(:,i+1)-contrast(:,i);
        end
        
        % take power of frame by frame subtraction
        diff_cp=power(diff_c,2);
        
        % GVTD
        rmsc=rms(diff_c,1);
                
        %scale plots
        mint=0.05*min(min(con_mc));
        maxt=0.05*max(max(con_mc));
        
        % plot traces;
        subplot('position', [0.15 0.8 0.75 0.1]);
        imagesc(squeeze(con_mc).*isbrain_rs,[mint maxt]); colorbar; hold on;
        xticks([t]); xticklabels([tl]); xlabel('Time(s) [contrast]'); ylabel('Pixels'); colormap gray;
        subplot('position', [0.15 0.6 0.75 0.1]);
        imagesc(squeeze(diff_c).*isbrain_rs,[mint maxt]); colorbar; hold on;
        xticks([t]); xticklabels([tl]); xlabel('Time(s) [diff contrast]'); ylabel('Pixels'); colormap gray;
        subplot('position', [0.15 0.4 0.75 0.1]);
        imagesc(squeeze(diff_cp).*isbrain_rs,[-1*power(mint,2) power(maxt,2)]); colorbar; hold on;
        xticks([t]); xticklabels([tl]); xlabel('Time(s) [diff contrast]^2'); ylabel('Pixels'); colormap gray;
        subplot('position', [0.15 0.05 0.715 0.28]);
        plot(rmsc); ylim([0 maxt]); xlim([0 max(t)]); hold on;
        xticks([t]); xticklabels([tl]); xlabel('Time(s) rms[diff contrast]'); ylabel('RMS');
        
end

        
        
        
        
        
        
        
        
        
        
        
        