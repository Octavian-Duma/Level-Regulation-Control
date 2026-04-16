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
%Calcul regulator bucla externa
K_proces=0.425;
T_proces=420;   
T0=47.5;
Kp_regulator=T_proces/K_proces/T0;
Ti_regulator=T_proces;

H_regulator=tf(Kp_regulator,[Ti_regulator,1])
 pidstd(Kp_regulator,Ti_regulator)

%Conditie_initiala=27.3;

%% ARDUINO CODE
% const float Ts = 0.5f; //perioada de esantionare
% const unsigned long Ts_ms = 500;//perioada de esantionare in milisec
% 
% const float Kp = 20.8f;
% const float Ti = 420.0f;
% //coeficienti discreti
% const float b0 = Kp;
% const float b1 = -Kp * (1.0f - Ts / Ti);
% 
% const float CONDITIE_INITIALA = 27.3f;
% // Vectori de memorie: [0] = valoarea curentă, [1] = valoarea anterioară
% float c[2] = {CONDITIE_INITIALA, CONDITIE_INITIALA};
% float e[2] = {0.0f, 0.0f};
% 
% union DataPackage {
%   byte b[4];//permite acces ca sir de 4 octeti individuali
%   float fval;//permite acces float intreg compus din 4 octeti
% };
% 
% unsigned long lastSampleTime = 0;
% 
% void setup() {
%   Serial.begin(19200);
% }
% 
% void loop() {
%   unsigned long now = millis(); //timpul exact curent in milisec
% 
%   if (now - lastSampleTime >= Ts_ms) {
%     lastSampleTime += Ts_ms;      // pas fix de 0.5 s nedepasit
% 
%     // citim eroarea dacă a venit ceva nou
%     if (Serial.available() >= 4) {
%       DataPackage inData;
%       for (int i = 0; i < 4; i++) {
%         inData.b[i] = Serial.read();// citim cei 4 octeti de la Simulink
%       }
%       e[0] = inData.fval;//Recompune numarul float (Eroarea curenta)
%     }
% 
%     // PI discret
%     c[0] = c[1] + b0 * e[0] + b1 * e[1];
% 
%     // trimitem comanda
%     DataPackage outData;
%     outData.fval = c[0];// punem rezultatul float în pachet
%     Serial.write(outData.b, 4);//trimitem cei 4 octeti inapoi in simulink
% 
%     // update istoric valoare curenta devine anterioara
%     c[1] = c[0];
%     e[1] = e[0];
%   }
% }
%%