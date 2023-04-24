surf(peaks)
axis vis3d
t = 0:pi/20:4*pi;
dx = sin(t)./40;
dy = cos(t)./40;
for i = 1:length(t);
    camdolly(dx(i),dy(i),0)
    drawnow 
end