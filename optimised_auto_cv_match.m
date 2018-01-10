function [all_roh,all_bg_scan,cv_vals] = optimised_auto_cv_match(tarheel_data, params, params2, TTLs, bg_scan_dist, timeinterval)

if nargin < 4
    TTLs = [];
end
if nargin < 4 || isempty(bg_scan_dist)
    multiscan = 1;
    bg_scan_dist = 0;
elseif ~isempty(bg_scan_dist)
    multiscan = 0;
end
if nargin < 6
    timeinterval = [];
end
if ~isfield(params,'bg_size') || isempty(params.bg_size)
    params.bg_size = 10;
end
if ~isfield(params,'bg_size') || isempty(params.bg_size)
    params.prog_bar = 1;
end

all_roh = [];
all_bg_scan = [];
cv_vals = [];

number_of_samples = size(tarheel_data,2);
load(params2.cv_match_template);
samples = [1:number_of_samples]';
bg_template = ones(number_of_samples,1);
RHO = zeros(number_of_samples,size(cv_match,2));
tic
if params.prog_bar
    cv_progressbar(0, 0)
end

last_sample = (number_of_samples-params.bg_size)-(bg_scan_dist-params.bg_size); %BG is currently avg of 10 scans ahead of bg
params.bg_pos = 1;
[processed_data] = process_raw_fcv_data(tarheel_data, params);

%for each background
for i = 1:last_sample
    if  params.prog_bar
        cv_progressbar(i/last_sample,0);
    end
    params.bg_pos = i;
    %params2.bg = i;
    tic    
    new_bg_avg = mean(processed_data(:,i:i+params.bg_size),2);
    for k = 1:size(processed_data,2)
        new_subbed_data(:,k) = processed_data(:,k) - new_bg_avg;
    end
    t_processing(i) = toc;
    fcv_CV = new_subbed_data;
    tic
    %run on subset of file or whole file
    if ~isempty(timeinterval)
        for j = timeinterval(1):timeinterval(2)
            RHO(j,:) = corr(fcv_CV(:,j),cv_match);
        end
        %NOT CORRECT: FIX THIS bit \/
        all_bg_scan = [all_bg_scan;(i*bg_template),samples];
    elseif multiscan
        t_iftime(i) = toc;
        tic
        for j = 1:number_of_samples
            RHO(j,:) = corr(fcv_CV(:,j),cv_match);
        end
        t_looptime(i) = toc;
        tic
        all_bg_scan = [all_bg_scan;(i*bg_template),samples];
        t_loopaftertime1(i) = toc;
        tic
        cv_vals{i} = fcv_CV;
        t_loopaftertime2(i) = toc;
        tic
    else
        RHO = corr(fcv_CV(:,i+bg_scan_dist),cv_match);
        all_bg_scan = [all_bg_scan;[i,i+bg_scan_dist]];
        cv_vals = [cv_vals,fcv_CV(:,i+bg_scan_dist)];
    end
    all_roh = [all_roh;RHO];
    
end

timetaken = toc;
%          |
%          | 
%make this V a separate function
%
% index = sign(all_roh);
% r_sqr = all_roh.^2;
% all_rsq = r_sqr.*index;
% da_rsq = all_rsq(:,1:7);
% 
% %find col of r_sqr values > 0.75
% index = find(da_rsq >= 0.75);
% col = ceil(index/size(da_rsq,1));
% row = index-((col-1)*size(da_rsq,1));
% 
% all_bg_scan_pass = all_bg_scan(row,:);
% da_rsq_top = da_rsq(row,:);
% da_rsq_top_top = max(da_rsq_top,[],2);
% all_bg_scan_pass(:,3) = da_rsq_top_top;
% ttl_on = sum(TTLs(all_bg_scan_pass(:,2),:),2);
% cv_matches = [all_bg_scan_pass,ttl_on];
% figure
% plot(t_processing)
% hold on
% plot(t_iftime)
% plot(t_looptime)
% plot(t_loopaftertime1)
% plot(t_loopaftertime2)
% plot(corrtime)
% plot(addtime)
% legend('processing', 'if', 'loop','loopafter','loopafter2','corr','add')

