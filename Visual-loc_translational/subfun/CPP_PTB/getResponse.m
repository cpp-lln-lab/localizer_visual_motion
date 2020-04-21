function responseEvents = getResponse(action, cfg, expParameters, getOnlyPress, verbose)
% wrapper function to use KbQueue
% The queue will be listening to key presses on the response box as defined
% in the cfg structure : see setParameters for more details
%
% INPUT
%
% getOnlyPress: will only return the key press and not the releases and not just the key presses. (default=1) 
%
% - action: Defines what we want the function to do
%  - init: to initialise the queue
%  - start: to start listening to keypresses
% 
% Get all the keypresses and return them as an array responseEvents
%
% Time   Keycode   Pressed
% 
% Pressed == 1  --> the key was pressed
% Pressed == 0  --> the key was released
%
% KbName(responseEvents(:,2)) will give all the keys pressed

if nargin < 4
    getOnlyPress = 1;
end

if nargin < 5
    verbose = 0;
end

responseEvents = [];

responseBox = cfg.responseBox;

switch action
    
    case 'init'
        
        % Clean and realease any queue that might be opened
        KbQueueRelease(responseBox);
        
        %% Defines keys
        % list all the response keys we want KbQueue to listen to
        
        % by default we listen to all keys
        % but if responseKey is set in the parameters we override this
        keysOfInterest = ones(1,256); 
        
        fprintf('\n Will be listening for key presses on : ')
        
        if isfield(expParameters, 'responseKey') && ~isempty(expParameters.responseKey)
            
            keysOfInterest = zeros(1,256);
            
            for iKey = 1:numel(expParameters.responseKey)
                fprintf('\n  - %s ', expParameters.responseKey{iKey})
                responseTargetKeys(iKey) = KbName(expParameters.responseKey(iKey)); %#ok<*SAGROW>
            end
            
            keysOfInterest(responseTargetKeys) = 1;
           
        else
            
            fprintf('ALL KEYS.')
            
        end
        
        fprintf('\n\n')
        
        % Create the keyboard queue to collect responses.
        KbQueueCreate(responseBox, keysOfInterest);
        
        
    case 'start'
        
        fprintf('\n starting to listen to keypresses\n')
        
        KbQueueStart(responseBox);
        
        
    case 'check'
        
        if verbose
            fprintf('\n checking recent keypresses\n')
        end
         
        while KbEventAvail(responseBox)
            
            event = KbEventGet(responseBox);
            
            % we only return the pressed keys by default
            if getOnlyPress && event.Pressed==0
            else
                responseEvents(end+1, :) = [event.Time event.Keycode event.Pressed];  %#ok<*AGROW>
            end
        end

        
        
    case 'flush'
        
        if verbose
            fprintf('\n reinitialising keyboard queue\n')
        end
       
        KbQueueFlush(responseBox);
        
        
    case 'stop'
        
        fprintf('\n stopping to listen to keypresses\n\n')
        
        KbQueueRelease(responseBox);
        
end


end