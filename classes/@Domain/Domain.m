classdef Domain

    methods(Static)

        function [points_ij] = make_points(ECS, type, varargin)
            % ECS: binary image
            % type: {'strided', 'random'}
            % varargin (optional, all have defaults):
            %   for 'strided': (__, stride, buffer)
            %   for 'random':  (__, seed)

            switch type
                case 'strided'
                    points_ij = make_strided_points(ECS, varargin{:});
                case 'random'
                    points_ij = make_random_points(ECS, varargin{:});
            end

        end

        function [im, padded] = extract(im, point, buffer, varargin)
            % extract a region from im, centered around point, with buffer on both sides
            % output will be padded using symmetry

            if nargin < 3
                buffer = 122;
            end

            % crop
            [idx_i, pad_i] = get_indices(point(1), size(im, 1), buffer, varargin{:});
            [idx_j, pad_j] = get_indices(point(2), size(im, 2), buffer, varargin{:});
            im = im(idx_i, :); % in i
            im = im(:, idx_j); % in j
            padded = pad_i || pad_j;

        end

    end
    
end
