function y=spci_filter(x,fp,fc,rp,rs,fs,kind)
%�����ͨ�˲� spci_filter(x,fp,fc,rp,rs,fs)
%ʹ��ע�����ͨ��������Ľ�ֹƵ�ʵ�ѡȡ��Χ�ǲ��ܳ��������ʵ�һ��
%����fp,fc��ֵ��ҪС�� Fs/2
% x: ��Ҫ��ͨ�˲�������
% fp��ͨ����ֹƵ��
% fc�������ֹƵ��
% rp���ߴ���˥��DB������
% rs����ֹ��˥��DB������
% fs������x�Ĳ���Ƶ��
% kind���˲�������
% 1: ������˹
% 2: �б�ѩ��I
% 3: �б�ѩ��II
% 4: ��Բ
% 5: yulewalk

% ��ʼ��ʱ���
t=0:1/fs:(length(x)-1)/fs;
% Ƶ�׷�������
len = length(x);
% ��ʼ��Ƶ�ʵ�
f=fs*(0:len/2 - 1)/len; 
% ��ʼ��y
y = zeros( length(x) , 2);
% ������С�˲�������  
na=sqrt(10^(0.1*rp)-1);  
ea=sqrt(10^(0.1*rs)-1);  
N=ceil(log10(ea/na)/log10(fc/fp));

wn=fp*2/fs;
if kind == 1
    [B, A] = butter(N , wn , 'low'); % ����MATLAB butter������������˲���  
elseif kind == 2
    [B, A] = cheby1(N , rp , wn , 'low'); % ����MATLAB cheby1����������Ƶ�ͨ�˲��� 
elseif kind == 3
    [B, A] = cheby2(N , rs , wn ,'low'); % ����MATLAB �б�ѩ��II������������˲���
elseif kind == 4
    [B, A] = ellip(N , rp , rs , wn , 'low'); % ����MATLAB ellip����������Ƶ�ͨ�˲��� 
elseif kind == 5
    fyule=[0 wn fc*2/fs 1]; % �ڴ˽��е��Ǽ���ƣ�ʵ����Ҫ��η���ȡ���ֵ  
    myule=[1 1 0 0]; % �ڴ˽��е��Ǽ���ƣ�ʵ����Ҫ��η���ȡ���ֵ  
    [B, A]=yulewalk(N , fyule , myule); % ����MATLAB yulewalk����������Ƶ�ͨ�˲���
end;
y=filter(B,A,x); % ���е�ͨ�˲�

end