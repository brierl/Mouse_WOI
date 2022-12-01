function n = normRow(m)

% normRow normalizes the rows in a 2D matrix. That is that is takes every
% row in the matrix and divides it by it's norm, so that that row vector
% will now have a norm of 1. Syntax:
% 
% normM=normRow(M)

[mr,mc]=size(m);

v=sqrt(sum((m.*m),2));

n=m./repmat(v,1,mc);

end