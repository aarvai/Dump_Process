function i = find_closest(a, b)
% This function returns an array of length a with the indices of 
% array b that are closest to the values of array a.
delta = abs(repmat(a, length(b), 1) - repmat(b', 1, length(a)));
[~, i] = min(delta, [], 1);
end
 