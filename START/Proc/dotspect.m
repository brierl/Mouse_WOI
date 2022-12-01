function [datahb]=dotspect(datamua,E)

% dotspect() performs spectroscopy on DOT <math>\frac{}{}\mu_a</math> data.
% 
% [datahb]=dotspect(datamua,E)
% 
% datamua is your absorption data, which must have a second-to-last
% dimension of color/wavelength. E is the spectroscopy matrix to use, which
% has dimensions wavelength x Hb contrast. If E is a square matrix, then
% the spectroscopy is performed with a simple matrix inversion. If E asks
% for fewer contrasts than there are wavelengths, then dotspect() should do
% a least-squares fitting, although this has never been tested. If there
% are more contrasts than wavelengths, the problem is obviously impossible
% to solve, resulting in an error. 

[Cin, Cout]=size(E);

[datamua, Sin, Sout]=datacondition(datamua,2);
L=Sout(1);
T=Sout(end);

if Sin(end-1)==1
    error('** Your data must have more than one wavelength to perform spectroscopy **')
elseif Cout>Cin
    error('** Your spectroscopy problem is underdetermined **')
elseif Cout==Cin % matrix inversion
    iE=inv(E);
elseif Cout<Cin % least-squares fit: CHECK!
    iE=pinv(E);
end

if numel(Sin)>=3
    Sout(2)=Cout;
    
    % Initialize Outputs
    datahb=zeros(Sout);
    for h=1:Cout
        tseq=zeros(L,T);
        for c=1:Cin
            tseq=tseq+squeeze(iE(h,c))*squeeze(datamua(:,c,:));
        end
        datahb(:,h,:)=tseq;
    end
    
    datahb=reshape(datahb,[Sin(1:end-2) Cout Sin(end)]);
else
    datahb=zeros(Cout,T);
    for h=1:Cout
        tseq=zeros(1,T);
        for c=1:Cin
            tseq=tseq+squeeze(iE(h,c))*squeeze(datamua(c,:));
        end
        datahb(h,:)=tseq;
    end
end
   
end