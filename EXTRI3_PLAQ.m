%--------------------------------------------------------------------------
% PURPOSE
%    Linear analysis of a 3D structure meshed with TRI3 Shell FEs
%--------------------------------------------------------------------------
% REFERENCES
%    Benjamin RICHARD
%    CEA, DEN, DANS, DM2S, SEMT, EMSI
%    benjamin.richard[at]cea.fr
%    21-09-2016
%--------------------------------------------------------------------------
% COMMENTS
% 
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
options.mode = 'TRID';

%% Loading of the input datafile
% FILE  = 'tri3_plaq.mail';
FILE  = 'tri3_plaq_T3G.mail';
ME = INPUT.ACQU(FILE,'MAIL');

%% Definition of the model
MO1  = MODEL('ST','MECHANICS','ELASTICITY','ISOTROPIC',[],[],'T3G');

%% Topology
TP   = TOPOLOGY(MO1);

%% Definition of the material
MA1  = CHAMELEM.MATE(MO1,'youn',1,'nu',0.25,'rho',1,'epai',1);

%% Boundary conditions
% Line L1 fixed
CL1  = MATRICE('DIRI','L1',1,2,3,4,5,6);
CLT  = CL1;
RIG1 = MATRICE('STIFF',MO1,MA1);
RIGT = [RIG1 CL1];

% Definition of a prescribed displacement
% FOT  = CHPOINT('LABEL','L3',2,1);
FOT  = CHPOINT('LABEL','P3',1,1);

% Static analysis
USOL = SOLVERS.RESO(RIGT,FOT);

% Strain
EPST = CHAMELEM.EPSI(MO1,USOL,MA1);

% Hook matrix
HOOT = CHAMELEM.HOOKE(MO1,MA1);

% Initialization of the CHAMELEM
cham = CHAMELEM.CHAM_INIT(MO1);

% Stresses
STRS = CHAMELEM.COMP(MO1,1,[MA1 HOOT],EPST,cham,0);

% Internal loads
BSTRS = CHPOINT.BSIGMA(MO1,MA1,STRS);

% Reaction loads
[chp1,chp2,chp3,chp4,C] = CHPOINT.REAC(CL1,USOL);

return 

%% Loading
EV1 = EVOL([0 1],[0 1],'Time','Displacement (m)');
CH1 = TIMELOAD(FO1,EV1,'MECA');
CHT = CH1;

%% Static analysis
PB1 = PROBLEM('model',MO1,'mater',MA1,'diric',CLT,'loadt',CHT,'comp_time',0:0.1:1);
SOL = SOLVERS(PB1);

%% Post-treatment

% Displacement at point P4 X and Y
USOL = SOL.result(end).displacement;
UP4  = CHPOINT.EXTR(USOL,'P4',[1 2]);

%% Non regression test
if abs(UP4(1) + 2.3604e-004) > 1.0e-4 || ...
        abs(UP4(2) + 1.0236e-004) > 1.0e-4

    error('TEST IS NOT SUCCESSFUL')
    
else
    
    disp('---------------------------------')
    disp('034_INCR_2D_TRI3 ')
    disp('TEST IS SUCCESSFUL')
    disp('---------------------------------')
    
end