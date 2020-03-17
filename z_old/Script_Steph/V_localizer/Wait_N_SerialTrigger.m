%% Wait_N_SerialTrigger

function Wait_N_SerialTrigger(SerPor, Ntrigger, TimeOutMilliSeconds)
    
    % empty the buffer of the serial port
    while (SerPor.BytesAvailable)   
        junk = fscanf(SerPor,'%c',1); 
    end
    
    fprintf (1,'%s%d%s\n', 'Wait ', Ntrigger, ' Serial Trigger');
    contflag = 0;
    tStart = GetSecs;
    while contflag<Ntrigger
        if SerPor.BytesAvailable
            % read the buffer of the serial port
            sbuttons = str2num(fscanf(SerPor,'%c',1));  
            
            % check if it is a RM trigger
            if sbuttons == 5  
                contflag=contflag+1;
                fprintf (1,'%d\n', contflag)
            end
        else    
            if (GetSecs - tStart) > TimeOutMilliSeconds/1000
                fprintf (1,'%s\n', 'Return for TIMEOUT!!!')
                return;
            end
        end
    end

    
