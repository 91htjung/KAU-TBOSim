function DisplayData = DisplayDataUpdate(DisplayData, Trajectory, flight, RunTime)
global plan Graphics config



StatusLookUp = {'Queued' ; 'Airborne' ; 'Arrived' ; 'Deleted' ; 'Paused'};
DataLookUp = {'Imported Flight - Radar Data' ; 'Planned Flight' ; 'Generated Flight'};

Callsign = flight(Graphics.RadarScreen.Target.NewID).callsign;
Status = StatusLookUp{flight(Graphics.RadarScreen.Target.NewID).status};
id = num2str(flight(Graphics.RadarScreen.Target.NewID).id);

if flight(Graphics.RadarScreen.Target.NewID).Data
    Data = 'manual';
else
    Data = 'auto';
end

Type = flight(Graphics.RadarScreen.Target.NewID).type;
Squawk = num2str(flight(Graphics.RadarScreen.Target.NewID).squawk, '%i');

Departure = [plan(flight(Graphics.RadarScreen.Target.NewID).id).departure ' (' plan(flight(Graphics.RadarScreen.Target.NewID).id).departure_RWY ')'];
Arrival = [plan(flight(Graphics.RadarScreen.Target.NewID).id).arrival ' (' plan(flight(Graphics.RadarScreen.Target.NewID).id).arrival_RWY ')'];

Longitude = num2str(flight(Graphics.RadarScreen.Target.NewID).long, '%3.6f');
Latitude = num2str(flight(Graphics.RadarScreen.Target.NewID).lat,  '%2.6f');
Altitude = [num2str(flight(Graphics.RadarScreen.Target.NewID).alt, '%5.1f') ' ft'];

Airspeed = [num2str(flight(Graphics.RadarScreen.Target.NewID).Vtas,  '%3.1f') ' kt'];
Heading = [num2str(flight(Graphics.RadarScreen.Target.NewID).hdg, '%3.1f') ' вк'];
RateofClimb = [num2str(flight(Graphics.RadarScreen.Target.NewID).ROCD, '%3.1f') ' ft/s'];

switch flight(Graphics.RadarScreen.Target.NewID).FS
    case 'TX'
        FlapSetting = 'Ground';
    case 'TO'
        FlapSetting = 'Take Off';
    case 'IC'
        FlapSetting = 'Climb';
    case 'CR'
        FlapSetting = 'Cruise';
    case 'AP'
        FlapSetting = 'Approach';
    case 'LD'
        FlapSetting = 'Landing';
    case 'HL'
        FlapSetting = 'Holding';
    case 'MS'
        FlapSetting = 'Missed';
    otherwise
        FlapSetting = 'Unknown';
end

ControlOpt = '';
if flight(Graphics.RadarScreen.Target.NewID).manual.spd(1)
    ControlOpt = [ControlOpt 'Speed(' num2str(flight(Graphics.RadarScreen.Target.NewID).manual.spd(2), '%3.1f') ') kt / '];
end
if flight(Graphics.RadarScreen.Target.NewID).manual.alt(1)
    ControlOpt = [ControlOpt 'Altitude(' num2str(flight(Graphics.RadarScreen.Target.NewID).manual.alt(2), '%5.1f') ') ft / '];
end
if flight(Graphics.RadarScreen.Target.NewID).manual.hdg(1)
    ControlOpt = [ControlOpt sprintf('\n') 'Heading(' num2str(flight(Graphics.RadarScreen.Target.NewID).manual.hdg(2), '%3.1f') ') / '];
end
if flight(Graphics.RadarScreen.Target.NewID).manual.cta(1)
    ControlOpt = [ControlOpt 'Dynamic'];
end
if isempty(ControlOpt)
   ControlOpt = 'Static'; 
end

Gentime = [num2str(flight(Graphics.RadarScreen.Target.NewID).gentime, '%6.1f') ' sec'];
Airtime = [num2str(RunTime - flight(Graphics.RadarScreen.Target.NewID).gentime, '%6.1f') ' sec'];

DisplayData.Target.String = ...
    ['\bf Target: \rm ' Callsign sprintf('\n') ...
    '\bf ID: \rm ' id sprintf('\n') ...
    '\bf Status: \rm ' Status sprintf('\n') ...
    '\bf Data: \rm ' Data sprintf('\n \n') ...
    '\bf Type: \rm ' Type sprintf('\n') ...
    '\bf Squawk: \rm ' Squawk sprintf('\n \n') ...
    '\bf Departure: \rm ' Departure sprintf('\n') ...
    '\bf Arrival: \rm ' Arrival sprintf('\n \n') ...
    '\bf Longitude: \rm ' Longitude sprintf('\n') ...
    '\bf Latitude: \rm ' Latitude sprintf('\n') ...
    '\bf Altitude: \rm ' Altitude sprintf('\n \n') ...
    '\bf Airspeed: \rm ' Airspeed sprintf('\n') ...
    '\bf Heading: \rm ' Heading sprintf('\n') ...
    '\bf Rate of Climb: \rm ' RateofClimb sprintf('\n \n') ...
    '\bf Flap Setting: \rm ' FlapSetting sprintf('\n \n') ...
    '\bf Start Time: \rm ' Gentime sprintf('\n') ...
    '\bf Air Time: \rm ' Airtime sprintf('\n \n') ...
    '\bf Control Option: \rm ' ControlOpt sprintf('\n') ...
    ];



