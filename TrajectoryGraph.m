
    % Reference Row Lookup List (A/C Performance Param)
    % 1: Segment Number
    % 2: Logitude (deg)
    % 3: Latitude (deg)
    % 4: Altitude (ft)
    % 5: Airspeed(TAS) (kt)
    % 6: Time (sec) - TrajectoryResolution defined in Configuration
    % 7: FlightStatus - 1)Taxi 2)TakeOff 3)InitialClimb 4)Cruise 5)Appraoach 6)Landing
    % 8: Longitudinal Acceleration (ft/sec^2)
    % 9: VerticalSpeed (ft/sec)
    % 10: Vertical Acceleration (ft/sec^2)
    % 11: RateOfClimbDescent (ft/min)
    % 12: Mass (kg)
    % 13: Thrust (kN)
    % 14: FuelFlow (kg/min)
    % 15: FuelperTime (kg/TrajResolution(sec))
    % 16: FuelUsed (kg)
    
    % Reference Row Lookup List (A/C Flight Envelope)
    % 17: Maximum Mass (t)
    % 18: Minimum Mass (t)
    % 19: Maximum Altitude (ft)
    % 20: Maximum Airspeed (kt)
    % 21: Minimum Airspeed (kt)
    % 22: Maximum Thrust (N)
    % 23: Maximum Longitudinal Acceleration (ft/sec^2)
    % 24: Maximum Normal Acceleration (ft/sec^2)
    
    Targetflight = 10;
    Graphswitch = 1;
    
Ref_timeaxis = [flight(Targetflight).Reference(6,:)];
Log_timeaxis = [flightlog(Targetflight).history(1,:) - flight(Targetflight).gentime];

figure
title(['flight #' num2str(Targetflight)]);

subplot(2,1,1)
grid on
hold on
plot(Ref_timeaxis, flight(Targetflight).Reference(2,:));
plot(Log_timeaxis, flightlog(Targetflight).history(2,:), 'g');
% plot(Log_timeaxis, flightlog(Targetflight).history(10,:), 'r');
hold off
xlabel('longitude (deg)')

subplot(2,1,2)
grid on
hold on
plot(Ref_timeaxis, flight(Targetflight).Reference(3,:));
plot(Log_timeaxis, flightlog(Targetflight).history(3,:), 'g');
% plot(Log_timeaxis, flightlog(Targetflight).history(11,:), 'r');
hold off
xlabel('latitude (deg)')

figure
subplot(3,1,1)
grid on
hold on
plot(Ref_timeaxis, flight(Targetflight).Reference(4,:));
plot(Log_timeaxis, flightlog(Targetflight).history(4,:), 'g');
% plot(Ref_timeaxis, Perf.(flight(Targetflight).type).MaxAlt * ones(length(Ref_timeaxis)), 'r');
hold off
xlabel('altitude (ft)')

subplot(3,1,2)
grid on
hold on
ylim([0 360])
plot(Ref_timeaxis, flight(Targetflight).Reference(25,:));
plot(Log_timeaxis, flightlog(Targetflight).history(6,:), 'g');
hold off
xlabel('heading (deg)')

subplot(3,1,3)
grid on
hold on
plot(Ref_timeaxis, flight(Targetflight).Reference(5,:));
plot(Log_timeaxis, flightlog(Targetflight).history(5,:), 'g');
hold off
xlabel('speed (kt)')

figure
subplot(3,1,1)
grid on
hold on
plot(Ref_timeaxis, flight(Targetflight).Reference(11,:));
plot(Log_timeaxis, (flightlog(Targetflight).history(7,:) * 60), 'g');
hold off
xlabel('ROCD (ft/min)')

subplot(3,1,2)
grid on
hold on
ylim([-3 3])
plot(Ref_timeaxis, flight(Targetflight).Reference(8,:));
plot(Log_timeaxis, (unit.nm2ft * flightlog(Targetflight).history(8,:)), 'g');
% plot(Log_timeaxis, 2 * ones(length(Log_timeaxis)), 'r');
% plot(Log_timeaxis, -2 * ones(length(Log_timeaxis)), 'r');
hold off
xlabel('longitudinal accel (ft/sec^2)')

subplot(3,1,3)
grid on
hold on
ylim([-5 5])
plot(Ref_timeaxis, flight(Targetflight).Reference(10,:));
plot(Log_timeaxis, flightlog(Targetflight).history(9,:), 'g');
% plot(Log_timeaxis, sqrt(21) * ones(length(Log_timeaxis)), 'r');
% plot(Log_timeaxis, -sqrt(21) * ones(length(Log_timeaxis)), 'r');
hold off
xlabel('vertical accel (ft/sec^2)')

figure
subplot(3,1,1)
grid on
hold on
try
plot(Ref_timeaxis, flight(Targetflight).Reference(13,:));
end
plot(Log_timeaxis, flightlog(Targetflight).history(13,:) / 1000, 'g');
hold off
xlabel('Thrust (kN)')

subplot(3,1,2)
grid on
hold on
try
plot(Ref_timeaxis, flight(Targetflight).Reference(12,:));
end
plot(Log_timeaxis, flightlog(Targetflight).history(14,:) * 1000, 'g');
% plot(Ref_timeaxis, Perf.(flight(Targetflight).type).Mass_max * ones(length(Ref_timeaxis)) * 1000, 'r');
% plot(Ref_timeaxis, Perf.(flight(Targetflight).type).Mass_min * ones(length(Ref_timeaxis)) * 1000, 'r');
hold off
xlabel('Mass (kg)')

