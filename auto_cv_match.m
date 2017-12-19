function [cv_matches] = auto_cv_match(fcv_data, params, cv_match_template, TTLs, interval)
%function [cv_matches] = auto_cv_match(tarheel_data, params, params2, TTLs, interval)
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
%       fcv_data: raw data extracted from tarheel (use tarheel read to
%       load data)
%
%       params: data structure containing parameters for
%       process_raw_fcv_data (see that function for details)
%
%       cv_match_template: example cv(s) in columns which the function will
%       match fcv_data against.
%
%       TTLs: extracted TTLs, used to calculate if an event occurred at the
%       time of a matching cv
%
%       interval: Period of time within a file to consider. e.g. only look
%       in the first 300 samples of a file for a cv_match would be 
%       interval = [0 300]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4
    TTLs = [];
end
if nargin < 5
    interval = [];
end

all_roh = [];
all_bg_scan = [];

number_of_samples = size(fcv_data,2);
cv_match = cv_match_template;
samples = [1:number_of_samples]';
bg_template = ones(number_of_samples,1);
RHO = zeros(number_of_samples,size(cv_match,2));
tic
cv_progressbar(0, 0)

%for each background
for i = 1:number_of_samples-10 %BG is currently avg of 10 scans ahead of bg
    cv_progressbar(i/(number_of_samples-10),0);
    params.bg_pos = i;
    %params2.bg = i;
    [processed_data] = process_raw_fcv_data(fcv_data, params);
    
    %invert?
    processed_fcv_CV = processed_data;
    if ~isempty(interval)
        for j = interval(1):interval(2)
            RHO(j,:) = corr(processed_fcv_CV(:,j),cv_match);
        end
    else
        for j = 1:number_of_samples
            RHO(j,:) = corr(processed_fcv_CV(:,j),cv_match);
        end
    end
    all_roh = [all_roh;RHO];
    all_bg_scan = [all_bg_scan;(i*bg_template),samples];
end

timetaken = toc;
index = sign(all_roh);
r_sqr = all_roh.^2;
all_rsq = r_sqr.*index;
da_rsq = all_rsq(:,1:7); %for specifically the seatle da templates first 7 da last 6 ph

%find col of r_sqr values > 0.75
index = find(da_rsq >= 0.75);
col = ceil(index/size(da_rsq,1));
row = index-((col-1)*size(da_rsq,1));

all_bg_scan_pass = all_bg_scan(row,:);
da_rsq_top = da_rsq(row,:);
da_rsq_top_top = max(da_rsq_top,[],2);
all_bg_scan_pass(:,3) = da_rsq_top_top;
ttl_on = sum(TTLs(all_bg_scan_pass(:,2),:),2);
cv_matches = [all_bg_scan_pass,ttl_on];

