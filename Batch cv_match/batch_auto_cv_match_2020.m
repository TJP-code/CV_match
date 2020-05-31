close all
clear
%%auto_cv_match
%1 - run on other animals
%2 - process output make summary, copy to excell, plot best ones (make
%figures big) and cycle through with space bar? 
%3 - try and get actual stupid colorbar

%params
params.filt_freq = 2000; %we found 2000Hz for 2 channel data gave a smoother CV
params.sample_freq = 58820; 

no_of_channels = 2; %should be metadata
mk_fcv_path = 'E:\Oxford Voltametry data\MK002 - for cv matching';

cvmatch = load('F:\Documents\GitHub\CV_match\Chemometrics\cv_match');
cv_template = cvmatch.cv_match(:,1:7);
visualise_matches = 0;
%get folders list
folder_list = dir([mk_fcv_path]);

threshold.cons = 0.75;
threshold.lib = 0.7;
threshold.smoothing = 5;

fcvwindowsize = 20;%window to look around fcv data in number of scans
point_number = 150;
min_file_length = 300;

%from folder with animal names: for each animal
for i=10:length(folder_list) %3
    %change into folder
    days = dir([mk_fcv_path '\' folder_list(i).name]);
    %for each day
    for j = 3:length(days)
        %get the test files and run cv_match
        path = ['\' folder_list(i).name '\' days(j).name];
        files_list = dir([mk_fcv_path path]);
        files = {files_list.name};
        %does the filename contain 'light' or 'sucrose'
        %delete folder and txt files
        isfolder = cell2mat({files_list.isdir});
        files(isfolder)=[];
        myindices = find(~cellfun(@isempty,strfind(files,'txt')));
        files([myindices])=[];            
        myindices = find(~cellfun(@isempty,regexpi(files,'suc|house|light|reward|exp')));
        %if there are any data files, take pairs of txt and bin and run cv match on them
        if ~isempty(myindices)
            varname = matlab.lang.makeValidName([folder_list(i).name '_' days(j).name]);
            MK_FCV.(varname).name = folder_list(i).name;
            MK_FCV.(varname).date = days(j).name;
            MK_FCV.(varname).number_of_channels = no_of_channels; %try and work out from header
            MK_FCV.(varname).MK = 0; %get this from the excell file name/data structure
            MK_FCV.(varname).male = 1;
            
            varname %to show progress
            for l = 1:length(myindices)
                %to show progress
                fprintf('file %d of %d...\n', l, length(myindices))
                testvarname = matlab.lang.makeValidName(['match_result_' files{myindices(l)}]);
                temp.cv_test_file = [path '\' files{myindices(l)}];
                temp.dio_test_file = [temp.cv_test_file '.txt'];
                %load ttls
                try
                    [temp.ts,temp.TTLs] = TTLsRead([mk_fcv_path temp.dio_test_file]);                    
                catch
                    temp.ts = [];
                    temp.TTLs = 'couldnt load TTL';
                    temp.ch0_cv_matches = [];
                    temp.ch1_cv_matches = [];
                end
                %run cv_match
                if ~isempty(temp.ts) || (length(temp.ts) < min_file_length)
                    [fcv_header, ch0_fcv_data, ch1_fcv_data] = tarheel_read([mk_fcv_path temp.cv_test_file],no_of_channels); %this was the wrong way round, check any previous matches
                    
                    [all_roh,all_bg_scan,~] = optimised_auto_cv_match(ch0_fcv_data, params, cv_template);
                    [temp.ch0_da_instance, temp.ch0_da_bg_scan, temp.ch0_match_matrix] = find_dopamine_instances(all_roh, all_bg_scan, threshold, visualise_matches);
                    
                     
                    if no_of_channels == 2 
                        [all_roh,all_bg_scan,~] = optimised_auto_cv_match(ch1_fcv_data, params, cv_template);
                        [temp.ch1_da_instance, temp.ch1_da_bg_scan, temp.ch1_match_matrix] = find_dopamine_instances(all_roh, all_bg_scan, threshold, visualise_matches);
                        
                    end
                    
                end
                
                MK_FCV.(varname).(testvarname) = temp;
                temp = []; %reset temp
            end
        end
    end
end    

%if visualise_matches; [temp.ch0_decision] = plot_cv_match_results_2018(ch0_fcv_data, temp.ch0_da_instance, temp.ch0_da_bg_scan,temp.ts, temp.TTLs,[varname ' ' testvarname], fcvwindowsize, point_number); end
%if visualise_matches; [temp.ch0_decision] = plot_cv_match_results_2018(ch1_fcv_data, temp.ch1_da_instance, temp.ch1_da_bg_scan,temp.ts, temp.TTLs,[varname ' ' testvarname], fcvwindowsize, point_number); end