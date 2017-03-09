function SecResp = SectTimo3D (action,sec_no,ndm,SecData,SecState)
%SectTimo3d 3d response of a multifiber section considering shear   
%% Adaptation de la routine crée initialement par Panagiotis Kotronis pour FedeasLab
%  SECRESP = SECTTIMO3D (ACTION,SEC_NO,NDM,SECDATA,SECSTATE)
%  function determines the 3d response of a multifiber section having two 
%           materials (e.g. reinforced concrete) by integration in y and 
%           z-direction. Shear is considered (Timoshenko theory)
%           The section can be rectangular or circular.
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  the character variable ACTION should have one of the following values
%  ACTION = 'chec' function checks section property data for omissions and returns default values in SECDATA
%           'data' function prints section properties in output file IOW
%           'init' function returns the section history variables in SECSTATE
%           'forc' function returns the section resisting forces in SECSTATE
%           'stif' function returns the section stiffness matrix and resisting forces in SECSTATE
%           'post' function returns data structure SECPOST with post-processing information
%  depending on the value of character variable ACTION the function returns information in data structure SECRESP
%  for the section with number SEC_NO and dimension NDM;
%  data structure SECDATA supplies the section property data;
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  data structure SECRESP stands for one of the following data objects depending on the value of ACTION 
%  SECRESP = SECDATA   for action = 'chec'
%  SECRESP = SECSTATE  for action = 'init'
%  SECRESP = SECSTATE  for action = 'stif'
%  SECRESP = SECSTATE  for action = 'forc'
%  SECRESP = SECPOST   for action = 'post'
%  SECRESP is empty    for action = 'data' and for unsupported keywords
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  SECSTATE is a data structure with information about the current section state; it has the fields
%         e     = vector of total section deformations
%         De    = vector of section deformation increments from last convergence
%         DDe   = vector of section deformation increments from last iteration (not used)
%         ds    = vector of section generalised displacements
%         Dds   = vector of section generalised displacements increments from last convergence
%         DDds  = vector of section generalised displacements increments from last iteration
%         edot  = vector of section deformation rates (not used)
%         ks    = section stiffness matrix; returned under ACTION ='stif'
%         s     = section resisting force vector; returned under ACTION = 'stif' or 'forc'
%         Past  = section history variables at last converged state
%         Pres  = current section history variables
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  SECDATA is a data structure with section property information; it has the fields
%         Form    = function name for section form ('Rect' or 'Circ')
%         d       = depth (rectangular section)
%         b       = width (rectangular section)
%         diam    = [dext dint] outer/inner diameter (circular section)
%         nyfib   = no of integration points in y (rectangular section)
%         nzfib   = no of integration points in z (rectangular section)
%         nrfib   = no of integration points in radial direction (circular section)
%         nthfib  = no of integration points in circumferential direction (circular section)
%         Inttyp  = function name for section integration
%                   (only 'MIDPOINT' is presently supported for a circular section)
%         SAy     = shear corrector factor
%         SAz     = shear corrector factor
%         nsteel  = number of steel bars
%         YZA     = array with Y coord Z coord and A area of the steel bars
%         YZAc    = array with Y coord Z coord and A area of the concrete fibres
%         MatName = function name for material stress-strain response
%         MatData = data structure with material property data
%         GA      = shear rigidity
%         EIy     = flexural rigidity
%         EIz     = flexural rigidity
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  SECPOST is a data structure with section response information for post-processing; it has the fields
%         e      = section deformations
%         s      = section force resultants
%         Mat{i} = material response information for post-processing (see material function with MatName)
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  REFERENCES
%  ----------
%      1. A FIBER/TIMOSHENKO BEAM ELEMENT IN CASTEM 2000
%         J. GUEDES, P. PEGON AND A.V. PINTO
%         SPECIAL PUBLICATION NR.I.94.31 JULY 1994
%         APPLIED MECHANICS UNIT, SAFETY TECHNOLOGY INSTITUTE
%         JOINT RESEARCH CENTRE, EUROPEAN COMMISSION
%         I-2102O ISPRA (VA) ITALY         
%      2. Cowper G.R. 1966. "The shear coefficient in Timoshenko's beam theory". 
%         Journal of applied mechanics, Transactions of the ASME, Vol. 33,
%         pp. 335-340. 
%  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  function contributed by Panagiotis KOTRONIS January 2007 
%  (Panagiotis.Kotronis@inpg.fr)
%  =========================================================================================
%  FEDEASLab - Release 2.6, July 2004
%  Matlab Finite Elements for Design, Evaluation and Analysis of Structures
%  Copyright(c) 1998-2004. The Regents of the University of California. All Rights Reserved.
%  Created by Professor Filip C. Filippou (filippou@ce.berkeley.edu)
%  Department of Civil and Environmental Engineering, UC Berkeley
%  =========================================================================================

