function cleanUp
WaitSecs(0.5);
Priority(0);
ListenChar();
ShowCursor
sca
if ~ismac
    % remove PsychDebugWindowConfiguration
    clear Screen 
end
end