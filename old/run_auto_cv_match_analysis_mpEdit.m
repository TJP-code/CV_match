clear
close all
datapath = 'C:\Users\mpanagi\Documents\GitHub\fcv_data_processing\test data\46_20170208_02 - Variable reward post\';

%
%Define templates for analyte of interest - n.b. only 1 analyte at a time, repeat cv match separately for additional analytes
CV_templates = dlmread('C:\Users\mpanagi\Documents\GitHub\fcv_data_processing\chemoset\cvmatrix1.txt');

%hardcoded for default cv template, should make a new da only
%template - ignore this line if you're using another template
CV_templates = CV_templates(:,1:7);

%cv match params
bg_params.filt_freq = 4000; %we found 2000Hz for 2 channel data gave a smoother CV
bg_params.sample_freq = 58820; 


cv_params.cv_match_template = CV_templates;
cv_params.shiftpeak = 1;
cv_params.plotfig = 1;
cv_params.colormap_type = 'fcv';
cv_params.scan_number = 60;
cv_params.point_number = 319;
cv_params.bg = 45;
cv_params.no_of_channels = 1;
cv_params.shiftV_min = 0.6;
cv_params.shiftV_max = 0.8;
cv_params.shiftV_ascending = 1; 

%--------------------------------------------------------------

no_of_channels = 1;
[TTLs, ch0_fcv_data, ch1_fcv_data] = read_whole_tarheel_session(datapath, no_of_channels);

[TTL_data.start, TTL_data.end] = extract_TTL_times(TTLs);
TTL_data.TTLs = TTLs;

cut_TTLs{1} = TTLs;
cut_ch0_data{1} = ch0_fcv_data;
cut_ch1_data{1} = ch1_fcv_data;

params.include.bits = []; %include target_bit
params.include.buffer = []; %time(s) before target,time after target
params.exclude.bits = [];
params.exclude.buffer = [];
params.target_bit = 9;
params.target_location = 0; %0 = start, 1 = end, 0.5 = middle
params.ignore_repeats = [10]; %no of seconds to ignore repeats
params.sample_rate = 10;
params.time_align = [10 30];
params.bg_pos = -2; %seconds relative to target_location


exclude_list = [4]; %not implemented yet
bg_adjustments = [5 -.5]; %not implemented yet

[cut_ch0_data, cut_ch0_points, cut_TTLs] = cut_fcv_data(ch0_fcv_data, TTL_data, params);
[cut_ch1_data, cut_ch1_points, ~] = cut_fcv_data(ch1_fcv_data, TTL_data, params); 

%set bg
bg_pos = ones(length(cut _ch0_data),1);
bg_pos = bg_pos*((params.time_align(1)+params.bg_pos)*params.sample_rate);

%%bg subtract/plot
for i = 1:length(cut_ch0_data)
    bg_params.bg_pos  = bg_pos(i);
    cv_params.bg = bg_pos(i);
    [processed_data{i}] = process_raw_fcv_data(cut_ch0_data{i}, bg_params);
end


% [RHO, r_sqr, h] = cv_match_analysis_mpEdit(processed_data{2}, cv_params, cut_TTLs{2});

[cv_matches] = auto_cv_match(processed_data{2}, params, cv_params, TTLs);