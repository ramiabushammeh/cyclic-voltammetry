function [ ] = setScanRate( sPort, scanRate )
% Identifier
fprintf(sPort, '%c', 'e');
% Value
fwrite(sPort, scanRate, 'uint16');
end