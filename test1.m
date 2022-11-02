N=100;
pn=0.1;
gama=0.16;
for i=1:1:20
Pf(i)=0.001+(i-1)*0.005 %单点虚警概率
thr=N*pn^2+sqrt(2*N)*pn^2*erfcinv(Pf(i)); %判决门限
Pds(i)=erfc((thr-(N+gama*N)*pn^2)/(sqrt(2*(N+2*gama*N))*pn^2)) %单点检测概率
end
plot(Pf,Pds,'-+');
xlabel('Pf');
ylabel('Pds');
legend('SNR=-20db');
axis([0 0.1 0 1]);