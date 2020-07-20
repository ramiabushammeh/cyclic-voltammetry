% CV Plotting Function

clear

%% Definitions
comPort = 'COM10';
maxVoltagemV = 1000;
minVoltagemV = 1000;
supplyVolt = 5000;
refVolt = 2500;

fbSelect = 1;
fbResistor = [1814000 1102000 99100 0];

% Scan Rate mV/s x 10
scanRate = 20;

%% Setup Serial Communication
[ sPort,flag ] = setupSerial( comPort );

pause(1);

% turn the LED off
fprintf(sPort, '%c', 'b');

%% Set the system parameters
% Max and min are reversed on purpose
setMinVolt( sPort, maxVoltagemV);
setMaxVolt( sPort, minVoltagemV);
setScanRate( sPort, scanRate);

%% Set up the data window

% variable to keep track of the working status
% 0 - stopped
% 1 - initializing
% 2 - recording 
% 3 - paused

global recStatus;
recStatus = 1;

% Create a figure and axes
f = figure('Visible','off');
f.Position = [400  165  560  550];

% create axes
ax = axes('Units','pixels');
ax.Position = [70   180  440  350];
ax.YLabel.String = 'Current [mA]';
ax.XLabel.String = 'Potential [V vs. Ag/Ag+]';
ax.XLim = [-3 3];
ax.YLim = [-0.015 0.015];
%ax.XLim = [0 256];
%ax.YLim = [0 4096];
ax.XGrid = 'on';
ax.YGrid = 'on';
dataColourOptions = ['b', 'g', 'c', 'm', 'y', 'k'];
currentDataColour = 1;
cycleNumber = 0;
prevVoltage = 0;

% File name edit box
fileName = uicontrol('Style', 'edit');
% Position = [left bottom width height]
fileName.Position = [350 20 200 20];
fileName.String = 'Filename';

% create radio button group for measuring resistances
radioBtnGroup = uibuttongroup('Units', 'pixels');
radioBtnGroup.Position = [195 0 150 120];
radioBtnGroup.SelectionChangedFcn = @setFBResistorCB;
radioBtnGroup.UserData = 1;
fbSelect = radioBtnGroup.UserData;

r1RadioBtn = uicontrol(radioBtnGroup, 'Style', 'radiobutton');
r1RadioBtn.Position = [0 90 100 37.5];
r1RadioBtn.String = 'R1';
r1RadioBtn.UserData = 1;

r2RadioBtn = uicontrol(radioBtnGroup, 'Style', 'radiobutton');
r2RadioBtn.Position = [0 60 100 37.5];
r2RadioBtn.String = 'R2';
r2RadioBtn.UserData = 2;

r3RadioBtn = uicontrol(radioBtnGroup, 'Style', 'radiobutton');
r3RadioBtn.Position = [0 30 100 37.5];
r3RadioBtn.String = 'R3';
r3RadioBtn.UserData = 3;

r4RadioBtn = uicontrol(radioBtnGroup, 'Style', 'radiobutton');
r4RadioBtn.Position = [0 0 100 37.5];
r4RadioBtn.String = 'R4';
r4RadioBtn.UserData = 4;

% Create start button
startBtn = uicontrol('Style', 'pushbutton');
startBtn.String = 'Start';
startBtn.Position = [20 20 50 20];
startBtn.Callback = @recordData;
startBtn.BackgroundColor = 'green';
startBtn.UserData = 0;

% Create stop button
stopBtn = uicontrol('Style', 'pushbutton');
stopBtn.String = 'Stop';
stopBtn.Position = [80 20 50 20];
stopBtn.Callback = @stopButton;
stopBtn.BackgroundColor = 'red';
stopBtn.Visible = 'off';
stopBtn.UserData = 0;

% Create pause button
pauseBtn = uicontrol('Style', 'pushbutton');
pauseBtn.String = 'Pause';
pauseBtn.Position = [140 20 50 20];
pauseBtn.Callback = @pauseButton;
pauseBtn.BackgroundColor = 'yellow';
pauseBtn.Visible = 'off';
pauseBtn.UserData = 0;

% Make figure visble after adding all components
f.Visible = 'on';

%% Record Data

CVRawData = zeros(2, 20);
CVData = zeros(2, 20);
currentIndex = 1;
endIndex = 20;

% Select the feedback resistor 
setFBResistor(sPort, fbSelect);

