function [c] = normalized_core(c)
% normalize the core such that the volume-weighted integral equals 1 and boundary values equal nan

[core, core_vals] = get_core(c);
vol = cellVolume(c.domain);
integral = sum(c.value(core).*vol.value(core), 'all');
c.value(~core) = NaN; % set all to NaN (for boundaries)
if integral ~= 0
    c.value(core) = core_vals/integral; % normalise
end

end
