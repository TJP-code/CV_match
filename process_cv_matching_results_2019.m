%changes

%save changes to cv match list as you go, load in and allow partial
%completion of the cv matching

%take the cvs that match and put into a table to export, with values but
%also filename and parameters to load the best cvs to show someone else.

%add a "best button" for the best match

%GUI?


%process cv match results
clear
close all 

%load struct
path = 'F:\FCV\MK001\';
load ([path 'MK001_CV_match_data'])
days = fieldnames(GLRA_FCV);
cv_table = {'Name','Date','Knockout','Male','Recording','Channel','Background','Scan','R²','Decision'};%,'TTL on'};
point_number = 150;
fcvwindowsize = 20;

threshold.cons = 0.75;
threshold.lib = 0.7;
threshold.smoothing = 5;

summary_table = {'Name','Date','Knockout','Male','Recording','Channel','R²'};
%go through struct

%for each day
for i = 1:length(days)
    temp =  GLRA_FCV.(days{i});
    recordings = fieldnames(temp);
    name = temp.name;
    date = temp.date;
    number_of_channels = temp.number_of_channels;
    
    myindices = find(~cellfun(@isempty,regexpi(recordings,'match_result')));
    
    %for each file
    for j = 1:length(myindices)
        match_data = temp.(recordings{myindices(j)});
        temp_table = []; temp_table2 = [];
        %load data
        [fcv_header, ch1_fcv_data, ch0_fcv_data] = tarheel_read([path match_data.cv_test_file],temp.number_of_channels);
        
        if ~isempty(match_data.ch0_da_instance)
            %ch0    
            ch0_title = sprintf('%s %s ch0\n%s',name,date,match_data.cv_test_file);
            plot_da_instances(match_data.ch0_da_instance, match_data.ch0_da_bg_scan, match_data.ch0_match_matrix, threshold)
            [match_data.ch0_decision] = plot_cv_match_results_2018(ch0_fcv_data, match_data.ch0_da_instance, match_data.ch0_da_bg_scan,...
                match_data.ts, match_data.TTLs,ch0_title, fcvwindowsize, point_number, match_data.ch0_match_matrix);

            if match_data.ch0_decision == -2
                close all
                return
            end
              temp_table = cell(length(match_data.ch0_decision),9);

            temp_table(:,1) = {name};
            temp_table(:,2) = {date};
            temp_table(:,3) = {temp.KO};
            temp_table(:,4) = {temp.male};
            temp_table(:,5) = {recordings{myindices(j)}};
            temp_table(:,6) = {0};%Channel
            temp_table(:,7) = {match_data.ch0_da_bg_scan(1)};%background
            temp_table(:,8) = {match_data.ch0_da_bg_scan(2)};%scan
            temp_table(:,9) = {match_data.ch0_da_instance(3)};%R2
            temp_table(:,10) = {match_data.ch0_decision};
            
            %summary - is there dopamine in this animal?
            summary_table = {'Name','Date','Knockout','Male','Recording','Channel','R²'};
            cv_table = [cv_table;temp_table];
        end
        if number_of_channels > 1 && ~isempty(match_data.ch1_da_instance)
            ch1_title = sprintf('%s %s ch1\n%s',name,date,match_data.cv_test_file);
             plot_da_instances(match_data.ch1_da_instance, match_data.ch1_da_bg_scan, match_data.ch1_match_matrix, threshold)
            [match_data.ch1_decision] = plot_cv_match_results_2018(ch1_fcv_data, match_data.ch1_da_instance, match_data.ch1_da_bg_scan,...
            match_data.ts, match_data.TTLs,ch1_title, fcvwindowsize, point_number, match_data.ch1_match_matrix);
            
            if match_data.ch1_decision == -2
                close all
                return
            end
        
            %ch1
            temp_table2 = cell(length(match_data.ch1_decision),9);
            temp_table2(:,1) = {name};
            temp_table2(:,2) = {date};
            temp_table2(:,3) = {temp.KO};
            temp_table2(:,4) = {temp.male};
            temp_table2(:,5) = {recordings{myindices(j)}};
            temp_table2(:,6) = {1};%Channel
            temp_table2(:,7) = {match_data.ch1_da_bg_scan(1)};%background
            temp_table2(:,8) = {match_data.ch1_da_bg_scan(2)};%scan
            temp_table2(:,9) = {match_data.ch1_da_instance(3)};%R2
            temp_table2(:,10) = {match_data.ch1_decision};
            
            cv_table = [cv_table;temp_table2];
        end        
        
        close all
    end
end


        