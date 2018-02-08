function [all_roh,all_bg_scan,cv_vals] = optimised_auto_cv_match(tarheel_data, params, cv_template, bg_scan_dist, timeinterval)
%function [all_roh,all_bg_scan,cv_vals] = optimised_auto_cv_match(tarheel_data, params, cv_template, bg_scan_dist, timeinterval)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Auto CV match
%
% This function takes FCV data and for each time point takes a background.
% For each of these backgrounded matrixes, it calculates the r² value
% against a provided cv template. This gives every combination of scan and
% background to help find a cv match. 
%
% Inputs
%       tarheel_data: raw data extracted from tarheel (use tarheel read to
%       load data)
%
%       params: data structure containing parameters for
%       process_raw_fcv_data (see that function for details)
%
%       cv_template: example cv(s) in columns which the function will
%       match fcv_data against.
%
%       bg_scan_dist: specify regular distance between bg and scan
%
%       timeinterval: Period of time within a file to consider. e.g. only look
%       in the first 300 samples of a file for a cv_match would be 
%       interval = [0 300]
%
% Outputs
%       cv_val: backgrounded cvs for all timepoints, output when using
%               bg_scan_dist to filter data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4
    TTLs = [];
end
if nargin < 4 || isempty(bg_scan_dist)
    multiscan = 1; %multiscan is default i.e. compare every combination of  bg and scan
    bg_scan_dist = 0;
elseif ~isempty(bg_scan_dist) %if you provide a bg_scan_dist i.e. regular distance for bg and scan, then only those are considered
    multiscan = 0;
end
if nargin < 6
    timeinterval = [];
end
if ~isfield(params,'prog_bar') || isempty(params.prog_bar)
    params.prog_bar = 1;
end
if ~isfield(params,'bg_size') || isempty(params.bg_size)
    params.bg_size = 10;
end

all_roh = [];
all_bg_scan = [];
cv_vals = [];

number_of_samples = size(tarheel_data,2);
samples = [1:number_of_samples]';
bg_template = ones(number_of_samples,1);
RHO = zeros(number_of_samples,size(cv_template,2));

if params.prog_bar
    cv_progressbar(0, 0)
end

%\/ test with scan dist why i did this \/
%last_sample = (number_of_samples-params.bg_size)-(bg_scan_dist-params.bg_size); %BG is currently avg of 10 scans ahead of bg
last_sample = (number_of_samples-params.bg_size); %BG is currently avg of 10 scans ahead of bg
params.bg_pos = 1;
[processed_data] = process_raw_fcv_data(tarheel_data, params);

%for each background
for i = 1:last_sample
    if  params.prog_bar
        cv_progressbar(i/last_sample,0);
    end
    params.bg_pos = i;
    
    %calc this background and subtrack from processed data
    new_bg_avg = mean(processed_data(:,i:i+params.bg_size),2);
    for k = 1:size(processed_data,2)
        new_subbed_data(:,k) = processed_data(:,k) - new_bg_avg;
    end
    fcv_CV = new_subbed_data;
    %run on subset of file or whole file
    if ~isempty(timeinterval)
        for j = timeinterval(1):timeinterval(2)
            RHO(j,:) = corr(fcv_CV(:,j),cv_template);
        end
        %NOT CORRECT: FIX THIS bit \/
        all_bg_scan = [all_bg_scan;(i*bg_template),samples];
    elseif multiscan
        for j = 1:number_of_samples
            RHO(j,:) = corr(fcv_CV(:,j),cv_template);
        end
        all_bg_scan = [all_bg_scan;(i*bg_template),samples];
        
        cv_vals{i} = fcv_CV; %possibly not needed in this case
    else
        RHO = corr(fcv_CV(:,i+bg_scan_dist),cv_match);
        all_bg_scan = [all_bg_scan;[i,i+bg_scan_dist]];
        cv_vals = [cv_vals,fcv_CV(:,i+bg_scan_dist)];
    end
    all_roh = [all_roh;RHO];
    
end
