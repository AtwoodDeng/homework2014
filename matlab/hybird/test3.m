img = imread('bigcat.jpg');
FI = abs(fft2(img));
NFI = 255*mat2gray(FI);
SFI = fftshift(NFI);
imgray = rgb2gray(SFI);

%fgray = spci_filter(FI,300,600,0.2,40,5000,1);
%fgray = imgray;

%isfft = ifftshift( fgray );
%mfft = isfft;
ifft = abs(ifft2(FI));

imshow(isfft);