switch action
  case {'chec','init','raideur'}
     
           

      
       if (~isfield(SecData,'Form'))  disp('Section');disp(sec_no);
      warning('section form missing, Rectangular assumed'); SecData.Form = 'Rect';end
     
    if (SecData.Form=='Vous')
       b1=SecData.b1;
       b2=SecData.b2;
       h =SecData.h;
       e1=SecData.e1;
       e3=SecData.e3;
       e4=SecData.e4;
       ev=SecData.ev;
       nb1=SecData.nb1;
       nh1=SecData.nh1;
       nb3=SecData.nb3;
       nh3=SecData.nh3;
       nb4=SecData.nb4;
       nh4=SecData.nh4;
       nbv=SecData.nbv;
       nhv=SecData.nhv;
       IntTyp=SecData.IntTyp;
       [yfib zfib wfib]=MaillageSectVoussoir(b1,b2,h,e1,e3,e4,ev,nb1,nh1,nb3,nh3,nb4,nh4,nbv,nhv,IntTyp);      
       SecData.YZAc=[yfib zfib wfib];
    end
       
    if (SecData.Form=='Rect')
       if (~isfield(SecData,'d'))       disp('Section');disp(sec_no); error('depth missing'); end
       if (~isfield(SecData,'b'))       disp('Section');disp(sec_no); error('width missing'); end
       if (~isfield(SecData,'nyfib'))   disp('Section');disp(sec_no);
         warning('no of integration points in y direction missing, 5 IP assumed'); SecData.nyfib = 5;end
       if (~isfield(SecData,'nzfib'))   disp('Section');disp(sec_no);
         warning('no of integration points in z direction missing, 5 IP assumed'); SecData.nzfib = 5;end
       if (~isfield(SecData,'IntTyp'))  disp('Section');disp(sec_no);
         warning('integration type missing, Gauss assumed'); SecData.IntTyp = 'Gauss';end
       % for a rectangular section the shear corrector factor provided by
       % Cowper (1966) is k=(10*(1+poisson))/(12+11*poisson)
       if (~isfield(SecData,'SAy'))   disp('Section');disp(sec_no);
         warning('shear corrector factor SAy missing, 5/6 assumed'); SecData.SAy = 5/6;end
       if (~isfield(SecData,'SAz'))   disp('Section');disp(sec_no);
         warning('shear corrector factor SAz missing, 5/6 assumed'); SecData.SAz = 5/6;end
      
        
       d=SecData.d;
       b=SecData.b;
       nyfib=SecData.nyfib;
       nzfib=SecData.nzfib;
       IntTyp=SecData.IntTyp;
       patcoor = [d/2  -b/2; -d/2   b/2];
       [yfib zfib wfib] = RectPatch2Fiber (patcoor,IntTyp,nyfib,nzfib);
       SecData.YZAc=[yfib zfib wfib];
    end
    if (SecData.Form=='Circ') 
        
        
               if (~isfield(SecData,'diam'))    disp('Section');disp(sec_no); error('diameter missing'); end
       if (~isfield(SecData,'nrfib'))   disp('Section');disp(sec_no);
         warning('no of integration points in radial direction missing, 10 IP assumed'); SecData.nrfib = 10;end
       if (~isfield(SecData,'nthfib'))   disp('Section');disp(sec_no);
         warning('no of integration points in circumferential direction missing, 5 IP assumed'); SecData.nthfib = 5;end
       if (~isfield(SecData,'IntTyp'))  disp('Section');disp(sec_no);
         warning('integration type missing, Midpoint assumed'); SecData.IntTyp = 'Midpoint';end
       % for a circular section the shear corrector factor provided by
       % Cowper (1966) is k=(6*(1+poisson))/(7+6*poisson)  
       if (~isfield(SecData,'SAy'))   disp('Section');disp(sec_no);
         warning('shear corrector factor SAy missing, 6/7 assumed'); SecData.SAy = 6/7;end
       if (~isfield(SecData,'SAz'))   disp('Section');disp(sec_no);
         warning('shear corrector factor SAz missing, 6/7 assumed'); SecData.SAz = 6/7;end
        
        
       diam=SecData.diam;
       nrfib=SecData.nrfib;
       nthfib=SecData.nthfib;
       IntTyp=SecData.IntTyp;
       [yfib zfib wfib] = CircPatch2Fiber (diam,IntTyp,nrfib,nthfib);
       SecData.YZAc=[yfib zfib wfib];
    end   
    
    
       if (~isfield(SecData,'MatName')) disp('Section');disp(sec_no); error('material name missing');end
    if (~isfield(SecData,'nsteel'))   disp('Section');disp(sec_no);
      warning('no steel bars, nsteel and YZA 0 assumed'); SecData.nsteel=0; SecData.YZA=0;end
    if (~isfield(SecData,'YZA'))   disp('Section');disp(sec_no);
      warning('no steel bars, nsteel and YZA 0 assumed'); SecData.nsteel=0; SecData.YZA=0;end
    
    SecData.MatData{1} = feval (SecData.MatName(1,:),'chec',1,SecData.MatData{1});
    SecData.MatData{2} = feval (SecData.MatName(2,:),'chec',1,SecData.MatData{2});
   
    
    if (SecData.Form=='Vous')
       b1=SecData.b1;
       b2=SecData.b2;
       h =SecData.h;
       e1=SecData.e1;
       e3=SecData.e3;
       e4=SecData.e4;
       ev=SecData.ev;
       nb1=SecData.nb1;
       nh1=SecData.nh1;
       nb3=SecData.nb3;
       nh3=SecData.nh3;
       nb4=SecData.nb4;
       nh4=SecData.nh4;
       nbv=SecData.nbv;
       nhv=SecData.nhv;
    end
    if (SecData.Form=='Rect') 
       d       = SecData.d;      % section depth
       b       = SecData.b;      % section width
       nyfib   = SecData.nyfib;  % no of integration points in y direction
       nzfib   = SecData.nzfib;  % no of integration points in z direction
    end
    if (SecData.Form=='Circ') 
       diam    = SecData.diam;   % section diameter [dext dint] outer/inner diameter
       nrfib   = SecData.nrfib;  % no of integration points in radial direction
       nthfib  = SecData.nthfib; % no of integration points in circumferential direction
    end
     
    SAy     = SecData.SAy;    % shear corrector factor
    SAz     = SecData.SAz;    % shear corrector factor
    IntTyp  = SecData.IntTyp; % integration type
    nsteel  = SecData.nsteel; % number of steel bars
    YZA     = SecData.YZA;    % array with Y coord Z coord and A area of the steel bars
    MatName = SecData.MatName;% array of material names
    MatData = SecData.MatData;% material data
    
    % determine the elastic parameters of the composite section (GA, EIy, EIz)
    ks   = zeros(ndm*2,ndm*2);    

     if (SecData.Form=='Vous')
       [yfib zfib wfib]=MaillageSectVoussoir(b1,b2,h,e1,e3,e4,ev,nb1,nh1,nb3,nh3,nb4,nh4,nbv,nhv,IntTyp);      
       SecData.YZAc=[yfib zfib wfib];
       nfib=length(wfib);
     end
    if (SecData.Form=='Rect') 
       % the dimension of the rectangular patch is supplied by specifying the
       % coordinates of opposite corners in array PATCOOR 
       % ([y1 z1 (top right);y2 z2 (bottom left)])
       % (NOTE: right handed local coordinate system x-y-z! y positive towards top and
       % z positive towards left)
       % discretization of section
       patcoor = [d/2  -b/2; -d/2   b/2];
       [yfib zfib wfib] = RectPatch2Fiber (patcoor,IntTyp,nyfib,nzfib);
       nfib = nyfib*nzfib;
    end
    if (SecData.Form=='Circ') 
       [yfib zfib wfib] = CircPatch2Fiber (diam,IntTyp,nrfib,nthfib);
       nfib = nrfib*nthfib;
    end

    % concrete
    for m=1:nfib
        y   = yfib(m);
		z   = zfib(m);        
        A   = wfib(m);
        MatState = feval (MatName(1,:),'init',m,MatData{1});
        Ct  = MatState.Pres.Ct;
        E   = Ct(1,1);
        G   = Ct(2,2);
        EA  = A*E;
	    GA  = A*G;
        ks(2,2) = ks(2,2)+SAy*GA;
		ks(5,5) = ks(5,5)+EA*z*z;
		ks(6,6) = ks(6,6)+EA*y*y;
    end

    % steel
    for i=1:nsteel
        ysteel = YZA(1,i);
        zsteel = YZA(2,i);
        Asteel = YZA(3,i);
        MatState = feval (MatName(2,:),'init',m+i,MatData{2});
        EAsteel  = Asteel*MatState.Ct;
        %ks(2,2) =  ks(2,2) + GAsteel;
        ks(5,5)  = ks(5,5) + EAsteel*zsteel*zsteel;
        ks(6,6)  = ks(6,6) + EAsteel*ysteel*ysteel;
   end
    
   SecData.GA    = ks(2,2);
   SecData.EIy   = ks(5,5);
   SecData.EIz   = ks(6,6);
   SecResp = SecData;
    
   otherwise
    % extract section properties
    if (SecData.Form=='Vous')
       b1=SecData.b1;
       b2=SecData.b2;
       h =SecData.h;
       e1=SecData.e1;
       e3=SecData.e3;
       e4=SecData.e4;
       ev=SecData.ev;
       nb1=SecData.nb1;
       nh1=SecData.nh1;
       nb3=SecData.nb3;
       nh3=SecData.nh3;
       nb4=SecData.nb4;
       nh4=SecData.nh4;
       nbv=SecData.nbv;
       nhv=SecData.nhv;
    end
    if (SecData.Form=='Rect') 
       d       = SecData.d;      % section depth
       b       = SecData.b;      % section width
       nyfib   = SecData.nyfib;  % no of integration points in y direction
       nzfib   = SecData.nzfib;  % no of integration points in z direction
    end
    if (SecData.Form=='Circ') 
       diam    = SecData.diam;   % section diameter [dext dint] outer/inner diameter
       nrfib   = SecData.nrfib;  % no of integration points in radial direction
       nthfib  = SecData.nthfib; % no of integration points in circumferential direction
    end
    SAy     = SecData.SAy;    % shear corrector factor
    SAz     = SecData.SAz;    % shear corrector factor
    IntTyp  = SecData.IntTyp; % integration type
    GA      = SecData.GA;     % elastic stiffness for shear
    EIy     = SecData.EIy;    % elastic stiffness for flexure y
    EIz     = SecData.EIz;    % elastic stiffness for flexure z
    nsteel  = SecData.nsteel; % number of steel bars
    YZA     = SecData.YZA;    % array with Y coord Z coord and A area of the steel bars   
    MatName = SecData.MatName;% array of material names
    MatData = SecData.MatData;% material data
    end
