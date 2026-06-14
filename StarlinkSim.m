startTime = datetime(2026, 6, 8);
stopTime = startTime + days(1);
sampleTime = 60;

sc = satelliteScenario(startTime, stopTime, sampleTime);

allLines = readlines("STARLINK.tle");

subsetLines = allLines(1:90);  
writelines(subsetLines, "SUBSET.tle");

sat = satellite(sc, "SUBSET.tle");

[position, velocity, time] = states(sat, "CoordinateFrame", "ecef");

viewer = satelliteScenarioViewer(sc);
show(sat);
groundTrack(sat);

figure;
plot(time, squeeze(position(1,:,1)));
hold on;
plot(time, squeeze(position(2,:,1)));
plot(time, squeeze(position(3,:,1)));
legend('x','y','z');
title('Satellite 1 Position');
exportgraphics(gcf, 'results/taskA/position_sat1.png', 'Resolution', 300);

figure;
plot(time, squeeze(velocity(1,:,1)));
hold on;
plot(time, squeeze(velocity(2,:,1)));
plot(time, squeeze(velocity(3,:,1)));
legend('vx','vy','vz');
title('Satellite 1 Velocity');
exportgraphics(gcf, 'results/taskA/velocity_sat1.png', 'Resolution', 300);