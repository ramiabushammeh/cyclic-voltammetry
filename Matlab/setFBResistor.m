function [ ] = setFBResistor( sPort, fbResistor )
% Identifier
fprintf(sPort, '%c', 'l');
% Value
fwrite(sPort, fbResistor, 'uint8');
end