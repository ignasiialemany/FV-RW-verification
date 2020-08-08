%% Free

% parameters
Lx = 20;
D0 = 1;
P0 = inf;
Nx = 1001;
dx = Lx/Nx; % target cell size
x0 = Lx/2;

% mesh
bx = [0, Lx/2.1, 1.1*Lx/2.1, Lx]; % put internal barriers close to center
D = [D0, D0, D0];
P = [0, P0, P0, 0];
solver = FV().mesh(dx, bx, P, D);
x = solver.domain.cellcenters.x;

% temporal
Nt = 30; % number of time steps, will give Nt+1 points incl. init
dt = 0.1;
t = dt*(0:Nt);

% run
[~, c] = solver.init(x0).solve(t);

% show
fig = figure('Color', 'w', 'Position', [0, 0, 1024, 512]);
ax = gca();
hold(ax, 'on');
colors = jet(Nt);
h = gobjects(1, Nt);
for n = 1:Nt
    if n == 1
        opts = {'LineStyle', '-', 'Marker', 'none', 'Color', 'k', ...
                'DisplayName', '$u(x, 0) = \delta(x)$'};
    else
        opts = {'LineStyle', ':', 'Marker', '.', 'Color', colors(n, :), ...
                'DisplayName', sprintf('$t_{%d} = %2.1f$', n-1, t(n))};
    end
    h(n) = plot(ax, x, c(n).value(2:end-1), opts{:});
end

% prettify
ax.TickLabelInterpreter = 'latex';
xlabel(ax, '$x$', 'Interpreter', 'latex');
ylabel(ax, '$u(x)$', 'Interpreter', 'latex');
ax.FontSize = 16;
ylim(ax, [0, max([c(2:end).value], [], 'all')]);
box(ax, 'on');
grid(ax, 'on');
legend(ax, [h(1), h(2), h(end)], 'Interpreter', 'latex');

% export
print(fig, 'FV_1D_Free.png', '-dpng');

%% Convergence

% continuum definition
Lx = 100;
D0 = 1;
P0 = 0.4; % m/s [1um/ms = 1e-3m/s]
x0 = Lx/2;
bx = [0, Lx/3, Lx/1.2, Lx];
P = [0, repmat(P0, 1, length(bx)-2), 0];
D = D0*ones(1, length(bx)-1);
meshparams = {bx, P, D};

% temporal resolution
Nt = 100; % number of time steps, will give Nt+1 points incl. init
final_t = 100; % ms [1ms = 1e-3s]
dt = final_t/Nt; % just for reference on time accuracy; scheme is implicit
time = linspace(0, final_t, Nt+1);

% create figure and axis
fig = figure('Color', 'w', 'Position', [0, 0, 1024, 512]);
ax = gca();
hold(ax, 'on');

% vary resolution
Nx_ra = [13, 25, 51, 101, 201, 401, 801]; % number of cell centres
h_solutions = gobjects(1, numel(Nx_ra));
for iNx = 1:numel(Nx_ra)

    % spatial resolution
    Nx = Nx_ra(iNx);
    dx = Lx/Nx; % approx

    % run
    [~, c] = FV().mesh(dx, meshparams{:}).init(x0).solve(time);
    c_end = c(end); % only final solution is interesting

    % show
    h = FV.showCellVariable(c_end, ax);
    h.Marker = '.';
    h.MarkerSize = 15;
    h.LineStyle = ':';
    h.LineWidth = 1;
    h.DisplayName = sprintf('$N_x = %d$', Nx);
    h_solutions(iNx) = h;

end

% draw the barriers
ylim_old = ylim(ax); % get current ymax
h_barriers = plot(ax, [bx(2:end-1); bx(2:end-1)], [0; ylim_old(2)], ...
                  'k--', 'DisplayName', 'Barriers');

% prettify
grid(ax, 'on');
box(ax, 'on');
ax.FontSize = 16;
ax.TickLabelInterpreter = 'latex';
xlabel(ax, '$x$', 'Interpreter', 'latex');
ylabel(ax, '$u(x)$', 'Interpreter', 'latex');
legend(ax, [h_solutions, h_barriers(1)], 'Interpreter', 'latex');

% export
print(fig, 'FV_1D_Convergence.png', '-dpng');
