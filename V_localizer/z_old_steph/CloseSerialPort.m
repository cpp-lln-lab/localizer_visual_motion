%% Close Serial Port
function []= CloseSerialPort(SerPor)
    
    %fprintf (1,'%s\n', 'CloseSeriaPort');
    fprintf(1, 'STOPING SERIAL PORT COM1 (BAUD RATE: 11520) ... ');
    fclose(SerPor);
    fprintf('DONE\n');
   
end
