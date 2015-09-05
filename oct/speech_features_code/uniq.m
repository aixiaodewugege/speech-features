function b = uniq(a)
% Like the MATLAB unique(), except it doesn't sort first.  Semantics match
% UNIX uniq, from which it derives its name.
%
% Works column-wise on a.  Doesn't work if there are NaN's or Inf's in a.
% Other restrictions apply.

columns = size(a,2);

d = a(:,1:columns-1)~=a(:,2:columns);

d = any(d,1);
d(1,columns) = 1;      % Final row is always member of unique list.
  
b = a(:,d);         % Create unique list by indexing into sorted list.
