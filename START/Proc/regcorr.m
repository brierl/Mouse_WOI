function [data2, R]=regcorr(data,hem)

% regcorr() regresses out a signal from data and returns the
% post-regression data as well as the correlation coefficient of the input
% regressor with every channel in the data. If y_{r} is the signal to be
% regressed out and y_{in} is a data time trace (either source-detector or
% imaged), then the output is the least-squares regression: y_{out} =
% y_{in} - y_{r}(<y_{in},y_{r}>/|y_{r}|^2). Additionally, the correlation
% coefficient is given by: R=(<y_{in},y_{r}>/(|y_{in}|*|y_{r}|)).
% 
% To use regcorr() The syntax is:
% 
% [data2 R]=regcorr(data,hem)
% 
% regcorr() takes two input variables data and hem. This first variable is
% your data from which you want the signal regressed. It must be an array
% of two or more dimensions. The last dimension must be time, and the
% second-to-last dimension must be color/contrast. The other dimensions can
% be arranged in any order (e.g., source by detector, optode pair, or
% voxels). regcorr() will then loop over these dimensions as well as the
% color/contrast dimension.
% 
% The second input variable is signal which you want regressed from all the
% measurements. It must be a two dimensional array with the first dimension
% being color/contrast, and the second being time. If there is more than
% one color/contrast (e.g., 750 nm and 850 nm), then the number of
% contrasts in hem must be the same as in data. In this case, the
% regression will be contrast-matched, where each color in data will have
% that specific color's noise regressed out. If hem has only one contrast
% (i.e., one row), then that time trace will be regressed out of every
% contrast in data.
% 
% regcorr() outputs the variable data2, which is the regressed data. This
% returned variable has the same array size as the input variable. The
% second output variable is the correlation coefficients with every
% channel. It has the same size as the input data array (except without the
% time dimension). The second output, R is the correlation coefficient
% between hem and every time trace in data (within a color/contrast).  

[data, Sin, Sout]=datacondition(data,2); % reshape to meas x color x time

[hem, Hin, Hout]=datacondition(hem,2); % reshape to color x time

% check compatibility
if Hout(end)~=Sout(end)
    error('** Your data and regressor do not have the same time length: perhaps check your Resampling Tolerance Flag **')
end

if numel(Sout)==3 % normal case
    L=Sout(1);
    C=Sout(2);
    T=Sout(3);
    
    data2=zeros(T,C,L);
    R=zeros(L,C);
    
    for c=1:C
        temp=squeeze(data(:,c,:))'; % get single color/contrast

        g=hem(c,:)'; % regressor/noise signal in correct orientation
        gp=pinv(g); % pseudoinverse for least-square regression
        beta=gp*temp; % regression coefficient
        
        data2(:,c,:)=temp-g*beta; % linear regression
        
        R(:,c)=normRow(g')*normCol(temp); % correlation coefficient
    end
    data2=permute(data2,[3 2 1]); % switch dimensions back to correct order
    R=reshape(R,Sin(1:(end-1))); % reshape to original size (minus time)
    
elseif numel(Sout)==2 % special case of one contrast
    
    temp=data';

    g=hem';
    gp=pinv(g);
    beta=gp*temp;

    data2=temp-g*beta;

    R=normr(g')*normc(temp);
    data2=permute(data2,[2 1]); % switch dimensions back to correct order
    
end

data2=reshape(data2,Sin); % reshape to original shape

end