%% section actions
switch action
    case 'chec'
        
    case{'init','raideur','masse'}
    % concrete
    % discretization of section
    if (SecData.Form=='Vous')
       [yfib zfib wfib]=MaillageSectVoussoir(b1,b2,h,e1,e3,e4,ev,nb1,nh1,nb3,nh3,nb4,nh4,nbv,nhv,IntTyp);      
       SecData.YZAc=[yfib zfib wfib];
       nfib=length(wfib);
    end
    if (SecData.Form=='Rect')
       patcoor = [d/2  -b/2; -d/2   b/2];
       [yfib zfib wfib] = RectPatch2Fiber (patcoor,IntTyp,nyfib,nzfib);
       nfib = nyfib*nzfib;
    end
    
    if (SecData.Form=='Circ')
       [yfib zfib wfib] = CircPatch2Fiber (diam,IntTyp,nrfib,nthfib);
       nfib = nrfib*nthfib;
    end
    
    % initialize before summation
    s    = zeros(ndm*2,1); 
    ks   = zeros(ndm*2,ndm*2);
    
    for m=1:nfib
        A   = wfib(m);
        y   = yfib(m);
		z   = zfib(m);                
        MatState = feval (MatName(1,:),'init',m,MatData{1});
        Econcr   = MatState.Pres.Ct(1,1);
        Gconcr   = MatState.Pres.Ct(2,2);
        Sigconcr = MatState.Pres.sig;
        EAconcr  = A*Econcr;
	    GAconcr  = A*Gconcr;
    % calculating section stiffness matrix ks
        ks(1,1) = ks(1,1)+EAconcr;
		ks(2,2) = ks(2,2)+SAy*GAconcr;
		ks(3,3) = ks(3,3)+SAz*GAconcr;		 
