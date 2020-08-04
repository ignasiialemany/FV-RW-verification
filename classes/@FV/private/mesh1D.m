function [domain, D_face, ID] = mesh1D(dx, x_b, P, D, varargin)
% mesh with specified resolution, but ensures the boundary locations are kept

% verify arguments
validateattributes(x_b, {'numeric'}, {'vector', 'increasing'}); % x locations of barriers
validateattributes(P, {'numeric'}, {'vector', 'nonnegative'}); % permeabilities
validateattributes(D, {'numeric'}, {'vector', 'nonnegative'}); % diffusivities
if numel(x_b) ~= numel(P)
    error('inconsistent size between x_b and P');
end
if numel(x_b) ~= numel(D)+1
    error('inconsistent size between x_b and D');
end

%TODO: process varargin

%% Construct the Cartesian mesh

% linear interpolation with approximate dx spacing between boundaries
l_c = diff(x_b); % lengths of compartments
NC = length(l_c);
xface = cell(1, NC);
ID_core = cell(1, NC);
for iC = 1:NC
    Nx = ceil(diff(x_b([iC,iC+1]))/dx);
    ID_core{iC} = repmat(iC, [1, Nx]);
    xface{iC} = linspace(x_b(iC), x_b(iC+1), Nx+1);
end
ID_core = cell2mat(ID_core);
xface = unique(cell2mat(xface), 'sorted'); % align and remove duplicates at b
domain = createMesh1D(xface); % construct mesh

ID = createCellVariable(domain, 0); % includes ghost cells
core = get_core(ID);
ID.value(core) = ID_core;

%% Assign the parameters

% diffusivities
D_cell = createCellVariable(domain, 0); % diffusivity
D_cell.value(core) = D(ID_core);

% permeabilities = flux conditions
D_face = linearMean(D_cell); % use for all faces without discontinuities
idx_m = find(diff(ID_core)); % at interface between IDs
% set membrane permeabilities
% P0 = 0 -> impermeable
% P0 = inf -> impermeable
for iM = 1:NC-1 % only inner boundaries

    % size
    dx = D_face.domain.cellsize.x(core);
    dx_L = dx(idx_m(iM)  );
    dx_R = dx(idx_m(iM)+1);
    dx_m = (dx_L+dx_R) / 2; %TODO: is this correct?

    % assign P
    D_ = D_face.xvalue(core);
    P_m = P(1 + iM) * dx_m; % dx for unit consistency
    if P_m < D_(idx_m) % cannot be larger than free diffusivity
        %NOTE: P_m = inf makes two cells become one -> undesirable
        D_(idx_m) = P_m; % assign
    end
    D_face.xvalue(core) = D_;

end

end
