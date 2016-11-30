classdef MicroplaneElastic
%     Drives the microplanes responses for a given strain vector and return
%     the corresponding stress vector
    properties (Access = private)
        E
        nu
        
        K
        G
        
        Npts
        points
        weights
        
    end
    methods
        function obj = MicroplaneElastic(modelParam, IntegrationMethod)
%             - LdC : constitutive law (class) which gives the normal and
%             tangential stress from given normal and tangential strain
%             - IntegrationMethod : Integration method
%               ->'BazantOh21'
            obj.E = modelParam(1);
            obj.nu = modelParam(2);
            
            obj.K = (1/3) * obj.E / ( 1 - 2*obj.nu );
            obj.G = (1/2) * obj.E /( 1 + obj.nu );
            
            [obj.points, obj.weights] = setNumericalIntegration(IntegrationMethod); % set integration points and associated weights
            obj.Npts = numel(obj.weights); % Number of integration points
            
        end
        function [E, nu] = giveElasticParameters(obj)
            E = obj.E;
            nu = obj.nu;
        end
        function [Stress, PlasticStrain, Variables] = giveRealStress(obj, Strain, PlasticStrain, Variables)
            
            [EpsV, EpsD, EpsT] = obj.decomposition(Strain); % Decomposition sur tous  les microplans
            
            % Initialisation
            SigV = 3 * obj.K * EpsV; % Volumetric stress
            SigD = 2 * obj.G * EpsD;
            SigT = 2 * obj.G * EpsT;
            
            % Computation of the microscopic stress - Integration
            Stress = zeros(6,1);
            
            dd = [1 1; 2 2; 3 3; 2 3; 3 1; 1 2]; % define i and j in the indexed notation
            I3 = eye(3); % Kronecker delta
            for u=1:6
                i = dd(u,1);
                j = dd(u,2);
                ff = zeros(obj.Npts, 1);
                for k=1:obj.Npts
                    n = obj.points(:,k);
                    TT(1,1) = n(i) * I3(1, j) + n(j) * I3(1, i);
                    TT(1,2) = n(i) * I3(2, j) + n(j) * I3(2, i);
                    TT(1,3) = n(i) * I3(3, j) + n(j) * I3(3, i);
                    ff(k, 1) = SigD(k) * n(i) * n(j) + 0.5 * TT * SigT(:,k);
                end
                Stress(u) = SigV * I3(i,j) +  6 * obj.weights * ff;
            end
            
        end
        function [EpsV, EpsD, EpsT] = decomposition(obj, StrainVector)
            
            StrainTensor = [StrainVector(1), StrainVector(6)/2,  StrainVector(5)/2;
                StrainVector(6)/2, StrainVector(2), StrainVector(4)/2;
                StrainVector(5)/2, StrainVector(4)/2, StrainVector(3)];
            
            % Initialisation
            EpsV = trace(StrainTensor)/3;
            EpsD = zeros(1, obj.Npts); % Normal Stain
            EpsT = zeros(3, obj.Npts); % Tangential strain vector
            
            for i = 1:obj.Npts
                n = obj.points(:,i);
                EpsN = n' * StrainTensor * n ;
                EpsD(i) = EpsN - EpsV;
                
%                 EpsT(1, i) = StrainTensor(1, :) * n - EpsN * n(1);
%                 EpsT(2, i) = StrainTensor(2, :) * n - EpsN * n(2);
%                 EpsT(3, i) = StrainTensor(3, :) * n - EpsN * n(3);
                EpsT(:,i) = StrainTensor * n - EpsN .* n;
                
            end
        end
    end
end
