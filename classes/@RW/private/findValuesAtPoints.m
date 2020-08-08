function [values, nomatch] = findValuesAtPoints(domain, pos)
% find the value at a point in the domain map

dim = size(pos, 2);
[idx_x, idx_y, idx_z] = deal(ones(size(pos, 1), 1)); % default
[nomatch_x, nomatch_y, nomatch_z] = deal(false(size(idx_x)));

if dim > 0 % x
    [idx_x, nomatch_x] = find_cells(pos(:, 1), domain.edges_x);
end
if dim > 1 % y
    [idx_y, nomatch_y] = find_cells(pos(:, 2), domain.edges_y);
end
if dim > 2 % z
    [idx_z, nomatch_z] = find_cells(pos(:, 3), domain.edges_z);
end

map = domain.map;
values = map(sub2ind(size(map), idx_x, idx_y, idx_z));
nomatch = nomatch_x | nomatch_y | nomatch_z;

end

function [indices, nomatch] = find_cells(pos, edges)

edges = edges(:)'; % edges as row vector
pos = pos(:); % pos as column vector
match = (pos > edges(1:end-1)) & (pos <= edges(2:end)); % [NP, Nedges]

% fix the nomatch case
nomatchL = pos <= edges(1);
nomatchR = pos >  edges(end);
nomatch = [nomatchL, nomatchR];
match(nomatchL, 1) = true;
match(nomatchR, end) = true;

indices = find(transpose(match)); % search row by row (hence transposed)
indices = mod(indices, size(match, 2)); % wrap around
indices(indices==0) = size(match, 2); % fix 0 after mod

end
