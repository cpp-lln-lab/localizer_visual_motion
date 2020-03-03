% Main_MR_Serial_Port
% LUMINA mode: ASCII/MEDx
% LUMINA Speed: 115200

clear all;
close all;

% FUNCTION
% open Serial Port "SerPor" - COM1 (BAUD RATE: 11520)
SerPor=OpenSerialPort();        % open Serial Port


% FUNCTION
% wait N MR_trigger with timeout of 10 sec.
Ntrigger=5;                     % No.of trigger expected before starting
TimeOutNtrigger_ms=20000;       % 20 sec. -- it is possible "inf" for infinite time  
Wait_N_SerialTrigger(SerPor, Ntrigger, TimeOutNtrigger_ms);


% FUNCTION
% wait one serial button with timeout of 20 sec.
% sbutton=1 if pressed the button blue
% sbutton=2 if pressed the button yellow
% sbutton=3 if pressed the button green
% sbutton=4 if pressed the button red
% sbutton=6 if not pressed any button
% RMI trigger is ignored
% ResTime is the response time in sec.

TimeOutButton_ms=20000;        % 20 sec.  
%  YOUR STIMULATION 
%  YOUR STIMULATION 
%  YOUR STIMULATION 
[sbutton, ResTime]=WaitOneSerialButton(SerPor,TimeOutButton_ms);
%fprintf (1,'%s %d\n', 'Button = ', sbutton);
%fprintf (1,'%s %.3f\n', 'Response time = ', ResTime);


% FUNCTION
% close Serial Port ----  VERY IMPORTANT NOT FORGET
CloseSerialPort(SerPor);





