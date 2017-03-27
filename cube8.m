%--------------------------------------------------------------------------
% PURPOSE
%    Test input MSH file - CUB8
%--------------------------------------------------------------------------
% REFERENCES
%    Benjamin RICHARD
%    CEA, DEN, DANS, DM2S, SEMT, EMSI
%    benjamin.richard[at]cea.fr
%    23-03-2017
%--------------------------------------------------------------------------
% COMMENTS
% 
% 
% 
%--------------------------------------------------------------------------

%% Clearing off

%% Global variables
global ME TP options

%% Options
options.mode      = 'TRID';
options.dimension = 3;

%% Definition of the section
FILE = 'cube8.msh';
ME   = INPUT.ACQU(FILE,'MSH2');

%% Definition of the model
MO1  = MODEL('Volume','MECHANICS','ELASTICITY','ISOTROPIC');
MOT  = MO1;

%% Definition of the material
MA1  = CHAMELEM.MATE(MO1,'youn',36000e6,'nu',0.2,'rho',...
    2500);
MAT  = MA1;

%% Topology
TP   = TOPOLOGY(MOT);

%% Stiffness matrix
RIG1 = MATRICE('STIFF',MOT,MAT);

FO1  = CHPOINT('LABEL','top',3,10e3);
CL1  = MATRICE('DIRI','bottom',1,2,3);

RIGT = [RIG1 CL1];
USOL = SOLVERS.RESO(RIGT,FO1);
EPS1 = CHAMELEM.EPSI(MOT,USOL,MAT);






