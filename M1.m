clear
n = 100; % number of time steps

eps = zeros(n,6); % [eps_11 eps_22 eps_33 eps_12 eps_23 eps_31]


Eps_0 = 0.25e-3;     %peak strain in uniaxial stress-strain r/s

p = 2;

E = 10^5*(5/2/pi); %initial young's modulus

nu = zeros(n,1);

nu(1,1) = 0.25; % desired poisson's ratio

% deps = [1 -nu -nu 0 0 0]*10^-5;% increment of strain

nu_m = 0.25; %poisson's ratio of the microplane model (1/4 constant) from the theory

sig = zeros(n,6);  % To store the total stress [sig_11 sig_22 sig_33 sig_12 sig_23 sig_31]

%  [P,W] = Bazant_Int(1); %selection of integration rule

[leb_tmp] = getLebedevSphere(50); % degree: { 6, 14, 26, 38, 50, 74, 86, 110, 146, 170, 194, 230, 266, 302, 
%   350, 434, 590, 770, 974, 1202, 1454, 1730, 2030, 2354, 2702, 3074, 
%   3470, 3890, 4334, 4802, 5294, 5810 };

P = horzcat((leb_tmp.x),(leb_tmp.y),(leb_tmp.z));

W = leb_tmp.w; 

eps_n = zeros(n,size(P,1)); % normal strain for each time step at every integration point 

a_n = zeros(n,size(P,1));

for s = 1:n
    
    
    c = zeros(3,3,3,3); % initialization of fouth order stiffess tensor
    
    c_c = zeros(3,3,3,3); % initialization of fouth order correction stiffess tensor
 
    

      for alpha = 1: size(P,1)
        
                        eps_n(s,alpha) = P(alpha,:)*[eps(s,1) eps(s,4)/2 eps(s,6)/2; 
                                                     eps(s,4)/2 eps(s,2) eps(s,5)/2; 
                                                     eps(s,6)/2 eps(s,5)/2 eps(s,3)]*P(alpha,:)'; %normal on the considered microplane
                                        
                        
                         a_n(s,alpha) =(1-(p*(eps_n(s,alpha)/Eps_0)^p)) * exp( -1.0 * ((eps_n(s,alpha)/Eps_0)^p)); % captures stiffness degradation

% if     eps_n(s,alpha) >= 0 
%             
%             a_n = (1 - ((eps_n(s,alpha)/Eps_0)^p)) * exp( -1.0 * ((eps_n(s,alpha)/Eps_0)^p));
%             
%             else
%                 
%             a_n = (1 + ((abs(eps_n(s,alpha)/Eps_0))^p)) * ...
%                    exp( -1.0 * ((abs(eps_n(s,alpha)/Eps_0))^p));
% end
%     
    for i = 1:3

        for j = 1:3

            for k = 1:3

                for m = 1:3
    
                                           

                        c(i,j,k,m) = c(i,j,k,m) + a_n(s,alpha)*E*P(alpha,i)*P(alpha,j)*P(alpha,k)*P(alpha,m)*W(alpha); %microplane stiffness tensor
                        
                        if(i==j&&k==m)
                        
%                              c_c(i,j,k,m) = ((1+nu(s))*2*pi*E/5*((nu_m-nu(s))))^-1; %correction compliance tensor
                        
                        end

                end

            end

        end

    end
 
      end

% D = [c(1,1,1,1) c(1,1,2,2) c(1,1,3,3) c(1,1,1,2) c(1,1,2,3) c(1,1,3,1);
%      c(2,2,1,1) c(2,2,2,2) c(2,2,3,3) c(2,2,1,2) c(2,2,2,3) c(2,2,3,1);
%      c(3,3,1,1) c(3,3,2,2) c(3,3,3,3) c(3,3,1,2) c(3,3,2,3) c(3,3,3,1);
%      c(1,2,1,1) c(1,2,2,2) c(1,2,3,3) c(1,2,1,2) c(1,2,2,3) c(1,2,3,1);
%      c(2,3,1,1) c(2,3,2,2) c(2,3,3,3) c(2,3,1,2) c(2,3,2,3) c(2,3,3,1);
%      c(3,1,1,1) c(3,1,2,2) c(3,1,3,3) c(3,1,1,2) c(3,1,2,3) c(3,1,3,1)]; %microplane stiffness matrix
%  
% C_c = [c_c(1,1,1,1) c_c(1,1,2,2) c_c(1,1,3,3) c_c(1,1,1,2) c_c(1,1,2,3) c_c(1,1,3,1);
%      c_c(2,2,1,1) c_c(2,2,2,2) c_c(2,2,3,3) c_c(2,2,1,2) c_c(2,2,2,3) c_c(2,2,3,1);
%      c_c(3,3,1,1) c_c(3,3,2,2) c_c(3,3,3,3) c_c(3,3,1,2) c_c(3,3,2,3) c_c(3,3,3,1);
%      c_c(1,2,1,1) c_c(1,2,2,2) c_c(1,2,3,3) c_c(1,2,1,2) c_c(1,2,2,3) c_c(1,2,3,1);
%      c_c(2,3,1,1) c_c(2,3,2,2) c_c(2,3,3,3) c_c(2,3,1,2) c_c(2,3,2,3) c_c(2,3,3,1);
%      c_c(3,1,1,1) c_c(3,1,2,2) c_c(3,1,3,3) c_c(3,1,1,2) c_c(3,1,2,3) c_c(3,1,3,1)]; %correction stiffness matrix
%                                  
%   C = inv(inv(D) + (C_c)); 
    
C = [c(1,1,1,1) c(1,1,2,2) c(1,1,3,3) c(1,1,1,2) c(1,1,2,3) c(1,1,3,1);
     c(2,2,1,1) c(2,2,2,2) c(2,2,3,3) c(2,2,1,2) c(2,2,2,3) c(2,2,3,1);
     c(3,3,1,1) c(3,3,2,2) c(3,3,3,3) c(3,3,1,2) c(3,3,2,3) c(3,3,3,1);
     c(1,2,1,1) c(1,2,2,2) c(1,2,3,3) c(1,2,1,2) c(1,2,2,3) c(1,2,3,1);
     c(2,3,1,1) c(2,3,2,2) c(2,3,3,3) c(2,3,1,2) c(2,3,2,3) c(2,3,3,1);
     c(3,1,1,1) c(3,1,2,2) c(3,1,3,3) c(3,1,1,2) c(3,1,2,3) c(3,1,3,1)];
 
 
 dummy = inv(C)*[1 0 0 0 0 0]'; 
 
 nu(s+1,1) = -dummy(2)/dummy(1);
 
 eps(s+1,:) = eps(s,:) + [1 -nu(s+1,1) -nu(s+1,1) 0 0 0]*10^-5; % strain for each time step
 
 sig(s+1,:) = (1/2*C*([1 -nu(s+1,1) -nu(s+1,1) 0 0 0]*10^-5)')'+sig(s,:);
%   nu(s+1,1) = 1/((1/(sig(s+1,2)/sig(s+1,1)))+1);
end

plot(eps(:,1),sig(:,1),'-*')
hold on
