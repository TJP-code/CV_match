function [RHO, r_sqr, h] = cv_match_analysis(fcv_data, params, TTLs)
%function [RHO, r_sqr] = cv_match_analysis(fcv_data, params)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Takes background subtracted fcv data along with a CV match template to calculate the
%   correlation coefficiant (default pearson) and r² value between the data CV at a given 
%   time and the dopamine and PH templates.
%
% --inputs--
%          
%   cv_match_template must contain at least a file called cv_match at 500×n matrix, outputting n r² values
%
%   Notes: point number for peak shift hardcores for two channels, to be fixed!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%check params
if nargin < 1; error('Need FCV data'); end;
if nargin < 2; params = []; end;
if nargin < 3; TTLs = []; end;
if ~isfield(params,'cv_match_template') || isempty(params.cv_match_template)
    error('Please provide CV match template filename')
end
if ~isfield(params,'point_number') || isempty(params.point_number)
     params.point_number = 150;
end
if ~isfield(params,'scan_number') || isempty(params.scan_number)
     params.scan_number = 20;
end
if ~isfield(params,'shiftpeak') || isempty(params.shiftpeak)
     params.shiftpeak = 0;
end
if ~isfield(params,'plotfig') || isempty(params.plotfig)
     params.plotfig = 0;
end
if ~isfield(params,'colormap_type') || isempty(params.colormap_type)
     params.colormap_type = 'jet';
end
if ~isfield(params,'bg') || isempty(params.bg)
     params.bg = [];
end

%load cv match
try
    cv_match = load(params.cv_match_template);
catch
    error('Failed to load cv match template, please check filename')
end
fcv_inv = fcv_data;
fcv_IT = fcv_inv(params.point_number,:);
fcv_CV = fcv_inv(:,params.scan_number);
ts = [0:0.1:length(fcv_IT)/10-0.1];

%if plot, plot tarheel style data for example
if params.plotfig
    [h] = visualise_fcv_data(fcv_data, ts, params, TTLs, cv_match, []);
end

shifted_cv = fcv_CV;
if params.shiftpeak
    [~, index] = max(cv_match);
    avg_peak = round(mean(index(1:7)));
    %add zeros to start or end of raw data
    %HARDCODED PEAK VALS
    [value, peak] = max(shifted_cv(148:178));
    shift_val = abs(peak+147-avg_peak);
    
    if peak>avg_peak && params.shiftpeak
        if params.plotfig
            subplot(2,3,3);
            hold on
            plot(shifted_cv(1:shift_val),'color',[0.6350    0.0780    0.1840])
            subplot(2,3,4);
            hold on
            plot(cv_match(:,length(shifted_cv):length(shifted_cv)+shift_val,'color',[0.6350    0.0780    0.1840]))
        end
        shifted_cv(1:shift_val) = [];        
        %add nans to the end
        %shifted_cv(length(shifted_cv):length(shifted_cv)+shift_val)=nan;
        
        %or remove end of cv match
        cv_match(:,length(shifted_cv):length(shifted_cv)+shift_val)=[];
        
    elseif peak<avg_peak && params.shiftpeak
        
        start_index = length(shifted_cv)-shift_val+1;
        end_index = length(shifted_cv);
        if params.plotfig
            subplot(2,3,3);
            hold on
            plot([start_index:end_index],shifted_cv(start_index:end_index),'color',[0.6350    0.0780    0.1840])
            subplot(2,3,4);
            hold on
            plot(cv_match(1:shift_val,:),'color',[0.6350    0.0780    0.1840])
        end
        shifted_cv(start_index:end_index)=[];  
        %add nans to start
        %shifted_cv = [shifted_cv;nan(shift_val,1)];
        
        %or remove start of cv match
        cv_match(1:shift_val,:) = [];
    end
end

%r² for data cv and different cv matchs
RHO = corr(shifted_cv,cv_match);
index = sign(RHO);
r_sqr = RHO.^2;
r_sqr = r_sqr.*index;
if params.plotfig
    [val,index] = max(r_sqr(1:7));
    suptitle(sprintf('rsqr = %d in template: %d bg = %d scan = %d',val,index,params.bg,params.scan_number))
    pos = get(h,'position');
    set(h,'position',[pos(1:2)/4 pos(3:4)*2])

end

