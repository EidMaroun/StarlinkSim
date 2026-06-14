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