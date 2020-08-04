function [c0] = init_spike(domain, origin, varargin)
% set initial concentration to a unit impulse at the specified origin

%TODO: process varargin

dim = domain.dimension;

% create object
c0 = createCellVariable(domain, 0); % zero everywhere

% find location
[x0_idx, y0_idx, z0_idx] = deal(0); % position
[dx0, dy0, dz0] = deal(1); % cell size at position
if dim > 0
    x0_idx = find_cell_containing_point(domain.facecenters.x, origin(1));
    dx0 = domain.cellsize.x(x0_idx);
end
if dim > 1
    y0_idx = find_cell_containing_point(domain.facecenters.y, origin(2));
    dy0 = domain.cellsize.y(y0_idx);
end
if dim > 2
    z0_idx = find_cell_containing_point(domain.facecenters.z, origin(3));
    dz0 = domain.cellsize.z(z0_idx);
end

% impulse such that integral equals unity @ 1+idx due to ghost cells at ends
if ~isempty(x0_idx) && ~isempty(y0_idx) && ~isempty(z0_idx) % only if found
    c0.value(1+x0_idx, 1+y0_idx, 1+z0_idx) = 1.0 / dx0 / dy0 / dz0;
end

end
