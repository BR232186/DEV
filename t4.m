%--------------------------------------------------------------------------
% PURPOSE
%    Test input MSH file
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
options.mode      = 'PLANE_STRESS';
options.dimension = 2;

%% Definition of the section
FILE = 't4.msh';
ME   = INPUT.ACQU(FILE,'MSH2');

%% Definition of the model
MO1  = MODEL('S1','MECHANICS','ELASTICITY','ISOTROPIC');
MO2  = MODEL('S2','MECHANICS','ELASTICITY','ISOTROPIC');
MOT  = [MO1 MO2];

%% Definition of the material
MA1  = CHAMELEM.MATE(MO1,'youn',36000e6,'nu',0.2,'rho',...
    2500);
MA2  = CHAMELEM.MATE(MO2,'youn',210000e6,'nu',0.3,'rho',...
    2500);
MAT  = [MA1 MA2];

%% Topology
TP   = TOPOLOGY(MOT);

%% Stiffness matrix
RIG1 = MATRICE('STIFF',MOT,MAT);

FO1  = CHPOINT('LABEL','BC2',2,10e3);
CL1  = MATRICE('DIRI','BC1',1,2);

RIGT = [RIG1 CL1];
USOL = SOLVERS.RESO(RIGT,FO1);
EPS1 = CHAMELEM.EPSI(MOT,USOL,MAT);

return