%    		ks(4,4) = ks(4,4)+GAconcr*(SAz*y*y+SAy*z*z);
   		ks(4,4) = ks(4,4)+GAconcr*(y*y+z*z);
		ks(5,5) = ks(5,5)+EAconcr*z*z;
		ks(6,6) = ks(6,6)+EAconcr*y*y;
 		         
        ks(1,5) = ks(1,5)+EAconcr*z;
		ks(1,6) = ks(1,6)-EAconcr*y;         
		ks(2,4) = ks(2,4)-SAy*GAconcr*z; 		 
		ks(3,4) = ks(3,4)+SAz*GAconcr*y; 		 
		ks(5,6) = ks(5,6)-EAconcr*y*z; 
        
	    ks(4,2) = ks(2,4);
		ks(4,3) = ks(3,4);			
	    ks(5,1) = ks(1,5);			 
	    ks(6,1) = ks(1,6);			 
	    ks(6,5) = ks(5,6);			 
    % section resisting force vector
        s(1) = s(1)+Sigconcr(1)*A;
	    s(2) = s(2)+SAy*Sigconcr(2)*A;
		s(3) = s(3)+SAz*Sigconcr(3)*A;
% 		s(4) = s(4)+SAz*Sigconcr(3)*A*y-SAy*Sigconcr(2)*A*z;
        s(4) = s(4)+Sigconcr(3)*A*y-Sigconcr(2)*A*z;
		s(5) = s(5)+Sigconcr(1)*A*z;
	    s(6) = s(6)-Sigconcr(1)*A*y;
        if strcmp(action,'raideur') || strcmp(action,'masse')
