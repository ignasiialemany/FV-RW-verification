function [Dx, Dy, MD, FA] = process(c, t_max)
% compute diffusion tensor parameters from diffusion data

% positions (C is transposed in FV code)
[Y, X] = meshgrid(c.domain.cellcenters.x, c.domain.cellcenters.y);
C = cN.value(2:end-1, 2:end-1); % concentration

% displacement
[dX2, dY2] = deal(X.^2, Y.^2); % X0 and Y0 are 0 by definition

% compute RMS
Dx = sum(C(:).*dX2(:)               )/(2*t_max);
Dy = sum(               C(:).*dY2(:))/(2*t_max);
MD = sum(C(:).*dX2(:) + C(:).*dY2(:))/(4*t_max);
FA = sqrt(3/2)*norm([Dx, Dy]-MD)/norm([Dx, Dy]);

end
