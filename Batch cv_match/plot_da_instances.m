function plot_da_instances(da_instance, da_bg_scan, match_matrix, threshold)


[d1_landscape, bg] = max(match_matrix);
smoothed_landscape = smooth(d1_landscape,threshold.smoothing);



if  ~isempty(da_instance)
    instance_start = da_instance(:,1);
    instance_end = da_instance(:,2);
    
    figure    
    subplot(2,1,1)
    hold on
    plot(d1_landscape,'k-o','MarkerSize',2,'MarkerFaceColor',[.1 .1 .1])
    plot(threshold.cons*ones(size(match_matrix,2)),'r')
    
    figure    
    subplot(2,1,1)
    hold on
    plot(d1_landscape,'k-o','MarkerSize',2,'MarkerFaceColor',[.1 .1 .1])
    plot(threshold.cons*ones(size(match_matrix,2)),'r')
    
    %color instances in
    for k = 1:length(instance_start)
        plot(instance_start(k):instance_end(k),d1_landscape(instance_start(k):instance_end(k)),'b','LineWidth',2);
    end

    plot(instance_start,d1_landscape(instance_start),'go','MarkerSize',10,'MarkerFaceColor',[.6 1 .6])
    plot(instance_end,d1_landscape(instance_end),'ro','MarkerSize',10,'MarkerFaceColor',[1 .6 .6])


    try
        plot(da_bg_scan(:,2), da_instance(:,3),'bo','MarkerSize',10,'MarkerFaceColor',[.6 .6 1])
    catch
    end
    subplot(2,1,2)
    hold on
    plot(smoothed_landscape,'k-o','MarkerSize',2,'MarkerFaceColor',[.1 .1 .1])
    plot(threshold.lib*ones(size(match_matrix,2)),'r')

    for k = 1:length(instance_start)
        plot(instance_start(k):instance_end(k),smoothed_landscape(instance_start(k):instance_end(k)),'b','LineWidth',2);
    end

    plot(instance_start,smoothed_landscape(instance_start),'go','MarkerSize',10,'MarkerFaceColor',[.6 1 .6])
    plot(instance_end,smoothed_landscape(instance_end),'ro','MarkerSize',10,'MarkerFaceColor',[1 .6 .6])

    try
        plot(da_bg_scan(:,2), smoothed_landscape(da_bg_scan(:,2)),'bo','MarkerSize',10,'MarkerFaceColor',[.6 .6 1])
    catch
    end

    figure
    match_matrix(match_matrix < 0) = 0;
    imagesc((match_matrix));
    ax = gca; 
    ax.YDir = 'normal';
    colorbar
    xlabel('Scan position')
    ylabel('Background position')

else

    figure    
    subplot(2,1,1)
    hold on
    plot(d1_landscape,'k-o','MarkerSize',2,'MarkerFaceColor',[.1 .1 .1])
    plot(threshold.cons*ones(size(match_matrix,2)),'r')
    subplot(2,1,2)
    hold on
    plot(smoothed_landscape,'k-o','MarkerSize',2,'MarkerFaceColor',[.1 .1 .1])
    plot(threshold.lib*ones(size(match_matrix,2)),'r')
    
    
end