while recStatus ~= 0
    % This is needed or else the plot won't show
    % set twice as fast as the fastest scan rate
    pause(0.00001);
    
    % Switch States
    % Start button was pressed
    if (startBtn.UserData == 1)     
        recStatus = 2;
        startBtn.UserData = 0;
        startBtn.Visible = 'off';
        stopBtn.Visible = 'on';
        pauseBtn.Visible = 'on';
        
        % clear all the data from the buffer
        flushinput(sPort);
        setOperation(sPort, 'start');
        
    % pause button was pressed
    elseif (pauseBtn.UserData == 1)
        recStatus = 3;
        pauseBtn.UserData = 0;
        startBtn.Visible = 'on';
        stopBtn.Visible = 'off';
        pauseBtn.Visible = 'off';
        
        setOperation(sPort, 'pause');
        
    elseif (stopBtn.UserData == 1)
        recStatus = 0;
        setOperation(sPort, 'stop');
    end
      
    % Recording State
    if (recStatus == 2)
        % Wait for data to become available
        if (sPort.BytesAvailable > 0)
            % read the identifier
            RXByte = fread( sPort, 1, 'uint8');
            
            % if voltage identifier
            if( RXByte == 'v' )
                % wait for the information to become available
                while (sPort.BytesAvailable <= 1)
                end
                
                CVRawData(1, currentIndex) = fread( sPort, 1, 'uint8' );
                
                % Convert the raw ADC Data into supplied
                % supplied voltage = 2*reference voltage - (ADC Val / Max ADC Val) * supply voltage
                CVData(1, currentIndex) = 2*refVolt / 1000 - ( CVRawData(1, currentIndex) / 256 ) * ( supplyVolt / 1000 );
                
                % Remove the reference voltage to get the cell voltage
                % voltage across cell = supplied voltage - reference voltge 
                CVData(1, currentIndex) = CVData(1, currentIndex) - refVolt / 1000;
                
                %
                if ( CVData(1, currentIndex) <= 0 && prevVoltage > 0)
                    %currentDataColour = currentDataColour + 1;
                    cycleNumber = cycleNumber + 1;
                    
                    if ( currentDataColour > 6 )
                        currentDataColour = 1;
                    end
                end
                
                prevVoltage = CVData(1, currentIndex);
                                
            % if current identifier
            elseif( RXByte == 'i' )
                % wait for the information to become available
                while (sPort.BytesAvailable <= 2)
                end 
                
                CVRawData(2,currentIndex) = fread( sPort, 1, 'uint16' );
                
                % current = ( reference voltage - measured voltage ) / feedback resistor
                CVData(2,currentIndex) = ( ( refVolt ) - ( ( CVRawData(2,currentIndex) / 4096 ) * ( supplyVolt ) ) ) / fbResistor(fbSelect);
                
                disp( [' Voltage: ', num2str(CVData(1, currentIndex)),'V (', num2str(CVRawData(1, currentIndex)), ')   Current: ', num2str(CVData(2, currentIndex)),'mA (', num2str(CVRawData(2, currentIndex)),')   Cycle: ', num2str(cycleNumber)]);
                 

                
                cla(ax);
                
                if (currentIndex == 1)
                    scatter(ax, CVData(1,currentIndex), CVData(2,currentIndex), 'MarkerFaceColor', 'red');
                else 
                    scatter(ax, CVData(1,1:currentIndex-1), CVData(2,1:currentIndex-1), 'd','MarkerFaceColor', dataColourOptions(currentDataColour));
                    hold on
                    scatter(ax, CVData(1,currentIndex), CVData(2,currentIndex), 'MarkerFaceColor', 'red');
                end
                
                                
                ax.YLabel.String = 'Current [mA]';
                ax.XLabel.String = 'Potential [V vs. Ag/Ag+]';
                ax.XLim = [-3 3];
                %ax.YLim = [-0.015 0.015];
                %ax.XLim = [0 256];
                %ax.YLim = [0 4096];
                ax.XGrid = 'on';
                ax.YGrid = 'on';
                
                currentIndex = currentIndex + 1;
                
            end
        end
    % Pause State
    elseif (recStatus == 3)

    end
    
    % Handle feedback resistor
    if ( fbSelect ~= radioBtnGroup.UserData )
        fbSelect = radioBtnGroup.UserData;
        setFBResistor( sPort, fbSelect );
    end 
    
    % Array resizing 
    if (currentIndex == endIndex)
       CVRawData = [CVRawData, zeros(2, 20)];
       CVData = [CVData, zeros(2, 20)];
       endIndex = size(CVRawData, 2);
    end
end

disp(' ');
disp('CV test complete');

%% Write Data to file
% fileHeader = [ 'File Name,',        fileName.String         ,...
%                ',Date and Time,',     char(datetime)          ,...
%                ',Max Voltage,',       num2str(maxVoltagemV)   ,...
%                ',Min Voltage,',       num2str(minVoltagemV)   ,...
%                ',Scan Rate,',         num2str(scanRate)       ];
      
csvwrite([fileName.String, 'RAW.csv'], CVRawData);
csvwrite([fileName.String, '.csv'], CVData);
savefig([fileName.String, '.fig']);
save([fileName.String, '.mat'], 'maxVoltagemV', 'minVoltagemV', 'supplyVolt', 'refVolt', 'fbResistor', 'scanRate', 'cycleNumber'); 

disp('Files have been saved');

%% Clean up
closeSerial( );
