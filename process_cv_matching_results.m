%process cv match results
clear
close all 

%load struct
load GLRA_FCV_NK_CV_match_results
days = fieldnames(GLRA_FCV);
cv_table = {'Name','Date','Knockout','Male','Recording','Channel','Background','Scan','R²','TTL on'};

%go through struct

%for each day
for i = 1:length(days)
    temp =  GLRA_FCV.(days{i});
    recordings = fieldnames(temp);
    name = temp.name;
    date = temp.date;
    number_of_channels = temp.number_of_channels;
    
    %for each file
    
    
    %ch0
    
    %if two ch
    
        %ch1
        
        
end


        
%old method

clear all
close all 
%add genotype information
load cv_matches_full
%get path of 
%gluA1_fcv_path = 'I:\GluA1 FCV\';
gluA1_fcv_path = 'C:\Data\GluA1 FCV\';
days = fieldnames(GLRA_FCV);
cv_table = {'Name','Date','Knockout','Male','Recording','Channel','Background','Scan','R²','TTL on'};
plot_figs = 1;
for i = 21:length(days)
   temp =  GLRA_FCV.(days{i});
   recordings = fieldnames(temp);
   name = temp.name;
   if isfield(temp,'WT')
       temp = rmfield(temp,'WT');
       recordings(length(recordings))=[];
   end
   if length(recordings) > 4
       for j = 5:length(recordings)
           %get path for excell file and look up genotype from there
           fullfile = temp.(recordings{j}).cv_test_file;
           excellpath = fullfile(1:(strfind(fullfile,[name '\'])+(length(name)-1)));
           excellfile = dir([gluA1_fcv_path excellpath '\*.xlsx'] );
           if regexpi(excellfile.name,'KO') > 1
               GLRA_FCV.(days{i}).KO = 1;
           elseif (regexpi(excellfile.name,'WT|MK') > 1)
               GLRA_FCV.(days{i}).KO = 0;
               if isfield(GLRA_FCV.(days{i}),'WT')
                GLRA_FCV.(days{i}) = rmfield(GLRA_FCV.(days{i}),'WT');
               end
               
               

           end
           
           %get best overall and best cv_match during TTL for each channel
           ch0_cv_matches = temp.(recordings{j}).ch0_cv_matches;
           ch1_cv_matches = temp.(recordings{j}).ch1_cv_matches;
           if ~isempty(ch0_cv_matches)
               [val,index] = max(ch0_cv_matches(:,3));
               ch0_max_cv = ch0_cv_matches(index,:);
               non_ttl = (ch0_cv_matches(:,4) == 0);
               ch0_cv_matches(non_ttl,:) = [];
               [val,index] = max(ch0_cv_matches(:,3));
               ch0_max_cv_TTL = ch0_cv_matches(index,:);
               if isempty(ch0_max_cv_TTL)
                   ch0_max_cv_TTL = ch0_max_cv;
               end
               %make entry in the table
               cv_table = [cv_table;{name,days{i},temp.KO,temp.male,recordings{j},0,...
                   ch0_max_cv_TTL(1),ch0_max_cv_TTL(2),ch0_max_cv_TTL(3),ch0_max_cv_TTL(4)}];
               title_text= sprintf('Animal: %s %s Channel: %d',days{i},recordings{j},0);
               
               %plot
               if plot_figs
                   [rsqr] = plot_cv_match_Results([gluA1_fcv_path temp.(recordings{j}).cv_test_file], ch0_max_cv_TTL, 0,temp.(recordings{j}).TTLs,title_text);
%                    if round(rsqr,3) ~= round(ch0_max_cv_TTL(3),3)
%                        whats = 'up';
%                    end
               end
           end
           if ~isempty(ch1_cv_matches)
               [val,index] = max(ch1_cv_matches(:,3));
               ch1_max_cv = ch1_cv_matches(index,:);
               non_ttl = (ch1_cv_matches(:,4) == 0);
               ch1_cv_matches(non_ttl,:) = [];
               [val,index] = max(ch1_cv_matches(:,3));
               ch1_max_cv_TTL = ch1_cv_matches(index,:);
               if isempty(ch1_max_cv_TTL)
                   ch1_max_cv_TTL = ch1_max_cv;
               end
               %add to table
               cv_table = [cv_table;{name,days{i},temp.KO,temp.male,recordings{j},1,...
                   ch1_max_cv_TTL(1),ch1_max_cv_TTL(2),ch1_max_cv_TTL(3),ch1_max_cv_TTL(4)}];
               %plot
                title_text= sprintf('Animal: %s %s Channel: %d',days{i},recordings{j},1);
                if plot_figs
                   [rsqr] = plot_cv_match_Results([gluA1_fcv_path temp.(recordings{j}).cv_test_file], ch1_max_cv_TTL, 1,temp.(recordings{j}).TTLs,title_text);
%                    if round(rsqr,3) ~= round(ch1_max_cv_TTL(3),3)
%                         whats = 'up';
%                    end
                end
           end
           
           
           
       end
   end
       
end