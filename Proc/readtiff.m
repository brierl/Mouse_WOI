function [data]=readtiff(filename)
% read in filetype .tif

% IN: 
%   filename: filename to be read in

% OUT:
%   data: read in image stack

info = imfinfo(filename);
numI = numel(info);
data=zeros(info(1).Width,info(1).Height,numI,'uint16'); %initialize 
fid=fopen(filename);

fseek(fid,info(1).Offset,'bof');
for k = 1:numI % loops through stack
    
    fseek(fid,[info(1,1).StripOffsets(1)-info(1).Offset],'cof');    
    tempdata=fread(fid,info(1).Width*info(1).Height,'uint16');
    data(:,:,k) = rot90((reshape(tempdata,info(1).Width,info(1).Height)),-1);
end

fclose(fid);

end