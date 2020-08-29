function feature_vec = Extract_Features(wind_mat,label,fA,fG,fP,fT)
% creating the feature vec for every example
feature_vec=zeros(1,10);

A_sig=wind_mat{:,1};
G_sig=wind_mat{:,2};
P_sig=wind_mat{:,3};
T_sig=wind_mat{:,4};

[P_P,f_P]=pwelch(P_sig-mean(P_sig),[],[],[],fP);
[P_G,f_G]=pwelch(G_sig-mean(G_sig),[],[],[],fG);
[P_A,f_A]=pwelch(A_sig-mean(A_sig),[],[],[],fA);


%% Pressure's features

% pressure first derivative
first_der_P=mean(diff(P_sig));
feature_vec(1,1)=first_der_P;

% max frequency of pressure without DC
max_valfreq_P = max(log10(P_P));
max_f=f_P(find(log10(P_P)==max_valfreq_P));
feature_vec(1,2)=max_f;

% skewness of pressure
skewness_P=skewness(P_sig);
feature_vec(1,3)=skewness_P;

%% Gyroscope's features

% mean of gyroscope signal
meanG=mean(G_sig);
feature_vec(1,4)=meanG;

% mean first derivetive of gyroscope
deriv1_G=mean(diff(G_sig));
feature_vec(1,5)=deriv1_G;
 
% max frequency of Gyroscop after DC
max_valfreq_G= max(log10(P_G));
max_f=f_G(find(log10(P_G)==max_valfreq_G));
feature_vec(1,6)=max_f;

%% Accilerumeter's features
% Calculate Accilerumeter's max-min
PtP_A=max(A_sig)-min(A_sig);
feature_vec(1,7)=PtP_A;

% count peaks of Accilerumeter 
[peaks_loc,~]=findpeaks(P_A);
countpeaks_G=length(peaks_loc);
feature_vec(1,8)=countpeaks_G;

% Calculate mean max-min of accelerometer
mean_10=mean(A_sig(1:round(0.05*end)));
mean_90=mean(A_sig(round(0.95*end):end));
mean_without_noise_A=mean_90-mean_10;
feature_vec(1,9)=mean_without_noise_A;

%% Termperature's features
P_T=mean(sqrt((T_sig.^2)+(P_sig.^2)));
feature_vec(1,10)=P_T;
 

end

