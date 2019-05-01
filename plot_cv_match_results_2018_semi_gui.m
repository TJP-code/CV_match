function [dopamine] = plot_cv_match_results_2018_semi_gui(fcv_data, da_instance, match_bg_scan,ts, TTLs,title_text, windowsize, point_number, match_matrix)
if nargin < 4
    ts = [0:0.1:size(fcv_data,2)/10-0.1];
end
if nargin < 5
    TTLs = [];
end

if nargin < 9
    match_matrix = [];
end

dopamine = zeros(size(da_instance,2),1);
dopamine = dopamine-1;

global exit
global instance_no
exit = 0;
instance_no = 0; 

params.filt_freq = 2000; %we found 2000Hz for 2 channel data gave a smoother CV
params.sample_freq = 58820; 
FigPos = [500,25,267,70];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot whole session
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[processed_data] = process_raw_fcv_data(fcv_data);

figure
show_da_instance(instance_no, processed_data, da_instance, match_bg_scan,ts, TTLs,title_text, windowsize, point_number, match_matrix)


exit_butt=uicontrol;
exit_butt.String = 'Exit';
exit_butt.Callback = @exitButtonPushed;
exit_butt.Position = [20 75 60 20];

next_butt=uicontrol;
next_butt.String = 'Next';
next_butt.Callback = @nextButtonPushed;
%next_butt.position


%w = waitforbuttonpress;
while exit ~= 1 
     
        w = waitforbuttonpress;
   

end

function exitButtonPushed(src,event)
    global exit
    exit = 1;
    %exit_butt.String = 'Exiting';

function nextButtonPushed(src,event)
    %clf
    global instance_no
    instance_no = instance_no+1;
    show_da_instance(instance_no, fcv_data, da_instance, match_bg_scan,ts, TTLs,title_text, windowsize, point_number, match_matrix)
    
function show_da_instance(i, fcv_data, da_instance, match_bg_scan,ts, TTLs,title_text, windowsize, point_number, match_matrix)

if i == 0
    
    fig_title = sprintf('%s file overview',title_text);
    newStr = strrep(fig_title,'_',' ');
    suptitle(newStr) 
    overview = 1;
    plot_fcv_cv_it_TTL(fcv_data, ts, TTLs,point_number, [],[1, length(ts)], match_matrix, da_instance, overview)
    set(gcf, 'Position', [100, 125, 1700, 1000]);

else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot each putative da event
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    winstart = da_instance(i,1)-windowsize;
    if winstart >  match_bg_scan(i,1); winstart = (match_bg_scan(i,1)-windowsize); end;
    if winstart < 1; winstart = 1; end;
    
    winend = da_instance(i,2)+windowsize;
    if winend < match_bg_scan(i,1); winend = match_bg_scan(i,1)+windowsize;end;
    if winend > size(fcv_data,2); winend = size(fcv_data,2);end;
    params.bg_pos = match_bg_scan(i,1);
    
    [processed_data] = process_raw_fcv_data(fcv_data, params);
    figure
    fig_title = sprintf('%s \n rsqr = %d putative match %d of %d',title_text,da_instance(i,3)*100,i,size(match_bg_scan,1));
    newStr = strrep(fig_title,'_',' ');
    suptitle(newStr) 
    plot_fcv_cv_it_TTL(processed_data, ts, TTLs,point_number, match_bg_scan(i,:), [winstart, winend],match_matrix)

    set(gcf, 'Position', [100, 125, 1700, 1000]);
    pause
    %Construct a questdlg with three options
    choice = tjp_questdlg('Is this Dopamine?', ...
    'CV_matching','Yes', ...
    'No','Not Sure','Not Sure',...
    FigPos);
    % Handle response
    switch choice
    case 'Yes'
        dopamine(i) = 1;
    case 'No'
        dopamine(i) = 0;
    case 'Not Sure'
        dopamine(i) = -1;
    end

end


function plot_fcv_cv_it_TTL(fcv_data, ts, TTLs,point_number, match_bg_scan, window, match_matrix, da_instance, overview)

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
h = plot_fcvdata(fcv_data, ts, lines); 

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
plot(ts(da_instance(:,2)),fcv_IT(da_instance(:,2)) ,'bo','MarkerSize',10,'MarkerFaceColor',[.6 .6 1])
hold off    

%plot ttls
if ~isempty(TTLs)
    subplot(12,12,[106:108,118:120,130:132,142:144]);
    plot_TTLs(double(TTLs),ts);
    ylim([0,size(TTLs, 2)+1]);
    xlim([ts(window(1)), ts(window(2))]);
    ax = gca;
    ax.FontSize = 8; 
    title('');xlim([ts(1),max(ts)]);xlabel('TTL Times(s)');
    set(gca,'ytick',[])
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
    if ~isempty(match_bg_scan)
        hold on
        plot(match_bg_scan(2), match_bg_scan(1),'ko','MarkerSize',10,'MarkerFaceColor',[.6 .6 .6])
    end
    if overview
        hold on
        plot(da_instance(:,2), da_instance(:,1),'ko','MarkerSize',10,'MarkerFaceColor',[.6 .6 .6])
    end
    hold off
end
