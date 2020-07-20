function [ ] = setMinVolt( sPort, minVoltmV )
% Identifier
fprintf(sPort, '%c', 'd');
% Value
fwrite(sPort, minVoltmV, 'uint16');
end

