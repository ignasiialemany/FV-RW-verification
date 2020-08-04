function [idx] = find_cell_containing_point(edges, x, clip)
% find cell index where x0 is inside one of the mesh cells bounded by xfaces

% handle input arguments
if nargin() < 3
    clip = false(); % by default, we don't clip
end

N = numel(edges);

% handle edge cases first
if x < edges(1)
    if clip, idx = 1; else, idx = []; end, return
elseif edges(N) < x
    if clip, idx = N; else, idx = []; end, return
end

imin = find(edges <= x, 1, 'last');
imax = find(edges >= x, 1, 'first') - 1;
if imin ~= imax
    if imin == 1 % here, imax == 0
        idx = imin;
    elseif imin == N % here, imax = N-1
        idx = imax;
    else % on internal face
        % let's use standard histogram binning approach, min <= x < max
        idx = imin;
    end
else
    idx = imin;
end
    
end
