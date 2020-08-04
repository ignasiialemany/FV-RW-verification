function c = solve(D_face, c0, time, varargin)
% the dimension-agnostic part of the code

%TODO: process varargin
if mod(numel(varargin), 2)
    error('must provide optional arguments as Name-Value pairs');
end
verbose = false;
while numel(varargin) > 0
    switch lower(varargin{1})
        case 'verbose'
            verbose = varargin{2};
            try
                validateattributes(verbose, {'numeric', 'logical'}, {'scalar', 'binary'});
            catch me
                error('invalid choice for verbose:\n%s', me.message);
            end
    end
    varargin = varargin(3:end); % pop Name-Value pair
end

domain = D_face.domain; % get domain

% boundary conditions
BC = createBC(domain); % Neumann, by default
names = {'left', 'right', 'top', 'bottom', 'back', 'front'};
for i = 1:2*domain.dimension
    % apply zero-flux (this setting is the default, but let's make it explicit)
    name = names{i};
    boundary.(name).periodic = 0; % non-periodic
    boundary.(name).a(:) = 1; % gradient term (Neumann)
    boundary.(name).b(:) = 0; % parameter term (Dirichlet)
    boundary.(name).c(:) = 0; % value
end
[Mat_bc, RHS_bc] = boundaryCondition(BC);

% internal conditions
Mat_diffusion = diffusionTerm(D_face);

% combine steady terms
Mat_steady = Mat_bc - Mat_diffusion;
RHS_steady = RHS_bc;

% time stepping
alpha = createCellVariable(domain, 1); % 1 to get unscaled d/dt

% time loop
c = repmat(c0, size(time)); % same size as time array
for n = 2:numel(time)
    % time step
    dt = time(n) - time(n-1);
    [Mat_trans, RHS_trans] = transientTerm(c(n-1), dt, alpha);
    % assemble
    Mat = Mat_trans + Mat_steady;
    RHS = RHS_trans + RHS_steady;
    % solve
    c(n) = solvePDE(domain, Mat, RHS);
    % print update
    if verbose
        fprintf('%6.2f%% (t = %f/%f)\n', time(n)/time(end)*100, time(n), time(end));
    end
end

end
