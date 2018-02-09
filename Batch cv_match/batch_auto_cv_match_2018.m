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
gluA1_fcv_path = 'C:\Data\GluA1 FCV\GluA1 Data\003\';

cvmatch = load('C:\Users\tjahansprice\Documents\GitHub\CV_match\Chemometrics\cv_match');
cv_template = cvmatch.cv_match(:,1:7);
visualise_matches = 1;
%get folders list
folder_list = dir([gluA1_fcv_path]);

threshold.cons = 0.75;
threshold.lib = 0.7;
threshold.smoothing = 5;

fcvwindowsize = 20;%window to look around fcv data in number of scans
point_number = 150;
min_file_length = 300;

%from folder with animal names: for each animal
for i=4:length(folder_list)
    %change into folder
    days = dir([gluA1_fcv_path '\' folder_list(i).name]);
    %for each day
    for j = 3:length(days)
        %get the test files and run cv_match
        path = ['\' folder_list(i).name '\' days(j).name];
        files_list = dir([gluA1_fcv_path path]);
        files = {files_list.name};
        %does the filename contain 'light' or 'sucrose'
        %delete folder and txt files
        isfolder = cell2mat({files_list.isdir});
        files(isfolder)=[];
        myindices = find(~cellfun(@isempty,strfind(files,'txt')));
        files([myindices])=[];            
        myindices = find(~cellfun(@isempty,regexpi(files,'suc|house|light|reward')));
        %if there are any data files, take pairs of txt and bin and run cv match on them
        if ~isempty(myindices)
            varname = matlab.lang.makeValidName([folder_list(i).name '_' days(j).name]);
            GLRA_FCV.(varname).name = folder_list(i).name;
            GLRA_FCV.(varname).date = days(j).name;
            GLRA_FCV.(varname).number_of_channels = no_of_channels; %try and work out from header
            GLRA_FCV.(varname).KO = 0; %get this from the excell file name/data structure
            GLRA_FCV.(varname).male = 1;
            varname %to show progress
            for l = 1:length(myindices)
                testvarname = matlab.lang.makeValidName(files{myindices(l)});
                temp.cv_test_file = [path '\' files{myindices(l)}];
                temp.dio_test_file = [temp.cv_test_file '.txt'];
                %load ttls
                try
                    [temp.ts,temp.TTLs] = TTLsRead([gluA1_fcv_path temp.dio_test_file]);                    
                catch
                    temp.ts = [];
                    temp.TTLs = 'couldnt load TTL';
                    temp.ch0_cv_matches = [];
                    temp.ch1_cv_matches = [];
                end
                %run cv_match
                if ~isempty(temp.ts) || length(temp.ts < min_file_length)
                    [fcv_header, ch1_fcv_data, ch0_fcv_data] = tarheel_read([gluA1_fcv_path temp.cv_test_file],no_of_channels);
                    
                    [all_roh,all_bg_scan,~] = optimised_auto_cv_match(ch0_fcv_data, params, cv_template);
                    [temp.ch0_da_instance, temp.ch0_da_bg_scan, temp.ch0_match_matrix] = find_dopamine_instances(all_roh, all_bg_scan, threshold, visualise_matches);
                    if visualise_matches; plot_cv_match_results_2018(ch0_fcv_data, temp.ch0_da_instance, temp.ch0_da_bg_scan,temp.ts, temp.TTLs,[varname ' ' testvarname], fcvwindowsize, point_number); end
                     
                    if no_of_channels == 2 
                        [all_roh,all_bg_scan,~] = optimised_auto_cv_match(ch1_fcv_data, params, cv_template);
                        [temp.ch1_da_instance, temp.ch1_da_bg_scan, temp.ch1_match_matrix] = find_dopamine_instances(all_roh, all_bg_scan, threshold, visualise_matches);
                        if visualise_matches; plot_cv_match_results_2018(ch1_fcv_data, temp.ch1_da_instance, temp.ch1_da_bg_scan,temp.ts, temp.TTLs,[varname ' ' testvarname], fcvwindowsize, point_number); end
                    end
                    
                end
                GLRA_FCV.(varname).(testvarname) = temp;
                temp = []; %reset temp
            end
        end
    end
end    