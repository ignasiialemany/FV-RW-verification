function [pos0] = place_in(NP, domain, varargin)
% place N walkers randomly inside a boolean ND map

%TODO: process varargin

bbox = domain.bbox;

pos0 = nan(NP, size(bbox, 1));
successfully_updated = false(NP, 1);
idx_needUpdate = 1:NP;
while numel(idx_needUpdate) > 0
    N_update = numel(idx_needUpdate); % temp var
    pos_new = generate_points(N_update, bbox);
    canbeplaced = findValuesAtPoints(domain, pos_new);
    ii = idx_needUpdate(canbeplaced);
    successfully_updated(ii) = true;
    pos0(ii, :) = pos_new(canbeplaced, :);
    idx_needUpdate = find(~successfully_updated);
end

end

function [pos] = generate_points(N, bbox)

dim = size(bbox, 2);
pos = bbox(1, :) + rand(N, dim).*diff(bbox, 1, 1);

end
