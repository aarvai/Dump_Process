function x = patch_missing_values(x)
% This script patches arrays that include NaN's with its nearest valid
% neighbor in the same column.
for c = 1:size(x,2)
    valid_values = find(~isnan(x(:,c)));
    for r = 1:size(x,1)
        if isnan(x(r,c))
            [~, closest_valid_index] = min(abs(valid_values - r));
            x(r,c) = x(valid_values(closest_valid_index),c);
        end
    end
end