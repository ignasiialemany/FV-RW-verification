%% Image based domain

im = true(100, 100);
im(20:30, 20:80) = false;
im(70:80, 20:60) = false;
im(40:60, 20:30) = false;

NP = 1e4;
seed = 328352; % for reproducibility
NT = 100;
t = linspace(0, 200, NT);

rw = RW(NP, seed);
rw.mesh(im);
rw.init('at', [0, 0]);
[~, pos_history] = rw.solve(t);

%% Visualize

% create the figure
fig = figure('Color', 'w', 'Position', [100, 100, 400, 400]);
ax = gca();

% prettify
hold(ax, 'on');
grid(ax, 'on');
box(ax, 'on');
axis(ax, 'equal');
axis(ax, 'tight');
ax.TickDir = 'out';
ax.FontSize = 16;
ax.TickLabelInterpreter = 'latex';

% axes
xlim(ax, rw.domain.edges_x([1, end]) + [-3, 3]*diff(rw.domain.edges_x(1:2)));
ylim(ax, rw.domain.edges_y([1, end]) + [-3, 3]*diff(rw.domain.edges_y(1:2)));
xtick = rw.domain.edges_x([1, round(end/2), end]);
ytick = rw.domain.edges_y([1, round(end/2), end]);
xticks(ax, xtick);
yticks(ax, ytick);
xlabel(ax, '$x$', 'Interpreter', 'latex');
ylabel(ax, '$y$', 'Interpreter', 'latex');

% prepare data
[X, Y] = meshgrid(rw.domain.edges_x, rw.domain.edges_y);
im_vis = flipud(im); % for compatibility with pcolor

% plot the domain as a bw image
h_domain = pcolor(ax, X, Y, padarray(double(im_vis), [1, 1], 'post'));
h_domain.EdgeColor = [0.2, 0.2, 0.2];
h_domain.EdgeAlpha = 0.2;
colormap(ax, 'gray');

% plot the walker positions (use the last one as an overview)
h_walkers = plot(ax, pos_history(:, 1, end), pos_history(:, 2, end), '.');

%% animate time history

frames = repmat(getframe(fig), 1, NT);
for n = 1:NT

    % update data
    h_walkers.XData = pos_history(:, 1, n);
    h_walkers.YData = pos_history(:, 2, n);

    % update the figure
    drawnow;
    pause(0.1); % so we can see something
    frame = getframe(fig);
    frames(n) = frame;

    % write GIF
    I = frame2im(frame);
    [A, cmap] = rgb2ind(I, 256);
    if n == 1
        imwrite(A, cmap, 'RW_2D_Animation.gif', 'gif', 'LoopCount', inf, 'DelayTime', 1/30);
    else
        imwrite(A, cmap, 'RW_2D_Animation.gif', 'gif', 'WriteMode', 'append', 'DelayTime', 1/30);
    end

end
