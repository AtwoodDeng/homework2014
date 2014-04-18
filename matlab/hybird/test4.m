img1 = imread('bill.jpg');
img2 = imread('jobs.jpg');
t = 0.43;
FI1 = fft2(img1);
SFI1 = fftshift(FI1);
FI2 = fft2(img2);
SFI2 = fftshift(FI2);

[L1,W1,k] = size(SFI1)[L2,W2,k] = size(SFI2);
L = min(L1,L2);
W = min(W1,W2);

CFI = SFI1(1:L,1:W,1:k);

CFI(L*t:L*(1-t),W*t:W*(1-t),1:3) = SFI2(L*t:L*(1-t),W*t:W*(1-t),1:3);

SCFI = ifftshift(CFI);

ICFI = ifft2(SCFI) ./ 255 ;

%imshow( mat2gray(abs(IFI)) * 255 );

imshow( mat2gray(abs(ICFI)) );
