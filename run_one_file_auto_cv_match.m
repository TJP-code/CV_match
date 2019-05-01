%test cv match
clear 
close all
filename = 'E:\mouse 6_ChAT_Cre_AAV5ChR2_BCCH47.3b_190204\opto only\stim 1_ tarheel_10hz70p10mW5mspulses.bin';
no_of_channels = 1;

[fcv_header, ch0_fcv_data, ch1_fcv_data] = tarheel_read(filename,no_of_channels);

params.filt_freq = 2000; %we found 2000Hz for 2 channel data gave a smoother CV
params.sample_freq = 58820*2; 
params.prog_bar = 1;
cvmatch = load('C:\Users\tjahansprice\Documents\GitHub\CV_match\Chemometrics\cv_analysis_cv_matrix\cvmatrix1.txt');
cv_template = cvmatch(:,1:7);
[~, TTL] = TTLsRead([filename '.txt']);
 
[all_roh,all_bg_scan,cv_vals] = optimised_auto_cv_match(ch0_fcv_data, params, cv_template);

threshold.cons = 0.75;
threshold.lib = 0.7;
threshold.smoothing = 5;
ts = [0:0.1:(size(cv_vals{1},2)/10)-0.1];
fcvwindowsize = 20;%window to look around fcv data in number of scans
point_number = 150;

[da_instance, da_bg_scan,match_matrix] = find_dopamine_instances(all_roh, all_bg_scan, threshold);


plot_da_instances(da_instance, da_bg_scan, match_matrix, threshold)
            
[match_data.ch1_decision] = plot_cv_match_results_2018(ch0_fcv_data, da_instance, da_bg_scan,...
            ts, [],'test', fcvwindowsize, point_number, match_matrix);
            