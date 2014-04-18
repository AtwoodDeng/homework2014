function [ out ] = fix_color( in )
% fix the rgb color to 0-255
%   

out = min( in , 255);
out = max( out , 0 ) ;


end

