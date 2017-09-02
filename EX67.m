%--------------------------------------------------------------------------
% PURPOSE
%    Non linear analysis - Shi's test - ZAFATI' model - IMPLEX
%--------------------------------------------------------------------------
% REFERENCES
%    Eliass ZAFATI
%    CEA, DEN, DANS, DM2S, SEMT, EMSI
%    eliass.zafati[at]cea.fr
%    eliass.zafati[at]gmail.com
%    27-01-2017
%--------------------------------------------------------------------------
% COMMENTS
% 
% 
%--------------------------------------------------------------------------

%% Clearing off
fclose all;
clear 
close all

%% Declaration de variables global
global options ME TP;

%% Definition des options
options.mode = 'PLANE_STRESS';

%% Loading of the input datafile
FILE  = '67.mail';
ME = INPUT.ACQU(FILE,'MAIL');

%% Definition of the model
MO1  = MODEL('S2','MECHANICS','ELASTICITY','ISOTROPIC','DAMAGE','ZAFATI');
MO2  = MODEL('S1','MECHANICS','ELASTICITY','ISOTROPIC');
MO3  = MODEL('S3','MECHANICS','ELASTICITY','ISOTROPIC');
MOT  = [MO1 MO2 MO3];

%% Topology
TP   = TOPOLOGY(MOT);

%% Definition of the material
MA1  = CHAMELEM.MATE(MO1,'youn',36e9,'nu',0.2,'rho',2200,'k0',1e-4,'S',1e-4,'s',5,'B',2,'eta',1,'c2',3e4);
MA2  = CHAMELEM.MATE(MO2,'youn',36e9,'nu',0.2,'rho',2200);
MA3  = CHAMELEM.MATE(MO3,'youn',36e9,'nu',0.2,'rho',2200);
MAT  = [MA1 [MA2 MA3]];

%% Boundary conditions

% Line L1 fixed
CL1  = MATRICE('DIRI','D1',2);
CL2  = MATRICE('DIRI','P1',1);
CL3  = MATRICE('DIRI','D7',2);
CLT  = [CL1 [CL2 CL3]];

% Definition of a prescribed displacement
FO1  = CHPOINT.DEPI(CL3,1);

%% Loading
EV1 = EVOL([0 1],[0 1e-5],'Time','Displacement (m)');
CHT = TIMELOAD(FO1,EV1,'DIRI');

%% Static analysis
PB1 = PROBLEM('model',MOT,'mater',MAT,'diric',CLT,'loadt',CHT,'comp_time',0:0.001:1,...
    'solve_type','IMPLEX');
SOL = SOLVERS(PB1);

%% Post-treatment

% Displacement at point P3 X and Y
EV_OUT = EVOL.REAC(SOL,CL3,EV1,2);
plot(EV_OUT);

close all

%% Non regrassion test
if abs(EV_OUT.ordo(end) - 2.528172645587808e+03) > 1.0e-4
    
    error('TEST IS NOT SUCCESSFUL')
    
else
    
    disp('---------------------------------')
    disp('053_INCR_NLINE_2D_TRI3_ZAFATI_IMPLEX_SHI')
    disp('TEST IS SUCCESSFUL')
    disp('---------------------------------')
    
end