%% Open Serial Port

function [SerPor]= OpenSerialPort()

    %fprintf (1,'%s\n', 'OpenSeriaPort');
    SerPor = serial('COM1', 'BaudRate', 115200 );
    set(SerPor,'InputBufferSize',128);
    warning    off all; %THIS IS NASTY!!! We do this because of timeout warning !!!!!!
    fprintf(1, 'STARTING SERIAL PORT COM1 (BAUD RATE: 115200) ... ');
    fopen(SerPor);
    fprintf('DONE\n');
    %SerPor.Terminator = '';
    %SerPor.BytesAvailable;
   
end
