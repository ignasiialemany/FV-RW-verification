function h = showCellVariable1D(c, ax, varargin)
% show data as a line with only markers

%TODO: process varargin

%% prepare data

% extract grid
X = c.domain.cellcenters.x; % plot cell-centric

% extract variable
[~, C] = get_core(c);

%% plot

% get axis
if nargin() < 2
    ax = gca();
end

% show
h = plot(ax, X, C);
h.Marker = 'o';
h.LineStyle = 'none';

%% prettify plot (bare minimum)

% squeeze x axis
xlim(ax, [min(c.domain.facecenters.x), max(c.domain.facecenters.x)]);

% show labels
xlabel(ax, 'x [units]');
ylabel(ax, 'u(x) [units]');

end
