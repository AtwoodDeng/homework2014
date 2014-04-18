% ��ͼ��Ҫ�������Լ���ͼƬ��
orgImage = imread('ziwei.jpg', 'jpg'); 
figure(1); imshow(orgImage); 
% ʹ��fft2�任
fftImage = fftshift(fft2(orgImage));   % 2d fft 
ampImage= abs(fftImage); 

%��ʾͼƬ
figure(2); imshow(ampImage,  [0  10000 ]); 

%������Ƕ�fft2��ͼƬ����Ƶ���´�����ϲ���Ҫ�ɡ�
% Convolution (low-pass filtering) 
filter = fspecial('gaussian',[10 10], 4);  % gaussian kernel 
filterImage = conv2(orgImage, filter);     % convolution 
figure(3); imshow(filterImage, [0 250]); 

% 2D FFT of filtered image 
fftFilterImage = fftshift(fft2(filterImage)); 
ampFilterImage= abs(fftFilterImage); 
figure(4); imshow(ampFilterImage,  [0  10000 ]);