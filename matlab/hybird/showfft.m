function [ out ] = showfft( file , outfile )
%show the fft image of the input image 
%    file : input file name
% outfile : output file name

img = imread(file);
FI = abs(fft2(img));
MI = mat2gray(FI)*255;
SMI = fftshift(MI);

%imshow(rgb2gray(SMI));
imwrite( rgb2gray(SMI) , outfile );
end

