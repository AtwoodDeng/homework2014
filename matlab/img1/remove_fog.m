function out = remove_fog(file_name)
%   GUIDEDFILTER   O(1) time implementation of guided filter.
%
%   - guidance image: I (should be a gray-scale/single channel image)
%   - filtering input image: p (should be a gray-scale/single channel image)
%   - local window radius: r
%   - regularization parameter: eps

img_name = imread([file_name , '.bmp']);
I = double(img_name) / 255;
% ��ȡͼ���С
[h,w,c] = size(I);
%ȥ��ϵ��
w0  = 0.95;
img_size = w * h;
%��ʼ�����ͼ��
dehaze = zeros(h,w,c);
%��ʼ����Ӱͨ��ͼ��
win_dark = zeros(h,w);
for i=1:h                 
    for j=1:w
        win_dark(i,j)=min(I(i,j,:));%������ͨ�������ֵ����dark_I(i,j),��Ȼ����άͼ����˶�άͼ
    end
 end
win_dark = ordfilt2(win_dark,1,ones(9,9),'symmetric');

imwrite( uint8(win_dark .* 255 ) , [file_name , '_dark.jpg']);

%�����������A�����ԭ��������ġ�Single Image Haze Removal Using Dark Channel Prior��
dark_channel = win_dark;
A = max(max(dark_channel));
[i,j] = find(dark_channel==A);
i = i(1);
j = j(1);
A = min ( 230 / 255 , mean(I(i,j,:)));

fprintf( 'A = %d\n' , A*255 );
%�����ʼ��transmission map
transmission = 1 - w0 * win_dark / A;


%��guided filter��trasmission map��soft matting
gray_I = mean( I(:,:,1) , 3 ) ;%����gray_I ������RGBͼ�����κ�һ��ͨ��
p = transmission;
r = 80;
eps = 10^-3;
transmission_filter = guidedfilter(gray_I, p, r, eps);
t0 = 0.2;
t1 = max(t0,transmission_filter);
imwrite( uint8(t1 .* 255 ) , [file_name , '_guide.jpg']);
for i=1:c
    for j=1:h
        for l=1:w
            dehaze(j,l,i)=(I(j,l,i)-A)/t1(j,l)+A;
        end
    end
end

imwrite( dehaze , [file_name , '_remove.jpg'] );
