function [subjectName, runNumber, sessionNumber] = UserInputs

% Get Subject Name, run number and session number
subjectName = input('Enter Subject Name: ','s');
if isempty(subjectName)
    subjectName = 'trial';
end

runNumber = input('Enter the run Number: ','s');
if isempty(runNumber)
    runNumber = 'trial';
end

sessionNumber = input('Enter the session Number: ','s');
if isempty(sessionNumber)
    sessionNumber = 'trial';
end

if exist(fullfile(pwd, '..', 'logfiles',[subjectName,'_run_',num2str(runNumber),num2str(sessionNumber),'.mat']),'file')>0
    error('This file is already present in your logfiles. Delete the old file or rename your run!!')
end

end