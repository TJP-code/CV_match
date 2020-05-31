function [dopamine] = plot_cv_match_results_2018(fcv_data, da_instance, match_bg_scan,ts, TTLs,title_text, windowsize, point_number, match_matrix)

%bg_scan is the actual DA points that give DA
%instance is start and end index of da - only need this to set limits on x axis
dopamine = zeros(size(match_bg_scan,1),1);
dopamine = dopamine - 1;
if nargin < 4 || isempty(ts)
    ts = [0:0.1:size(fcv_data,2)/10-0.1];
end
if nargin < 5
    TTLs = [];
end

if nargin < 9
    match_matrix = [];
end

params.filt_freq = 2000; %we found 2000Hz for 2 channel data gave a smoother CV
params.sample_freq = 58820; 
FigPos = [900,25,267,70];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot whole session
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[processed_data] = process_raw_fcv_data(fcv_data);
figure
fig_title = sprintf('%s file overview',title_text);
newStr = strrep(fig_title,'_',' ');
suptitle(newStr) 
overview = 1;
plot_fcv_cv_it_TTL(processed_data, ts, TTLs,point_number, [],[1, length(ts)], match_matrix, match_bg_scan, overview,[])
set(gcf, 'Position', [100, 125, 1700, 1000]);
 
choice = tjp_questdlg('Would you like to cv match?', ...
    'CV_matching','Yes', ...
    'Skip','Exit','Yes',...
    FigPos);
    % Handle response
    switch choice
    case 'Yes'
        overview = 0;
    case 'Skip'
        overview = -1;
    case 'Exit'
        dopamine = -2;
        return
    end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot each putative da event
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if overview == 0
for i = 1:size(match_bg_scan,1)
    winstart = da_instance(i,1)-windowsize;
    if winstart >  match_bg_scan(i,1); winstart = (match_bg_scan(i,1)-windowsize); end;
    if winstart < 1; winstart = 1; end;
    
    winend = da_instance(i,2)+windowsize;
    if winend < match_bg_scan(i,1); winend = match_bg_scan(i,1)+windowsize;end;
    if winend > size(fcv_data,2); winend = size(fcv_data,2);end;
    params.bg_pos = match_bg_scan(i,1);
    
    [processed_data] = process_raw_fcv_data(fcv_data, params);
    figure
    fig_title = sprintf('%s rsqr = %d putative match %d of %d',title_text,da_instance(i,3)*100,i,size(match_bg_scan,1));
    newStr = strrep(fig_title,'_',' ');
    suptitle(newStr) 
    
    [clim] = scale_fcv_colorbar(processed_data(:,winstart:winend));
    
    plot_fcv_cv_it_TTL(processed_data, ts, TTLs,point_number, match_bg_scan(i,:), [winstart, winend],match_matrix, match_bg_scan, overview, clim);

    set(gcf, 'Position', [100, 125, 1700, 1000]);
    %pause
    %Construct a questdlg with three options
    choice = tjp_questdlg('Is this Dopamine?', ...
    'CV_matching','Yes', ...
    'No','Skip Animal','No',...
    FigPos);
    % Handle response
    switch choice
    case 'Yes'
        dopamine(i) = 1;
    case 'No'
        dopamine(i) = 0;
    case 'Skip Animal'
        return
    end
end
end



function plot_fcv_cv_it_TTL(fcv_data, ts, TTLs,point_number, match_bg_scan, window, match_matrix, all_matches, overview, clim)

if nargin < 5
    match_bg_scan = [];
end

if nargin < 7
    match_matrix = [];
end
fcv_IT = fcv_data(point_number,:);

subplot(12,12,[1:9,13:21,25:33,37:45,49:57,61:69,73:81,85:93,97:105]); 
if ~isempty(match_bg_scan)
    lines.point_number = point_number;
    lines.scan_number = match_bg_scan(2);
    lines.bg = match_bg_scan(1);
else
    lines = [];
end
if ~isempty(clim)
    h = plot_fcvdata(fcv_data, ts, lines,clim); 
else
    h = plot_fcvdata(fcv_data, ts, lines); 
end

xlim([ts(window(1)), ts(window(2))]);
ax = gca;
ax.FontSize = 8; 
if length(h) > 1
    set(h(2:4), 'LineWidth',2);
end

originalSize1 = get(gca, 'Position');
colorbar('westoutside')
set(gca, 'Position', originalSize1);
set(gca,'xtick',[])
xlabel('');
%plot it and cv
if ~isempty(match_bg_scan)
    subplot(12,12,[10:12,22:24,34:36,46:48]); 
    fcv_CV = fcv_data(:,match_bg_scan(2));
    %two channels
    voltage = [-0.3932:0.0068:1.3,(1.3-0.0068):-0.0068:-0.4];
    plot(voltage,fcv_CV);
    title('Cyclic Voltammogram');xlabel('Waveform Point Number');ylabel('Current (nA)')
    xlim([voltage(1),max(voltage)]);
    ax = gca;
    ax.FontSize = 8; 
end
    subplot(12,12,[109:117,121:129,133:141]); 


plot(ts, fcv_IT)
title('Current Vs Time');xlabel('Time');ylabel('Current (nA)')
xlim([ts(window(1)), ts(window(2))]);
ax = gca;
ax.FontSize = 8; 

%plot all da instances
hold on
if ~isempty(match_bg_scan)
    plot(ts(all_matches(:,2)),fcv_IT(all_matches(:,2)) ,'ko','MarkerSize',10,'MarkerFaceColor',[.6 .6 .6])
    plot(ts(match_bg_scan(2)),fcv_IT(match_bg_scan(2)) ,'bo','MarkerSize',10,'MarkerFaceColor',[.6 .6 1])    
    
else
    try
    plot(ts(all_matches(:,2)),fcv_IT(all_matches(:,2)) ,'bo','MarkerSize',10,'MarkerFaceColor',[.6 .6 1])
    catch
    end
end

%plot ttls
if ~isempty(TTLs)&& ~strcmp(TTLs, 'couldnt load TTL')
    subplot(12,12,[106:108,118:120,130:132,142:144]);
    plot_TTLs(double(TTLs),ts);
    set(gca,'ytick',[])
    ylim([0,size(TTLs, 2)+1]);
    xlim([ts(window(1)), ts(window(2))]);
    ax = gca;
    ax.FontSize = 8; 
    title('');xlabel('TTL Times(s)');
   
end

if ~isempty(match_matrix)
    subplot(12,12,[58:60,70:72, 82:84,94:96]);
    %match_matrix(match_matrix < 0) = 0;
    imagesc((match_matrix));
    ax = gca;
    ax.YDir = 'normal';
    colormap(ax,jet)
    xlabel('Scan position')
    ylabel('Background position')
    originalSize2 = get(gca, 'Position');
    colorbar('eastoutside')
    set(gca, 'Position', originalSize2);
    ax = gca;
    ax.FontSize = 8; 
    set(gca,'xtick',[])
    set(gca,'ytick',[])

    hold on
    try
    plot(all_matches(:,2), all_matches(:,1),'ko','MarkerSize',10,'MarkerFaceColor',[.6 .6 .6])
    catch
    end
    if ~isempty(match_bg_scan)
        hold on
        plot(match_bg_scan(2), match_bg_scan(1),'ko','MarkerSize',10,'MarkerFaceColor',[1 .6 .6])
    end

end
