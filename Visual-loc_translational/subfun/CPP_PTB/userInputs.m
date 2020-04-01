function [subjectName, runNumber, sessionNumber] = userInputs(cfg)
% Get subject, run and session number and mae sure they are
% positive integer values


if cfg.debug
    
    subjectName = 666;
    runNumber = 666;
    sessionNumber = 666;
    
else
        
    subjectName = str2double(input('Enter subject number: ', 's') );
    subjectName = checkInput(subjectName);

    
    runNumber = str2double(input('Enter the run number: ', 's'));
    runNumber = checkInput(runNumber);
    
    sessionNumber = str2double(input('Enter the session (i.e day) number: ', 's'));
    sessionNumber = checkInput(sessionNumber);

end

end


function input2check = checkInput(input2check)


while isnan(input2check) || fix(input2check) ~= input2check || input2check<0
  input2check = str2double(input('Please enter a positive integer: ', 's'));
end


end