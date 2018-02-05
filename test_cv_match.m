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

cv_matches = find_dopamine_instances(all_roh,all_bg_scan, TTL);


match_params.cv_match_template = cv_template;
match_params.shiftpeak = 1;
match_params.plotfig = 1;  
match_params.colormap_type = 'fcv';
match_params.scan_number = 100;
match_params.point_number = 150;
match_params.bg = 50;
[RHO_shift, r_sqr_shift, h] = cv_match_analysis_new(cv_vals{50}, match_params, TTL);