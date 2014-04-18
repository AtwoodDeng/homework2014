function [ out ] = point_processing( img_name , tra_name ,  brightness, contrast , gama )
% point processing for image 
%   img_name : the filename of input image
%   recomend : brightness = 100 , contrast = 2 , gama = 0.5

img = imread( [img_name , '.jpg'] );
[r,c,d] = size(img);

% initialize look up table
lookup = zeros( 257 , 3 );

% Inc/Dec Brightness
for i = 1:1:257
    lookup( i , 1 ) = fix_color ( i - 1 + brightness );
    lookup( i , 2 ) = fix_color ( i - 1 + brightness );
    lookup( i , 3 ) = fix_color ( i - 1 + brightness );
end


for i = 1:1:r
    for j = 1:1:c
        img( i , j , 1 ) = lookup( img( i , j , 1 ) + 1 , 1 );
        img( i , j , 2 ) = lookup( img( i , j , 2 ) + 1 , 2 );
        img( i , j , 3 ) = lookup( img( i , j , 3 ) + 1 , 3 );
    end
end

imwrite( img , [ img_name , '_brightness.jpg'] );


% Inc/Dec Contrast
img = imread( [img_name , '.jpg'] );

for i = 1:1:257
    lookup( i , 1 ) = fix_color ( contrast * ( i - 127 ) + 127 );
    lookup( i , 2 ) = fix_color ( contrast * ( i - 127 ) + 127 );
    lookup( i , 3 ) = fix_color ( contrast * ( i - 127 ) + 127 );
end


for i = 1:1:r
    for j = 1:1:c
        img( i , j , 1 ) = lookup( img( i , j , 1 ) + 1 , 1 );
        img( i , j , 2 ) = lookup( img( i , j , 2 ) + 1 , 2 );
        img( i , j , 3 ) = lookup( img( i , j , 3 ) + 1 , 3 );
    end
end


imwrite( img , [ img_name , '_contrast.jpg'] );

% Inc/Dec Gama
img = imread( [img_name , '.jpg'] );

for i = 1:1:257
    lookup( i , 1 ) = fix_color ( 255 * ( i / 255 )^(1/gama) );
    lookup( i , 2 ) = fix_color ( 255 * ( i / 255 )^(1/gama) );
    lookup( i , 3 ) = fix_color ( 255 * ( i / 255 )^(1/gama) );
end


for i = 1:1:r
    for j = 1:1:c
        img( i , j , 1 ) = lookup( img( i , j , 1 ) + 1 , 1 );
        img( i , j , 2 ) = lookup( img( i , j , 2 ) + 1 , 2 );
        img( i , j , 3 ) = lookup( img( i , j , 3 ) + 1 , 3 );
    end
end


imwrite( img , [ img_name , '_gama.jpg'] );

% Histogram Equalization
img = imread( [img_name , '.jpg'] );
tra = imread( [tra_name , '.jpg'] );

remap_tra = remap( tra );
remap_img = remap( img );

for k = 1:1:d
    j = 1;
    for i = 1:1:257
        while remap_img( i , k ) > remap_tra( j , k ) && j < 257
            j = j + 1;
        end
        lookup( i , k) = j ;
    end
end

for i = 1:1:r
    for j = 1:1:c
        img( i , j , 1 ) = lookup( img( i , j , 1 ) + 1 , 1 );
        img( i , j , 2 ) = lookup( img( i , j , 2 ) + 1 , 2 );
        img( i , j , 3 ) = lookup( img( i , j , 3 ) + 1 , 3 );
    end
end


imwrite( img , [ img_name , '_HE.jpg'] );

end

