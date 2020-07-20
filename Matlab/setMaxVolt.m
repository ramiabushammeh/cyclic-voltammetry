function [ ] = setMaxVolt( sPort, maxVoltmV )
% Identifier
fprintf(sPort, '%c', 'c');
% Value
fwrite(sPort, maxVoltmV, 'uint16');
end

