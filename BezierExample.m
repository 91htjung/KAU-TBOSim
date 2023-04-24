clc;
clf;
clear all;
 
axis equal;
grid on;
 
xlabel u;
ylabel Pu;
 
%plotting a Cubic Bezier curve
 
%defining four control points p0, p1, p2 & p3 - four arbitrary points
%  
% p0 = [37.371777777777780 126.5852777777778 5000]';


p0 = [0 0 0]';

p1 = [1 1 0]';
 
p2 = [3 -1 0]';
 
p3 = [4 0 0]';
 
% defining Bezier Geometric Matrix B
 
B = [p0 p1 p2 p3]';
 
% Bezier Basis transformation Matrix M
 
M = [-1 3 -3 1; 3 -6 3 0; -3 3 0 0; 1 0 0 0];
 
% Calcutaion of Algebric Coffecient Matrix A
 
A = M*B;
 
% defining u axis
 
u = linspace(0,1,10);
 
u = u';
 
unit = ones(size(u));
 
U = [u.^3 u.^2 u unit];
 
% calculation of value of function Pu for each value of u
 
Pu = U*A;
 
%plotting control polygon
 
line(B(:,1), B(:,2), B(:,3))
 
hold on;
 
% plotting Bezier curve
 
plot3(Pu(:,1), Pu(:,2), Pu(:,3),'r','linewidth',1.0)
 
legend('Polygon','Bezier Curve')