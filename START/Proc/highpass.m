function [fdata]=highpass(data,omegaHz,frate)

% highpass() high-pass filters data, preserving phase information. Syntax:
% 
% [fdata]=highpass(data,omegaHz,framerate)
% 
% data can be an array of any size, as long as time is the last dimension.
% If data is a struct, then every field is filtered. omegaHz is the cut-off
% frequency of the filter (in Hz). framerate is the framerate of your data
% (in Hz). 

if isstruct(data)
    N=fieldnames(data);
    
    for f=1:size(N,1)
        fname=N{f};
        fdata.(fname)=highpass(data.(fname),omegaHz,frate);
    end
else

    % Reshape to Stuff x Time
    [data2, Sin, Sout]=datacondition(data,1);
    
    % Initialize
    fdata=zeros(Sout);
    
    % Hz Freq. -> Frac. of Nyquist Freq.
    omegaNy=omegaHz*(2/frate);
    
    [b,a] = butter(5,omegaNy,'high');
    
    for n=1:Sout(1)
        fdata(n,:)=filtfilt(b,a,squeeze(data2(n,:)));
    end
    
    fdata=reshape(fdata,Sin);
    
end

end