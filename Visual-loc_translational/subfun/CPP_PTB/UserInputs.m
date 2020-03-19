function [subjectName, runNumber, sessionNumber] = UserInputs(Cfg)
% Get Subject Name, run number and session number


if Cfg.debug
    
    subjectName = [];
    runNumber = [];
    sessionNumber = [];
    
else
    
    subjectName = input('Enter Subject Name: ','s');
    runNumber = input('Enter the run Number: ','s');
    sessionNumber = input('Enter the session Number: ','s');
    
    
    
    % ADD A WAY TO CHECK INPUTS (e.g  make sure they are numbers)
    
    
    
end

if isempty(subjectName)
    subjectName = '001';
end

if isempty(runNumber)
    runNumber = '666';
end

if isempty(sessionNumber)
    sessionNumber = '999';
end




%     if exist(fullfile(pwd, '..', 'logfiles',[subjectName,'_run_',num2str(runNumber),num2str(sessionNumber),'.mat']),'file')>0
%         error('This file is already present in your logfiles. Delete the old file or rename your run!!')
%     end




end