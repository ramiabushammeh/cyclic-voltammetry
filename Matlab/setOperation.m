function [ ] = setOperation( sPort, state )

switch (state)
    case 'start'
        fprintf(sPort, '%c', 'f');
    case 'stop'
        fprintf(sPort, '%c', 'g');
    case 'pause'
        fprintf(sPort, '%c', 'h');      
end

end