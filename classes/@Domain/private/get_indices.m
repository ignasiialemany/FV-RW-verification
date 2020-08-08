function [indices, padded] = get_indices(i, N, buffer)
% get buffered indices with periodic boundary padding near ends

if i-buffer < 1
    overlap = buffer-i;
    indices = [N-overlap:N, 1:i+buffer];
    padded = true;
elseif i+buffer > N
    overlap = (i+buffer) - N;
    indices = [i-buffer:N, 1:overlap];
    padded = true;
else
    indices = i-buffer:i+buffer;
    padded = false;
end

end
