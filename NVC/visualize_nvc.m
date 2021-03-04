function [fhandle]=visualize_nvc(corroxyg6,lagsoxyg6,r,all_lags,isbrain2,oi,seedcenter,mice)

    % plot data
    ha=tight_subplot(1,5,[0.1 0.03],[0.1 0.1],[0.1 0.1]);
    fhandle=gcf;
    axes(ha(1));
    imagesc(r,[-1 1]); colorbar; colormap jet; title('Corr (r)'); axis off; axis square;
    axes(ha(2));
    imagesc(all_lags,[-1 1]); colorbar; colormap jet; title('Lags (s)'); axis off; axis square;
    
    %set seed diameter
    mm=10;
    mpp=mm/oi.nVx;
    seedradmm=0.25;
    seedradpix=seedradmm/mpp;

    % make image P with numbered seeds in clusters
    [P]=burnseeds(seedcenter,seedradpix,isbrain2);
    P=fliplr(P);
    
    axes(ha(3));
    plot(nanmean(lagsoxyg6(find(P==1),:),1)/(oi.framerate/mice.info.temp_ds),nanmean(corroxyg6(find(P==1),:),1)); title('parietal'); axis square; ylabel('r'); xlabel('s');
    
    axes(ha(4));
    plot(nanmean(lagsoxyg6(find(P==4),:),1)/(oi.framerate/mice.info.temp_ds),nanmean(corroxyg6(find(P==4),:),1)); title('motor'); axis square; ylabel('r'); xlabel('s');
    
    axes(ha(5));
    plot(nanmean(lagsoxyg6(find(P==5),:),1)/(oi.framerate/mice.info.temp_ds),nanmean(corroxyg6(find(P==5),:),1)); title('ss'); axis square; ylabel('r'); xlabel('s');
    
end