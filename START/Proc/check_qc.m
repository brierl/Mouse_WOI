function [fhandle]=check_qc(rawdata_f,fulldetrend,isbrain2,mice,oi)  

% qc imaging data

% IN:
%   rawdata_f: light levels oi.nVx x oi.nVy x light sources x time
%   fulldetrend: detrended data oi.nVx x oi.nVy x light sources x time
%   isbrain2: binary mask oi.nVx x oi.nVy
%   mice: struct containing mouse file and processing info
%   oi: optical instrument properties

% OUT:
% fhandle: figure handle 

        isbrain_rs=logical(reshape(isbrain2,oi.nVx*oi.nVy,[]));
        rawdata_f=double(reshape(rawdata_f,oi.nVx*oi.nVy,oi.numls,[]));
        rawdata_dt=double(reshape(fulldetrend,oi.nVx*oi.nVy,oi.numls,[]));
        
        % average data within mask
        mdata=squeeze(mean(rawdata_f(isbrain_rs,:,:),1));
        mdata_dt=squeeze(mean(rawdata_dt(isbrain_rs,:,:),1));
        
        % normalize data by time
        for c=1:oi.numls
            mdatanorm(c,:)=mdata(c,:)./(squeeze(mean(mdata(c,:),2)));
            mdatanorm_dt(c,:)=mdata_dt(c,:)./(squeeze(mean(mdata_dt(c,:),2)));
        end
        
        % std of data after detrending
        for c=1:oi.numls
            stddatanorm(c,:)=std(mdatanorm_dt(c,:),0,2);
        end
        
        % make x-axis
        time=linspace(1,size(mdata,2),size(mdata,2))/oi.framerate*mice.info.temp_ds;
        
        fhraw=figure('Units','inches','Position',[15 3 10 7], 'PaperPositionMode','auto','PaperOrientation','Landscape');
        set(fhraw,'Units','normalized','visible','on');
        
        plotedit on
        fhandle=gcf;
        
        %% Raw Data Check plot

        % plot raw light levels
        subplot('position', [0.12 0.5 0.17 0.2])
        p=plot(time,mdata'); title('Raw Data');
        title('Raw Data');
        xlabel('Time (sec)')
        ylabel('Counts');
        for i=1:size(mdata,1)
            set(p(i),'Color',oi.colors{i});
        end
        
        
        % plot normalized light levels
        subplot('position', [0.35 0.5 0.17 0.2])
        p=plot(time,mdatanorm'); title('Normalized Raw Data');
        xlabel('Time (sec)')
        ylabel('Mean Counts')
        ylim([0.95 1.05])
        for i=1:size(mdata,1)
            set(p(i),'Color',oi.colors{i});
        end

        % plot std after detrending
        subplot('position', [0.6 0.5 0.1 0.2])
        plot(stddatanorm*100');
        set(gca,'XTick',(1:size(mdata,1)));
        title('Std Deviation');
        ylabel('% Deviation')       
        
        %% FFT Check plot
        % plot fft of raw light levels
        fdata=abs(fft(logmean(mdata),[],2));
        hz=linspace(0,oi.framerate/mice.info.temp_ds,size(mdata,2));        
        subplot('position', [0.77 0.5 0.2 0.2])
        p=loglog(hz(1:ceil(size(mdata,2)/2)),fdata(:,1:ceil(size(mdata,2)/2))'); title('FFT Raw Data');
        xlabel('Frequency (Hz)')
        ylabel('Magnitude')
        xlim([0.01 15]);
        for i=1:size(mdata,1)
            set(p(i),'Color',oi.colors{i});
        end
         
end