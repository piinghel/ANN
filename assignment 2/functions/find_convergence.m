function [idx] = find_convergence(record)
% find the index number where there are no changes anymore
idx = 0;
for i=1:size(record,1)
    difference = diff(record(i,:));
    if max(abs(difference)) == 0
        conv_i = 0;
    else
        conv_i = find(difference,1,'last');
    end
    idx = max(idx,conv_i);
end

