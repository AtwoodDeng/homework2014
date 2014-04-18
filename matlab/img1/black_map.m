function [ out ] = black_map( img , bw )
%output the black map for image with the boundary width

[r,c,d] = size(img);
out = zeros( r , c  , d);

for i = 1:1:r
    for j = 1:1:c
        out(i,j,1) = get_dark( img , i , j , bw );
        out(i,j,2) = out(i,j,1);
        out(i,j,3) = out(i,j,1);
    end
end

end