% permet de de pas avoir de warning du fait qu'on écrase des valeurs
% historiques dans la cellule.
        else
        SecState.Pres.Mat{m} = MatState.Pres;
        end
    end

    % steel bars

    
    for i=1:nsteel
       ysteel = YZA(1,i);
       zsteel = YZA(2,i);
       Asteel = YZA(3,i);
       MatState = feval (MatName(2,:),'init',m+i,MatData{2});
       Esteel   = MatState.Ct;
       EAsteel  = Asteel*Esteel;
       Sigsteel = MatState.sig;

    % calculating section stiffness matrix ks
        ks(1,1) = ks(1,1)+EAsteel;
        %ks(2,2) = ks(2,2)+EAsteel;
		ks(5,5) = ks(5,5)+EAsteel*zsteel*zsteel;
		ks(6,6) = ks(6,6)+EAsteel*ysteel*ysteel;
 		         
        ks(1,5) = ks(1,5)+EAsteel*zsteel;
		ks(1,6) = ks(1,6)-EAsteel*ysteel;         
        ks(5,6) = ks(5,6)-EAsteel*ysteel*zsteel; 

        ks(5,1) = ks(1,5);			 
	    ks(6,1) = ks(1,6);			 
	    ks(6,5) = ks(5,6);			 

        % section resisting force vector
        s(1) = s(1)+Sigsteel*Asteel;
		s(5) = s(5)+Sigsteel*Asteel*zsteel;
	    s(6) = s(6)-Sigsteel*Asteel*ysteel;
        if strcmp(action,'raideur') || strcmp(action,'masse')
