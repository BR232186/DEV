clear
n = 101; % number of time steps

eps = zeros(n,6); % [eps_11 eps_22 eps_33 eps_12 eps_23 eps_31]

deps = [1 0 0 0 0 0]*10^-6; % increment of strain

sig_el = zeros(n,6); % elastic part of stress matrix as per voight's sign convention [sig_el_11 sig_el_22 sig_el_33 sig_el_12 sig_el_23 sig_el_31]

sigma_nel = zeros(3,3,n); % tensor of stress relxation

sig_nel = zeros(n,6); %  matrix of stress relaxation as per voight's sign convention [sig_nel_11 sig_nel_22 sig_nel_33 sig_nel_12 sig_nel_23 sig_nel_31]

sig = zeros(n,6); %total stress matrix as per voight's sign convention [sig_11 sig_22 sig_33 sig_12 sig_23 sig_31]

[P,W] = Bazant_Int(1); %selection of integration rule

eps_n = zeros(n,size(P,1)); % normal strain for each time step at every integration point 

eps_V = zeros(n,size(P,1)); % volumetric strain component for each time step at every integration point 

eps_D = zeros(n,size(P,1)); % deviatoric strain component for each time step at every integration point 

eps_t = zeros(n,size(P,1),3); % vector of tangential strain for each time step at every integration point 

eps_T = zeros(n,size(P,1)); % tangential strain modulus for each time step at every integration point 

sig_V = zeros(3,3,size(P,1)); %  Volumetric stress relaxation

sig_D = zeros(3,3,size(P,1)); %  deviatoric stress relaxation

sig_T = zeros(3,3,size(P,1)); %  tangential stress relaxation

C_V = 62.5; % modulus of sig_V vs. eps_V

C_D = 53.125; % modulus of sig_D vs. eps_D

C_T = 21.0805; % modulus of sig_T vs. eps_T

p1 = 1;

p2 = 1;

p3 = 1;

a1 = 1.e-4;

a2 = 1.e-3;

a3 = 0.0018;

