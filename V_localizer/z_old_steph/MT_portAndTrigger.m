function [SerPor] = MT_portAndTrigger
% Opens Serial Port and Waits for the Trigger

SerPor = OpenSerialPort();        % open Serial Port
    
% FUNCTION
% wait N MR_trigger with timeout of 10 sec.
Ntrigger = 5;                     % No.of trigger expected before starting

TimeOutNtrigger_ms = 20000;       % 20 sec. -- it is possible "inf" for infinite time

Wait_N_SerialTrigger(SerPor, Ntrigger, TimeOutNtrigger_ms);

end