Trajectory.Line.XData = flight(Graphics.RadarScreen.Target.NewID).Reference(2,:);
Trajectory.Line.YData = flight(Graphics.RadarScreen.Target.NewID).Reference(3,:);

% Trajectory.From.XData = flight(Graphics.RadarScreen.Target.NewID).Reference(2, flight(Graphics.RadarScreen.Target.NewID).ReferenceFrom);
% Trajectory.From.YData = flight(Graphics.RadarScreen.Target.NewID).Reference(3, flight(Graphics.RadarScreen.Target.NewID).ReferenceFrom);
% 
% Trajectory.To.XData = flight(Graphics.RadarScreen.Target.NewID).Reference(2, flight(Graphics.RadarScreen.Target.NewID).ReferenceTo);
% Trajectory.To.YData = flight(Graphics.RadarScreen.Target.NewID).Reference(3, flight(Graphics.RadarScreen.Target.NewID).ReferenceTo);


Trajectory.From.XData = flight(Graphics.RadarScreen.Target.NewID).Reference(2, flight(Graphics.RadarScreen.Target.NewID).ReferenceFrom);
Trajectory.From.YData = flight(Graphics.RadarScreen.Target.NewID).Reference(3, flight(Graphics.RadarScreen.Target.NewID).ReferenceFrom);

Trajectory.To.XData = flight(Graphics.RadarScreen.Target.NewID).Reference(2, flight(Graphics.RadarScreen.Target.NewID).ReferenceTo);
Trajectory.To.YData = flight(Graphics.RadarScreen.Target.NewID).Reference(3, flight(Graphics.RadarScreen.Target.NewID).ReferenceTo);
% 
% Graphics.RadarScreen.Trajectory.Waypoints = [];
% Graphics.RadarScreen.Trajectory.WPName = [];
% 
% if ~isempty(flight(Graphics.RadarScreen.Target.NewID).trajectory)
%     Graphics.RadarScreen.Trajectory.Waypoints = plot([flight(Graphics.RadarScreen.Target.NewID).trajectory.long], [flight(Graphics.RadarScreen.Target.NewID).trajectory.lat], 'LineStyle', 'none', 'Marker', '^', 'MarkerEdgeColor', [1 1 1], 'MarkerSize', 5);
%     Graphics.RadarScreen.Trajectory.WPName = text([flight(Graphics.RadarScreen.Target.NewID).trajectory.long], [flight(Graphics.RadarScreen.Target.NewID).trajectory.lat], strcat(sprintf('\n'), {flight(Graphics.RadarScreen.Target.NewID).trajectory.wp_name}), 'Interpreter', 'none', 'Color', [1 1 1], 'FontSize', 5, 'HorizontalAlignment', 'center');
%     
%     if config.ViewWayp
%         Graphics.RadarScreen.Trajectory.Waypoints.Visible = 'on';
%         for index_WPName = 1:length(Graphics.RadarScreen.Trajectory.WPName)
%             Graphics.RadarScreen.Trajectory.WPName(index_WPName).Visible = 'on';
%         end
%     else
%         Graphics.RadarScreen.Trajectory.Waypoints.Visible = 'off';
%         for index_WPName = 1:length(Graphics.RadarScreen.Trajectory.WPName)
%             Graphics.RadarScreen.Trajectory.WPName(index_WPName).Visible = 'off';
%         end
%     end
% end

Graphics.RadarScreen.Data.Number.ID.String = ['ID #' num2str(Graphics.RadarScreen.Target.NewID)];
Graphics.RadarScreen.Data.Number.Callsign.String = flight(Graphics.RadarScreen.Target.NewID).callsign;
Graphics.RadarScreen.Data.Number.Type.String = flight(Graphics.RadarScreen.Target.NewID).type;
Graphics.RadarScreen.Data.Number.Squawk.String = ['Squawk: ' num2str(flight(Graphics.RadarScreen.Target.NewID).squawk)];
Graphics.RadarScreen.Data.Number.Status.String = StatusLookUp{flight(Graphics.RadarScreen.Target.NewID).status};
Graphics.RadarScreen.Data.Number.DataOrig.String = DataLookUp{flight(Graphics.RadarScreen.Target.NewID).Data + 1};
Graphics.RadarScreen.Data.Number.Status.String = StatusLookUp{flight(Graphics.RadarScreen.Target.NewID).status};

