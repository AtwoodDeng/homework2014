function [ col ] = get_dark( img , x , y , range )
% get the dark channel of img[x][y] and within the range

[r,c,d] = size( img );
col = 255;

for i = max(1,x-range):1:min(r,x+range)
    for j =  max(1,y-range):1:min(c,y+range)
       for k = 1:1:d
            if img( i , j ,k ) < col
                col = img( i , j , k );
            end
       end
    end
end

end

