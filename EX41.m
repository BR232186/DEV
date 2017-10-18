%--------------------------------------------------------------------------
% PURPOSE
%    Test eigenvalue problem on a 2D plane structure
%--------------------------------------------------------------------------
% REFERENCES
%    Benjamin RICHARD
%    CEA, DEN, DANS, DM2S, SEMT, EMSI
%    benjamin.richard[at]cea.fr
%    15-10-2017
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
FILE  = 'portique.mail';
ME = INPUT.ACQU(FILE,'MAIL');

%% Definition of the model
MO1  = MODEL('S1','MECHANICS','ELASTICITY','ISOTROPIC');
MO2  = MODEL('S2','MECHANICS','ELASTICITY','ISOTROPIC');
MO3  = MODEL('S3','MECHANICS','ELASTICITY','ISOTROPIC');
MO4  = MODEL('S4','MECHANICS','ELASTICITY','ISOTROPIC');
MOT  = [MO1 [MO2 [MO3 MO4]]];

%% Topology
TP   = TOPOLOGY(MOT);

%% Definition of the material
MA1  = CHAMELEM.MATE(MO1,'youn',36000e6,'nu',0.2,'rho',2500);
MA2  = CHAMELEM.MATE(MO2,'youn',36000e6,'nu',0.2,'rho',2500);
MA3  = CHAMELEM.MATE(MO3,'youn',28000e6,'nu',0.2,'rho',2500);
MA4  = CHAMELEM.MATE(MO4,'youn',28000e6,'nu',0.2,'rho',2500);
MAT  = [MA1 [MA2 [MA3 MA4]]];

%% Eigenvalue analysis - STEP 1
% Set the BCs
CL1  = MATRICE('DIRI','P2',1,2);
CL2  = MATRICE('DIRI','P6',2);
CLT  = [CL1 CL2];

% Lumped mass
MAD1 = MATRICE('MADD','L15',[1 2],7.5e3/41);
MAD2 = MATRICE('MADD','L17',[1 2],7.5e3/41);

% First problem to solve
PB1  = PROBLEM('model',MOT,'mater',MAT,'diric',CLT,'solve_type','MODAL',...
    'lumped_mass',[MAD1 MAD2]);
SOL1 = SOLVE(PB1);

%% Post processing

% Get the first eigenvalue
f1_calc = SOL1.eigenfrequency(1);

% Plot the first modeshape
CHPOINT.plot(SOL1.modeshape(1),'DEFORMED','STOT',100,1);
close all

%% Non regression test
if abs(f1_calc - 7.6025)/7.6025 > 1.0e-4

    error('TEST IS NOT SUCCESSFUL')
    
else
    
    disp('---------------------------------')
    disp('041_MODAL_2D STRUCTURE')
    disp('TEST IS SUCCESSFUL')
    disp('---------------------------------')
    
end