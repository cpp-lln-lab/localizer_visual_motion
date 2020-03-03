function [sbutton,secs]= MT_TakeSerialButtonPerFrame(SerPor)
% Taken from original function TakeSerialButton
%Adapted by mohamed to check button press per Frame of dot motion
%and return as an output the button press and time of presses.
%Changed the while loop to an if condition, and gave a value of 0 to secs
%and sbutton if SerPor.BytesAvailable is not true.
    %fprintf (1,'%s\n', 'TakeSerialButton')

   sbutton=0;
   
   if (SerPor.BytesAvailable)
       if sbutton==0 
           sbutton = str2num(fscanf(SerPor,'%c',1));  % read serial buffer
           secs = GetSecs;                            % CB added this line, to take the time
           if sbutton==5                              % check if it is a MR trigger  
               sbutton = 0;                           % if trigger, ignored
               secs = 0;
           end
       else
           junk = fscanf(SerPor,'%c',1); 
           secs = 0;
           sbutton = 0;
       end 
    else
        secs = 0;
        sbutton = 0;
   end
         
end
    
