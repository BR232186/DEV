%--------------------------------------------------------------------------
% PURPOSE
%    Test multifiber beams - incremental solving - elastoplastic and damage
%    laws - bending loading
%--------------------------------------------------------------------------
% REFERENCES
%    Benjamin RICHARD
%    CEA, DEN, DANS, DM2S, SEMT, EMSI
%    benjamin.richard[at]cea.fr
%    18-10-2017
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
FILE = 'EX44_1.mail';
ME   = INPUT.ACQU(FILE,'MAIL');

%% Definition of the model - cross section scale
MO1  = MODEL('SBET' ,'MECHANICS','ELASTICITY','ISOTROPIC','DAMAGE','MAZARS','QUAS');
MO2  = MODEL('SAINF','MECHANICS','ELASTICITY','ISOTROPIC','PLASTICITY','VONMISES','POJS');
MO3  = MODEL('SASUP','MECHANICS','ELASTICITY','ISOTROPIC','PLASTICITY','VONMISES','POJS');
MOT  = [MO1 [MO2 MO3]];

%% Definition of the materials - cross section scale
MA1  = CHAMELEM.MATE(MO1,'youn',36000e6,'nu',0.2,'rho',...
    2500,'ay',0.83,'az',0.83,'at',0.8,'k0',1.0e-4,'bt',12000,...
    'beta',1.06,'ac',1.2,'bc',1500);
MA2  = CHAMELEM.MATE(MO2,'youn',200000e6,'nu',0.3,'rho',...
    7100,'sect',pi*0.012^2/4,'sigy',500e6,'K',0.01*210000e6);
MA3  = CHAMELEM.MATE(MO3,'youn',200000e6,'nu',0.3,'rho',...
    7100,'sect',pi*0.006^2/4,'sigy',500e6,'K',0.01*210000e6);
MAT  = [MA1 [MA2 MA3]];

%% Definition of the beam
FILE = 'EX44_2.mail';
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
CL1  = MATRICE('DIRI','P1G',1,2,3,4,5,6);
CL2  = MATRICE('DIRI','P1D',2,3);
CL3  = MATRICE('DIRI','P0' ,2);

CLT  = [CL1 [CL2 CL3]];

%% Loading
FO1 = CHPOINT.DEPI(CL3,-0.01);

EV1 = EVOL([0 1],[0 1],'Time','Displacement (m)');
CHT = TIMELOAD(FO1,EV1,'DIRI');

%% Static analysis
PB1 = PROBLEM('model',MOBT,'mater',MABT,'diric',CLT,'loadt',CHT,'comp_time',0:0.01:1,...
    'solve_type','SECANT_NEWTON','stif_update',10);
SOL = SOLVE(PB1);

%% Reaction curve

% Results from CastLab
EV_OUT      = EVOL.REAC(SOL,CL3,EV1,2,'P0');
EV_OUT.absc = -EV_OUT.absc;
EV_OUT.ordo = -EV_OUT.ordo;
plot(EV_OUT);

% Reference results (Cast3M)
ref = ...
    [
  0.0000           0.0000
  1.00000E-04      2200.6
  2.00000E-04      4401.1
  3.00000E-04      6601.7
  4.00000E-04      8802.3
  5.00000E-04      11003.
  6.00000E-04      8077.6
  7.00000E-04      7786.9
  8.00000E-04      7301.6
  9.00000E-04      7120.9
  1.00000E-03      7207.8
  1.10000E-03      7444.9
  1.20000E-03      7768.7
  1.30000E-03      8145.0
  1.40000E-03      8554.0
  1.50000E-03      8984.1
  1.60000E-03      9428.1
  1.70000E-03      9881.2
  1.80000E-03      10341.
  1.90000E-03      10801.
  2.00000E-03      11256.
  2.10000E-03      11686.
  2.20000E-03      9772.3
  2.30000E-03      10141.
  2.40000E-03      10513.
  2.50000E-03      10888.
  2.60000E-03      11265.
  2.70000E-03      11643.
  2.80000E-03      12021.
  2.90000E-03      12400.
  3.00000E-03      12779.
  3.10000E-03      13159.
  3.20000E-03      13528.
  3.30000E-03      13885.
  3.40000E-03      14243.
  3.50000E-03      14601.
  3.60000E-03      14959.
  3.70000E-03      15317.
  3.80000E-03      15675.
  3.90000E-03      16032.
  4.00000E-03      16390.
  4.10000E-03      16746.
  4.20000E-03      17100.
  4.30000E-03      17452.
  4.40000E-03      17799.
  4.50000E-03      16535.
  4.60000E-03      16892.
  4.70000E-03      17237.
  4.80000E-03      17580.
  4.90000E-03      17922.
  5.00000E-03      18264.
  5.10000E-03      18607.
  5.20000E-03      18939.
  5.30000E-03      19267.
  5.40000E-03      19588.
  5.50000E-03      19910.
  5.60000E-03      20230.
  5.70000E-03      20551.
  5.80000E-03      20872.
  5.90000E-03      21193.
  6.00000E-03      21514.
  6.10000E-03      21835.
  6.20000E-03      22156.
  6.30000E-03      22476.
  6.40000E-03      22735.
  6.50000E-03      22907.
  6.60000E-03      23078.
  6.70000E-03      23249.
  6.80000E-03      23421.
  6.90000E-03      23496.
  7.00000E-03      23503.
  7.10000E-03      23508.
  7.20000E-03      23514.
  7.30000E-03      23520.
  7.40000E-03      23525.
  7.50000E-03      23531.
  7.60000E-03      23537.
  7.70000E-03      23543.
  7.80000E-03      23549.
  7.90000E-03      23555.
  8.00000E-03      23561.
  8.10000E-03      23567.
  8.20000E-03      23573.
  8.30000E-03      23579.
  8.40000E-03      23585.
  8.50000E-03      23591.
  8.60000E-03      23597.
  8.70000E-03      23603.
  8.80000E-03      23609.
  8.90000E-03      23615.
  9.00000E-03      23621.
  9.10000E-03      23626.
  9.20000E-03      23632.
  9.30000E-03      23638.
  9.40000E-03      23644.
  9.50000E-03      23650.
  9.60000E-03      23656.
  9.70000E-03      23662.
  9.80000E-03      23668.
  9.90000E-03      23673.
  1.00000E-02      23679.];

hold on
plot(ref(:,1),ref(:,2),'go')
legend('CastLab','Cast3M','Location','Best')
close all

%% Non regression test
if abs(EV_OUT.ordo(end) - ref(end,2))/ref(end,2) > 1.0e-3
    
    error('TEST IS NOT SUCCESSFUL')
    
else
    
    disp('---------------------------------')
    disp('044_INCR_DAM_PLAS_F3P_MULTIFIBER')
    disp('TEST IS SUCCESSFUL')
    disp('---------------------------------')
    
end