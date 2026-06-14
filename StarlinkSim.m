startTime = datetime(2026, 6, 8);
stopTime = startTime + days(1);
sampleTime = 60;

sc = satelliteScenario(startTime, stopTime, sampleTime);

allLines = readlines("STARLINK.tle");

subsetLines = allLines(1:90);  
writelines(subsetLines, "SUBSET.tle");

sat = satellite(sc, "SUBSET.tle");

[satPos, satVel, time] = states(sat, "CoordinateFrame", "ecef");

viewer = satelliteScenarioViewer(sc);
show(sat);
groundTrack(sat);

figure;

subplot(2,1,1);
plot(time, squeeze(satPos(1,:,1))/1000, 'LineWidth', 1.2);
hold on;
plot(time, squeeze(satPos(2,:,1))/1000, 'LineWidth', 1.2);
plot(time, squeeze(satPos(3,:,1))/1000, 'LineWidth', 1.2);
grid on;
title('Satellite 1 Position (ECEF)');
xlabel('Time');
ylabel('Position (km)');
legend('x','y','z');

subplot(2,1,2);
plot(time, squeeze(satVel(1,:,1))/1000, 'LineWidth', 1.2);
hold on;
plot(time, squeeze(satVel(2,:,1))/1000, 'LineWidth', 1.2);
plot(time, squeeze(satVel(3,:,1))/1000, 'LineWidth', 1.2);
grid on;
title('Satellite 1 Velocity (ECEF)');
xlabel('Time');
ylabel('Velocity (km/s)');
legend('vx','vy','vz');

exportgraphics(gcf, 'results/taskA/sat1_state.png', 'Resolution', 300);


%% Task B: Receiver and visible satellites

rxLat = 33.8938;
rxLon = 35.5018;
rxAlt = 0;

elevationMask = 10;   % degrees

rx = groundStation(sc, ...
    rxLat, rxLon, ...
    "Altitude", rxAlt, ...
    "MinElevationAngle", elevationMask, ...
    "Name", "Receiver");

ac = access(sat, rx);
ac.LineWidth = 2;

intervals = accessIntervals(ac);
disp(intervals);
writetable(intervals, 'results/taskB/satellite_intervals.csv');

%% Task C: Generate pseudorange and Doppler measurements

numSat = numel(sat);
numTime = numel(time);

rxECEF = lla2ecef([rxLat, rxLon, rxAlt]);
rxPos = repmat(rxECEF', 1, numTime);
rxVel = zeros(3, numTime);

range = NaN(numTime, numSat);
rangeRate = NaN(numTime, numSat);
pseudorange = NaN(numTime, numSat);
doppler = NaN(numTime, numSat);

c = physconst("LightSpeed");
fc = 11.325e9;   % Example Starlink Ku-band frequency

for k = 1:numSat
    for i = 1:numTime

        r_vec = satPos(:, i, k) - rxPos(:, i);
        v_vec = satVel(:, i, k) - rxVel(:, i);

        r_norm = norm(r_vec); 
        range(i, k) = r_norm;

        r_rate = dot(r_vec, v_vec) / r_norm;
        rangeRate(i, k) = r_rate;

        pseudorange(i, k) = r_norm;  % Noiseless
        doppler(i, k) = -r_rate * fc / c;
    end
end

% Apply visibility mask from Task B
for k = 1:numSat
    satName = string(sat(k).Name);

    rows = strcmp(string(intervals.Source), satName);

    visibleTimes = false(numTime,1);

    for j = find(rows)'
        visibleTimes = visibleTimes | ...
            (time' >= intervals.StartTime(j) & time' <= intervals.EndTime(j));
    end

    range(~visibleTimes,k) = NaN;
    pseudorange(~visibleTimes,k) = NaN;
    doppler(~visibleTimes,k) = NaN;
    rangeRate(~visibleTimes,k) = NaN;
end

k = 1;

figure;

subplot(3,1,1);
plot(time, range(:,k)/1000, 'LineWidth', 1.5);
title("Range");
ylabel("km");
grid on;

subplot(3,1,2);
plot(time, pseudorange(:,k)/1000, 'LineWidth', 1.5);
title("Pseudorange");
ylabel("km");
grid on;

subplot(3,1,3);
plot(time, doppler(:,k), 'LineWidth', 1.5);
title("Doppler");
ylabel("Hz");
xlabel("Time");
grid on;
exportgraphics(gcf, 'results/taskC/measurements_sat1.png', 'Resolution', 300);





