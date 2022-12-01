function [fdata]=lowpass(data,omegaHz,frate)

% lowpass() low-pass filters data, preserving phase information. Syntax:
% 
% [fdata]=lowpass(data,omegaHz,framerate)
% 
% data can be an array of any size, as long as time is the last dimension.
% If data is a struct, then every field is filtered. omegaHz is the cut-off
% frequency of the filter (in Hz). framerate is the framerate of your data
% (in Hz). 

if isstruct(data)
    N=fieldnames(data);
    
    for f=1:size(N,1)
        fname=N{f};
        fdata.(fname)=lowpass(data.(fname),omegaHz,frate);
    end
else
    % Reshape to Stuff x Time
    [data2, Sin, Sout]=datacondition(data,1);

    % Initialize
    fdata=zeros(Sout);
    
    % Convert Hz Frequency to a Fraction of the Nyquist Frequency
    omegaNy=omegaHz*(2/frate);
    
    % Make Filter
    [b,a] = butter(5,omegaNy);
    
    % Filter every time trace (w/ phase preservation)
    for n=1:Sout(1)
        fdata(n,:)=filtfilt(b,a,squeeze(data2(n,:)));
    end
    
    fdata=reshape(fdata,Sin);
end

end