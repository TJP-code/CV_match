function [RHO, r_sqr, h] = cv_match_analysis(fcv_data, params, TTLs)
%CV_MATCH_ANALYSIS 
%   Function to perform CV matching (correlation, pearson by default)between 
%   FCV data and a supplied set of model CVs. %Provides the correlation coefficient 
%   and r� value between templates and data CV at each time point
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Inputs - 
%           fcv_data - variable containing data CVs such that [r,c] rows = CV scan point, 
%           params - data frame containing parameters [see below]
%           TTLs - 
% Outputs - 
%           RHO - 
%           r_sqr - 
%           h - 
%
% params data frame - 
%         .cv_match_template = 'C:\Users\mpanagi\Documents\GitHub\fcv_data_processing\chemoset\cvmatrix2.txt';
%         .shiftpeak = 1;           %%if .shiftpeak = 1, allow cv match to shift the peak of the data CV to match the template cv
%         .plotfig = 1;            %%if .plotfig = 1, plot tarheel style data for example
%         .colormap_type = 'fcv';
%         .scan_number = 20;
%         .point_number = 150;
%         .bg = 95;
%         .shiftV_min = 0.6;    %%For peak shift matching, sets lower bound Voltage of waveform for where the peak of the wave form should be.
%         .shiftV_max = 0.8;    %%For peak shift matching, sets upper bound Voltage of waveform for where the peak of the wave form should be.
%         .shiftV_ascending = 1;%%For peak shift matching, deinfes whether the min/max Voltage bounds are on the ascending or descending part of the applied waveform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%check inputs
if nargin < 1; error('Need FCV data'); end;
if nargin < 2; params = []; end;
if nargin < 3; TTLs = []; end;

%check params - apply defaults for missing values
if ~isfield(params,'cv_match_template') || isempty(params.cv_match_template)
    error('Please provide CV match templates')
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
if ~isfield(params,'shiftV_min') || isempty(params.shiftV_min)
     params.shiftV_min = 0.6;
end
if ~isfield(params,'shiftV_max') || isempty(params.shiftV_max)
     params.shiftV_max = 0.8;
end
if ~isfield(params,'shiftV_ascending') || isempty(params.shiftV_ascending)
     params.shiftV_ascending = 1;
end
%% Pull out fcv data at specified scan number/point for plotting and analysis
cv_match = params.cv_match_template;
fcv_IT = fcv_data(params.point_number,:);
fcv_CV = fcv_data(:,params.scan_number);
ts = [0:0.1:length(fcv_IT)/10-0.1];

%% if .plotfig = 1, plot tarheel style data for example
if params.plotfig
    [h] = visualise_fcv_data(fcv_data, ts, params, TTLs, cv_match, []);
end

%% if .shiftpeak = 1, allow cv match to shift the peak of the data CV to match the template cv
%This is where hardcoding needs to be fixed

%identify min and max boundary for peak shift
voltages = voltagesweep(params.no_of_channels);
if params.shiftV_ascending
    peak_min = find(voltages > params.shiftV_min, 1, 'first');
    peak_max = find(voltages > params.shiftV_max, 1, 'first');
else
    peak_min = find(voltages > params.shiftV_min, 1, 'last');
    peak_max = find(voltages > params.shiftV_max, 1, 'last');
end

%

shifted_cv = fcv_CV;
if params.shiftpeak
    [~, index] = max(cv_match);
    avg_peak = round(mean(index));

    [value, data_peak] = max(shifted_cv(peak_min:peak_max));
    shift_val = abs(data_peak+(peak_min-1)-avg_peak);
    
    if data_peak>avg_peak && params.shiftpeak
        if params.plotfig
            subplot(2,3,3);
            hold on
            plot(shifted_cv(1:shift_val),'color',[0.6350    0.0780    0.1840])
%             subplot(2,3,6);
%             hold on
%             plot(cv_match(:,length(shifted_cv):length(shifted_cv)+shift_val,'color',[0.6350    0.0780    0.1840]))
        end
        
        %remove start of raw data
        shifted_cv(1:shift_val) = [];        
        %remove end of cv templates
        cv_match(:,length(shifted_cv):length(shifted_cv)+shift_val)=[];
        
    elseif data_peak<avg_peak && params.shiftpeak
        
        start_index = length(shifted_cv)-shift_val+1;
        end_index = length(shifted_cv);
        if params.plotfig
            subplot(2,3,3);
            hold on
            plot([start_index:end_index],shifted_cv(start_index:end_index),'color',[0.6350    0.0780    0.1840])
%             subplot(2,3,6);
%             hold on
%             plot(cv_match(1:shift_val,:),'color',[0.6350    0.0780    0.1840])
        end
        
        %remove end of raw data
        shifted_cv(start_index:end_index)=[];  
        %remove start of cv templates
        cv_match(1:shift_val,:) = [];
    end
end

%r� for data cv and different cv matchs
RHO = corr(shifted_cv,cv_match);
index = sign(RHO);
r_sqr = RHO.^2;
r_sqr = r_sqr.*index;
if params.plotfig
    [val,index] = max(r_sqr(1:7));
    suptitle(sprintf('Rsqr = %d in template # %d bg = %d scan = %d',val,index,params.bg,params.scan_number))
    pos = get(h,'position');
    set(h,'position',[pos(1:2)/4 pos(3:4)*2])


end