for s = 1:n %loop on all the time steps
    
    
    
    c = zeros(3,3,3,3); % initialization of fouth order stiffess tensor
    
    sigma_nel = zeros(3,3,n); % initialization of stress relxation tensor

    for alpha = 1: size(P,1) %loop on all the integration points
    
    
        eps_n(s,alpha) = P(alpha,:)*[eps(s,1) eps(s,4) eps(s,6); 
                                     eps(s,4) eps(s,2) eps(s,5); 
                                     eps(s,6) eps(s,5) eps(s,3)]*P(alpha,:)'; %normal strain on the considered microplane
                                        
        eps_V(s,alpha) = sum(P(alpha,:)*[eps(s,1) eps(s,4) eps(s,6); 
                                         eps(s,4) eps(s,2) eps(s,5); 
                                         eps(s,6) eps(s,5) eps(s,3)])/3;  %volumetric strain on the considered microplane
                                        
        eps_D(s,alpha) = eps_n(s,alpha) - eps_V(s,alpha); %deviatoric strain on the considered microplane
        
        deps_n(alpha) = P(alpha,:)*[deps(1) deps(4) deps(6); 
                                     deps(4) deps(2) deps(5); 
                                     deps(6) deps(5) deps(3)]*P(alpha,:)'; %normal strain on the considered microplane
                                 
        deps_V(alpha) = sum(P(alpha,:)*[deps(1) deps(4) deps(6); 
                                         deps(4) deps(2) deps(5); 
                                         deps(6) deps(5) deps(3)])/3;  %volumetric strain on the considered microplane
                                        
        deps_D(alpha) = deps_n(alpha) - deps_V(alpha); %deviatoric strain on the considered microplane
        
                        
        dummy = P(alpha,:)*[eps(s,1) eps(s,4) eps(s,6); 
                            eps(s,4) eps(s,2) eps(s,5); 
                            eps(s,6) eps(s,5) eps(s,3)];
                        
        eps_t(s,alpha,:) = dummy - P(alpha,:)*eps_n(s,alpha); %tangential strain vector on the considered microplane
                        
        eps_T(s,alpha) = (eps_t(s,alpha,1)^2+eps_t(s,alpha,2)^2+eps_t(s,alpha,3)^2)^0.5; % tangential strain modulus 
        
        deps_t(alpha,:) = dummy - P(alpha,:)*eps_n(alpha); %tangential strain vector on the considered microplane
                        
        deps_T(alpha) = (deps_t(alpha,1)^2+deps_t(alpha,2)^2+deps_t(alpha,3)^2)^0.5; % tangential strain modulus 
  
        for i = 1:3

            for j = 1:3
                
                sig_V(i,j,s) = P(alpha,i)*P(alpha,j)*C_V*(1-p1*(eps_V(s,alpha)/a1)^p1)*exp(-(eps_V(s,alpha)/a1)^p1)* deps_V(alpha); %  Volumetric stress relaxation
                
                sig_D(i,j,s) = P(alpha,i)*P(alpha,j)*C_D *(1-p2*(eps_D(s,alpha)/a1)^p2)*exp(-(eps_D(s,alpha)/a2)^p2)* deps_D(alpha); %  deviatoric stress relaxation

                
                sig_T(i,j,s) = (1/2)*(P(alpha,i)*deps_t(alpha,j) + P(alpha,j)*deps_t(alpha,i)...
                                        - 2*P(alpha,i)*P(alpha,j)*(P(alpha,1)*deps_t(alpha,1)+P(alpha,2)*deps_t(alpha,2)+P(alpha,3)*deps_t(alpha,3)))...
                                                                                                             *C_T *(1-p3*eps_T(s,alpha)^(p3-1)/a3^(p3))*exp(-(eps_T(s,alpha)/a3)^p3); %  tangential stress relaxation
            
           
                   
           
                sigma_nel(i,j,s) = sigma_nel(i,j,s) + (sig_V(i,j,s)+sig_D(i,j,s)+ sig_T(i,j,s))*W(alpha); %total stress relaxation on the considered microplane

            for k = 1:3


                for m = 1:3
    
                        c(i,j,k,m) = c(i,j,k,m) + (C_D-C_T)*P(alpha,i)*P(alpha,j)*P(alpha,k)*P(alpha,m)*W(alpha);
                        
                        if(k==m)
                            
                            c(i,j,k,m) = c(i,j,k,m) + (1/3)*(C_V-C_D)*P(alpha,i)*P(alpha,j)*W(alpha);
                            
                        end
                        
                        if(j==m)
                            
                            c(i,j,k,m) = c(i,j,k,m) + (1/4)*C_T*P(alpha,i)*P(alpha,k)*W(alpha);
                            
                        end
                        
                        if(j==k)
                            
                            c(i,j,k,m) = c(i,j,k,m) + (1/4)*C_T*P(alpha,i)*P(alpha,m)*W(alpha);
                            
                        end
                        
                        if(i==m)
                            
                            c(i,j,k,m) = c(i,j,k,m) + (1/4)*C_T*P(alpha,k)*P(alpha,j)*W(alpha);
                            
                        end
                        
                        if(i==k)
                            
                            c(i,j,k,m) = c(i,j,k,m) + (1/4)*C_T*P(alpha,m)*P(alpha,j)*W(alpha);
                            
                        end
                        
                end
                
            end
            
            end
            
        end
        
    end
                        

C = [c(1,1,1,1) c(1,1,2,2) c(1,1,3,3) c(1,1,1,2) c(1,1,2,3) c(1,1,3,1);
     c(2,2,1,1) c(2,2,2,2) c(2,2,3,3) c(2,2,1,2) c(2,2,2,3) c(2,2,3,1);
     c(3,3,1,1) c(3,3,2,2) c(3,3,3,3) c(3,3,1,2) c(3,3,2,3) c(3,3,3,1);
     c(1,2,1,1) c(1,2,2,2) c(1,1,3,3) c(1,2,1,2) c(1,2,2,3) c(1,2,3,1);
     c(2,3,1,1) c(2,3,2,2) c(2,3,3,3) c(2,3,1,2) c(2,3,2,3) c(2,3,3,1);
     c(3,1,1,1) c(3,1,2,2) c(3,1,3,3) c(3,1,1,2) c(3,1,2,3) c(3,1,3,1)]*6;  % stiffness matrix as per voight's sign convention 
 
 sig_nel(s,:) = [sigma_nel(1,1,s) sigma_nel(2,2,s) sigma_nel(3,3,s) sigma_nel(1,2,s) sigma_nel(2,3,s) sigma_nel(3,1,s)]; %  matrix of stress relaxation as per voight's sign convention 
    
 sig_el(s+1,:) = sig_el(s,:)+(C*deps')';  % elastic part of stress matrix as per voight's sign convention
 
 sig(s+1,:) = sig(s,:)+(C*deps')' - sig_nel(s,:)*6; %total stress matrix 
 
 eps(s+1,:) = eps(s,:) + deps; % strain for each time step
 
end

plot(eps(:,1),sig(:,1),'')
