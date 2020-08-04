function [domain, D_face, ID] = mesh2D(dxdy, im, D, varargin)
% dxdy: [m_per_px_x, m_per_px_y]
% im: true where D=D, false where D=0
%
% converts an image to a domain and assigns diffusivities
%
% 0 denotes origin
% i,j are MATLAB indices, e.g. A(i=1,j=1) == #
%
%     j
%   +--->          A               ....               C
% i |  0-----------------------\          /-----------------------\
%   V  | #                   * |          | #         ^         * |
%      |                       |          |         y |           |
%      |                       |   ===>   |           0--->       |
%      |                       |          |             x         |
%      | !                   $ |          | !                   $ |
%      \-----------------------/          \-----------------------/
%
% first, though, we rotate the image so we can keep using an image but with i'=x, j'=y
% we now have !-$ = positive x, and !-# positive y
%
% B = transpose(A)
%
%     j'
%   +--->   B
% i'| 0-----------\
%   V | !       # |
%     |           |
%     |           |
%     |           |
%     |           |
%     |           |
%     | $       * |
%     \-----------/

% reshape input boolean image
im_xy = rot90(im, -1);
[Nx, Ny] = size(im_xy, [1, 2]);
Lx = Nx*dxdy(1);
Ly = Ny*dxdy(2);
fx = linspace(-Lx/2, +Lx/2, Nx+1);
fy = linspace(-Ly/2, +Ly/2, Ny+1);
domain = createMesh2D(fx, fy);

% cell diffusivities
D_values = createCellVariable(domain, 0); % zero where false
D_values.value(get_core(D_values)) = im_xy*D;

% flux conditions
D_face = linearMean(D_values); % method irrelevant, because fluxes will be assigned below
diff_alongx = abs(diff(D_values.value, 1, 2))>0; % \_ change in D
diff_alongy = abs(diff(D_values.value, 1, 1))>0; % /
D_face.xvalue(diff_alongy(:, 2:end-1)) = 0; % \_ zero flux
D_face.yvalue(diff_alongx(2:end-1, :)) = 0; % /

% IDs
ID = createCellVariable(domain, 0); % includes ghost cells
core = get_core(ID);
ID.value(core) = im_xy;

end
