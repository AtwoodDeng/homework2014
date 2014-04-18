function [ out ] = remap( in )
%remap the picture
%   
[r,c,d] = size(in);

out = zeros( 257 , 3 );
for i = 1:1:r
    for j = 1:1:c
        for k = 1:1:d
            out( in ( i , j , k ) + 1 , k ) =  out( in ( i , j , k ) + 1 , k ) + 1;
        end
    end 
end
for k = 1:1:d
    out(:,k) = out(:,k)./sum( out(:,k) );
end
for i = 2:1:257
    for k = 1:1:d
        out( i , k ) =  out( i , k ) + out ( i - 1 , k );
    end
end

end

