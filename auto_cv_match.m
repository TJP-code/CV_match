function [cv_matches] = auto_cv_match(tarheel_data, params, params2, TTLs, interval)

if nargin < 4
    TTLs = [];
end
if nargin < 5
    interval = [];
end

all_roh = [];
all_bg_scan = [];

number_of_samples = size(tarheel_data,2);
cv_match = params2.cv_match_template;
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
    [processed_data] = process_raw_fcv_data(tarheel_data, params);
    
    %invert?
    fcv_CV = processed_data;
    if ~isempty(interval)
        for j = interval(1):interval(2)
            RHO(j,:) = corr(fcv_CV(:,j),cv_match);
        end
    else
        for j = 1:number_of_samples
            RHO(j,:) = corr(fcv_CV(:,j),cv_match);
        end
    end
    all_roh = [all_roh;RHO];
    all_bg_scan = [all_bg_scan;(i*bg_template),samples];
end

timetaken = toc;
index = sign(all_roh);
r_sqr = all_roh.^2;
all_rsq = r_sqr.*index;
da_rsq = all_rsq(:,1:7);

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
