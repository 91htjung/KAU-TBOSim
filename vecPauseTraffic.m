function flight = vecPauseTraffic(flight)
global config
delay = [flight.delay] + config.update;
delay = num2cell(delay);
[flight.delay] = delay{:};
end