function [pos_history] = solve(domain, t, pos0, randstream, varargin)
% perform the random walk using rejection sampling to accelerate the step

%TODO: process varargin
if mod(numel(varargin), 2)
    error('must provide optional arguments as Name-Value pairs');
end
maxstep = 3;
while numel(varargin) > 0
    switch lower(varargin{1})
        case 'verbose'
            maxstep = varargin{2};
            try
                validateattributes(maxstep, {'numeric'}, {'scalar', 'positive'});
            catch me
                error('invalid choice for maxstep:\n%s', me.message);
            end
    end
    varargin = varargin(3:end); % pop Name-Value pair
end

NT = numel(t);
NP = size(pos0, 1);
dim = size(pos0, 2);
pos_history = repmat(pos0, [1, 1, NT]);
for n = 2:NT % start at 2 s.t. first one is starting position

    % get parameters
    dt = diff(t(n-1:n)); % time step
    pos_prev = pos_history(:, :, n-1); % starting position

    % compute the step by rejection sampling
    dpos = zeros(NP, dim);
    needUpdate = true(NP, 1); % all, initially
    num_rejections = 0; % counter for number of rejections
    while any(needUpdate)

        % try to draw a step
        dpos(needUpdate, :) = draw_random([sum(needUpdate), dim], randstream, maxstep);
        pos_new = pos_prev + dpos*sqrt(2*domain.D*dt); % predicted position

        % reject invalid steps
        needUpdate = check_for_step_rejection(pos_new, domain); % (still) invalid
        num_rejections = num_rejections + 1;
        if num_rejections > 10 % check how many times we have rejected
            pos_new(needUpdate, :) = pos_prev(needUpdate, :); % just stay still this step
            break % out of while loop
        end

    end

    % complete the step
    pos_history(:, :, n) = pos_new;

end

end

function [val] = draw_random(shape, randomstream, thresh)

val = inf(shape);
tooLarge = true(shape(1), 1);
while any(tooLarge)
    val(tooLarge, :) = randn(randomstream, sum(tooLarge), shape(2));
    tooLarge = any(abs(val) > thresh, shape(2));
end

end

function [needUpdate] = check_for_step_rejection(pos_new, domain)

[inregion, leftDomain] = findValuesAtPoints(domain, pos_new);
needUpdate = ~inregion | any(leftDomain, 2);

end
