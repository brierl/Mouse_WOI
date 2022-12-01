function y = normr(x)

%  NORMR Normalize rows of matrices.
%
%  <a href="matlab:doc normr">normr</a>(X) takes a single matrix or cell array of matrices and returns
%  the matrices with rows normalized to a length of one.
%
%  Here the rows of a random matrix are randomized.
%
%    x = <a href="matlab:doc rands">rands</a>(4,8);
%    y = <a href="matlab:doc normr">normr</a>(x)
%
%  See also NORMC.

% Mark Beale, 1-31-92
% Copyright 1992-2010 The MathWorks, Inc.

% Checks
if nargin < 1,error(message('nnet:Args:NotEnough')); end
wasMatrix = ~iscell(x);
x = nntype.data('format',x,'Data');

% Compute
y = cell(size(x));
for i=1:numel(x)
  xi = x{i};
  cols = size(xi,2);
  n = 1 ./ sqrt(sum(xi.*xi,2));
  yi = xi .* n(:,ones(1,cols));
  yi(~isfinite(yi)) = 1;
  y{i} = yi;
end

% Format
if wasMatrix, y = y{1}; 

end