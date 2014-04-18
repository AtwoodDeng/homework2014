% 读图（要换成你自己的图片）
orgImage = imread('ziwei.jpg', 'jpg'); 
figure(1); imshow(orgImage); 
% 使用fft2变换
fftImage = fftshift(fft2(orgImage));   % 2d fft 
ampImage= abs(fftImage); 

%显示图片
figure(2); imshow(ampImage,  [0  10000 ]); 

%下面的是对fft2的图片，在频域下处理，你肯不需要吧。
% Convolution (low-pass filtering) 
filter = fspecial('gaussian',[10 10], 4);  % gaussian kernel 
filterImage = conv2(orgImage, filter);     % convolution 
figure(3); imshow(filterImage, [0 250]); 

% 2D FFT of filtered image 
fftFilterImage = fftshift(fft2(filterImage)); 
ampFilterImage= abs(fftFilterImage); 
figure(4); imshow(ampFilterImage,  [0  10000 ]);