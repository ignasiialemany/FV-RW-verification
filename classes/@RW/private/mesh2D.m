function [domain, imedges_x, imedges_y] = mesh2D(im, varargin)
% convert an image to a domain with pixel edges

%TODO: process varargin
if mod(numel(varargin), 2)
    error('must provide optional arguments as Name-Value pairs');
end
D = 1;
res = 1;
while numel(varargin) > 0
    switch lower(varargin{1})
        case 'diffusivity'
            D = varargin{2};
            try
                validateattributes(D, {'numeric'}, {'scalar', 'nonnegative', 'finite'});
            catch me
                error('invalid choice for diffusivity:\n%s', me.message);
            end
        case 'resolution'
            res = varargin{2};
            try
                validateattributes(res, {'numeric'}, {'scalar', 'positive', 'finite'});
            catch me
                error('invalid choice for resolution:\n%s', me.message);
            end
    end
    varargin = varargin(3:end); % pop Name-Value pair
end

% transformation
im_xy = rot90(im, -1); % see FV.mesh2D
[Nx, Ny] = size(im_xy, [1, 2]);

% centered around 0
imedges_x = linspace(-Nx*res/2, +Nx*res/2, Nx+1);
imedges_y = linspace(-Ny*res/2, +Ny*res/2, Ny+1);

% store
domain.D = D;
domain.res = [1, 1]*res;
domain.map = im_xy;
domain.edges_x = imedges_x;
domain.edges_y = imedges_y;
domain.bbox = [[imedges_x(1); imedges_x(end)], [imedges_y(1); imedges_y(end)]];

end
