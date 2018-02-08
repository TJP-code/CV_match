%test cv match
clear 
close all
filename = 'C:\Data\GluA1 FCV\GluA1 Data\003\Gazorpazorp\20180116_RI60_Day2\1_unexpected_light';
no_of_channels = 2;

[fcv_header, ch0_fcv_data, ch1_fcv_data] = tarheel_read(filename,no_of_channels);

params.filt_freq = 2000; %we found 2000Hz for 2 channel data gave a smoother CV
params.sample_freq = 58820; 
params.prog_bar = 1;
cvmatch = load('C:\Users\tjahansprice\Documents\GitHub\CV_match\Chemometrics\cv_match');
cv_template = cvmatch.cv_match;
[~, TTL] = TTLsRead([filename '.txt']);
 
[all_roh,all_bg_scan,cv_vals] = optimised_auto_cv_match(ch0_fcv_data, params, cv_template(:,1:7));

threshold.cons = 0.75;
threshold.lib = 0.7;
threshold.smoothing = 5;
ts = [0:0.1:size(cv_vals{1},1)-0.1];

[da_instance, da_bg_scan] = find_dopamine_instances(all_roh, all_bg_scan, threshold);


match_params.cv_match_template = cv_template;
match_params.shiftpeak = 0;
match_params.plotfig = 1;  
match_params.colormap_type = 'fcv';
match_params.point_number = 150;

for i = 1:length(da_instance)
    match_params.bg = da_bg_scan(i, 1);
    match_params.scan_number = da_bg_scan(i, 2);

    cv_match_analysis_new(cv_vals{match_params.bg}, match_params, TTL);

end
