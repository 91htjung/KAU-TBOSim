
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
    
Ref_timeaxis = [flight(10).Reference(6,:)];
Log10_timeaxis = [flightlog(10).history(1,:) - flight(10).gentime];
Log11_timeaxis = [flightlog(11).history(1,:) - flight(11).gentime];
Log12_timeaxis = [flightlog(12).history(1,:) - flight(12).gentime];
Log13_timeaxis = [flightlog(13).history(1,:) - flight(13).gentime];

figure
% title(['flight #' num2str(Targetflight)]);

subplot(2,1,1)
grid on
hold on
plot(Ref_timeaxis, flight(10).Reference(2,:), 'k');
plot(Log10_timeaxis, flightlog(10).history(2,:), 'Color', [1 0 0]);
plot(Log11_timeaxis, flightlog(11).history(2,:), 'Color', [0.8 0.2 0.8]);
plot(Log12_timeaxis, flightlog(12).history(2,:), 'Color', [0 0 1]);
plot(Log13_timeaxis, flightlog(13).history(2,:), 'Color', [0.2 0.8 0.8]);
legend('trajectory', 'Dynamic - NoWind', 'Dynamic - Wind', 'Static - NoWind', 'Static - Wind')
hold off
xlabel('longitude (deg)')

subplot(2,1,2)
grid on
hold on
plot(Ref_timeaxis, flight(10).Reference(3,:), 'k');
plot(Log10_timeaxis, flightlog(10).history(3,:), 'Color', [1 0 0]);
plot(Log11_timeaxis, flightlog(11).history(3,:), 'Color', [0.8 0.2 0.8]);
plot(Log12_timeaxis, flightlog(12).history(3,:), 'Color', [0 0 1]);
plot(Log13_timeaxis, flightlog(13).history(3,:), 'Color', [0.2 0.8 0.8]);
hold off
xlabel('latitude (deg)')

figure
subplot(3,1,1)
grid on
hold on
plot(Ref_timeaxis, flight(10).Reference(4,:), 'k');
plot(Log10_timeaxis, flightlog(10).history(4,:), 'Color', [1 0 0]);
plot(Log11_timeaxis, flightlog(11).history(4,:), 'Color', [0.8 0.2 0.8]);
plot(Log12_timeaxis, flightlog(12).history(4,:), 'Color', [0 0 1]);
plot(Log13_timeaxis, flightlog(13).history(4,:), 'Color', [0.2 0.8 0.8]);
legend('trajectory', 'Dynamic - NoWind', 'Dynamic - Wind', 'Static - NoWind', 'Static - Wind')
hold off
xlabel('altitude (ft)')

subplot(3,1,2)
grid on
hold on
ylim([0 360])
plot(Ref_timeaxis, flight(10).Reference(25,:), 'k');
plot(Log10_timeaxis, flightlog(10).history(6,:), 'Color', [1 0 0]);
plot(Log11_timeaxis, flightlog(11).history(6,:), 'Color', [0.8 0.2 0.8]);
plot(Log12_timeaxis, flightlog(12).history(6,:), 'Color', [0 0 1]);
plot(Log13_timeaxis, flightlog(13).history(6,:), 'Color', [0.2 0.8 0.8]);
hold off
xlabel('heading (deg)')

subplot(3,1,3)
grid on
hold on
plot(Ref_timeaxis, flight(10).Reference(5,:), 'k');
plot(Log10_timeaxis, flightlog(10).history(5,:), 'Color', [1 0 0]);
plot(Log11_timeaxis, flightlog(11).history(5,:), 'Color', [0.8 0.2 0.8]);
plot(Log12_timeaxis, flightlog(12).history(5,:), 'Color', [0 0 1]);
plot(Log13_timeaxis, flightlog(13).history(5,:), 'Color', [0.2 0.8 0.8]);
hold off
xlabel('speed (kt)')

