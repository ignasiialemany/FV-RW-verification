function h = showCellVariable2D(c, ax, varargin)
% show data as a surface, 2D (top) view, flat interpolation

%TODO: process varargin

%% prepare data

% extract grid
X = c.domain.facecenters.x;
Y = c.domain.facecenters.y;

% extract variable
[~, C] = get_core(c); % get core
C = padarray(C, [1, 1], NaN, 'post'); % for XY match, will be ignored
C = C.'; % needs to be transposed for plotting

%% plot

% get axis
if nargin() < 2
    ax = gca();
end

% show
h = surf(ax, X, Y, C);
h.FaceColor = 'flat';
h.EdgeColor = 'none'; % remove grid lines

%% prettify plot (bare minimum)

% look at surface from above
view(ax, 2);

% squeeze axes
axis(ax, 'normal', 'tight', 'square');

% show axis labels for clarity
xlabel(ax, 'x [units]');
ylabel(ax, 'y [units]');

% show colorbar
cbar = colorbar(ax);
cbar.Label.String = 'c(x,y) [units]';

end
