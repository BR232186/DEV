%--------------------------------------------------------------------------
% PURPOSE
%    Test multifiber beams
%--------------------------------------------------------------------------
% REFERENCES
%    Benjamin RICHARD
%    CEA, DEN, DANS, DM2S, SEMT, EMSI
%    benjamin.richard[at]cea.fr
%    22-08-2016
%--------------------------------------------------------------------------
% COMMENTS
% 
% 
% 
%--------------------------------------------------------------------------

%% Clearing off

%% Global variables
global ME TP 

%% Definition of the section
FILE = 'sec_bet.mail';
ME   = INPUT.ACQU(FILE,'MAIL');

%% Definition of the model
MO1  = MODEL('SBET' ,'MECHANICS','ELASTICITY','ISOTROPIC','QUAS');
MO2  = MODEL('SAINF','MECHANICS','ELASTICITY','ISOTROPIC','POJS');
MO3  = MODEL('SASUP','MECHANICS','ELASTICITY','ISOTROPIC','POJS');
MOT  = [MO1 [MO2 MO3]];
% MOT  = [MO1 [MO2]];

%% Definition of the material
MA1  = CHAMELEM.MATE(MO1,'youn',36000e6,'nu',0.2,'rho',...
    2500,'ay',0.83,'az',0.83);
MA2  = CHAMELEM.MATE(MO2,'youn',210000e6,'nu',0.3,'rho',...
    2500,'sect',0);
MA3  = CHAMELEM.MATE(MO3,'youn',210000e6,'nu',0.3,'rho',...
    2500,'sect',0);
MAT  = [MA1 [MA2 MA3]];
% MAT  = [MA1 [MA2]];

%% Definition of the beam
FILE = 'seg2.mail';
ME   = INPUT.ACQU(FILE,'MAIL');

%% Definition of the model
MOB1 = MODEL('LT','MECHANICS','ELASTICITY','SECTION','PLASTICITY',...
    'SECTION','TIMO');
MOBT = MOB1;

%% Topology
TP   = TOPOLOGY(MOBT);

%% Definition of the material
MAB1 = CHAMELEM.MATE(MOB1,'mods',MOT,'mats',MAT);
MABT = MAB1;

%% Stiffness matrix
RIG1 = MATRICE('STIFF',MOB1,MAB1);

FO1  = CHPOINT('LABEL','P2',2,10e3);
CL1  = MATRICE('DIRI','P1',1,2,3,4,5,6);

RIGT = [RIG1 CL1];
USOL = SOLVERS.RESO(RIGT,FO1);

EPS0 = CHAMELEM.EPSI(MOBT,USOL,MABT);
VAR0 = CHAMELEM.CHAM_INIT(MOBT,MABT);
SIG0 = CHAMELEM.COMP(MOBT,1,MABT,EPS0,VAR0,0);
BSI0 = CHPOINT.BSIGMA(MOBT,MABT,SIG0);
[chp1,chp2,chp3,chp4,C] = CHPOINT.REAC(CL1,USOL);
chp1 + chp2
up2 = CHPOINT.EXTR(USOL,'P2',2)

return










%% Boundary conditions

% Line L1 fixed
CL1  = MATRICE('DIRI','P1',1);
CL2  = MATRICE('DIRI','P4',1);
CL3  = MATRICE('DIRI','LT',2);
CLT  = [CL1 [CL2 CL3 ]];

% Definition of a prescribed displacement
FO1  = CHPOINT.DEPI(CL2,1);

%% Loading
EV1 = EVOL([0 1],[0 7.5e-4],'Time','Displacement (m)');
CHT = TIMELOAD(FO1,EV1,'DIRI');

%% Static analysis
PB1 = PROBLEM('model',MOT,'mater',MAT,'diric',CLT,'loadt',CHT,'comp_time',0:0.01:1,...
    'solve_type','SECANT_NEWTON');
SOL = SOLVERS(PB1);

%% Post-treatment

% Displacement at point P3 X and Y
EV_OUT = EVOL.REAC(SOL,CL1,EV1,1);
plot(EV_OUT);

close all

%% Non regrassion test
if abs(EV_OUT.ordo(9) + 1.313076342233628e+06) > 1.0e-4

    error('TEST IS NOT SUCCESSFUL')
    
else
    
    disp('---------------------------------')
    disp('054_INCR_NLINE_BARRE_MAZARS_LOCAL_UPDATED')
    disp('TEST IS SUCCESSFUL')
    disp('---------------------------------')
    
end