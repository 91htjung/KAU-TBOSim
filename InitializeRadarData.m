function Graphics = InitializeRadarData(flight, Map, RunTime, Graphics)

global config Airspace Aerodrome Procedure plan Command Active

StatusLookUp = {'Queued' ; 'Airborne' ; 'Arrived' ; 'Deleted' ; 'Paused'};
DataLookUp = {'Imported Flight - Radar Data' ; 'Planned Flight' ; 'Generated Flight'};
    
% radarposition = line;
for i = 1:length(flight)
    if config.TrailFlag
        Graphics.RadarScreen.radartrail(flight(i).id) = plot([flight(i).long : flight(i).long], [flight(i).lat : flight(i).lat], 'LineStyle', Graphics.Options.Linestyle.Aircraft.Trail, 'Color', Graphics.Options.Color.Aircraft.Trail, 'LineWidth', Graphics.Options.Linewidth.Aircraft.Trail);
        Graphics.RadarScreen.trailfix(i).long = -1;
        Graphics.RadarScreen.trailfix(i).lat = -1;
        Graphics.RadarScreen.trailfix(i).count = config.TrailInterval;
    end
    
    if config.HdgLineFlag
        Graphics.RadarScreen.hdgline(flight(i).id) = plot([flight(i).long ; flight(i).lat], [flight(i).long + (Graphics.Parameter.CurrentZoom * config.HdgLineParam(1) * (config.HdgLineParam(2) ^ nm2deg(flight(i).Vtas)) * sin(deg2rad(flight(i).hdg))) ; flight(i).lat + (Graphics.Parameter.CurrentZoom * config.HdgLineParam(1) * (config.HdgLineParam(2) ^ nm2deg(flight(i).Vtas)) * cos(deg2rad(flight(i).hdg)))], 'LineStyle', Graphics.Options.Linestyle.Aircraft.Heading, 'Color', Graphics.Options.Color.Aircraft.Heading, 'LineWidth', Graphics.Options.Linewidth.Aircraft.Heading);
    end
    
    Graphics.RadarScreen.radarposition(flight(i).id) = plot(flight(i).long, flight(i).lat, 'LineStyle', 'none', 'Marker', Graphics.Options.Markerstyle.Aircraft.Position, 'MarkerEdgeColor', Graphics.Options.Color.Aircraft.InactivePosition, 'MarkerSize', Graphics.Options.Markersize.Aircraft.Position, 'LineWidth', Graphics.Options.Linewidth.Aircraft.Position);
    Graphics.RadarScreen.datablock(flight(i).id) = text(flight(i).long, flight(i).lat, sprintf(['\n   ']), 'Color', [0.25 0.9 0.55], 'FontSize', Graphics.Options.Fontsize.Aircraft.DataBlock, 'HorizontalAlignment', 'left');
    
    set(Graphics.RadarScreen.datablock(flight(i).id), 'ButtonDownFcn', {@RadarDataBlockCallback, flight, RunTime});
    Graphics.RadarScreen.datablock(flight(i).id).String = ['\bf' sprintf('\t \t \t \t') '\bf' flight(i).callsign sprintf('\n\t \t \t \t') '\bf' num2str(round(flight(i).alt), '%i') ' ft'  sprintf('\t \t \t') '\bf' num2str(round(flight(i).Vtas), '%i') ' kt'];
    Graphics.RadarScreen.datablock(flight(i).id).UserData = flight(i).id;
    
    Graphics.RadarScreen.radarposition(flight(i).id).Visible = 'off';
    Graphics.RadarScreen.datablock(flight(i).id).Visible = 'off';
        
    
end


% text
if config.AutoRadarUpdate
    RadarOpt = 'Auto';
else
    RadarOpt = ['Manual (' num2str(config.ManualRadarUpdate * config.update, '%2.2f') ' sec)'];
end


% zoom(Graphics.MainWindow.screen, 1);

Graphics.RadarScreen.DisplayData.Timer = text('Units', 'normalized', 'Position', [0.60 ; 0.67], 'String', ['\bf Runtime: ' '\rm / seconds' sprintf('\n') '\bf 0' '\rm Aircrafts'], 'Color', [1.0 1.0 1.0], 'FontSize', 8, 'VerticalAlignment', 'top');

Graphics.RadarScreen.DisplayData.GlobalData = text('Units', 'normalized', 'Position', [0.60 ; 0.64], ...
    'String', ['\bf Simulation Configuration' sprintf('\n') ...
    '\bf Scenario: ' '\rm ' config.Scenario sprintf('\n') ...
    '\bf Simulation Update Time: ' '\rm ' num2str(config.update, '%2.2f') ' sec' sprintf('\n') ...
    '\bf Trajectory Resolution: ' '\rm ' num2str(config.TrajRes, '%2.2f') ' sec' sprintf('\n') ...
    '\bf Radar Update: ' '\rm ' RadarOpt sprintf('\n')], ...
    'Color', [1.0 1.0 1.0], 'FontSize', 8,  'VerticalAlignment', 'top');

