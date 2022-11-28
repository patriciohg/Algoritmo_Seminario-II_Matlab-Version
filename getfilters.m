function [cL,cH] = getfilters(r,Nx,Ny)
h = Ny/2;
w = Nx/2;
[x,y] = meshgrid(-h:h-1,-w:w-1);
%[x,y] = meshgrid(-380:379,-285:284);
z = sqrt(double(x.^2)+double(y.^2));
cL = z < r;
cH = ~cL;
end