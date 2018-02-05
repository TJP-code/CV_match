function [cv_matches,match_matrix] = find_dopamine_instances(all_roh,all_bg_scan, TTL)

if nargin < 4
    TTL = [];
end

index = sign(all_roh);
r_sqr = all_roh.^2;
all_rsq = r_sqr.*index;

%find col of r_sqr values > 0.75
index = find(all_rsq >= 0.75);
col = ceil(index/size(all_rsq,1));
row = index-((col-1)*size(all_rsq,1));

all_bg_scan_pass = all_bg_scan(row,:);
da_rsq_top = all_rsq(row,:);
da_rsq_top_top = max(da_rsq_top,[],2);
all_bg_scan_pass(:,3) = da_rsq_top_top;
cv_matches = [all_bg_scan_pass];
if ~isempty(TTL)
    ttl_on = sum(TTLs(all_bg_scan_pass(:,2),:),2);
    cv_matches = [cv_matches,ttl_on];
end

match_matrix = zeros(max(max(all_bg_scan_pass)));
linearInd = sub2ind(size(match_matrix), cv_matches(:,1), cv_matches(:,2));
match_matrix(linearInd) = 1;
figure;imagesc(rot90(match_matrix))
rowsum = sum(match_matrix,1);
figure;plot(smooth(rowsum,10))

colsum = sum(match_matrix,2);
figure;plot(smooth(colsum,10),'r')


