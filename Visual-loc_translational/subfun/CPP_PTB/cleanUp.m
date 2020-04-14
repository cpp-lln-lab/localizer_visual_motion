function cleanUp

WaitSecs(0.5);

Priority(0);
KbQueueRelease;
ListenChar();
ShowCursor

% Screen Close All
sca
if ~ismac
    % remove PsychDebugWindowConfiguration
    clear Screen
end

close all

 
end