% permet de de pas avoir de warning du fait qu'on écrase des valeurs
% historiques dans la cellule.
        else
        SecState.Pres.Mat{m+i} = MatState.Pres; 
        end
    end
    SecState.s   = s;
    SecState.ks  = ks;
    SecResp = SecState;
    
%% state determination
    otherwise
        % concrete
    % discretization of section
    if (SecData.Form=='Vous')
       [yfib zfib wfib]=MaillageSectVoussoir(b1,b2,h,e1,e3,e4,ev,nb1,nh1,nb3,nh3,nb4,nh4,nbv,nhv,IntTyp);      
       SecData.YZAc=[yfib zfib wfib];
       nfib=length(wfib);
    end
    if (SecData.Form=='Rect')
       patcoor = [d/2  -b/2; -d/2   b/2];
       [yfib zfib wfib] = RectPatch2Fiber (patcoor,IntTyp,nyfib,nzfib);
       nfib = nyfib*nzfib;
    end
    
    if (SecData.Form=='Circ')
       [yfib zfib wfib] = CircPatch2Fiber (diam,IntTyp,nrfib,nthfib);
       nfib = nrfib*nthfib;
    end
         
    % initialize before assembly
    s    = zeros(ndm*2,1);      
    ks   = zeros(ndm*2,ndm*2);
    
    %MatState = Extract_Sec2MatState(m,as,SecState);
    
    % retreive section total displacements    
    ds(5:6)   = SecState.ds(5:6);
    % retreive section displacement increments from last convergence 
    dds(5:6)  = SecState.Dds(5:6);
    % retreive section displacement increments from last iteration
    ddds(5:6) = SecState.DDds(5:6);

    dsV(5:6)   = SecState.dsV(5:6);

    
    % retreive section deformations     
    vs(1:6) = SecState.e(1:6);
    % retreive section deformation increments from last convergence   
    dvs(1:6)  = SecState.De(1:6);
    % retreive section deformation increments from last iteration   
    ddvs(1:6)  = SecState.DDe(1:6);

    vsV(1:6) = SecState.eV(1:6);

    % concrete
    for m=1:nfib     
        A = wfib(m);
        y = yfib(m);
   		z = zfib(m);
        
        %(a 3D law is used for concrete)
        % total strains in the fiber          
      	eps(1,1) = vs(1)-y*vs(6)+z*vs(5);
		eps(2,1) = vs(2)-ds(6)-z*vs(4);
		eps(3,1) = vs(3)+ds(5)+y*vs(4);
        
        % strains in the fiber from last convergence         
        eps(1,2) = dvs(1)-y*dvs(6)+z*dvs(5);
		eps(2,2) = dvs(2)-dds(6)-z*dvs(4);
		eps(3,2) = dvs(3)+dds(5)+y*dvs(4);
        
        % strains in the fiber from last iteration         
        eps(1,3) = ddvs(1)-y*dvs(6)+z*ddvs(5);
		eps(2,3) = ddvs(2)-dds(6)-z*ddvs(4);
		eps(3,3) = ddvs(3)+ddds(5)+y*ddvs(4);
        
        % vitesse in the fiber from last iteration (pour matériaux visqueux)
        eps(1,4) = vsV(1)-y*vsV(6)+z*vsV(5);
		eps(2,4) = vsV(2)-dsV(6)-z*vsV(4);
		eps(3,4) = vsV(3)+dsV(5)+y*vsV(4);
        
        MatState.eps = eps(:,:);
        
        % extract current material history variables
        MatState.Pres  = SecState.Pres.Mat{m};
        
        % extract material history variables at last convergence
        MatState.Past  = SecState.Past.Mat{m};
        MatState = feval (MatName(1,:),'stif',m,MatData{1},MatState);
        Econcr  = MatState.Pres.Ct(1,1);
        Gconcr  = MatState.Pres.Ct(2,2);
        Sigconcr = MatState.Pres.sig;
        EAconcr  = A*Econcr;
	    GAconcr  = A*Gconcr;
        
        % calculating section stiffness matrix ks
        ks(1,1) = ks(1,1)+EAconcr;
		ks(2,2) = ks(2,2)+SAy*GAconcr;
		ks(3,3) = ks(3,3)+SAz*GAconcr;		 
