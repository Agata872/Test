clear all;close all;clc;
%产生瑞利噪声
sigma=2;t=1e-3;fs=1e6;ts=1/fs;
t1=0.05e-3:1/fs:0.2e-3-1/fs;
n=length(t1);
rand('state',0);
u=rand(1,n);
rayleigh_noise=sqrt(2*log2(1./u))*sigma;

%产生目标回波
N=t/ts;
N=uint32(N);
s_pc_1=[zeros(1,100),1,zeros(1,N-101)];
noise=rand(1,N);
rayleigh_clutter=[zeros(1,50),rayleigh_noise,zeros(1,N-200)];
figure,subplot(3,1,1),plot((0:ts:t-ts),s_pc_1),title('目标回波信号');
subplot(3,1,2),plot((0:ts:t-ts),noise),title('热噪声');
subplot(3,1,3),plot((0:ts:t-ts),rayleigh_clutter),title('瑞利杂波');
s_pc=s_pc_1+0.1*rayleigh_clutter+0.1*noise;
figure(2),plot((0:ts:t-ts),s_pc),
xlabel('t(单位：s)'),title('叠加了瑞利分布杂波、热噪声的目标回波');

%慢门限恒虚警处理
cfar_result=zeros(1,N);
cfar_result(1,1)=s_pc(1,1);
for i=2:N
   cfar_result(i)=s_pc(1,i)/mean(s_pc(1,1:i));
end
figure(3),plot((0:ts:t-ts),cfar_result),
xlabel('t(单位：s)'),title('采用慢门限处理结果');

%快门限恒虚警处理
cfar_k_result=zeros(1,N);
cfar_k_result(1,1)=s_pc(1,1)/(sqrt(2)/pi*mean(s_pc(1,2:17)));

%第1点恒虚警处理时噪声均值由后面的16点的噪声确定
for i=2:16  %第2点到16点的恒虚警处理的噪声均值由其前面和后面的16点的噪声共同决定
    noise_mean=sqrt(2)/pi*mean(s_pc(1,1:i-1)+mean(s_pc(1,i+1:i+16)))/2;
    cfar_k_result(1,i)=s_pc(1,i)/noise_mean;
end

for i=17:N-17 
    %正常的数据点的恒虚警处理的噪声均值由其前面和后面的各26点的噪声决定
    noise_mean=sqrt(2)/pi*max(mean(s_pc(1,i-16:i-1)),mean(s_pc(1,i+1:i+16)));
    cfar_k_result(1,i)=s_pc(1,i)/noise_mean;
end
for i=N-16:N-1
    %倒数第16点到倒数第2点恒虚警处理的噪声的均值由其前面16点和后面的噪声共同决定
    noise_mean=sqrt(2)/pi*(mean(s_pc(1,i-16:i-1))+mean(s_pc(1,i+1:N)))/2;
    cfar_k_result(1,i)=s_pc(1,i)/noise_mean;
end
%最后一点的恒虚警处理的噪声均值由其前面16点的噪声决定
cfar_k_result(1,N)=s_pc(1,N)/(sqrt(2)/pi*mean(s_pc(1,N-16:N-1)));
figure(4) 
plot(0:ts:t-ts,cfar_k_result),xlabel('t(单位：s)'),title('采用快门限恒虚警处理结果');

