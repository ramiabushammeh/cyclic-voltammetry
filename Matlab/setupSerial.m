function [ sPort,flag ] = setupSerial( comPort ) 
    % Initialatize the serial port communication between MATLAB uC
    % Ensures that the uC is communicating with MATLAB. 
    % There is code on the uC to acknowledge this. 
    % Define the COM Port as :
    %   comPort = 'COM#';
    % If setup is complete then the value of setup is returned as 1, else 0

    flag = 1;
    
    % First close any current serial channels open in MATLAB
    com_objs = instrfindall; %Note: "instrfindall" will display all pertinent information about any open serial port
    if ~isempty(com_objs)
        fclose(com_objs); %close this serial COM port connection, but leave the serial object in existence
        delete(com_objs); %delete the serial object too
    end

    sPort = serial(comPort); % create a serial port object 

    % set serial parameters
    set(sPort, 'DataBits', 8);
    set(sPort, 'StopBits', 1);
    set(sPort, 'BaudRate', 9600);
    set(sPort, 'Parity', 'none');

    fopen(sPort); % connect the serial port
    
%     % acknolagement routine 
% 
%     a = 'b';
% 
%     while (a ~= 'a')
%         
%         fprintf(sPort, '%c', 'a'); % print over the serial port in character format the letter a
%         
%         a = fread(sPort, 1, 'uchar'); % read single binary element as an 8 bit unsigned character
%     end
% 
%     % display connection results
%     if(a == 'a')
%         display(sprintf('\nHandshake Complete\n\nSerial communication has been established\n'));   
%     else
%         display(sprintf('\nHandshake Timeout\n\nSerial communication has failed\n'));
%     end
% 
%     % send 'a' to the microcontroller so that it can start working 
%     fprintf(sPort, '%c', 'a'); % print over the serial port in character format the letter a

end

