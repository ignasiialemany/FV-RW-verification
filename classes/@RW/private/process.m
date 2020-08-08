function [Dx, Dy, MD, FA] = process(xy0, xyN, t_max)
% compute diffusion tensor parameters from diffusion data

% displacement
dXY2 = (xyN - xy0).^2;
[dX2, dY2] = deal(dXY2(:, 1), dXY2(:, 2));

% compute RMS
Dx = mean(dX2      )/(2*t_max);
Dy = mean(      dY2)/(2*t_max);
MD = mean(dX2 + dY2)/(4*t_max);
FA = sqrt(3/2)*norm([Dx, Dy]-MD)/norm([Dx, Dy]);

end
