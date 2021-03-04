function [fhandle]=visualize_nvc_avg(max_rs_corr,max_stds_corr,max_rs_lags,max_stds_lags,rs_corr,stds_corr,rs_lags,isbrain2_aff,WL,WL_factor,mice,b,oi,seedcenter)

    % plot maps 
    for q=1:size(max_rs_corr,3)
        figure(q)
        fhandle(1,q)=gcf;
        ha=tight_subplot(4,2,[0.1 0.03],[0.1 0.1],[0.1 0.1]); 

        axes(ha(1));
        Im2=overlaymouse(max_rs_corr(:,:,q),WL, isbrain2_aff,'jet',-1,1,WL_factor);
        imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:)); colorbar; title('Corr (r)'); axis off;
        axes(ha(2));
        Im2=overlaymouse(max_rs_lags(:,:,q),WL, isbrain2_aff,'jet',-1,1,WL_factor);
        imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:)); colorbar; title('Lags (s)'); axis off;
        axes(ha(3));
        Im2=overlaymouse(max_stds_corr(:,:,q),WL, isbrain2_aff,'jet',0,0.6,WL_factor);
        imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:)); colorbar; title('Corr Std (r)'); axis off;
        axes(ha(4));
        Im2=overlaymouse(max_stds_lags(:,:,q),WL, isbrain2_aff,'jet',0,3,WL_factor);
        imagesc(Im2(oi.plot_factor+1+WL_factor:end-oi.plot_factor,oi.plot_factor+1:end-oi.plot_factor,:)); colorbar; title('Lags Std (s)'); axis off;
        
        annotation('textbox', [0.03 0.9 1 0.1], ...
        'String', ['group ' num2str(q) ' band ' char(mice(1).bandstr(b))], ...
        'EdgeColor', 'none', ...
        'FontSize', 12, ...
        'FontWeight','bold')
    
        %set seed diameter
        mm=10;
        mpp=mm/oi.nVx;
        seedradmm=0.25;
        seedradpix=seedradmm/mpp;

        % make image P with numbered seeds in clusters
        [P]=burnseeds(seedcenter,seedradpix,isbrain2_aff);
        P=fliplr(P);

        axes(ha(5));
        errorbar(nanmean(rs_lags(find(P==1),:,q),1)/(oi.framerate/mice(1).info.temp_ds),nanmean(rs_corr(find(P==1),:,q),1),nanmean(stds_corr(find(P==1),:,q),1)); title('parietal'); ylabel('r'); xlabel('s');

        axes(ha(6));
        errorbar(nanmean(rs_lags(find(P==4),:,q),1)/(oi.framerate/mice(1).info.temp_ds),nanmean(rs_corr(find(P==4),:,q),1),nanmean(stds_corr(find(P==4),:,q),1)); title('motor'); ylabel('r'); xlabel('s');

        axes(ha(7));
        errorbar(nanmean(rs_lags(find(P==5),:,q),1)/(oi.framerate/mice(1).info.temp_ds),nanmean(rs_corr(find(P==5),:,q),1),nanmean(stds_corr(find(P==5),:,q),1)); title('ss');  ylabel('r'); xlabel('s');
    
        axes(ha(8));
        errorbar(nanmean(rs_lags(find(P==13),:,q),1)/(oi.framerate/mice(1).info.temp_ds),nanmean(rs_corr(find(P==13),:,q),1),nanmean(stds_corr(find(P==13),:,q),1)); title('vis');  ylabel('r'); xlabel('s');
    
        clear ha
    end