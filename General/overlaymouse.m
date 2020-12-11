function Im2=overlaymouse(Im,WL,isbrain,cname,cmin,cmax,WL_factor)

% overlaymouse maps image data (Im) onto a WL image and scales ([cmin cmax])
% using a contrast (cname, e.g. 'jet') and within brain regions as specified 
% by a binary mask (isbrain)

% OUT:
%   Im2: overlayed image

if max(WL(:))>1
    Im2=double(WL)/255;
else
    Im2=WL;
end

[nVx,nVy]=size(Im);

if ischar(cname)
    cmap=colormap(cname);
else
    cmap=cname;
end


if ischar(cmin)
    switch cmin
        case 'min'
            cmin=min(min(Im));
        case '-max'
            cmin=-max(max(Im));
        case 'minmax'
            cmin=-max([-min(min(Im)) max(max(Im))]);
    end
end

if ischar(cmax)
    switch cmax
        case 'max'
            cmax=max(max(Im));       
        case '-min'
            cmax=-min(min(Im));
        case 'minmax'
            cmax=max([-min(min(Im)) max(max(Im))]);       
    end
end

cnum=size(cmap,1);

cslope=(cnum-1)/(cmax-cmin);
cinter=1-cslope*cmin;

for x=1:nVx
    for y=1:nVy
        if isbrain(x,y)==1
            cidx=round(cslope*Im(x,y)+cinter);
            if cidx>cnum
                cidx=cnum;
            end
            if cidx<1
                cidx=1;
            end
            
            if isnan(cidx)
                cidx=1;
            end
            
            assignin('base', 'IM2', Im2);
            assignin('base','cidx', cidx);
            assignin('base','cmap', cmap);
            
            Im2(x+WL_factor,y,:)=cmap(cidx,:);
        end
    end
end


end