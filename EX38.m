%--------------------------------------------------------------------------
% PURPOSE
%    Test multifiber beams - incremental solving - elastoplastic and damage
%    laws
%--------------------------------------------------------------------------
% REFERENCES
%    Benjamin RICHARD
%    CEA, DEN, DANS, DM2S, SEMT, EMSI
%    benjamin.richard[at]cea.fr
%    16-09-2017
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
FILE = '38_1.mail';
ME   = INPUT.ACQU(FILE,'MAIL');

%% Definition of the model - cross section scale
MO1  = MODEL('SBET' ,'MECHANICS','ELASTICITY','ISOTROPIC','DAMAGE','MAZARS','QUAS');
MO2  = MODEL('SAINF','MECHANICS','ELASTICITY','ISOTROPIC','PLASTICITY','VONMISES','POJS');
MO3  = MODEL('SASUP','MECHANICS','ELASTICITY','ISOTROPIC','PLASTICITY','VONMISES','POJS');
MOT  = [MO1 [MO2 MO3]];

%% Definition of the materials - cross section scale
MA1  = CHAMELEM.MATE(MO1,'youn',36000e6,'nu',0.2,'rho',...
    2500,'ay',0.83,'az',0.83,'at',1.2,'k0',1.0e-4,'bt',15000,...
    'beta',1.06,'ac',0.8,'bc',1500);
MA2  = CHAMELEM.MATE(MO2,'youn',210000e6,'nu',0.3,'rho',...
    2500,'sect',5e-1,'sigy',500e6,'K',0.05*210000e6);
MA3  = CHAMELEM.MATE(MO3,'youn',210000e6,'nu',0.3,'rho',...
    2500,'sect',5e-1,'sigy',500e6,'K',0.05*210000e6);
MAT  = [MA1 [MA2 MA3]];

%% Definition of the beam
FILE = '38_2.mail';
ME   = INPUT.ACQU(FILE,'MAIL');

%% Definition of the model -  beam scale
MOB1 = MODEL('LT','MECHANICS','ELASTICITY','SECTION','PLASTICITY',...
    'SECTION','TIMO');
MOBT = MOB1;

%% Topology
TP   = TOPOLOGY(MOBT);

%% Definition of the material - beam scale
MAB1 = CHAMELEM.MATE(MOB1,'mods',MOT,'mats',MAT);
MABT = MAB1;

%% Dirichlet boundary conditions
CL1  = MATRICE('DIRI','P1',1,2,3,4,5,6);
CL2  = MATRICE('DIRI','P2',1);
CLT  = [CL1 CL2];

%% Loading
FO1 = CHPOINT.DEPI(CL2,1.0);

EV1 = EVOL([0 1 2],[0 1.0e-2 0],'Time','Displacement (m)');
CHT = TIMELOAD(FO1,EV1,'DIRI');

%% Static analysis
PB1 = PROBLEM('model',MOBT,'mater',MABT,'diric',CLT,'loadt',CHT,'comp_time',0:0.0025:0.2,...
    'solve_type','QUASI_NEWTON');
SOL = SOLVERS(PB1);

%% Reaction curve
EV_OUT = EVOL.REAC(SOL,CL2,EV1,1);
plot(EV_OUT);
close all

%% Non regrassion test
if abs(EV_OUT.ordo(end) - 1.0224e+09)/1.0224e+09 > 1.0e-4
    
    error('TEST IS NOT SUCCESSFUL')
    
else
    
    disp('---------------------------------')
    disp('038_INCR_DAM_PLAS_MULTIFIBER')
    disp('TEST IS SUCCESSFUL')
    disp('---------------------------------')
    
end