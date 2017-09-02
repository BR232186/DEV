%--------------------------------------------------------------------------
% PURPOSE
%    Test multifiber beams - direct solving - linear case
%--------------------------------------------------------------------------
% REFERENCES
%    Benjamin RICHARD
%    CEA, DEN, DANS, DM2S, SEMT, EMSI
%    benjamin.richard[at]cea.fr
%    01-09-2017
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
FILE = '60_1.mail';
ME   = INPUT.ACQU(FILE,'MAIL');

%% Definition of the model
MO1  = MODEL('SBET' ,'MECHANICS','ELASTICITY','ISOTROPIC','QUAS');
MO2  = MODEL('SAINF','MECHANICS','ELASTICITY','ISOTROPIC','POJS');
MO3  = MODEL('SASUP','MECHANICS','ELASTICITY','ISOTROPIC','POJS');
MOT  = [MO1 [MO2 MO3]];

%% Definition of the material
MA1  = CHAMELEM.MATE(MO1,'youn',36000e6,'nu',0.2,'rho',...
    2500,'ay',0.83,'az',0.83);
MA2  = CHAMELEM.MATE(MO2,'youn',210000e6,'nu',0.3,'rho',...
    2500,'sect',0);
MA3  = CHAMELEM.MATE(MO3,'youn',210000e6,'nu',0.3,'rho',...
    2500,'sect',0);
MAT  = [MA1 [MA2 MA3]];

%% Definition of the beam
FILE = '60_2.mail';
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

%% Loading
FO1  = CHPOINT('LABEL','P2',2,10e3);

%% Loading
EV1 = EVOL([0 1],[0 1e-5],'Time','Displacement (m)');
CHT = TIMELOAD(FO1,EV1,'FORC');




%% Stiffness matrix
RIG1 = MATRICE('STIFF',MOB1,MAB1);


%% Mass matrix
CL1  = MATRICE('DIRI','P1',1,2,3,4,5,6);

%% Assembling of the stiffness matrix and the boundary conditions
RIGT = [RIG1 CL1];

%% Direct solving
USOL = SOLVERS.RESO(RIGT,FO1);

%% Computation of the strains
EPS0 = CHAMELEM.EPSI(MOBT,USOL,MABT);

%% Initialization of a CHAMELEM
VAR0 = CHAMELEM.CHAM_INIT(MOBT,MABT);

%% Computation of the stresses
SIG0 = CHAMELEM.COMP(MOBT,1,MABT,EPS0,VAR0,0);

%% Integration of the stresses
BSI0 = CHPOINT.BSIGMA(MOBT,MABT,SIG0);

%% Computation of the reaction forces
[chp1,chp2,chp3,chp4,C] = CHPOINT.REAC(CL1,USOL);

%% Extraction of the value of the displacement in P2 point in the vertical direction
UP2 = CHPOINT.EXTR(USOL,'P2',2);

%% Non regrassion test
if abs(UP2 - 1.090604605923700e-07)/1.090604605923700e-07 > 1.0e-4

    error('TEST IS NOT SUCCESSFUL')
    
else
    
    disp('---------------------------------')
    disp('060_LINE_MULTIFIBER')
    disp('TEST IS SUCCESSFUL')
    disp('---------------------------------')
    
end