function [Vfin,Ffin,sortie,sortie2,sortie3,sortie4] = IDEFIX_1DDL(Vini,Fini,Uini,dU,para)

% ----------------------------------------------------------------------- %
%% Initialisation des valeurs 
% Parametres modele
% -----------------
% Limite �lastique en d�placement : 
Ue  = para(1);%m
% Raideur �lastique :
K   = para(2);%N/m
% Coefficient de perte de raideur �lastique : 
p   = para(3);
% Coefficient de fragilit� entre 0 et 1: 
q   = para(4);
% Largeur des boucles d'hyst�r�se :
api = para(5);
% Pente initiale boucles d'hyst�r�ses :
bpi = para(6);
% D�placement de refermeture de fissure
Uc = para(7);
% Coefficient de pincement
lp = para(8);


% Energie de fissuration :
Ye  = 0.5*K*Ue^2;
% Param�tres Armstrong-Fredericks :
C   = bpi;
gamma = 2/api;
% Fonction de refermeture
f = @(u) (1 - lp)*exp(-abs((u/Uc).^1));

% Variables
% ---------
% Endommagement positif
Dp0 = Vini(1); 
% Ecrouissage endommagement positif
Zp0 = Vini(2); 
% Endommagement n�gatif
Dm0 = Vini(3); 
% Ecrouissage endommagement n�gatif
Zm0 = Vini(4); 
% Force de rappel glissement/frottement
Xpi = Vini(5); 
% Glissement
Upi = Vini(6); 
% Ecrouissage cinematique glissement/frottement
alphapi = Vini(7); 
% ----------------------------------------------------------------------- %

% Debut de l'increment   
Ufin = Uini + dU;


%% 1. Gestion de l'endommagement :
%  -------------------------------

% Calcul de l'�nergie de d�formation �lastique :
Uk  = Ufin;
dUk = dU;
Y = 0.5 * K * Uk^2;
% Calcul de la variable d'endommagement :
if Uk >= 0
    critD = Y - Zp0  - Ye;
    if critD >0
        % Calcul de l'endommagement positif :
        Dpfin = (1 - p)  * (1 - (Ye/Y)^(q));
        Zpfin = Zp0 + 0.5 * K * dUk * (2 * Uk - dUk) ;
    else
        Dpfin = Dp0;
        Zpfin = Zp0;
    end;
    
    Dmfin = Dm0;
    Zmfin = Zm0;
    Dfin = Dpfin;
else
    critD = Y - Zm0  - Ye;
    if critD >0
        % Calcul de l'endommagement n�gatif :
        Dmfin =  (1 - p) * (1 - (Ye/Y)^(q));
        Zmfin = Zm0 + 0.5 * K * dUk * (2 * Uk - dUk) ;
    else
        Dmfin = Dm0;
        Zmfin = Zm0;
    end;
    Dpfin = Dp0;
    Zpfin = Zp0;
    Dfin = Dmfin;
end;

Dh = max(Dmfin,Dpfin);
Kp = K * (1 - f(Ufin) * Dfin);

%% 2. Gestion du frottement non lin�aire :
%  ---------------------------------------

% Contrainte test : 
Fpik = Dh * Kp * (Uk - Upi);
% Contrainte relative test :
Gpik = Fpik  - Xpi;

% à coder : test Xpi > parametre => sub-stepping

% Fonction crit�re : 
fpi_trial0 = abs(Gpik);

if fpi_trial0 > 0
    fpik      = abs(Gpik);
    crit      = 1.;
    while crit > 1.E-10
%         dlambdapi = fpik / (Dh * K + C * (-sign(Gpik) * (-sign(Gpik) + gamma/2 * Xpi)));
        dlambdapi = fpik / (Dh * Kp + C * (1 - gamma/2 * Xpi * sign(Gpik)));
        dUpi      = dlambdapi * sign(Gpik);
        Upi       = Upi + dUpi;
        dXpi      = - dlambdapi * C * (-sign(Gpik) + gamma/2 * Xpi);
        Xpi       = Xpi + dXpi;
        Fpik      = Fpik - Kp * Dh * dlambdapi*sign(Gpik);
        dalphapi  = dXpi/C;
%         alphapi   = alphapi + dlambdapi ;
        alphapi = alphapi + dalphapi;
        Gpik      = Fpik  - Xpi;
        fpik      = abs(Gpik);
        crit      = abs(fpik/fpi_trial0);        
    end
    alphapifin = alphapi;
    Xpifin     = Xpi;
    Upifin     = Upi;
else
    alphapifin = alphapi;
    Xpifin     = Xpi;
    Upifin     = Upi;
end;

Kd = (1 - Dfin) * Kp ;    
Fpfin  = Kd * Uk;
Fpifin = Dh * Kp * (Uk - Upi);
Ffin   = Fpfin + Fpifin;
sortie = Kd;
sortie2 = Dfin;
sortie3 = Fpifin;
sortie4 = Upifin;

%% Enregistrement des variables
%  ----------------------------

% Variables
% ---------
% Endommagement positif
Vfin(1)  = Dpfin; 
% Ecrouissage endommagement positif
Vfin(2)  = Zpfin; 
% Endommagement n�gatif
Vfin(3)  = Dmfin; 
% Ecrouissage endommagement n�gatif
Vfin(4)  = Zmfin; 
% Force de rappel glissement/frottement
Vfin(5) = Xpifin; 
% Glissement
Vfin(6) = Upifin; 
% Ecrouissage cinematique glissement/frottement
Vfin(7) = alphapifin; 
