function VKE = test_transk

% Input
B    = [-0.7071  0.7071 0 ; 
        -0.7071 -0.7071 0 ;
        0       0       1];
NBNO = 3;
ICOM = 0;

VKE  = rand(18,18);
VKE  = 0.5*(VKE+VKE');

VKE = transk(VKE,B,NBNO,ICOM);

function VKE = transk(VKE,B,NBNO,ICOM)

% Idexes to extract proper dofs
idx = [1,2,1,4,3,1,2,4,2,1,4,3,4,3,1,2,4,2,4,2,1,...
    4,3,4,3,4,3,1,2,4,2,4,2,4,2,1];

NB = NBNO + NBNO;
IJ = 1;
JTROIS = 0;

for J=1:NB
    ITROIS = 0;
    for I=1:J
        ICH = idx(IJ);
        if ICOM == 1
            ICH = 4;
        end
        
        for IA=1:3
            for IB=1:3
                A(IA,IB)=VKE(ITROIS+IA,JTROIS+IB);
            end
        end
        
        switch ICH
            case 1
                AA = vmult1(A,B);
            case 2
                AA = vmult2(A,B);
            case 3
                AA = vmult3(A,B);
            case 4
                AA = vmult4(A,B);
            otherwise
                
                error('Case not implemented')
                
        end
        
        AA = reshape(AA,3,3);
        for IA=1:3
            for IB=1:3
                VKE(ITROIS+IA,JTROIS+IB)=AA(IA,IB);
                VKE(JTROIS+IB,ITROIS+IA)=AA(IA,IB);
            end
        end
        IJ = IJ + 1;
        ITROIS = ITROIS + 3;
    end
    JTROIS = JTROIS + 3;
end

function AA = vmult1(A,B)
B11=B(1,1);
B12=B(1,2);
B13=B(1,3);
B21=B(2,1);
B22=B(2,2);
B23=B(2,3);
B31=B(3,1);
B32=B(3,2);
B33=B(3,3);

C1=B11*A(1)+B21*A(4);
C2=B11*A(4)+B21*A(5);
C3=B12*A(1)+B22*A(4);
C4=B12*A(4)+B22*A(5);
C5=B13*A(1)+B23*A(4);
C6=B13*A(4)+B23*A(5);
C7=B31*A(9);
C8=B32*A(9);
C9=B33*A(9);

AA(1)=B11*C1+B21*C2+B31*C7;
AA(4)=B12*C1+B22*C2+B32*C7;
AA(5)=B12*C3+B22*C4+B32*C8;
AA(7)=B13*C1+B23*C2+B33*C7;
AA(8)=B12*C5+B22*C6+B32*C9;
AA(9)=B13*C5+B23*C6+B33*C9;
AA(2)=AA(4);
AA(3)=AA(7);
AA(6)=AA(8);

function AA = vmult2(A,B)
B11=B(1,1);
B12=B(1,2);
B13=B(1,3);
B21=B(2,1);
B22=B(2,2);
B23=B(2,3);
B31=B(3,1);
B32=B(3,2);
B33=B(3,3);

C1=B11*A(3)+B21*A(6);
C2=B12*A(3)+B22*A(6);
C3=B13*A(3)+B23*A(6);

AA(1)=B31*C1;
AA(2)=B32*C1;
AA(3)=B33*C1;
AA(4)=B31*C2;
AA(5)=B32*C2;
AA(6)=B33*C2;
AA(7)=B31*C3;
AA(8)=B32*C3;
AA(9)=B33*C3;

function AA = vmult3(A,B)
B11=B(1,1);
B12=B(1,2);
B13=B(1,3);
B21=B(2,1);
B22=B(2,2);
B23=B(2,3);
B31=B(3,1);
B32=B(3,2);
B33=B(3,3);

AA(1)=B11*A(7)*B31+B21*A(8)*B31;
AA(2)=B12*A(7)*B31+B22*A(8)*B31;
AA(3)=B13*A(7)*B31+B23*A(8)*B31;
AA(4)=B11*A(7)*B32+B21*A(8)*B32;
AA(5)=B12*A(7)*B32+B22*A(8)*B32;
AA(6)=B13*A(7)*B32+B23*A(8)*B32;
AA(7)=B11*A(7)*B33+B21*A(8)*B33;
AA(8)=B12*A(7)*B33+B22*A(8)*B33;
AA(9)=B13*A(7)*B33+B23*A(8)*B33;

function AA = vmult4(A,B)
IJ=1;

for J=1:3
    
    for I1=1:3
        C=0;
        for J1=1:3
            C=C+A(I1,J1)*B(J1,J);
        end
        T(I1)=C;
    end
    
    for I=1:3
        C=0;
        for J1=1:3
            C=C+T(J1)*B(J1,I);
        end
        AA(IJ)=C;
        IJ=IJ+1;
    end
    
end





