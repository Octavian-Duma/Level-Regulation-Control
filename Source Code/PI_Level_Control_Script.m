%Date  SCPC

A=332.5;
C=9;

k1=0.624;
k2=-0.015;
k3=-0.0006;
k=0.035;
keta = 8*10^-5;

k11=k2^2+4*(k-k3)*k1;
k12=8*(k-k3);
k13=2*(k-k3);

%%
% Date identificare 
y_sim = out.semnal;
t_sim = out.tout;

plot(t_sim,y_sim);
grid;
Kp=(y_sim(end)-y_sim(1))/0.5;
y_63=0.63*(y_sim(end)-y_sim(1))+ y_sim(1);
T=160;


%%
% Date identificare -verificare

y_sim = out.semnal;
t_sim = out.tout;
y_initial = 3.5;

Kp_identificat = 1.672; 
Tp_identificat = 160;  


Hf_identificat = tf(Kp_identificat, [Tp_identificat, 1]); 

delta_u = 0.5; 

Ts = 0.1; 
t_model = t_sim(1):Ts:t_sim(end);
u_model = delta_u * ones(size(t_model));

y_model = lsim(Hf_identificat, u_model, t_model);
y_model = y_model + y_initial;

figure;
plot(t_sim, y_sim);
hold on;
plot(t_model, y_model, 'r--');
xlabel('Timp (secunde)');
ylabel('Amplitudine semnal');
grid on;
legend('Date Simulink ', 'Model Hf ','Location','east');
hold off;
%%
%Date personale SCPC
%u0=5.2

A=332.5;
C=6.8;
k=0.032;

k1=0.624;
k2=-0.015;
k3=-0.0006;

keta=8*10^-5;

k11=k2^2+4*(k-k3)*k1;
k12=8*(k-k3);
k13=2*(k-k3);

%%
%Date personale identificare
y_sim = out.semnal1;
t_sim = out.tout;

plot(t_sim,y_sim);
grid;
Kf=(y_sim(end)-y_sim(1))/0.5;
y_63=0.63*(y_sim(end)-y_sim(1))+ y_sim(1);
T=190;
Hf=tf(Kf,[T,1]);
%%
%Cautare exacta punct de perioada T -interpolare =>T=191 sec
y = out.semnal1;
t = out.tout;
y_valoare_cautata =  6.1162; 

if y_valoare_cautata >= min(y) && y_valoare_cautata <= max(y)
    [y_unic, indici_unici] = unique(y);
    t_unic = t(indici_unici);
    t_exact = interp1(y_unic, t_unic, y_valoare_cautata);
    fprintf('Valoarea y = %.4f este la t = %.4f secunde.\n', ...
            y_valoare_cautata, t_exact);
else
    fprintf(y_valoare_cautata, min(y), max(y));
end

%%
%Identificare verificare pe datele date personale

y_sim = out.semnal1;
t_sim = out.tout;
y_initial = y_sim(1);

Kp_identificat = 2.464;
Tp_identificat = 190;   

Hf_identificat = tf(Kp_identificat, [Tp_identificat, 1]); 
delta_u = 0.5; 

Ts = 0.1; 
t_model = t_sim(1):Ts:t_sim(end);
u_model = delta_u * ones(size(t_model));

y_model = lsim(Hf_identificat, u_model, t_model);
y_model = y_model + y_initial;

figure;
plot(t_sim, y_sim);
hold on;
plot(t_model, y_model, 'r--');
xlabel('Timp (secunde)');
ylabel('Amplitudine semnal');
grid on;
legend('Date Simulink ', 'Model Hf ','Location','east');
hold off;

%%
%Calculare regulator PI bucla inchisa

T_proces=190;
K_proces=2.464;
Hf = tf(K_proces, [T_proces, 1]); 

T0=T_proces/4;
k_amplificare=1;

H_0=tf(k_amplificare,[T0,1]);

Kp_regulator=T_proces/K_proces/T0;
Ti_regulator=T_proces;

H_regulator=tf(Kp_regulator,[Ti_regulator,1])
pidstd(Kp_regulator,Ti_regulator)

%%
%Feed-forward - compensare
delta_h=20-16.02;
delta_qi=33.47-27.3;
delta_uc=5.7-5.2;
k_compensare=(delta_h/delta_qi)/(delta_h/delta_uc)
%%
%Identificare bucla externa cascada
y_sim = out.externa;
t_sim = out.tout;
plot(t_sim,y_sim);
grid;

%%
%Identificare bucla interna cu T0 = 1 pe 2000 sec
y_sim = out.externa;
t_sim = out.tout;

plot(t_sim,y_sim);
grid;

y_st=mean(y_sim(236):y_sim(244))

Kf=(y_st-y_sim(1))/(30-27.3);
y_63=0.63*(y_st-y_sim(1))+ y_sim(1);
T=400;
Kf=0.425;
Hf=tf(Kf,[T,1])

%%
%identificare bucla externa cu T0 = 0.25 pe 2000 sec
y_sim = out.externa1;
t_sim = out.tout;

plot(t_sim,y_sim);
grid;

y_st=mean(y_sim(236):y_sim(244));

Kf=(y_st-y_sim(1))/(30-27.3);
y_63=0.63*(y_st-y_sim(1))+ y_sim(1);
T=400;
Kf=0.425;
Hf=tf(Kf,[T,1])

%%
%Verificare identifcare bucla externa cascada
y_sim = out.externa;
t_sim = out.tout;
y_initial = 5.34;

Kp_identificat =  0.425;
Tp_identificat =  420;   

Hf_identificat = tf(Kp_identificat, [Tp_identificat, 1]); 
delta_u = (30-27.3);

Ts = 0.1; 
t_model = t_sim(1):Ts:t_sim(end);
u_model = delta_u * ones(size(t_model));

y_model = lsim(Hf_identificat, u_model, t_model);
y_model = y_model + y_initial;

figure;
plot(t_sim, y_sim);
hold on;
plot(t_model, y_model, 'r--');
xlabel('Timp (secunde)');
ylabel('Amplitudine semnal');
grid on;
legend('Date Simulink ', 'Model Hf ','Location','east');
hold off;


%%
%Calcul regulator bucla interna
delta_qi=33.47-27.3;
delta_uc=5.7-5.2;
Kf1=delta_qi/delta_uc;
y63=delta_qi*0.63+27.3;
Tp1=0.79;
Hf1=tf(Kf1,[Tp1,1])

%T01= 1 sec
Kr1=Tp1/Kf1/1;
Ti=Tp1;
Hr1=tf(Kr1,[Ti,1])

%T02= 0.25 sec
Kr2=Tp1/Kf1/0.25;
Hr2=tf(Kr2,[Ti,1])


%%
%Calcul regulator bucla externa
K_proces=0.425;
T_proces=420;   
T0=47.5;
Kp_regulator=T_proces/K_proces/T0;
Ti_regulator=T_proces;

H_regulator=tf(Kp_regulator,[Ti_regulator,1])
pidstd(Kp_regulator,Ti_regulator);