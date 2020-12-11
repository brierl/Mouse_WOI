function n = normCol(m)

% normCol normalizes the columns in a 2D matrix. That is that is takes
% every column in the matrix and divides it by it's norm, so that that
% column vector will now have a norm of 1. Syntax:
% 
% normM=normCol(M)

[mr,mc]=size(m);

v=sqrt(sum((m.*m),1));

n=m./repmat(v,mr,1);

end
