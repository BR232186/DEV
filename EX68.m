%--------------------------------------------------------------------------
% PURPOSE
%    Non linear analysis - 2D test - ZAFATI' model - QUASI-NEWTON
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
FILE  = '68.mail';
ME = INPUT.ACQU(FILE,'MAIL');

%% Definition of the model
MO1  = MODEL('SURFT','MECHANICS','ELASTICITY','ISOTROPIC','DAMAGE','ZAFATI');
MOT  = MO1;

%% Topology
TP   = TOPOLOGY(MOT);

%% Definition of the material
MA1  = CHAMELEM.MATE(MO1,'youn',36e9,'nu',0.2,'rho',2200,'k0',1e-4,'S',1e-4,'s',5,'B',2,'eta',1,'c2',3e4);
MAT  = MA1;

%% Boundary conditions

% Line L1 fixed
CL1  = MATRICE('DIRI','P10',2);
CL2  = MATRICE('DIRI','P2',1);
CL3  = MATRICE('DIRI','P2',2);
CL4  = MATRICE('DIRI','P7',2);
CLT  = [CL1 [[CL2 CL3] CL4]];

% Definition of a prescribed displacement
FO1  = CHPOINT.DEPI(CL1,1);

%% Loading
EV1 = EVOL([0 1 2 3],[0 -3e-5 0 1e-5],'Time','Displacement (m)');
CHT = TIMELOAD(FO1,EV1,'DIRI');

list= [0:0.05:1,1:0.1:1.9,1.9:0.005:2,2:0.005:2.2,2.2:0.02:3];
list=unique(list);

%% Static analysis
PB1 = PROBLEM('model',MOT,'mater',MAT,'diric',CLT,'loadt',CHT,'comp_time',list,...
     'solve_type','QUASI_NEWTON');
SOL = SOLVERS(PB1);

%% Post-treatment

% Displacement at point P3 X and Y
EV_OUT = EVOL.REAC(SOL,CL1,EV1,2);
plot(EV_OUT);

close all

%% Non regression test
if abs(EV_OUT.ordo(end) - 1.014111323244210e+04)/1.014111323244210e+04 > 1.0e-4

    error('TEST IS NOT SUCCESSFUL')
    
else
    
    disp('---------------------------------')
    disp('068_INCR_ZAFATI_QUASI_NEWTON')
    disp('TEST IS SUCCESSFUL')
    disp('---------------------------------')
    
end