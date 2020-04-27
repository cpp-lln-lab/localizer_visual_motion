function [expParameters] = userInputs(cfg, expParameters)
% Get subject, run and session number and mae sure they are
% positive integer values

if nargin<1
    cfg.debug = false;
end

if nargin<2
    expParameters = [];
end


if cfg.debug
    
    subjectGrp = 'ctrl';
    subjectNb = 666;
    runNb = 666;
    sessionNb = 666;
    
else
    
    subjectGrp = lower(input('Enter subject group (leave empty if none): ', 's'));
    
    subjectNb = str2double(input('Enter subject number (1-999): ', 's') );
    subjectNb = checkInput(subjectNb);
    
    sessionNb = str2double(input('Enter the session (i.e day - 1-999)) number: ', 's'));
    sessionNb = checkInput(sessionNb);
    
    runNb = str2double(input('Enter the run number (1-999): ', 's'));
    runNb = checkInput(runNb);
    
end


expParameters.subjectGrp = subjectGrp;
expParameters.subjectNb = subjectNb;
expParameters.sessionNb = sessionNb;
expParameters.runNb = runNb;


end


function input2check = checkInput(input2check)


while isnan(input2check) || fix(input2check) ~= input2check || input2check<0
    input2check = str2double(input('Please enter a positive integer: ', 's'));
end


end