LatDMS = degrees2dms(flight(Graphics.RadarScreen.Target.NewID).lat);
LongDMS = degrees2dms(flight(Graphics.RadarScreen.Target.NewID).long);

Graphics.RadarScreen.Data.Number.Latitude.Value.String = [num2str(LatDMS(1), '%i') '?' num2str(LatDMS(2), '%i') char(39) ' ' num2str(LatDMS(3), '%.1f') '" '];
Graphics.RadarScreen.Data.Number.Longitude.Value.String = [num2str(LongDMS(1), '%i') '?' num2str(LongDMS(2), '%i') char(39) ' ' num2str(LongDMS(3), '%.1f') '" '];
Graphics.RadarScreen.Data.Number.Altitude.Value.String = [num2str(flight(Graphics.RadarScreen.Target.NewID).alt, '%.1f'), ' ft'];
Graphics.RadarScreen.Data.Number.FlapSetting.Value.String = flight(Graphics.RadarScreen.Target.NewID).FS;
Graphics.RadarScreen.Data.Number.Heading.Value.String = [num2str(flight(Graphics.RadarScreen.Target.NewID).hdg, '%.1f'), '?'];
Graphics.RadarScreen.Data.Number.Speed.Value.String = [num2str(flight(Graphics.RadarScreen.Target.NewID).Vtas, '%.1f'), ' kt'];
Graphics.RadarScreen.Data.Number.VertSpeed.Value.String = [num2str(flight(Graphics.RadarScreen.Target.NewID).ROCD, '%.2f'), ' ft/s'];
Graphics.RadarScreen.Data.Number.LongAccel.Value.String = [num2str(flight(Graphics.RadarScreen.Target.NewID).LongAccel, '%.2f'), ' ft/s?'];
Graphics.RadarScreen.Data.Number.VertAccel.Value.String = [num2str(flight(Graphics.RadarScreen.Target.NewID).VertAccel, '%.2f'), ' ft/s?'];
Graphics.RadarScreen.Data.Number.RateOfTurn.Value.String = [num2str(flight(Graphics.RadarScreen.Target.NewID).RateOfTurn, '%.2f'), ' deg/s'];
Graphics.RadarScreen.Data.Number.Thrust.Value.String = [num2str(flight(Graphics.RadarScreen.Target.NewID).Thrust / 1000, '%.1f'), ' kN'];
Graphics.RadarScreen.Data.Number.Drag.Value.String = [num2str(flight(Graphics.RadarScreen.Target.NewID).Drag / 1000, '%.1f'), ' kN'];
Graphics.RadarScreen.Data.Number.Lift.Value.String = [num2str(flight(Graphics.RadarScreen.Target.NewID).Lift / 1000, '%.1f'), ' kN'];
Graphics.RadarScreen.Data.Number.Mass.Value.String = [num2str(flight(Graphics.RadarScreen.Target.NewID).mass, '%.2f'), ' t'];
Graphics.RadarScreen.Data.Number.FuelFlow.Value.String = [num2str(flight(Graphics.RadarScreen.Target.NewID).FuelFlow, '%.2f'), ' kg/s'];
Graphics.RadarScreen.Data.Number.FuelCon.Value.String = [num2str(flight(Graphics.RadarScreen.Target.NewID).FuelConsumption, '%.1f'), ' kg'];
Graphics.RadarScreen.Data.Number.GenTime.Value.String = num2str(flight(Graphics.RadarScreen.Target.NewID).gentime);
Graphics.RadarScreen.Data.Number.ELDT.Value.String = num2str(flight(Graphics.RadarScreen.Target.NewID).gentime + flight(Graphics.RadarScreen.Target.NewID).Reference(6,end));
Graphics.RadarScreen.Data.Number.AirTime.Value.String = num2str(max(0, RunTime - flight(Graphics.RadarScreen.Target.NewID).gentime));


Graphics.RadarScreen.Control.Heading.FromValue.String = [num2str(flight(Graphics.RadarScreen.Target.NewID).hdg, '%.1f'), '?'];
Graphics.RadarScreen.Control.Altitude.FromValue.String = [num2str(flight(Graphics.RadarScreen.Target.NewID).alt, '%.1f'), ' ft'];
Graphics.RadarScreen.Control.Speed.FromValue.String = [num2str(flight(Graphics.RadarScreen.Target.NewID).Vtas, '%.1f'), ' kt'];



end