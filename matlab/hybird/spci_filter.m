function y=spci_filter(x,fp,fc,rp,rs,fs,kind)
%特殊低通滤波 spci_filter(x,fp,fc,rp,rs,fs)
%使用注意事项：通带或阻带的截止频率的选取范围是不能超过采样率的一半
%即，fp,fc的值都要小于 Fs/2
% x: 需要带通滤波的序列
% fp：通带截止频率
% fc：阻带截止频率
% rp：边带区衰减DB数设置
% rs：截止区衰减DB数设置
% fs：序列x的采样频率
% kind：滤波器类型
% 1: 巴特沃斯
% 2: 切比雪夫I
% 3: 切比雪夫II
% 4: 椭圆
% 5: yulewalk

% 初始化时间点
t=0:1/fs:(length(x)-1)/fs;
% 频谱分析长度
len = length(x);
% 初始化频率点
f=fs*(0:len/2 - 1)/len; 
% 初始化y
y = zeros( length(x) , 2);
% 计算最小滤波器阶数  
na=sqrt(10^(0.1*rp)-1);  
ea=sqrt(10^(0.1*rs)-1);  
N=ceil(log10(ea/na)/log10(fc/fp));

wn=fp*2/fs;
if kind == 1
    [B, A] = butter(N , wn , 'low'); % 调用MATLAB butter函数快速设计滤波器  
elseif kind == 2
    [B, A] = cheby1(N , rp , wn , 'low'); % 调用MATLAB cheby1函数快速设计低通滤波器 
elseif kind == 3
    [B, A] = cheby2(N , rs , wn ,'low'); % 调用MATLAB 切比雪夫II函数快速设计滤波器
elseif kind == 4
    [B, A] = ellip(N , rp , rs , wn , 'low'); % 调用MATLAB ellip函数快速设计低通滤波器 
elseif kind == 5
    fyule=[0 wn fc*2/fs 1]; % 在此进行的是简单设计，实际需要多次仿真取最佳值  
    myule=[1 1 0 0]; % 在此进行的是简单设计，实际需要多次仿真取最佳值  
    [B, A]=yulewalk(N , fyule , myule); % 调用MATLAB yulewalk函数快速设计低通滤波器
end;
y=filter(B,A,x); % 进行低通滤波

end