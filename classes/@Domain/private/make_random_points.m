function [points_ij] = make_random_points(ECS, seed, varargin)
% find points [i, j] randomly taken from ECS

if nargin < 2
    seed = 123412;
end
rng(seed);

%TODO: process varargin

[points_i, points_j] = find(ECS);
points_ij = [points_i, points_j];
random_indices = randperm(size(points_ij, 1));
points_ij = points_ij(random_indices, :);

end
