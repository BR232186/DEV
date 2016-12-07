
n = 500; % number of time steps

eps = zeros(n,1); % [eps_11 ]

Eps_0 = 0.5e-3;     %peak strain in uniaxial stress-strain r/s

p = 1;

E = 30e9; %initial young's modulus


deps = 10^-5;% increment of strain


sig = zeros(n,1);  % To store the total stress [sig_11]

%   [P,W] = Bazant_Int(1); %selection of integration rule

[leb_tmp] = getLebedevSphere(50); % degree: { 6, 14, 26, 38, 50, 74, 86, 110, 146, 170, 194, 230, 266, 302, 
%   350, 434, 590, 770, 974, 1202, 1454, 1730, 2030, 2354, 2702, 3074, 
%   3470, 3890, 4334, 4802, 5294, 5810 };

P = horzcat((leb_tmp.x),(leb_tmp.y),(leb_tmp.z));

W = leb_tmp.w; 

eps_n = zeros(n,size(P,1)); % normal strain for each time step at every integration point 

a_n = zeros(n,size(P,1));

for s = 1:n
    
    eps(s+1,1) = eps(s,1) + deps; % strain for each time step
    
    C = 0; % initialization of fouth order stiffess tensor
     
    for alpha = 1: size(P,1)
        
                        eps_n(s,alpha) = eps(s+1,1); %normal on the considered microplane
                                        
                        a_n(s,alpha) = (1- (p*(abs(eps_n(s,alpha))/Eps_0)^p)) * exp(-(abs(eps_n(s,alpha))/Eps_0)^p); % captures stiffness degradation

                        C = C + a_n(s,alpha)*E*P(alpha,1)*P(alpha,1)*P(alpha,1)*P(alpha,1)*W(alpha); %microplane stiffness tensor
                        
                       sig(s+1,1) = 1/2*C*deps+sig(s,1);

     end
end
plot(eps(:,1),sig(:,1),'')
