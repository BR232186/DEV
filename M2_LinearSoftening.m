clear
n = 1000; % number of time steps

eps = zeros(n,6); % [eps_11 eps_22 eps_33 eps_12 eps_23 eps_31]

deps = [1 1 1 0 0 0]*10^-5; % increment of strain

sig = zeros(n,6); %total stress matrix as per voight's sign convention [sig_11 sig_22 sig_33 sig_12 sig_23 sig_31]

[P,W] = Bazant_Int(1); %selection of integration rule

% P = [1 0 0];
% W = 1;

eps_n = zeros(n,size(P,1)); % normal strain for each time step at every integration point 

eps_V = zeros(n,size(P,1)); % volumetric strain component for each time step at every integration point 

eps_D = zeros(n,size(P,1)); % deviatoric strain component for each time step at every integration point 

eps_t = zeros(n,size(P,1),3); % vector of tangential strain for each time step at every integration point 

eps_T = zeros(n,size(P,1)); % tangential strain modulus for each time step at every integration point 

sig_V = zeros(n,size(P,1)); %  Volumetric stress relaxation

sig_D = zeros(n,size(P,1)); %  deviatoric stress relaxation

sig_T = zeros(n,size(P,1)); %  tangential stress relaxation

C_V = zeros(n,size(P,1));%62.5; % modulus of sig_V vs. eps_V

C_D = zeros(n,size(P,1));%53.125; % modulus of sig_D vs. eps_D

C_T = zeros(n,size(P,1));%; % modulus of sig_T vs. eps_T

a1 = 5*1.e-4;

a2 = 1.e-3;

a3 = 5*1.e-3;

a4 = 1.e-2;

a5 = 0.0018;

a6 = 2*0.0018;

for s = 1:n %loop on all the time steps
    
    
    
    c = zeros(3,3,3,3); % initialization of fouth order stiffess tensor
    
    sigma_nel = zeros(3,3,n); % initialization of stress relxation tensor

    for alpha = 1: size(P,1) %loop on all the integration points
    
   eps_n(s,alpha) = P(alpha,:)*[eps(s,1) eps(s,4)/2. eps(s,6)/2.; 
                                            eps(s,4)/2. eps(s,2) eps(s,5)/2.; 
                                            eps(s,6)/2. eps(s,5)/2. eps(s,3)]*P(alpha,:)'; %normal on the considered microplane
                                        
        eps_V(s,alpha) = (eps(s,1)+eps(s,2)+eps(s,3))/3; %sum(P(alpha,:)*[eps(s,1) eps(s,4) eps(s,6); 
%                                          eps(s,4) eps(s,2) eps(s,5); 
%                                          eps(s,6) eps(s,5) eps(s,3)])/3;  %volumetric strain on the considered microplane
                                        
        eps_D(s,alpha) = eps_n(s,alpha) - eps_V(s,alpha); %deviatoric strain on the considered microplane
        
        
        
                        
        eps_vec = P(alpha,:)*[eps(s,1) eps(s,4) eps(s,6); 
                            eps(s,4) eps(s,2) eps(s,5); 
                            eps(s,6) eps(s,5) eps(s,3)];
                        
        eps_t(s,alpha,:) =  ([eps(s,1) eps(s,4) eps(s,6); 
                            eps(s,4) eps(s,2) eps(s,5); 
                            eps(s,6) eps(s,5) eps(s,3)]*P(alpha,:)')' - P(alpha,:)*eps_n(s,alpha); %tangential strain vector on the considered microplane
                        
        eps_T(s,alpha) = (eps_t(s,alpha,1)^2+eps_t(s,alpha,2)^2+eps_t(s,alpha,3)^2)^0.5; % tangential strain modulus 
        
        if(abs(eps_V(s,alpha))<a1)
               C_V(s,alpha) = 62.5;   
               
        elseif(a1<abs(eps_V(s,alpha))&&abs(eps_V(s,alpha))<a2)
           
            C_V(s,alpha) = -62.5; 
            
        elseif(abs(eps_V(s,alpha))>=a2)
            C_V(s,alpha) = 0;
           
        end
       
        if(abs(eps_D(s,alpha))<a3)
               C_D(s,alpha) = 53.125;   
               
        elseif(a3<=abs(eps_D(s,alpha))&&abs(eps_D(s,alpha))<a4)
            C_D(s,alpha) = -53.125; 
        elseif(abs(eps_D(s,alpha))>=a4)
            C_D(s,alpha) = 0;
        end
       
        
        if(abs(eps_T(s,alpha))<a5)
               C_T(s,alpha) = 21.0805;   
               
        elseif(a5<=abs(eps_T(s,alpha))&&abs(eps_T(s,alpha))<a6)
            C_T(s,alpha) = -21.0805; 
        elseif(abs(eps_T(s,alpha))>=a6)
            C_T(s,alpha) = 0;
        end
       
        
       for i = 1:3
           
           for j = 1:3
               
            for k = 1:3


                for m = 1:3
    
                        c(i,j,k,m) = c(i,j,k,m) + (C_D(s,alpha)-C_T(s,alpha))*P(alpha,i)*P(alpha,j)*P(alpha,k)*P(alpha,m)*W(alpha);
                        
                        if(k==m)
                            
                            c(i,j,k,m) = c(i,j,k,m) + (1/3)*(C_V(s,alpha)-C_D(s,alpha))*P(alpha,i)*P(alpha,j)*W(alpha);
                            
                        end
                        
                        if(j==m)
                            
                            c(i,j,k,m) = c(i,j,k,m) + (1/4)*C_T(s,alpha)*P(alpha,i)*P(alpha,k)*W(alpha);
                            
                        end
                        
                        if(j==k)
                            
                            c(i,j,k,m) = c(i,j,k,m) + (1/4)*C_T(s,alpha)*P(alpha,i)*P(alpha,m)*W(alpha);
                            
                        end
                        
                        if(i==m)
                            
                            c(i,j,k,m) = c(i,j,k,m) + (1/4)*C_T(s,alpha)*P(alpha,k)*P(alpha,j)*W(alpha);
                            
                        end
                        
                        if(i==k)
                            
                            c(i,j,k,m) = c(i,j,k,m) + (1/4)*C_T(s,alpha)*P(alpha,m)*P(alpha,j)*W(alpha);
                            
                        end
                        
                end
                
            end
            
            end
            
        end
        
    end
                        

C = [c(1,1,1,1) c(1,1,2,2) c(1,1,3,3) c(1,1,1,2) c(1,1,2,3) c(1,1,3,1);
     c(2,2,1,1) c(2,2,2,2) c(2,2,3,3) c(2,2,1,2) c(2,2,2,3) c(2,2,3,1);
     c(3,3,1,1) c(3,3,2,2) c(3,3,3,3) c(3,3,1,2) c(3,3,2,3) c(3,3,3,1);
     c(1,2,1,1) c(1,2,2,2) c(1,2,3,3) c(1,2,1,2) c(1,2,2,3) c(1,2,3,1);
     c(2,3,1,1) c(2,3,2,2) c(2,3,3,3) c(2,3,1,2) c(2,3,2,3) c(2,3,3,1);
     c(3,1,1,1) c(3,1,2,2) c(3,1,3,3) c(3,1,1,2) c(3,1,2,3) c(3,1,3,1)]*6;  % stiffness matrix as per voight's sign convention 
 
 
 dsig = (C*deps')';
 sig(s+1,:) = sig(s,:)+(C*deps')'; %total stress matrix 
 
 eps(s+1,:) = eps(s,:) + deps; % strain for each time step
 
end

plot(eps(:,1),sig(:,1),'-r')
