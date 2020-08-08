classdef RW < handle
    %RW Wrapper class to perform a random walk

    methods
        % class object methods

        function this = RW(NP, seed)
            %RW Constructor
            %   Initializes a class object with NP walkers and optional seed

            % default construction, no arguments given
            if nargin == 0
                return
            end

            % number of particles
            this.NP = NP;

            % optional seed argument
            if nargin < 2
                this.randomStream = RandStream('mt19937ar');
                seed = this.randomStream.Seed;
            else
                this.randomStream = RandStream('mt19937ar', 'Seed', seed);
            end
            this.seed = seed; % store for reference

        end

        %TODO: allow construction from data, make sure they are validated properly
        %TODO: copy, save, etc.

    end

    properties(SetAccess=protected)
        % data, read-only

        %RANDOMSTREAM Random stream used for random walk
        randomStream {mustBeRandStream} = []

        %SEED Seed value used to initialise the random stream
        seed(1,1) {mustBeNonnegative, mustBeInteger, mustBeLessThanOrEqual(seed, 4294967296)}

        %NP Number of walkers
        NP(1,1) {mustBeNonnegative, mustBeInteger, mustBeReal}

        %DOMAIN Domain structure
        domain = struct()

        %POS Position of walkers
        pos = []

    end

    methods(Access=public)
        % public methods for manipulate the class data

        function [this, domain] = mesh(this, dom, varargin)
            %MESH Create a mesh
            %   This is a wrapper for the (private) function mesh. It passes all arguments through.

            %TODO: add support for 1D and 3D
            if ~ismatrix(dom) || isvector(dom)
                error('only support 2D domains right now');
            end

            % calculate mesh
            domain = mesh2D(dom, varargin{:});

            % store
            this.domain = domain;

        end

        function [this, pos0] = init(this, type, varargin)
            %INIT Initialize the walkers
            %   This is a wrapper for the (private) functions place_*. It places walkers either at a
            %   specific point, or inside the domain.

            % ensure we have called .mesh before
            if isempty(this.domain)
                error('No domain found, make sure to run .mesh first!');
            end

            % call the chosen function
            switch type
                case 'in'
                    pos0 = place_in(this.NP, this.domain, varargin{:});
                case 'at'
                    pos0 = place_at(this.NP, this.domain, varargin{:});
                otherwise
                    validatestring(type, {'in', 'at'}); % throws error
            end

            % store
            this.pos = pos0;

        end

        function [this, pos_history] = solve(this, time, varargin)
            %SOLVE Call the solver
            %   This is a wrapper for the (private) function solve. It marches through time time
            %   array and passes all other arguments through.

            % call private function
            pos_history = solve(this.domain, time, this.pos, this.randomStream, varargin{:});

            % store final position
            this.pos = pos_history(:, :, end);

        end

    end

    methods(Static, Access=public)

        function [ADC] = processResults(xy0, xyN, t_max)
            % process diffusion data and calculate ADCs

            % verify inputs
            validateattributes(xy0, {'numeric'}, {});
            validateattributes(xyN, {'numeric'}, {});
            if ~isequal(size(xy0), size(xyN))
                error('xy inputs do not have matching size');
            end
            validateattributes(t_max, {'numeric'}, {'scalar'});

            % call private function
            [Dx, Dy, MD, FA] = process(xy0, xyN, t_max);

            % convert output
            ADC = struct('Dx', Dx, 'Dy', Dy, 'MD', MD, 'FA', FA);

        end
        
    end

end

% -------------------------------------- %
%               Validators               %
% -------------------------------------- %

function mustBeRandStream(property)
% Validates that the property is a RandStream. It may also be empty.

if isempty(property), return, end

validateattributes(property, {'RandStream'}, {'scalar'});

end