subplot(3,1,3)
grid on
hold on
try
plot(Ref_timeaxis, flight(Targetflight).Reference(16,:));
end
plot(Log_timeaxis, flightlog(Targetflight).history(15,:), 'g');
hold off
xlabel('FuelUsed (kg)')

if Graphswitch > 1
    subplot(4,1,1);
    grid on
    hold on
    plot(Ref_timeaxis, flight(Targetflight).Reference(4,:));
    try
        plot(Ref_timeaxis,flight(Targetflight).Reference(19,:), 'r');
    end
    plot(Log_timeaxis,flightlog(Targetflight).history(4,:), 'g');
    hold off
    title('Altitude (ft)')
    
    subplot(4,1,2);
    grid on
    hold on
    plot(Ref_timeaxis, flight(Targetflight).Reference(5,:));
    try
        plot(Ref_timeaxis, flight(Targetflight).Reference(20,:), 'r');
        plot(Ref_timeaxis, flight(Targetflight).Reference(21,:), 'r');
    end
    plot(Log_timeaxis, flightlog(Targetflight).history(5,:), 'g');
    hold off
    title('True Airspeed (kt)')
    
    subplot(4,1,3);
    grid on
    hold on
    try
        plot(Ref_timeaxis, flight(Targetflight).Reference(25,:));
    end
    plot(Log_timeaxis, flightlog(Targetflight).history(6,:), 'g');
    hold off
    title('Heading (deg)')
    
    subplot(4,1,4);
    grid on
    hold on
    try
        plot(flight(Targetflight).Reference(12,:)/1000);
        plot(flight(Targetflight).Reference(17,:), 'r');
        plot(flight(Targetflight).Reference(18,:), 'r');
    end
    hold off
    title('mass (t)')
    xlabel('time (sec)')
    
    figure
    subplot(3,1,1);
    grid on
    hold on
    try
        plot(Ref_timeaxis, abs(flight(Targetflight).Reference(8,:)));
    end
    plot(Log_timeaxis, (unit.nm2ft * abs(flightlog(Targetflight).history(8,:))), 'g');
    try
        plot(Ref_timeaxis, flight(Targetflight).Reference(23,:), 'r');
    end
    hold off
    title('Longitudinal Acceleration (ft/s^2)')
    
    subplot(3,1,2);
    grid on
    hold on
    try
        plot(Ref_timeaxis, sqrt(flight(Targetflight).Reference(8,:).^2 + flight(Targetflight).Reference(10,:).^2));
    end
    plot(Log_timeaxis, sqrt((unit.nm2ft * flightlog(Targetflight).history(8,:)).^2 + flightlog(Targetflight).history(9,:).^2), 'g');
    % plot(Ref_timeaxis, flight(Targetflight).Reference(24,:), 'r');
    hold off
    title('Normal Acceleration (ft/s^2)')
    
    subplot(3,1,3)
    grid on
    hold on
    plot(Ref_timeaxis, flight(Targetflight).Reference(11,:));
    plot(Log_timeaxis, (flightlog(Targetflight).history(7,:) * 60), 'g');
    title('ROCD (ft/min)')
    xlabel('time (sec)')
    hold off
    
    figure
    subplot(3,1,1);
    grid on
    hold on
    plot(flight(Targetflight).Reference(13,:));
    % plot(flight(Targetflight).Reference(22,:) / 1000, 'r');
    hold off
    title('Thrust (kN)')
    
    subplot(3,1,2);
    grid on
    hold on
    plot(flight(Targetflight).Reference(14,:));
    hold off
    title('Fuel Flow (kg/min)')
    
    subplot(3,1,3)
    grid on
    hold on
    plot(flight(Targetflight).Reference(16,:));
    title('Fuel Consumption (kg)')
    hold off
    xlabel('time (sec)')
end


    figure
    subplot(2,2,1);
    grid on
    hold on
    ylim([0 150000])
    plot(Ref_timeaxis, flight(Targetflight).Reference(13,:) * 1000);
    plot(Ref_timeaxis, flight(Targetflight).Reference(22,:), 'r');
    plot(Log_timeaxis, flightlog(Targetflight).history(13,:), 'g');
    hold off
    title('Thrust (N)')
    
    subplot(2,2,2)
    grid on
    hold on
    ylim([0 150000])
    plot(Ref_timeaxis,flight(Targetflight).Reference(27,:));
    plot(Log_timeaxis, flightlog(Targetflight).history(17,:), 'g');
    title('Drag (N)')
    hold off
    xlabel('time (sec)')
    
    subplot(2,2,3);
    grid on
    hold on
    ylim([0 1000000])
    plot(Ref_timeaxis, flight(Targetflight).Reference(26,:));
    plot(Log_timeaxis, flightlog(Targetflight).history(16,:), 'g');
    hold off
    title('Lift (N)')
    
    
    subplot(2,2,4);
    grid on
    hold on
    ylim([0 1000000])
    try
        plot(Ref_timeaxis, flight(Targetflight).Reference(12,:) * atmos.g_0);
    end
    plot(Log_timeaxis, flightlog(Targetflight).history(14,:) * 1000 * atmos.g_0, 'g');
    hold off
    title('Weight (N)')