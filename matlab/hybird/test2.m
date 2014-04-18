img=imread('ziwei.jpg','jpg');
subplot(1,2,1)
imshow(img);
s=fft2(img);
fs = spci_filter(FI,100,10000,0.2,20,300,1);
ss=real(ifft2(fs));
sss=uint8(ss);
subplot(1,2,2);
imshow(sss);