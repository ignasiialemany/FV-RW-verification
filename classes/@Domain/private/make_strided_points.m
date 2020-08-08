function [points_ij] = make_strided_points(ECS, stride, varargin)
% find points [i, j] in ECS with equispacing (stride)

if nargin < 2
    stride = 20;
end

%TODO: process varargin

points_ij = nan(numel(ECS), 2);
counter = 0;
for point_i = 1:stride:size(ECS, 1)
    for point_j = 1:stride:size(ECS, 2)
        if ECS(point_i, point_j)
            counter = counter + 1;
            points_ij(counter, :) = [point_i, point_j];
        end
    end
end
points_ij(isnan(points_ij(:, 1)), :) = [];

end