%    		ks(4,4) = ks(4,4)+GAconcr*(SAz*y*y+SAy*z*z);
        ks(4,4) = ks(4,4)+GAconcr*(y*y+z*z);

		ks(5,5) = ks(5,5)+EAconcr*z*z;
		ks(6,6) = ks(6,6)+EAconcr*y*y;
		         
        ks(1,5) = ks(1,5)+EAconcr*z;
		ks(1,6) = ks(1,6)-EAconcr*y;         
		ks(2,4) = ks(2,4)-SAy*GAconcr*z; 		 
		ks(3,4) = ks(3,4)+SAz*GAconcr*y; 		 
		ks(5,6) = ks(5,6)-EAconcr*y*z; 
         
	    ks(4,2) = ks(2,4);
		ks(4,3) = ks(3,4);			
	    ks(5,1) = ks(1,5);			 
	    ks(6,1) = ks(1,6);			 
	    ks(6,5) = ks(5,6);			 
        
        % section resisting force vector
        s(1) = s(1)+Sigconcr(1)*A;
	    s(2) = s(2)+SAy*Sigconcr(2)*A;
		s(3) = s(3)+SAz*Sigconcr(3)*A;
% 		s(4) = s(4)+SAz*Sigconcr(3)*A*y-SAy*Sigconcr(2)*A*z;
		s(4) = s(4)+Sigconcr(3)*A*y-Sigconcr(2)*A*z;

		s(5) = s(5)+Sigconcr(1)*A*z;
	    s(6) = s(6)-Sigconcr(1)*A*y;
        SecState.Pres.Mat{m} = MatState.Pres;
    end
    
  % steel bars 
  for i=1:nsteel  
       ysteel = YZA(1,i);
       zsteel = YZA(2,i);
       Asteel = YZA(3,i);

       %(a 1D law is used for steel)
       MatState.eps = vs(1)-ysteel*vs(6)+zsteel*vs(5);      
       MatState.Deps  = dvs(1)-ysteel*dvs(6)+zsteel*dvs(5);
       MatState.DDeps = ddvs(1)-ysteel*dvs(6)+zsteel*ddvs(5);
        
       % extract current material history variables
       MatState.Pres = SecState.Pres.Mat{m+i};
       % extract material history variables at last convergence
       MatState.Past = SecState.Past.Mat{m+i};
       MatState = feval (MatName(2,:),'stif',m+i,MatData{2},MatState); 

       Esteel   = MatState.Ct;
       EAsteel  = Asteel*Esteel;
       Sigsteel = MatState.sig;
    % calculating section stiffness matrix ks
        ks(1,1) = ks(1,1)+EAsteel;
		ks(5,5) = ks(5,5)+EAsteel*zsteel*zsteel;
		ks(6,6) = ks(6,6)+EAsteel*ysteel*ysteel;
 		         
        ks(1,5) = ks(1,5)+EAsteel*zsteel;
		ks(1,6) = ks(1,6)-EAsteel*ysteel;         
        ks(5,6) = ks(5,6)-EAsteel*ysteel*zsteel; 

        ks(5,1) = ks(1,5);			 
	    ks(6,1) = ks(1,6);			 
	    ks(6,5) = ks(5,6);			 

        % section resisting force vector
        s(1) = s(1)+Sigsteel*Asteel;
		s(5) = s(5)+Sigsteel*Asteel*zsteel;
	    s(6) = s(6)-Sigsteel*Asteel*ysteel;
        SecState.Pres.Mat{m+i} = MatState.Pres;        
    end
   
    SecState.s = s;
    SecState.ks = ks;
    SecResp = SecState;

end