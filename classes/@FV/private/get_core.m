function [core, core_val] = get_core(c)
% returns the core of the domain cells (i.e. no ghost cells)

core = false(size(c.value));
dim = c.domain.dimension;
switch dim
    case 1
        core(2:end-1) = true();
    case 2
        core(2:end-1, 2:end-1) = true();
    case 3
        core(2:end-1, 2:end-1, 2:end-1) = true();
    otherwise
        error('Cannot get the core for %d-D CellVariable', dim);
end
size_core = max(1, size(core)-2); % in case of singleton dimensions
core_val = reshape(c.value(core), size_core);

end
