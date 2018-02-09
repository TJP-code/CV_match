function plot_cv_match_results_2018(fcv_data, da_instance, match_bg_scan,ts, TTLs,title_text, windowsize, point_number)
if nargin < 4
    ts = [0:0.1:size(fcv_data,2)/10-0.1];
end
if nargin < 5
    TTLs = [];
end
params.filt_freq = 2000; %we found 2000Hz for 2 channel data gave a smoother CV
params.sample_freq = 58820; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot whole session
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[processed_data] = process_raw_fcv_data(fcv_data);
figure
fig_title = sprintf('%s file overview',title_text);
newStr = strrep(fig_title,'_',' ');
suptitle(newStr) 
plot_fcv_cv_it_TTL(processed_data, ts, TTLs,point_number)
    % Construct a questdlg with three options
    choice = questdlg('Would you like a dessert?', ...
    'Dessert Menu', ...
    'Ice cream','Cake','No thank you','No thank you');
    % Handle response
    switch choice
    case 'Ice cream'
        disp([choice ' coming right up.'])
        dessert = 1;
    case 'Cake'
        disp([choice ' coming right up.'])
        dessert = 2;
    case 'No thank you'
        disp('I''ll bring you your check.')
        dessert = 0;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot each putative da event
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    fig_title = sprintf('%s \n rsqr = %d putative match %d of %d',title_text,da_instance(i,3)*100,i,size(match_bg_scan,1));
    newStr = strrep(fig_title,'_',' ');
    suptitle(newStr) 
    plot_fcv_cv_it_TTL(processed_data(:,winstart:winend), ts(winstart:winend), TTLs(winstart:winend,:),point_number, match_bg_scan(i,:)-winstart)
    
    % Construct a questdlg with three options
    choice = questdlg('Would you like a dessert?', ...
    'Dessert Menu', ...
    'Ice cream','Cake','No thank you','No thank you');
    % Handle response
    switch choice
    case 'Ice cream'
        disp([choice ' coming right up.'])
        dessert = 1;
    case 'Cake'
        disp([choice ' coming right up.'])
        dessert = 2;
    case 'No thank you'
        disp('I''ll bring you your check.')
        dessert = 0;
    end
end

function plot_fcv_cv_it_TTL(fcv_data, ts, TTLs,point_number, match_bg_scan)

if nargin < 5
    match_bg_scan = [];
end

fcv_IT = fcv_data(point_number,:);

subplot(4,4,[1:3,5:7,9:11]); 
if ~isempty(match_bg_scan)
    lines.point_number = point_number;
    lines.scan_number = match_bg_scan(2);
    lines.bg = match_bg_scan(1);
else
    lines = [];
end
h = plot_fcvdata(fcv_data, ts, lines);
originalSize1 = get(gca, 'Position');
colorbar('westoutside')
set(gca, 'Position', originalSize1);
%plot it and cv
if ~isempty(match_bg_scan)
    subplot(4,4,4); 
    fcv_CV = fcv_data(:,match_bg_scan(2));
    %two channels
    voltage = [-0.3932:0.0068:1.3,(1.3-0.0068):-0.0068:-0.4];
    plot(voltage,fcv_CV);
    title('Cyclic Voltammogram');xlabel('Waveform Point Number');ylabel('Current (nA)')
    subplot(4,4,13:15); 
else
    subplot(4,4,13:15);
end

plot(ts, fcv_IT)
title('Current Vs Time');xlabel('Time');ylabel('Current (nA)')
xlim([ts(1),max(ts)]);

%plot ttls
  if ~isempty(TTLs)
    subplot(4,4,[12,16]);
    plot_TTLs(double(TTLs),ts);
    ylim([0,size(TTLs, 2)+1]);
end


