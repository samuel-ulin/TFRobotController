function servo_angles

theta = 0:1:150;
phi = 10:1:180;

L1 = 21;
L2 = 22.4;
h0 = 20;
y_claw = 18;

XY = @(theta,phi) [L1*cosd(theta) - L2*cosd(theta+phi);...
    L1*sind(theta) - L2*sind(theta+phi) + h0];

points = zeros(4, length(theta)*length(phi));

i = 1;
for t = theta
    for p = phi
        points(1:2,i) = XY(t, p);
        points(3,i) = t;
        points(4,i) = p;
        i = i + 1;
    end
end

%Remove points outside of the playing field
%Points less than r = 20cm
index = points(1,:) > 5;
points = points(:,index);
%Points greater than r = 40cm
index = points(1,:) < 30;
points = points(:,index);
%Points below ground
index = points(2,:) > (0 + y_claw);
points = points(:,index);
%Points above 30cm
index = points(2,:) < (35 + y_claw);
points = points(:,index);

figure(1);
clf;
plot(points(1,:), points(2,:), 'b.');
axis([-5, 40, -10 + y_claw, 45 + y_claw]);

%Match points to grid

%Third dimension - 1=x, 2=y, 3=theta, 4=phi
grid = zeros(30 - 5 + 1, 35 - 0 + 1, 4);

%Fill x and y
for i = 1:length(grid(:,1,1))
    for j = 1:length(grid(1,:,1))
        grid(i,j,1) = i + 4;
        grid(i,j,2) = j - 1 + y_claw;
    end
end

%Plot to check whether x and y values are correct
figure(2);
clf;
plot(grid(:,:,1), grid(:,:,2), 'r.');

%Matching algorithm
for i = 1:length(grid(:,1,1))
    for j = 1:length(grid(1,:,1))
        %For each gridpoint, look through points vector to closest matching
        %point
        grid_xy = [grid(i,j,1), grid(i,j,2)];
        min_point = inf;
        
        for k = 1:1:length(points);
            if norm(grid_xy - points(1:2,k)', 2) < min_point;
                min_point = norm(grid_xy - points(1:2,k)', 2);
                grid(i,j,3) = points(3,k);
                grid(i,j,4) = points(4,k);
            end
        end
        
    end
end

figure(3);
clf;
hold on;
for i = 1:length(grid(:,1,1))
    for j = 1:length(grid(1,:,1))
        xy = XY(grid(i,j,3), grid(i,j,4));
        plot([grid(i,j,1), xy(1)], [grid(i,j,2), xy(2)], 'r.-');
    end
end
plot(grid(:,:,1), grid(:,:,2), 'b.');

% figure(4);
% clf;
% for i = 1:length(grid(:,1,1))
%     for j = 1:length(grid(1,:,1))
%         xy0 = [0, h0];
%         xy1 = [L1*cosd(grid(i,j,3)), L1*sind(grid(i,j,3)) + h0];
%         xy2 = XY(grid(i,j,3), grid(i,j,4))';
%         disp(norm(xy1-xy0, 2) - L1);
%         disp(norm(xy2-xy1, 2) - L2);
%         plot([xy0(1), xy1(1), xy2(1)], [xy0(2), xy1(2), xy2(2)], 'b');
%         axis([-10, 45, -5, 50]);
%         pause(0.1);
%     end
% end

dlmwrite('x.points', grid(:,:,1)', 'delimiter', '\t');
dlmwrite('y.points', grid(:,:,2)', 'delimiter', '\t');
dlmwrite('theta.points', grid(:,:,3)', 'delimiter', '\t');
dlmwrite('phi.points', grid(:,:,4)', 'delimiter', '\t');