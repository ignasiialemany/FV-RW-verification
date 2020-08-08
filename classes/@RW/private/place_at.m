function [pos] = place_at(NP, domain, point, varargin)
% place N walkers at a point

%TODO: process varargin

if nargin < 3
    point = mean(domain.bbox, 1);
end

pos = ones(NP, size(domain.bbox, 1)) .* point;

end
