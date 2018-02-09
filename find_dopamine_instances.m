function [da_instance, da_bg_scan, match_matrix] = find_dopamine_instances(all_roh, all_bg_scan, threshold, visualise_matches)
%function [da_instance, da_bg_scan] = find_dopamine_instances(all_roh, all_bg_scan, threshold, visualise_matches)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% find_dopamine_instances processes data output from auto_cv_match, finding "instances of dopamine" sustained 
% epochs of data where cv's match a template. The function creates an rsqr smoothed landscape for the file merging 
% close together peaks of high rsqr values into dopamine "instances". Only instances that pass a liberal threshold 
% when smoothed and a conservative threshold unsmoothed are returned as purative dopamine events. .
% 
% Inputs
%           all_roh:     r values output from auto_cv_match
%           all_bg_scan: 2×n matrix of combinations of background and scan numbers corisponding to the same 
%                        all_roh r value, also output from auto_cv_match
%
%           threshold.   (data structure containing threshold params
%                        cons      - conservative rsqr threshold (i.e. 0.75)
%                        lib       - liberal rsqr threshold      (i.e. 0.7)
%                        smoothing - number of points to smooth landscape   
%
%           visualise_matches: debugging mode to plot raw and smoothed rsqr
%                              landscapes with dopamine instances shown
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4
    visualise_matches = 0;
end

index = sign(all_roh);
r_sqr = all_roh.^2;
all_rsq = r_sqr.*index;
da_instance = [];
da_bg_scan = [];

%old method
%cv_matches_sig = find_rsqr_vals(all_rsq, all_bg_scan, TTL, threshold.cons);

match_matrix = rsqr_landscape(all_rsq, all_bg_scan);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For each time that passes conservative threshold
% 1) does it have a smoothed value greater than liberal threshold 
% (is it surrounded by other high rsqr val neighbours and therefore not noise)
% 2) is it part of an "instance" of dopamine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[d1_landscape, bg] = max(match_matrix);
smoothed_landscape = smooth(d1_landscape,threshold.smoothing);
peaks = (smoothed_landscape >= threshold.lib);
peak_shifted = [0;[peaks(1:(length(peaks)-1))]];
peak_diff = peaks-peak_shifted;
peak_start = find(peak_diff == 1);
peak_end = find(peak_diff == -1);
peak_start_temp = peak_start-1;
peak_start_temp(peak_start_temp < 1) = 1;
peak_end_temp = peak_end;

%for each "dopamine event"
for k = 1:length(peak_start)-1
    
    %if event is near others merge
    if peak_start(k+1)-peak_end(k) < 5
        peak_start_temp(k+1) = -1;
        peak_end_temp(k) = -1;
    end
     
end
peak_start_temp(peak_start_temp==-1) = [];
peak_end_temp(peak_end_temp==-1) = [];

for j = 1:length(peak_start_temp)
    
    da(j,1) = peak_start_temp(j);
    da(j,2) = peak_end_temp(j);
    [peak_val,val_index] = max(d1_landscape(peak_start_temp(j):peak_end_temp(j)));  
    if peak_val > threshold.cons
        da(j,3) = peak_val;
        da(j,4) = da(j,1)+val_index-1;
        da(j,5) = bg(da(j,4));
    else
        da(j,3) = -1;
    end
end

if  ~isempty(peak_start)
    da((da(:,3)==-1),:) = [];
    if ~isempty(da)
        da_bg_scan = da(:, [5,4]);
        da_instance = da(:,1:3);
    end

    %debugging
    if visualise_matches

        figure    
        subplot(2,1,1)
        hold on
        plot(d1_landscape,'k-o')
        plot(threshold.cons*ones(size(match_matrix,2)),'r')

        plot(peak_start_temp,d1_landscape(peak_start_temp),'go')
        plot(peak_end_temp,d1_landscape(peak_end_temp),'rx')
        try
            plot(da(:,4), da(:,3),'bo')
        catch
        end
        subplot(2,1,2)
        hold on
        plot(smoothed_landscape,'k-o')
        plot(threshold.lib*ones(size(match_matrix,2)),'r')
        plot(peak_start_temp,smoothed_landscape(peak_start_temp),'go')
        plot(peak_end_temp,smoothed_landscape(peak_end_temp),'rx')
        try
            plot(da(:,4), smoothed_landscape(da(:,4)),'bo')
        catch
        end

        figure
        match_matrix(match_matrix < 0) = 0;
        imagesc(rot90(match_matrix));
        colorbar
    end
else
    %debugging
    if visualise_matches

        figure    
        subplot(2,1,1)
        hold on
        plot(d1_landscape,'k-o')
        plot(threshold.cons*ones(size(match_matrix,2)),'r')
        subplot(2,1,2)
        hold on
        plot(smoothed_landscape,'k-o')
        plot(threshold.lib*ones(size(match_matrix,2)),'r')
    end
    
end


function cv_matches = find_rsqr_vals(rsq, bg_scan, TTL, rsq_val)

%find col of r_sqr values > rsq_val
index = find(rsq >= rsq_val);
col = ceil(index/size(rsq,1));
row = index-((col-1)*size(rsq,1));

all_bg_scan_pass = bg_scan(row,:);
da_rsq_top = rsq(row,:);
da_rsq_top_top = max(da_rsq_top,[],2);
all_bg_scan_pass(:,3) = da_rsq_top_top;
cv_matches = [all_bg_scan_pass];
if ~isempty(TTL)
    ttl_on = sum(TTL(all_bg_scan_pass(:,2),:),2);
    cv_matches = [cv_matches,ttl_on];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot passing rsqr vals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% match_matrix = zeros(max(max(bg_scan)));
% linearInd = sub2ind(size(match_matrix), cv_matches(:,1), cv_matches(:,2));
% match_matrix(linearInd) = 1;
% figure;imagesc(rot90(match_matrix))
% rowsum = sum(match_matrix,1);
% figure;plot(smooth(rowsum,10))
% 
% colsum = sum(match_matrix,2);
% figure;plot(smooth(colsum,10),'r')


function match_matrix = rsqr_landscape(rsq, bg_scan)

if ismatrix(rsq)
    %get best rsqr for each bg/scan combination
    rsq = max(rsq');
end

match_matrix = (zeros(max(max(bg_scan))))-1;

%for each scan/bg combination
for i = 1:length(rsq)
    if match_matrix(bg_scan(i,1), bg_scan(i,2)) < rsq(i)
        match_matrix(bg_scan(i,1), bg_scan(i,2)) = rsq(i);
    end
end

%match_matrix(match_matrix < 0) = 0;