Graphics.RadarScreen.DisplayData.Target = text('Units', 'normalized', 'Position', [0.60 ; 0.59], 'String', ['\bf Target: ' '\rm callsign' sprintf('\n') ], 'Color', [1.0 1.0 1.0], 'FontSize', 8, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');


Graphics.RadarScreen.DisplayData.Timer.Units = 'data';
Graphics.RadarScreen.DisplayData.GlobalData.Units = 'data';
Graphics.RadarScreen.DisplayData.Target.Units = 'data';

Graphics.RadarScreen.Target.OldID = config.InitialTarget;
Graphics.RadarScreen.Target.NewID = config.InitialTarget;

zoom(Graphics.MainWindow.screen,'reset')



set(Graphics.RadarScreen.CamTarget, 'Callback', @CamLocCallback);

Graphics.RadarScreen.Trajectory.Line = plot(flight(Graphics.RadarScreen.Target.NewID).Reference(2,:), flight(Graphics.RadarScreen.Target.NewID).Reference(3,:), 'Color', [0.8 0.8 0.8], 'Linestyle', '-', 'LineWidth', 1);
if config.ViewTraj
   Graphics.RadarScreen.Trajectory.Line.Visible = 'on';
else
   Graphics.RadarScreen.Trajectory.Line.Visible = 'off';
end

Graphics.RadarScreen.Trajectory.From = plot(flight(Graphics.RadarScreen.Target.NewID).Reference(2, flight(Graphics.RadarScreen.Target.NewID).ReferenceFrom), flight(Graphics.RadarScreen.Target.NewID).Reference(3, flight(Graphics.RadarScreen.Target.NewID).ReferenceFrom), 'LineStyle', 'none', 'Marker', 'x', 'MarkerEdgeColor', [0.7 0.5 0.5], 'MarkerSize', 5);
Graphics.RadarScreen.Trajectory.To = plot(flight(Graphics.RadarScreen.Target.NewID).Reference(2, flight(Graphics.RadarScreen.Target.NewID).ReferenceTo), flight(Graphics.RadarScreen.Target.NewID).Reference(3, flight(Graphics.RadarScreen.Target.NewID).ReferenceTo), 'LineStyle', 'none', 'Marker', 'd', 'MarkerEdgeColor', [0.5 0.5 0.7], 'MarkerSize', 5);

if config.ViewCont
   Graphics.RadarScreen.Trajectory.From.Visible = 'on';
   Graphics.RadarScreen.Trajectory.To.Visible = 'on';
else
   Graphics.RadarScreen.Trajectory.From.Visible = 'off';
   Graphics.RadarScreen.Trajectory.To.Visible = 'off';
end

% 
% if ~isempty(flight(Graphics.RadarScreen.Target.NewID).trajectory)
% 
% Graphics.RadarScreen.Trajectory.Waypoints = plot([flight(Graphics.RadarScreen.Target.NewID).trajectory.long], [flight(Graphics.RadarScreen.Target.NewID).trajectory.lat], 'LineStyle', 'none', 'Marker', '^', 'MarkerEdgeColor', [1 1 1], 'MarkerSize', 5);
% Graphics.RadarScreen.Trajectory.WPName = text([flight(Graphics.RadarScreen.Target.NewID).trajectory.long], [flight(Graphics.RadarScreen.Target.NewID).trajectory.lat], strcat(sprintf('\n'), {flight(Graphics.RadarScreen.Target.NewID).trajectory.wp_name}), 'Interpreter', 'none', 'Color', [1 1 1], 'FontSize', 5, 'HorizontalAlignment', 'center');
%                            
% % Graphics.RadarScreen.Waypoint(WPMark).Name = text(Airspace.Waypoint(WPMark).Long(:), Airspace.Waypoint(WPMark).Lat(:),sprintf(['\n ' Airspace.Waypoint(WPMark).Name]), 'Color', [0.7 0.7 0.7], 'FontSize', 5, 'HorizontalAlignment', 'center');
% else
%     Graphics.RadarScreen.Trajectory.Waypoints = [];
%     Graphics.RadarScreen.Trajectory.WPName = [];
% end
% 
% if config.ViewWayp
%    Graphics.RadarScreen.Trajectory.Waypoints.Visible = 'on';
%    for index_WPName = 1:length(Graphics.RadarScreen.Trajectory.WPName)
%        Graphics.RadarScreen.Trajectory.WPName(index_WPName).Visible = 'on';
%    end
% else
%    Graphics.RadarScreen.Trajectory.Waypoints.Visible = 'off';
%    for index_WPName = 1:length(Graphics.RadarScreen.Trajectory.WPName)
%        Graphics.RadarScreen.Trajectory.WPName(index_WPName).Visible = 'off';
%    end
% end

% Plan / Strip Data Input
Graphics.RadarScreen.Plan.Strip.Data = cell(length(flight), 6);
Graphics.RadarScreen.Plan.Strip.Data(:,1) = num2cell([flight.id]');
Graphics.RadarScreen.Plan.Strip.Data(:,2) = {flight.callsign}';
Graphics.RadarScreen.Plan.Strip.Data(:,3) = {flight.type}';
Graphics.RadarScreen.Plan.Strip.Data(:,4) = strcat({plan.departure}, '(', strrep({plan.departure_RWY},'RWY',''), ')')';
Graphics.RadarScreen.Plan.Strip.Data(:,5) = strcat({plan.arrival}, '(', strrep({plan.arrival_RWY},'RWY',''), ')')';
Graphics.RadarScreen.Plan.Strip.Data(:,6) = num2cell([flight.gentime]')';

% Plan / AC Route Detail Data Input
Graphics.RadarScreen.Plan.Detail.Data = cell(length([flight(config.InitialTarget).trajectory.TRAJ_num]), 7);

Graphics.RadarScreen.Plan.Detail.Data(:,1) = num2cell(round([flight(config.InitialTarget).trajectory.TRAJ_num]',1));
Graphics.RadarScreen.Plan.Detail.Data(:,2) = {flight(config.InitialTarget).trajectory.wp_name}';
Graphics.RadarScreen.Plan.Detail.Data(:,3) = {flight(config.InitialTarget).trajectory.type}';
Graphics.RadarScreen.Plan.Detail.Data(:,4) = {flight(config.InitialTarget).trajectory.traj_name}';
Graphics.RadarScreen.Plan.Detail.Data(:,5) = cellstr(num2str([flight(config.InitialTarget).trajectory.lat]'))';
Graphics.RadarScreen.Plan.Detail.Data(:,6) = cellstr(num2str([flight(config.InitialTarget).trajectory.long]'))';
Graphics.RadarScreen.Plan.Detail.Data(:,7) = num2cell([flight(config.InitialTarget).trajectory.alt]');


Graphics.RadarScreen.Table.Object.Data = cell(length(flight), 7);
Graphics.RadarScreen.Table.Object.Data(:,1) = num2cell([flight.id]');
Graphics.RadarScreen.Table.Object.Data(:,2) = {flight.callsign}';





for FLlen = 1:length(flight)
    
    if and(config.RadarColorLabel, flight(FLlen).label == 1)
        c = [0.6, 0.6, 0.6];
    else
        switch flight(FLlen).status
            case 1
                c = [0.6,0.6,0.6];    % gray
            case 2
                c = [0.25,0.9,0.55];
            case 3
                c = [0.3,0.3,0.3];
            case 4
                c = [0.95,0.25,0.55];
            case 5
                
                
        end
    end

        
    
%     if config.RadarColorLabel
%         
%         clr = dec2hex(round(c * 255),2)'; clr = ['#';clr(:)]';
%         
% %         Graphics.RadarScreen.Table.Object.Data(FLlen,3) = strcat(['<html><body bgcolor="' clr '" >'], StatusLookUp(flight(FLlen).status));
% 
%         Graphics.RadarScreen.Table.Object.Data(FLlen,1) = num2cell(flight(FLlen).id);
%         if ~flight(FLlen).label
%             Graphics.RadarScreen.Table.Object.Data(FLlen,2) = strcat(['<html><font color="' clr '">'], {num2str(flight(FLlen).callsign)});
%             Graphics.RadarScreen.Table.Object.Data(FLlen,3) = strcat(['<html><font color="' clr '">'], StatusLookUp(flight(FLlen).status));
%         else
%             Graphics.RadarScreen.Table.Object.Data(FLlen,2) = {flight(FLlen).callsign};
%             Graphics.RadarScreen.Table.Object.Data(FLlen,3) = StatusLookUp(flight(FLlen).status);
%         end
%        
%         Graphics.RadarScreen.Table.Object.Data(FLlen,4) = num2cell(0);
%         Graphics.RadarScreen.Table.Object.Data(FLlen,5) = num2cell(round(flight(FLlen).gentime + flight(FLlen).Reference(6,end)));
%         Graphics.RadarScreen.Table.Object.Data(FLlen,6) = num2cell(0);
%         Graphics.RadarScreen.Table.Object.Data(FLlen,7) = num2cell(0);
%         
%     else
        
        clr = dec2hex(round(c * 255),2)'; clr = ['#';clr(:)]';
%         Graphics.RadarScreen.Table.Object.Data(FLlen,3) = strcat(['<html><body bgcolor="' clr '" >'], StatusLookUp(flight(FLlen).status));

        Graphics.RadarScreen.Table.Object.Data(FLlen,3) = strcat(['<html><table border=0 width=400 bgcolor="' clr '" ><TR><TD>'], StatusLookUp(flight(FLlen).status));
        Graphics.RadarScreen.Table.Object.Data(FLlen,4) = num2cell(0);
        Graphics.RadarScreen.Table.Object.Data(FLlen,5) = num2cell(round(flight(FLlen).gentime + flight(FLlen).Reference(6,end)));
        Graphics.RadarScreen.Table.Object.Data(FLlen,6) = num2cell(0);
        Graphics.RadarScreen.Table.Object.Data(FLlen,7) = num2cell(0);
    end
    
% end

Graphics.RadarScreen.Table.Object.Data(:,4) = num2cell([flight.gentime]');
Graphics.RadarScreen.Table.Object.UserData = config.InitialTarget;
Graphics.RadarScreen.Table.Object.Data = sortrows(Graphics.RadarScreen.Table.Object.Data, 4);
List = [Graphics.RadarScreen.Table.Object.Data{:,1}];
Graphics.RadarScreen.Table.Lookup = zeros(length(List),4);  
for ListIn = 1:length(List)
    Graphics.RadarScreen.Table.Lookup(List(ListIn),1) = ListIn;
    Graphics.RadarScreen.Table.Lookup(List(ListIn),2) = List(ListIn);
%     Graphics.RadarScreen.Table.Lookup(List(ListIn),3) = flight(List(ListIn)).label;
    Graphics.RadarScreen.Table.Lookup(List(ListIn),3) = 1;
    Graphics.RadarScreen.Table.Lookup(List(ListIn),4) = 1;
end

Graphics.RadarScreen.Table.Data = Graphics.RadarScreen.Table.Object.Data;

set(Graphics.RadarScreen.Table.Object, 'CellSelectionCallback', {@RadarDataBlockCallback, flight, RunTime});
set(Graphics.RadarScreen.Plan.Strip, 'CellSelectionCallback', {@RadarDataBlockCallback, flight, RunTime});


set(Graphics.RadarScreen.Table.FilterButton, 'Callback', @TableFilterCallback);
set(Graphics.RadarScreen.Table.RefreshButton, 'Callback', {@TableFilterRefreshCallback, flight, RunTime});

set(Graphics.RadarScreen.Table.FilterList, 'Callback', @TableFilterCallback);
set(Graphics.RadarScreen.Table.FilterInbound, 'Callback', @TableFilterCallback);
set(Graphics.RadarScreen.Table.FilterOutbound , 'Callback', @TableFilterCallback);

% Graphics.RadarScreen.Target.Object = findobj(Graphics.radarscreen, 'Tag', 'TargetAC');
Graphics.RadarScreen.Target.Object.String = {flight.callsign};
Graphics.RadarScreen.Target.Object.Value = config.InitialTarget;

Loc = Graphics.RadarScreen.Table.Lookup(config.InitialTarget,1);

% Graphics.RadarScreen.Table.Object.Data{Loc,2} = ['<html><body bgcolor="#FFCC00"><b>' Graphics.RadarScreen.Table.Object.Data{Loc,2}];

Graphics.RadarScreen.Table.Object.Data{Loc,2} = ['<html><table border=0 width=400 bgcolor="#FFCC00"><TR><TD><b>' Graphics.RadarScreen.Table.Object.Data{Loc,2}];



% Graphics.RadarScreen.Plan.Strip.Data{config.InitialTarget,2} = ['<html><body bgcolor="#FFCC00"><b>' Graphics.RadarScreen.Plan.Strip.Data{config.InitialTarget,2}];
Graphics.RadarScreen.Plan.Strip.Data{config.InitialTarget,2} = ['<html><table border=0 width=400 bgcolor="#FFCC00"><TR><TD><b>' Graphics.RadarScreen.Plan.Strip.Data{config.InitialTarget,2}];




% Graphics.RadarScreen.Target.OldID = config.InitialTarget;

if config.AircraftCam
    Graphics.RadarScreen.radaraxis.CameraTarget = [flight(config.InitialTarget).long ; flight(config.InitialTarget).lat ; 0];
end

set(Graphics.RadarScreen.Target.Object, 'Callback', {@RadarDataBlockCallback, flight, RunTime});


% Control Status
if flight(config.InitialTarget).manual.cta(1) % Dynamic
    Graphics.RadarScreen.Control.Option.Dynamic.Value = 1;
    Graphics.RadarScreen.Control.Option.Static.Value = 0;
    Graphics.RadarScreen.Control.Option.Manual.Value = 0;
elseif flight(config.InitialTarget).manual.hdg(1) % Manual
    Graphics.RadarScreen.Control.Option.Dynamic.Value = 0;
    Graphics.RadarScreen.Control.Option.Static.Value = 0;
    Graphics.RadarScreen.Control.Option.Manual.Value = 1;
else % Static
    Graphics.RadarScreen.Control.Option.Dynamic.Value = 0;
    Graphics.RadarScreen.Control.Option.Static.Value = 1;
    Graphics.RadarScreen.Control.Option.Manual.Value = 0;
end


Graphics.RadarScreen.Control.Option.Heading.Value = flight(config.InitialTarget).manual.hdg(1);
Graphics.RadarScreen.Control.Option.Speed.Value = flight(config.InitialTarget).manual.spd(1);
Graphics.RadarScreen.Control.Option.Altitude.Value = flight(config.InitialTarget).manual.alt(1);
    


set(Graphics.RadarScreen.Control.Option.TrajPanel, 'SelectionChangedFcn', @Control_button) 
set(Graphics.RadarScreen.Control.Option.Heading, 'Callback', @Manual_button)
set(Graphics.RadarScreen.Control.Option.Speed, 'Callback', @Manual_button)
set(Graphics.RadarScreen.Control.Option.Altitude, 'Callback', @Manual_button)

set(Graphics.RadarScreen.Control.Heading.Up, 'Callback', @Control_updown)
set(Graphics.RadarScreen.Control.Altitude.Up, 'Callback', @Control_updown)
set(Graphics.RadarScreen.Control.Speed.Up, 'Callback', @Control_updown)
set(Graphics.RadarScreen.Control.Misc.BearingUp, 'Callback', @Control_updown)
set(Graphics.RadarScreen.Control.Misc.LevelUp, 'Callback', @Control_updown)
set(Graphics.RadarScreen.Control.Misc.TimeUp, 'Callback', @Control_updown)

set(Graphics.RadarScreen.Control.Heading.Down, 'Callback', @Control_updown)
set(Graphics.RadarScreen.Control.Altitude.Down, 'Callback', @Control_updown)
set(Graphics.RadarScreen.Control.Speed.Down, 'Callback', @Control_updown)
set(Graphics.RadarScreen.Control.Misc.BearingDown, 'Callback', @Control_updown)
set(Graphics.RadarScreen.Control.Misc.LevelDown, 'Callback', @Control_updown)
set(Graphics.RadarScreen.Control.Misc.TimeDown, 'Callback', @Control_updown)

set(Graphics.RadarScreen.Control.Direct.WPName, 'Callback', @Waypoint_index)
set(Graphics.RadarScreen.Control.Direct.WPID, 'Callback', @Waypoint_index)
set(Graphics.RadarScreen.Control.Direct.WPList, 'Callback', @Waypoint_index)

set(Graphics.RadarScreen.Control.Misc.WPName, 'Callback', @Waypoint_index)
set(Graphics.RadarScreen.Control.Misc.WPID, 'Callback', @Waypoint_index)
set(Graphics.RadarScreen.Control.Misc.WPList, 'Callback', @Waypoint_index)


set(Graphics.RadarScreen.Control.Heading.Apply, 'Callback', @Heading_Apply)



% Data Value

Graphics.RadarScreen.Data.Number.ID.String = ['ID #' num2str(config.InitialTarget)];
Graphics.RadarScreen.Data.Number.Callsign.String = flight(config.InitialTarget).callsign;
Graphics.RadarScreen.Data.Number.Type.String = flight(config.InitialTarget).type;
Graphics.RadarScreen.Data.Number.Squawk.String = ['Squawk: ' num2str(flight(config.InitialTarget).squawk)];
Graphics.RadarScreen.Data.Number.Status.String = StatusLookUp{flight(config.InitialTarget).status};
Graphics.RadarScreen.Data.Number.DataOrig.String = DataLookUp{flight(config.InitialTarget).Data + 1};

LatDMS = degrees2dms(flight(config.InitialTarget).lat);
LongDMS = degrees2dms(flight(config.InitialTarget).long);

Graphics.RadarScreen.Data.Number.Latitude.Value.String = [num2str(LatDMS(1), '%i') '?' num2str(LatDMS(2), '%i') '` ' num2str(LatDMS(3), '%.1f') '" '];
Graphics.RadarScreen.Data.Number.Longitude.Value.String = [num2str(LongDMS(1), '%i') '?' num2str(LongDMS(2), '%i') '` ' num2str(LongDMS(3), '%.1f') '" '];
Graphics.RadarScreen.Data.Number.Altitude.Value.String = [num2str(flight(config.InitialTarget).alt, '%.1f'), ' ft'];
Graphics.RadarScreen.Data.Number.FlapSetting.Value.String = flight(config.InitialTarget).FS;
Graphics.RadarScreen.Data.Number.Heading.Value.String = [num2str(flight(config.InitialTarget).hdg, '%.1f'), '?'];
Graphics.RadarScreen.Data.Number.Speed.Value.String = [num2str(flight(config.InitialTarget).Vtas, '%.1f'), ' kt'];
Graphics.RadarScreen.Data.Number.VertSpeed.Value.String = [num2str(flight(config.InitialTarget).ROCD, '%.2f'), ' ft/s'];
Graphics.RadarScreen.Data.Number.LongAccel.Value.String = [num2str(flight(config.InitialTarget).LongAccel, '%.2f'), ' ft/s^2'];
Graphics.RadarScreen.Data.Number.VertAccel.Value.String = [num2str(flight(config.InitialTarget).VertAccel, '%.2f'), ' ft/s^2'];
Graphics.RadarScreen.Data.Number.RateOfTurn.Value.String = [num2str(flight(config.InitialTarget).RateOfTurn, '%.2f'), ' deg/s'];
Graphics.RadarScreen.Data.Number.Thrust.Value.String = [num2str(flight(config.InitialTarget).Thrust / 1000, '%.1f'), ' kN'];
Graphics.RadarScreen.Data.Number.Drag.Value.String = [num2str(flight(config.InitialTarget).Drag / 1000, '%.1f'), ' kN'];
Graphics.RadarScreen.Data.Number.Lift.Value.String = [num2str(flight(config.InitialTarget).Lift / 1000, '%.1f'), ' kN'];
Graphics.RadarScreen.Data.Number.Mass.Value.String = [num2str(flight(config.InitialTarget).mass, '%.2f'), ' t'];
Graphics.RadarScreen.Data.Number.FuelFlow.Value.String = [num2str(flight(config.InitialTarget).FuelFlow, '%.2f'), ' kg/s'];
Graphics.RadarScreen.Data.Number.FuelCon.Value.String = [num2str(flight(config.InitialTarget).FuelConsumption, '%.1f'), ' kg'];
Graphics.RadarScreen.Data.Number.GenTime.Value.String = num2str(flight(config.InitialTarget).gentime);
Graphics.RadarScreen.Data.Number.ELDT.Value.String = num2str(flight(config.InitialTarget).gentime + flight(config.InitialTarget).Reference(6,end));
Graphics.RadarScreen.Data.Number.AirTime.Value.String = num2str(max(0, RunTime - flight(config.InitialTarget).gentime));

% Data Graph
Graphics.RadarScreen.Data.Line.Ref_Altitude = line('Parent', Graphics.RadarScreen.Data.Graph.Altitude, 'XData', flight(config.GraphTarget).gentime + flight(config.GraphTarget).Reference(6,:), 'YData', flight(config.GraphTarget).Reference(4,:), 'Color', [0 1 0]);
% Graphics.RadarScreen.Data.Line.Ref_Heading = line('Parent', Graphics.RadarScreen.Data.Graph.Heading, 'XData', flight(config.GraphTarget).gentime + flight(config.GraphTarget).Reference(6,:), 'YData', flight(config.GraphTarget).Reference(25,:), 'Color', [0 1 0]);
Graphics.RadarScreen.Data.Line.Ref_Speed = line('Parent', Graphics.RadarScreen.Data.Graph.Speed, 'XData', flight(config.GraphTarget).gentime + flight(config.GraphTarget).Reference(6,:), 'YData', flight(config.GraphTarget).Reference(5,:), 'Color', [0 1 0]);
Graphics.RadarScreen.Data.Line.Ref_VertSpeed = line('Parent', Graphics.RadarScreen.Data.Graph.VertSpeed, 'XData', flight(config.GraphTarget).gentime + flight(config.GraphTarget).Reference(6,:), 'YData', flight(config.GraphTarget).Reference(9,:), 'Color', [0 1 0]);
Graphics.RadarScreen.Data.Line.Ref_LongAccel = line('Parent', Graphics.RadarScreen.Data.Graph.LongAccel, 'XData', flight(config.GraphTarget).gentime + flight(config.GraphTarget).Reference(6,:), 'YData', flight(config.GraphTarget).Reference(8,:), 'Color', [0 1 0]);
Graphics.RadarScreen.Data.Line.Ref_VertAccel = line('Parent', Graphics.RadarScreen.Data.Graph.VertAccel, 'XData', flight(config.GraphTarget).gentime + flight(config.GraphTarget).Reference(6,:), 'YData', flight(config.GraphTarget).Reference(10,:), 'Color', [0 1 0]);
Graphics.RadarScreen.Data.Line.Ref_Thrust = line('Parent', Graphics.RadarScreen.Data.Graph.Thrust, 'XData', flight(config.GraphTarget).gentime + flight(config.GraphTarget).Reference(6,:), 'YData', flight(config.GraphTarget).Reference(13,:) * 1000, 'Color', [0 1 0]);
Graphics.RadarScreen.Data.Line.Ref_Mass = line('Parent', Graphics.RadarScreen.Data.Graph.Mass, 'XData', flight(config.GraphTarget).gentime + flight(config.GraphTarget).Reference(6,:), 'YData', flight(config.GraphTarget).Reference(12,:) / 1000, 'Color', [0 1 0]);
% Graphics.RadarScreen.Data.Line.Ref_Lift = line('Parent', Graphics.RadarScreen.Data.Graph.Lift, 'XData', flight(config.GraphTarget).gentime + flight(config.GraphTarget).Reference(6,:), 'YData', flight(config.GraphTarget).Reference(26,:), 'Color', [0 1 0]);
% Graphics.RadarScreen.Data.Line.Ref_Drag = line('Parent', Graphics.RadarScreen.Data.Graph.Drag, 'XData', flight(config.GraphTarget).gentime + flight(config.GraphTarget).Reference(6,:), 'YData', flight(config.GraphTarget).Reference(27,:), 'Color', [0 1 0]);

Graphics.RadarScreen.Data.Line.Altitude = line('Parent', Graphics.RadarScreen.Data.Graph.Altitude, 'XData', RunTime, 'YData', flight(config.GraphTarget).alt, 'Color', [0 0 1]);
Graphics.RadarScreen.Data.Line.Heading = line('Parent', Graphics.RadarScreen.Data.Graph.Heading, 'XData', RunTime, 'YData', flight(config.GraphTarget).hdg, 'Color', [0 0 1]);
Graphics.RadarScreen.Data.Line.Speed = line('Parent', Graphics.RadarScreen.Data.Graph.Speed, 'XData', RunTime, 'YData', flight(config.GraphTarget).Vtas, 'Color', [0 0 1]);
Graphics.RadarScreen.Data.Line.VertSpeed = line('Parent', Graphics.RadarScreen.Data.Graph.VertSpeed, 'XData', RunTime, 'YData', flight(config.GraphTarget).ROCD, 'Color', [0 0 1]);
Graphics.RadarScreen.Data.Line.LongAccel = line('Parent', Graphics.RadarScreen.Data.Graph.LongAccel, 'XData', RunTime, 'YData', flight(config.GraphTarget).LongAccel, 'Color', [0 0 1]);
Graphics.RadarScreen.Data.Line.VertAccel = line('Parent', Graphics.RadarScreen.Data.Graph.VertAccel, 'XData', RunTime, 'YData', flight(config.GraphTarget).VertAccel, 'Color', [0 0 1]);
Graphics.RadarScreen.Data.Line.Thrust = line('Parent', Graphics.RadarScreen.Data.Graph.Thrust, 'XData', RunTime, 'YData', flight(config.GraphTarget).Thrust, 'Color', [0 0 1]);
Graphics.RadarScreen.Data.Line.Mass = line('Parent', Graphics.RadarScreen.Data.Graph.Mass, 'XData', RunTime, 'YData', flight(config.GraphTarget).mass, 'Color', [0 0 1]);
Graphics.RadarScreen.Data.Line.Lift = line('Parent', Graphics.RadarScreen.Data.Graph.Lift, 'XData', RunTime, 'YData', flight(config.GraphTarget).Lift, 'Color', [0 0 1]);
Graphics.RadarScreen.Data.Line.Drag = line('Parent', Graphics.RadarScreen.Data.Graph.Drag, 'XData', RunTime, 'YData', flight(config.GraphTarget).Drag, 'Color', [0 0 1]);


set(Graphics.RadarScreen.Procedure.AirRoute.NationalList, 'Callback', @AirRouteFilterCallback);
set(Graphics.RadarScreen.Procedure.AirRoute.Table, 'CellEditCallback', @AirRouteSelectCallback);




if config.timer ~= 0
    if config.update == config.timer
        Graphics.RadarScreen.RealTime.Value = 1;
        Graphics.RadarScreen.FastTime.Value = 0;
        Graphics.RadarScreen.SlowMotion.Value = 0;
    elseif config.update < config.timer
        Graphics.RadarScreen.RealTime.Value = 0;
        Graphics.RadarScreen.FastTime.Value = 0;
        Graphics.RadarScreen.SlowMotion.Value = 1;
    else
        config.timer = config.update;
        Graphics.RadarScreen.RealTime.Value = 1;
        Graphics.RadarScreen.FastTime.Value = 0;
        Graphics.RadarScreen.SlowMotion.Value = 0;
    end
else
    Graphics.RadarScreen.SlowMotion.Value = 0;
    Graphics.RadarScreen.RealTime.Value = 0;
    Graphics.RadarScreen.FastTime.Value = 1;
end

end
%%
function Control_button(Old, New, source,eventdata)
global config Graphics Command plan

input = New.NewValue.UserData;

valid = 0;

switch input
    
    case {'dynamic' ; 'static' ; 'manual'}
        command_line = input;
        valid = 1;
    otherwise
        command_line = '';
        valid = 0;
end

if valid
    apply_command(command_line);
end
end

function Manual_button(hObject, eventdata, handles)

command_line = hObject.UserData;
valid = 1;

if valid
    apply_command(command_line);
end

end


function Heading_Apply(hObject, eventdata, handles)
global Graphics

    % Validation
    if ~isnan(str2double(Graphics.RadarScreen.Control.Heading.ToValue.String))
        command = 'hdg';
        dir = Graphics.RadarScreen.Control.Heading.TurnDirection.SelectedObject.Tag;
        bank = Graphics.RadarScreen.Control.Heading.BankanblePanel.SelectedObject.Tag;
        value = mod(round(str2double(Graphics.RadarScreen.Control.Heading.ToValue.String)), 360);

        valid = 1;
    else
        Graphics.RadarScreen.Control.Heading.ToValue.String = 0;
        command = '';
        dir = '';
        bank = '';
        value = 0;
        valid = 0;
    end
    
    if valid
        
        command_line = [command num2str(value, '%03i') dir ' ban' bank];
        apply_command(command_line);
        
    else
        
        
    end
    
end



function Control_updown(hObject, eventdata, handles)
global Graphics

switch hObject.Tag
    case 'Heading'
        if ~isnan(str2double(Graphics.RadarScreen.Control.Heading.ToValue.String))
            Graphics.RadarScreen.Control.Heading.ToValue.String = num2str(mod(str2double(Graphics.RadarScreen.Control.Heading.ToValue.String) + hObject.UserData, 360));
        else
            Graphics.RadarScreen.Control.Heading.ToValue.String = num2str(mod(0 + hObject.UserData, 360));
        end
    case 'Altitude'
        if ~isnan(str2double(Graphics.RadarScreen.Control.Altitude.ToValue.String))
            Graphics.RadarScreen.Control.Altitude.ToValue.String = num2str(min(99900,max(100,str2double(Graphics.RadarScreen.Control.Altitude.ToValue.String) + hObject.UserData)));
        else
            Graphics.RadarScreen.Control.Altitude.ToValue.String = num2str(min(99900,max(100,100 + hObject.UserData)));
        end
    case 'Speed'
        if ~isnan(str2double(Graphics.RadarScreen.Control.Speed.ToValue.String))
            Graphics.RadarScreen.Control.Speed.ToValue.String = num2str(min(999,max(10, str2double(Graphics.RadarScreen.Control.Speed.ToValue.String) + hObject.UserData)));
        else
            Graphics.RadarScreen.Control.Speed.ToValue.String = num2str(min(999,max(10, 10 + hObject.UserData)));
        end
    case 'Bearing'
        if ~isnan(str2double(Graphics.RadarScreen.Control.Misc.BearingValue.String))
            Graphics.RadarScreen.Control.Misc.BearingValue.String = num2str(mod(str2double(Graphics.RadarScreen.Control.Misc.BearingValue.String) + hObject.UserData, 360));
        else
            Graphics.RadarScreen.Control.Misc.BearingValue.String = num2str(mod(0 + hObject.UserData, 360));
        end
    case 'Level'
        if ~isnan(str2double(Graphics.RadarScreen.Control.Misc.LevelValue.String))
            Graphics.RadarScreen.Control.Misc.LevelValue.String = num2str(min(99900, max(100, str2double(Graphics.RadarScreen.Control.Misc.LevelValue.String) + hObject.UserData)));
        else
            Graphics.RadarScreen.Control.Misc.LevelValue.String = num2str(min(99900, max(100, 0 + hObject.UserData)));
        end
    case 'Time'
        if ~isnan(str2double(Graphics.RadarScreen.Control.Misc.TimeValue.String))
            Graphics.RadarScreen.Control.Misc.TimeValue.String = num2str(min(86400, max(1, str2double(Graphics.RadarScreen.Control.Misc.TimeValue.String) + hObject.UserData)));
        else
            Graphics.RadarScreen.Control.Misc.TimeValue.String = num2str(min(86400, max(1, 0 + hObject.UserData)));
        end
end

end

function Waypoint_index(hObject, eventdata, handles)
global Airspace Graphics


switch hObject.UserData
    
    case 1 % Name input
        if ~isempty(find(strcmp({Airspace.Waypoint.Name}, hObject.String), 1))
            TargetWPID = Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, hObject.String)).id;
        else
            TargetWPID = 0;
            % Can't find matching Waypoint
        end
    case 2 % ID input
        if ~isnan(str2double(hObject.String))
            if str2double(hObject.String) <= length(Airspace.Waypoint)
                TargetWPID = str2double(hObject.String);
            else
                TargetWPID = 0;
                % Over Waypoint index limit
            end
        % Non valid WPID input
        
        end
            
    case 3 % List input
        contents = cellstr(get(hObject,'String'));
        if ~isempty(find(strcmp({Airspace.Waypoint.Name}, contents{get(hObject,'Value')}), 1))
            TargetWPID = Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, contents{get(hObject,'Value')})).id;
        else
            TargetWPID = 0;
            % Has no matching Waypoint name in DB -> Unknown Error
        end
        
        
end


switch hObject.Tag
    case 'Direct'
        if TargetWPID ~= 0
            Graphics.RadarScreen.Control.Direct.WPName.String = Airspace.Waypoint(TargetWPID).Name;
            Graphics.RadarScreen.Control.Direct.WPID.String = num2str(TargetWPID);
            
            if ~isempty(find(strcmp(cellstr(get(Graphics.RadarScreen.Control.Direct.WPList,'String')), Airspace.Waypoint(TargetWPID).Name), 1))
                Graphics.RadarScreen.Control.Direct.WPList.Value = find(strcmp(Graphics.RadarScreen.Control.Direct.WPList.String, Airspace.Waypoint(TargetWPID).Name), 1);
            else
                Graphics.RadarScreen.Control.Direct.WPList.Value = 1;
            end
        else
            % invalid input
        end
    case 'Holding'
        if TargetWPID ~= 0
            Graphics.RadarScreen.Control.Misc.WPName.String = Airspace.Waypoint(TargetWPID).Name;
            Graphics.RadarScreen.Control.Misc.WPID.String = num2str(TargetWPID);
            if ~isempty(find(strcmp(cellstr(get(Graphics.RadarScreen.Control.Misc.WPList,'String')), Airspace.Waypoint(TargetWPID).Name), 1))
                Graphics.RadarScreen.Control.Misc.WPList.Value = find(strcmp(Graphics.RadarScreen.Control.Misc.WPList.String, Airspace.Waypoint(TargetWPID).Name), 1);
            else
                Graphics.RadarScreen.Control.Misc.WPList.Value = 1;
            end
        else
            % invalid input
        end
end


end

function TableFilterCallback(hObject, eventdata, handles)
global Graphics plan
value = get(Graphics.RadarScreen.Table.FilterButton, 'Value');
if value
    AirportList = get(Graphics.RadarScreen.Table.FilterList, 'String');
    SelectedAirport = AirportList{get(Graphics.RadarScreen.Table.FilterList, 'Value')};
    InboundChk = get(Graphics.RadarScreen.Table.FilterInbound, 'Value');
    OutboundChk = get(Graphics.RadarScreen.Table.FilterOutbound, 'Value');
    if strcmp(SelectedAirport, 'All')
        Graphics.RadarScreen.Table.Lookup(:,4) = ones(length(Graphics.RadarScreen.Table.Lookup(:,4)),1);
    else
        if InboundChk
            arridx = strcmp({plan.arrival}, SelectedAirport);
        else
            arridx = zeros(1,length({plan.arrival}));
        end
        if OutboundChk
            depidx = strcmp({plan.departure}, SelectedAirport);
        else
            depidx = zeros(1,length({plan.departure}));
        end
        idx = or(arridx, depidx);
%         ididx = [1:length(idx)].*idx;
%         ididx(ididx==0)=[];
%         
%         idxs = arrayfun(@(x)find(Graphics.RadarScreen.Table.Lookup(:,1)==x,1),ididx);
        
        Graphics.RadarScreen.Table.Lookup(:,4) = zeros(length(Graphics.RadarScreen.Table.Lookup(:,4)),1);
        Graphics.RadarScreen.Table.Lookup(idx,4) = 1;
    end
    
else
    Graphics.RadarScreen.Table.Lookup(:,4) = ones(length(Graphics.RadarScreen.Table.Lookup(:,4)),1);
end

end



function AirRouteFilterCallback(hObject, eventdata, handles)
global Graphics

List = get(Graphics.RadarScreen.Procedure.AirRoute.NationalList, 'String');
National = List{get(Graphics.RadarScreen.Procedure.AirRoute.NationalList, 'Value')};
switch National
    case 'All'
        Graphics.RadarScreen.Procview.ARLookup(:,3) = 1;
    otherwise
        Graphics.RadarScreen.Procview.ARLookup(:,3) = 0;
        idx = strcmp({Graphics.RadarScreen.Procview.ARTable{:,3}}, National);
        Graphics.RadarScreen.Procview.ARLookup(idx,3) = 1;
end

tabidx = and(Graphics.RadarScreen.Procview.ARLookup(:,2), Graphics.RadarScreen.Procview.ARLookup(:,3));
hllookup = Graphics.RadarScreen.Procview.ARLookup(:,4);

nonload = [Graphics.RadarScreen.Procview.ARLookup(:,2) == 0];

tabidx(nonload) = [];
hllookup(nonload) = [];

origtable = Graphics.RadarScreen.Procview.ARTable;

FilteredData = reshape({origtable{tabidx,:}}, [length({origtable{tabidx,:}})/length(origtable(1,:)),length(origtable(1,:))]);
FilteredData(:,4) = num2cell(logical(hllookup(tabidx)));

Graphics.RadarScreen.Procedure.AirRoute.Table.Data = FilteredData;



end


function AirRouteSelectCallback(hObject, eventdata, handles)
global Graphics
val = eventdata.NewData;
ind = hObject.Data{eventdata.Indices(1),1};

if val
    Plotid = Graphics.RadarScreen.Procview.ARLookup(Graphics.RadarScreen.Procview.ARLookup(:,1) == ind,5);
    Graphics.RadarScreen.AirRoute(Plotid).Line.Color = [0.8 0.8 0.8];
    Graphics.RadarScreen.AirRoute(Plotid).Line.LineWidth = 1;
    
    Graphics.RadarScreen.AirRoute(Plotid).Name.Color = [0.8 0.8 0.8];
    Graphics.RadarScreen.AirRoute(Plotid).Name.FontSize = 7;
    Graphics.RadarScreen.Procview.ARLookup(Plotid,4) = val;
else
    Plotid = Graphics.RadarScreen.Procview.ARLookup(Graphics.RadarScreen.Procview.ARLookup(:,1) == ind,5);
    Graphics.RadarScreen.AirRoute(Plotid).Line.Color = [0.7 0.7 0.2];
    Graphics.RadarScreen.AirRoute(Plotid).Line.LineWidth = 0.5;
    
    Graphics.RadarScreen.AirRoute(Plotid).Name.Color = [0.7 0.7 0.2];
    Graphics.RadarScreen.AirRoute(Plotid).Name.FontSize = 6;
    Graphics.RadarScreen.Procview.ARLookup(Plotid,4) = val;
end

end

function CamLocCallback(hObject, eventdata, handles)
global Graphics Aerodrome Airspace config
    contents = cellstr(get(hObject,'String'));
   
    if ~isempty(find(strcmp({Aerodrome.ID}, contents{get(hObject,'Value')}), 1))
        TargetLoc = [Aerodrome(strcmp({Aerodrome.ID}, contents{get(hObject,'Value')})).Long ; Aerodrome(strcmp({Aerodrome.ID}, contents{get(hObject,'Value')})).Lat];
%     elseif ~isempty(find(strcmp({Airspace.ATS.ID}, contents{get(hObject,'Value')}), 1))
%         TargetLoc = [Airspace.ATS(strcmp({Airspace.ATS.ID}.Long, contents{get(hObject,'Value')})).Long ; Airspace.ATS(strcmp({Airspace.ATS.ID}.Long, contents{get(hObject,'Value')})).Lat];
    else
        TargetLoc = config.InitCamPoint;
    end
    
    
    XMean = (Graphics.RadarScreen.radaraxis.XLim(1) + Graphics.RadarScreen.radaraxis.XLim(2)) / 2;
    YMean = (Graphics.RadarScreen.radaraxis.YLim(1) + Graphics.RadarScreen.radaraxis.YLim(2)) / 2;
    
    XDiff = TargetLoc(1) - XMean;
    YDiff = TargetLoc(2) - YMean;
    
    Graphics.RadarScreen.radaraxis.XLim = Graphics.RadarScreen.radaraxis.XLim + XDiff;
    Graphics.RadarScreen.radaraxis.YLim = Graphics.RadarScreen.radaraxis.YLim + YDiff;
    
end

function apply_command(command_line)
global plan Command Graphics

Loglen = Command.input{end,1};

Command.input(Loglen + 1, 1) = num2cell(Loglen + 1);
Command.input(Loglen + 1, 2) = cellstr(datestr(datetime('now')));        
Command.input(Loglen + 1, 3) = cellstr(['/' plan(Graphics.RadarScreen.Target.NewID).callsign ' ' command_line]);
   
Command.new = [Command.new ; Loglen + 1];

currString = cellstr(get(Graphics.MainWindow.Display,'String'));
currString = flip(currString);
if iscell(currString)
    currString{end+1}=sprintf(' [ %d ]    [ %s ]    " %s "', Command.input{Loglen + 1,1}, Command.input{Loglen + 1,2}, Command.input{Loglen + 1,3});
else
    currString = [currString sprintf('\n') sprintf(' [ %d ]    [ %s ]    " %s "', Command.input{Loglen + 1,1}, Command.input{Loglen + 1,2}, Command.input{Loglen + 1,3})];
end
currString = flip(currString);
set(Graphics.MainWindow.Display,'String',currString);
     

end