figure
subplot(3,1,1)
grid on
hold on
plot(Ref_timeaxis, flight(10).Reference(11,:), 'k');
plot(Log10_timeaxis, flightlog(10).history(7,:) * 60, 'Color', [1 0 0]);
plot(Log11_timeaxis, flightlog(11).history(7,:) * 60, 'Color', [0.8 0.2 0.8]);
plot(Log12_timeaxis, flightlog(12).history(7,:) * 60, 'Color', [0 0 1]);
plot(Log13_timeaxis, flightlog(13).history(7,:) * 60, 'Color', [0.2 0.8 0.8]);
legend('trajectory', 'Dynamic - NoWind', 'Dynamic - Wind', 'Static - NoWind', 'Static - Wind')
hold off
xlabel('ROCD (ft/min)')

subplot(3,1,2)
grid on
hold on
ylim([-3 3])
plot(Ref_timeaxis, flight(10).Reference(8,:), 'k');
plot(Log10_timeaxis, flightlog(10).history(8,:) * unit.nm2ft, 'Color', [1 0 0]);
plot(Log11_timeaxis, flightlog(11).history(8,:) * unit.nm2ft, 'Color', [0.8 0.2 0.8]);
plot(Log12_timeaxis, flightlog(12).history(8,:) * unit.nm2ft, 'Color', [0 0 1]);
plot(Log13_timeaxis, flightlog(13).history(8,:) * unit.nm2ft, 'Color', [0.2 0.8 0.8]);
hold off
xlabel('longitudinal accel (ft/sec^2)')

subplot(3,1,3)
grid on
hold on
ylim([-5 5])
plot(Ref_timeaxis, flight(10).Reference(10,:), 'k');
plot(Log10_timeaxis, flightlog(10).history(9,:), 'Color', [1 0 0]);
plot(Log11_timeaxis, flightlog(11).history(9,:), 'Color', [0.8 0.2 0.8]);
plot(Log12_timeaxis, flightlog(12).history(9,:), 'Color', [0 0 1]);
plot(Log13_timeaxis, flightlog(13).history(9,:), 'Color', [0.2 0.8 0.8]);
hold off
xlabel('vertical accel (ft/sec^2)')

figure
subplot(3,1,1)
grid on
hold on
plot(Ref_timeaxis, flight(10).Reference(13,:), 'k');
plot(Log10_timeaxis, flightlog(10).history(13,:) / 1000, 'Color', [1 0 0]);
plot(Log11_timeaxis, flightlog(11).history(13,:) / 1000, 'Color', [0.8 0.2 0.8]);
plot(Log12_timeaxis, flightlog(12).history(13,:) / 1000, 'Color', [0 0 1]);
plot(Log13_timeaxis, flightlog(13).history(13,:) / 1000, 'Color', [0.2 0.8 0.8]);
legend('trajectory', 'Dynamic - NoWind', 'Dynamic - Wind', 'Static - NoWind', 'Static - Wind')
hold off
xlabel('Thrust (kN)')

subplot(3,1,2)
grid on
hold on
plot(Ref_timeaxis, flight(10).Reference(12,:), 'k');
plot(Log10_timeaxis, flightlog(10).history(14,:) * 1000, 'Color', [1 0 0]);
plot(Log11_timeaxis, flightlog(11).history(14,:) * 1000, 'Color', [0.8 0.2 0.8]);
plot(Log12_timeaxis, flightlog(12).history(14,:) * 1000, 'Color', [0 0 1]);
plot(Log13_timeaxis, flightlog(13).history(14,:) * 1000, 'Color', [0.2 0.8 0.8]);
hold off
xlabel('Mass (kg)')

subplot(3,1,3)
grid on
hold on
plot(Ref_timeaxis, flight(10).Reference(16,:), 'k');
plot(Log10_timeaxis, flightlog(10).history(15,:), 'Color', [1 0 0]);
plot(Log11_timeaxis, flightlog(11).history(15,:), 'Color', [0.8 0.2 0.8]);
plot(Log12_timeaxis, flightlog(12).history(15,:), 'Color', [0 0 1]);
plot(Log13_timeaxis, flightlog(13).history(15,:), 'Color', [0.2 0.8 0.8]);
hold off
xlabel('FuelUsed (kg)')