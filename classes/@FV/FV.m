classdef FV < handle
    %FV Wrapper class around methods and data from FVTool

    methods
        % class object methods

        function obj = FV()
            %FV Constructor
            %   Initializes an empty class object, unless FVTool is not found.

            % check for FVTool, and fails with error if not found
            required = true;
            check_FVTool(required);

        end

        %TODO: allow construction from data, make sure they are validated properly
        %TODO: copy, save, etc.

    end

    properties(SetAccess=protected)
        % data, read-only

        %ID Identifier for cells
        Ic {mustBeCellVariable} = []

        %DF Diffusivity on faces
        Df {mustBeFaceVariable} = []
        
        %Cc Concentration in the cells
        Cc {mustBeCellVariable} = []

        %DOMAIN Domain mesh
        domain {mustBeMeshStructure} = []

    end

    methods(Access=public)
        % public methods for manipulate the class data

        function [this, domain, Df, Ic] = mesh(this, resolution, varargin)
            %MESH Create a mesh
            %   This is a wrapper for the (private) functions meshND. It calls the correct function
            %   based on the number of elements in the resolutions ([dx, [dy, [dz]]]) argument.

            % verify input
            validateattributes(resolution, {'numeric'}, {'vector'});

            % pick the right function
            dim = numel(resolution);
            switch dim
                case 1
                    mesh = @mesh1D;
                case 2
                    % dxdy = m_per_px most likely
                    mesh = @mesh2D;
                otherwise
                    error('Cannot mesh %d-D geometries', dim);
            end

            % execute function
            [domain, Df, Ic] = mesh(resolution, varargin{:});

            % store
            [this.domain, this.Df, this.Ic] = deal(domain, Df, Ic);

        end
        
        function [this, C0] = init(this, origins, varargin)
            %INIT Initialize a solution
            %   This is a wrapper for the (private) function init_spike. It adds a unit spike at
            %   each point in origins, and afterwards normalizes the total domain.

            % ensure we have called .mesh before
            if isempty(this.domain)
                error('No domain found, make sure to run .mesh first!');
            end

            % verify input
            validateattributes(origins, {'numeric'}, {'finite'});
            dim = this.domain.dimension;
            if dim ~= size(origins, 2)
                error('Data is %d-D, but origin was %-D', dim, size(origins, 2));
            end

            % initialize
            C0 = createCellVariable(this.domain, 0);
            for i = 1:size(origins, 1)
                C0 = C0 + init_spike(this.domain, origins(i, :), varargin{:});
            end
            C0 = normalized_core(C0);

            % store
            this.Cc = C0;

        end

        function [this, c_history] = solve(this, t, varargin)
            %SOLVE Call the solver
            %   This is a wrapper for the (private) function solve. It marches through time time
            %   array and passes all other arguments through.

            % we are solving
            % $$\frac{\partial c}{\partial t} - \nabla \cdot \left(D\nabla c\right) = 0$$

            % ensure we have called .init before
            if isempty(this.Cc)
                error('No initial solution found, make sure to run .init first!');
            end

            % verify inputs
            validateattributes(t, {'numeric'}, {'vector', 'finite', 'nonnegative', 'increasing'});
            if t(1) ~= 0
                t(2:end+1) = t;
                t(1) = 0;
            end

            % call the private solve routine
            c_history = solve(this.Df, this.Cc, t, varargin{:});
            this.Cc = c_history(end);

        end

    end

    methods(Static, Access=public) % static helper methods

        function [h] = showCellVariable(cellVar, varargin)
            %SHOWCELLVARIABLE Display a cell variable
            %   This is a wrapper for the (private) functions showCellVariableND. It selects the
            %   correct function based on data dimension and passes all other arguments through.

            % `visualizeCells(c)` in FVTool is not pretty, so we have our own implementation.

            % verify input
            validateattributes(cellVar, {'CellVariable'}, {'scalar'});

            % pick the right function
            dim = cellVar.domain.dimension;
            switch dim
                case 1
                    show = @showCellVariable1D;
                case 2
                    show = @showCellVariable2D;
                otherwise
                    error('Cannot visualise %d-D cell variables!', dim);
            end
 
            % execute function
            h = show(cellVar, varargin{:});

        end

        function [cellVar] = normalizeCellVariable(cellVar)
            %NORMALIZE Normalizes a cell variable
            %   Normalizes the core such that the integral (volume-weighted) is equal to unity.
            %   It also sets the boundary values to nan.

            % verify input
            validateattributes(cellVar, {'CellVariable'}, {'scalar'});

            % call private function
            cellVar = normalized_core(cellVar);

        end

        function [ADC] = processResults(c, t_max)
            % process diffusion data and calculate ADCs

            % verify inputs
            validateattributes(c, {'CellVariable'}, {'scalar'});
            validateattributes(t_max, {'numeric'}, {'scalar'});

            % call private function
            [Dx, Dy, MD, FA] = process(c, t_max);

            % convert output
            ADC = struct('Dx', Dx, 'Dy', Dy, 'MD', MD, 'FA', FA);

        end

    end

end

% -------------------------------------- %
%               Validators               %
% -------------------------------------- %

function mustBeCellVariable(property)
% Validates that the property is a (FVTool) CellVariable. It may also be empty.

if isempty(property), return, end

if check_FVTool()
    validateattributes(property, {'CellVariable'}, {'scalar'});
end

end

function mustBeFaceVariable(property)
% Validates that the property is a (FVTool) FaceVariable. It may also be empty.

if isempty(property), return, end

if check_FVTool()
    validateattributes(property, {'FaceVariable'}, {'scalar'});
end

end

function mustBeMeshStructure(property)
% Validates that the property is a (FVTool) MeshStructure. It may also be empty.

if isempty(property), return, end

if check_FVTool()
    validateattributes(property, {'MeshStructure'}, {'scalar'});
end

end
