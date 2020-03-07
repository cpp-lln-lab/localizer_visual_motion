function Wait4Trigger(Cfg)

if strcmp(Cfg.Device,'Scanner')
    
    fprintf('Waiting for trigger \n');
    
    DrawFormattedText(Cfg.win,'Waiting For Trigger',...
        'center', 'center', Cfg.textColor);
    Screen('Flip', Cfg.win);
    
    triggerCounter=0;
    
    while triggerCounter < Cfg.numTriggers
        
        [keyIsDown, ~, keyCode, ~] = KbCheck(-1);
        
        if strcmp(KbName(keyCode),Cfg.triggerKey)
            
            triggerCounter = triggerCounter+1 ;
            
            fprintf('Trigger %s \n', num2str(triggerCounter));
            
            DrawFormattedText(Cfg.win,['Trigger ',num2str(triggerCounter)],'center', 'center', Cfg.textColor);
            Screen('Flip', Cfg.win);
            
            while keyIsDown
                [keyIsDown, ~, ~, ~] = KbCheck(-1);
            end
            
        end
    end
end
end