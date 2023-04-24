% Radar
function [Graphics] = InitializeRadar(flight, Map, RunTime)

global config plan Airspace Aerodrome Procedure Command

StatusLookUp = {'Queued' ; 'Airborne' ; 'Arrived' ; 'Deleted' ; 'Paused'};

% clear Graphics
% Graphics = struct;

% Graphics.MainWindow.tab_radar = 
Graphics.radarscreen = RadarGUI;

% pos = get(0, 'ScreenSize');
% Graphics.radarscreen.Visible = 'off';

Graphics.radarscreen.Name = 'Radar Screen';
Graphics.radarscreen.Units = 'normalized';
Graphics.radarscreen.OuterPosition = [0 0.05 1 0.95]; % Taskbar is visible

Graphics.radarscreen.UserData = [1 ; 1];
Graphics.radaraxis = gca;

hold on
grid on
Graphics.radaraxis.Color = [0.15 0.15 0.25];
Graphics.radaraxis.DataAspectRatio = [1 1 40000];
% radaraxis.PlotBoxAspectRatio = [1 1 40000];
Graphics.radaraxis.Position = [0 0.05 1 0.95];

Graphics.radaraxis.ActivePositionProperty = 'position';

% ratio: 16:9 로 메뉴얼 입력
Graphics.radaraxis.XLim = [118 146];
% radaraxis.XAxisLocation = 'top';
Graphics.radaraxis.YLim = [28 41];
% radaraxis.XColor = [1 1 1];
% radaraxis.YColor = [1 1 1];
Graphics.radaraxis.GridColor = [0.5 0.5 0.5];
Graphics.radaraxis.Layer = 'top';
% axis vis3d


load coast

for Region = 1:length(config.Map)
    if strcmp(config.Map{Region}, 'Korea')
        newlong = [long(1:6073)', fliplr(Map.Korea.Segment(2).long), long(6093:end)'];
        newlat = [lat(1:6073)', fliplr(Map.Korea.Segment(2).lat), lat(6093:end)'];
        
        % simple world map
        plot(newlong, newlat, 'Color', [0.4 0.4 0.4]);
    end
    
    %126.1 37.75 -- 128.3 38.67
    % 6073 6093
    
    if config.RadarCL
        try
            for Segment = 1:length(Map.(config.Map{Region}).Segment)
                fill(Map.(config.Map{Region}).Segment(Segment).long(:), Map.(config.Map{Region}).Segment(Segment).lat(:), [0.4 0.4 0.4], 'LineStyle', 'none')
            end
        end
    end
    
    if config.RadarWP
        for WPMark = 1:length(Airspace.Waypoint)
%             try
                switch Airspace.Waypoint(WPMark).Type
                    case 'Waypoint'
                        if Airspace.Waypoint(WPMark).display && strcmp(config.Map{Region}, Airspace.Waypoint(WPMark).Nationality)
                            plot(Airspace.Waypoint(WPMark).Long(:), Airspace.Waypoint(WPMark).Lat(:), 'LineStyle', 'none', 'Marker', '^', 'MarkerEdgeColor', [0.7 0.7 0.7], 'MarkerSize', 4)
                            text(Airspace.Waypoint(WPMark).Long(:), Airspace.Waypoint(WPMark).Lat(:),sprintf(['\n ' Airspace.Waypoint(WPMark).Name]), 'Color', [0.7 0.7 0.7], 'FontSize', 5, 'HorizontalAlignment', 'center');
                        end
                end
%             end
        end
    end
    
    if config.RadarAR
        LongHist = 0;
        LatHist = 0;
        for ARMark = 1:length(Airspace.route)
%             try
            if or(strcmp(Airspace.route(ARMark).nationality, 'International'), strcmp(Airspace.route(ARMark).nationality, config.Map{Region}))
                plot([Airspace.route(ARMark).trajectory.WP_long], [Airspace.route(ARMark).trajectory.WP_lat], 'Color', [0.7 0.7 0.2], 'LineWidth', 0.5);
                for TrajLen = 1:length(Airspace.route(ARMark).trajectory)
                    TextLoc = 1;
                    Loc = 1;
                    if length(Airspace.route(ARMark).trajectory) < TextLoc + 2
                        break
                    else
                        TextLoc = TextLoc + 1;
                        Loc = [Loc TextLoc];
                    end
                end
                for LocLen = 1:length(Loc)
                    cor = 0;
                    TextLong = Airspace.route(ARMark).trajectory(Loc(LocLen)).WP_long * (0.5 + cor) + Airspace.route(ARMark).trajectory(Loc(LocLen) + 1).WP_long * (0.5 - cor);
                    TextLat = Airspace.route(ARMark).trajectory(Loc(LocLen)).WP_lat * (0.5 + cor) + Airspace.route(ARMark).trajectory(Loc(LocLen) + 1).WP_lat * (0.5 - cor);
                    
                    
                    LongMatch = (LongHist == TextLong);
                    LatMatch = (LatHist .* LongMatch == TextLat);
                    
                    if any(LatMatch)
                        if cor >= 0.8
                            cor = cor - 0.8;
                        else
                            cor = cor + 0.2;
                        end
                    else
                        LongHist = [LongHist TextLong];
                        LatHist = [LatHist TextLat];
                    end
                    
                    text(Airspace.route(ARMark).trajectory(Loc(LocLen)).WP_long * (0.5 + cor) + Airspace.route(ARMark).trajectory(Loc(LocLen) + 1).WP_long * (0.5 - cor), Airspace.route(ARMark).trajectory(Loc(LocLen)).WP_lat * (0.5 + cor) + Airspace.route(ARMark).trajectory(Loc(LocLen) + 1).WP_lat * (0.5 - cor), sprintf(['\n ' Airspace.route(ARMark).name]), 'Color', [0.7 0.7 0.2], 'FontSize', 6, 'HorizontalAlignment', 'center');
                    
                end
            end
        end
%     end
    end
    
    if config.RadarAS
        for ASMark = 1:length(Airspace.ATS)
%             try
            
            if strcmp(Airspace.ATS(ASMark).Nationality, config.Map{Region})
                
                SectorLength = Airspace.ATS(ASMark).Boundary(end).Sector;
                
                for SectorLen = 1:SectorLength
                    SectorStart = find([Airspace.ATS(ASMark).Boundary.Sector] == SectorLen, 1);
                    SectorEnd = find([Airspace.ATS(ASMark).Boundary.Sector] == SectorLen, 1, 'last');
                    
                    for SectorRow = SectorStart:SectorEnd - 1
                        plot([Airspace.ATS(ASMark).Boundary(SectorRow).Long ; Airspace.ATS(ASMark).Boundary(SectorRow + 1).Long], [Airspace.ATS(ASMark).Boundary(SectorRow).Lat ; Airspace.ATS(ASMark).Boundary(SectorRow + 1).Lat], '-', 'Color', [0.8 0.4 0.8]);
                        plot([Airspace.ATS(ASMark).Boundary(SectorRow).Long ; Airspace.ATS(ASMark).Boundary(SectorRow + 1).Long], [Airspace.ATS(ASMark).Boundary(SectorRow).Lat ; Airspace.ATS(ASMark).Boundary(SectorRow + 1).Lat], '-', 'Color', [0.8 0.4 0.8]);
                        plot([Airspace.ATS(ASMark).Boundary(SectorRow).Long ; Airspace.ATS(ASMark).Boundary(SectorRow).Long], [Airspace.ATS(ASMark).Boundary(SectorRow).Lat ; Airspace.ATS(ASMark).Boundary(SectorRow).Lat], '-', 'Color', [0.8 0.4 0.8]);
                    end
                    
                    plot([Airspace.ATS(ASMark).Boundary(SectorEnd).Long ; Airspace.ATS(ASMark).Boundary(SectorStart).Long], [Airspace.ATS(ASMark).Boundary(SectorEnd).Lat ; Airspace.ATS(ASMark).Boundary(SectorStart).Lat], '-', 'Color', [0.8 0.4 0.8]);
                    plot([Airspace.ATS(ASMark).Boundary(SectorEnd).Long ; Airspace.ATS(ASMark).Boundary(SectorStart).Long], [Airspace.ATS(ASMark).Boundary(SectorEnd).Lat ; Airspace.ATS(ASMark).Boundary(SectorStart).Lat], '-', 'Color', [0.8 0.4 0.8]);
                    
                    text((Airspace.ATS(ASMark).Boundary(SectorStart).Long + Airspace.ATS(ASMark).Boundary(SectorStart + 1).Long) / 2, (Airspace.ATS(ASMark).Boundary(SectorStart).Lat + Airspace.ATS(ASMark).Boundary(SectorStart + 1).Lat) / 2, sprintf(['\n ' Airspace.ATS(ASMark).Name '_' num2str(Airspace.ATS(ASMark).Boundary(SectorStart).SectorName)]), 'Color', [0.8 0.4 0.8], 'FontSize', 6, 'HorizontalAlignment', 'center', 'Interpreter','none');
                    
                    
                end
            end
%         end
        end
    end
    
    
    if config.RadarAD
        for ADMark = 1:length(Aerodrome)
%             try
            if strcmp(Aerodrome(ADMark).Nationality, config.Map{Region})
                
                scatter(Aerodrome(ADMark).Long, Aerodrome(ADMark).Lat, 40, 's', 'MarkerEdgeColor', [0.4 0.48 0.8], 'MarkerFaceColor', [0.4 0.48 0.8], 'LineWidth', 2)
                text(Aerodrome(ADMark).Long, Aerodrome(ADMark).Lat - nm2deg(2.5), ['\bf ' Aerodrome(ADMark).ID], 'Color', [0.4 0.48 0.8], 'FontSize', 8, 'HorizontalAlignment', 'center');
                
                % Aerodrome Distance Marker
                th = 0:pi/50:2*pi;
                ln = 0;
                
                switch Aerodrome(ADMark).Size
                    case 'Large'
                        rend = 20;
                    case 'Medium'
                        rend = 10;
                    case 'Small'
                        rend = 5;
                end
                
                for r = 5:5:rend
                    xunit = nm2deg(r) * cos(th) + Aerodrome(ADMark).Long;
                    yunit = nm2deg(r) * sin(th) + Aerodrome(ADMark).Lat;
                    ln = ~ln;
                    if ln
                        plot(xunit, yunit, 'LineStyle', '--', 'Color', [0.4 0.48 0.8]);
                    else
                        plot(xunit, yunit, 'LineStyle', '-', 'Color', [0.4 0.48 0.8]);
                    end
                end
                
                for RWYMark = 1:length(Aerodrome(ADMark).RWY)
                    plot([Aerodrome(ADMark).RWY(RWYMark).THRlong Aerodrome(ADMark).RWY(RWYMark).ENDlong], [Aerodrome(ADMark).RWY(RWYMark).THRlat Aerodrome(ADMark).RWY(RWYMark).ENDlat], 'Color', [0.3, 0.3, 0.3], 'LineStyle', '-', 'LineWidth', 2)
                end
            end
%         end
        end
        
    end
    
end

% radarposition = line;
for i = 1:length(flight)
    Graphics.radartrail(flight(i).id) = plot([flight(i).long : flight(i).long], [flight(i).lat : flight(i).lat], 'LineStyle', ':', 'Color', [0.6 0.6 0.6], 'LineWidth', 1.5);
    Graphics.radarposition(flight(i).id) = plot(flight(i).long, flight(i).lat, 'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', [0.6 0.6 0.6], 'MarkerSize', 5, 'LineWidth', 1.5);
    Graphics.datablock(flight(i).id) = text(flight(i).long, flight(i).lat, sprintf(['\n   ']), 'Color', [0.25 0.9 0.55], 'FontSize', 6, 'HorizontalAlignment', 'left');
    Graphics.trailfix(i).long = -1;
    Graphics.trailfix(i).lat = -1;
    Graphics.trailfix(i).count = config.TrailInterval;
end


% text
if config.AutoRadarUpdate
    RadarOpt = 'Auto';
else
    RadarOpt = ['Manual (' num2str(config.ManualRadarUpdate * config.update, '%2.2f') ' sec)'];
end
Graphics.Timer = text(0.05, 0.95, ['\bf Runtime: ' '\rm / seconds' sprintf('\n') '\bf 0' '\rm Aircrafts'], 'Color', [1.0 1.0 1.0], 'FontSize', 8, 'Units', 'normalized', 'VerticalAlignment', 'top');
Graphics.GlobalData = text(0.05, 0.90, ...
    ['\bf Simulation Configuration' sprintf('\n') ...
    '\bf Scenario: ' '\rm ' config.Scenario sprintf('\n') ...
    '\bf Simulation Update Time: ' '\rm ' num2str(config.update, '%2.2f') ' sec' sprintf('\n') ...
    '\bf Trajectory Resolution: ' '\rm ' num2str(config.TrajRes, '%2.2f') ' sec' sprintf('\n') ...
    '\bf Radar Update: ' '\rm ' RadarOpt sprintf('\n')], ...
    'Color', [1.0 1.0 1.0], 'FontSize', 8, 'Units', 'normalized', 'VerticalAlignment', 'top');


Graphics.DisplayData = text(0.05, 0.05, ['\bf Target: ' '\rm callsign' sprintf('\n') ], 'Color', [1.0 1.0 1.0], 'FontSize', 8, 'Units', 'normalized', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
Graphics.DisplayData.UserData = 1;
Graphics.Trajectory.Line = plot(flight(Graphics.DisplayData.UserData).Reference(2,:), flight(Graphics.DisplayData.UserData).Reference(3,:), 'Color', [0.8 0.8 0.8], 'Linestyle', '-', 'LineWidth', 1);

Graphics.Trajectory.From = plot(flight(Graphics.DisplayData.UserData).Reference(2, flight(Graphics.DisplayData.UserData).ReferenceFrom), flight(Graphics.DisplayData.UserData).Reference(3, flight(Graphics.DisplayData.UserData).ReferenceFrom), 'LineStyle', 'none', 'Marker', 'x', 'MarkerEdgeColor', [0.7 0.5 0.5], 'MarkerSize', 5);
Graphics.Trajectory.To = plot(flight(Graphics.DisplayData.UserData).Reference(2, flight(Graphics.DisplayData.UserData).ReferenceTo), flight(Graphics.DisplayData.UserData).Reference(3, flight(Graphics.DisplayData.UserData).ReferenceTo), 'LineStyle', 'none', 'Marker', 'd', 'MarkerEdgeColor', [0.5 0.5 0.7], 'MarkerSize', 5);
Graphics.Trajectory.Sch = plot(flight(Graphics.DisplayData.UserData).long_sc, flight(Graphics.DisplayData.UserData).lat_sc, 'LineStyle', 'none', 'Marker', 's', 'MarkerEdgeColor', [0.5 0.7 0.5], 'MarkerSize', 5);

Graphics.radarscreen.Visible = 'on';


Graphics.RadarList.Object = findobj(Graphics.radarscreen, 'Tag', 'RadarList');
Graphics.Command.Input = findobj(Graphics.radarscreen, 'Tag', 'CommandIn');
Graphics.Command.Display = findobj(Graphics.radarscreen, 'Tag', 'CommandLog');


Graphics.Button.Play = findobj(Graphics.radarscreen, 'Tag', 'PlayBTN');
Graphics.Button.Pause = findobj(Graphics.radarscreen, 'Tag', 'PauseBTN');
Graphics.Button.Stop = findobj(Graphics.radarscreen, 'Tag', 'StopBTN');

Graphics.Button.List = findobj(Graphics.radarscreen, 'Tag', 'ListButton');
Graphics.Button.Command = findobj(Graphics.radarscreen, 'Tag', 'CommandButton');

Graphics.TargetList = findobj(Graphics.radarscreen, 'Tag', 'TargetAC');

Graphics.RealTimeMode = findobj(Graphics.radarscreen, 'Tag', 'Realtime');
Graphics.UpdateDisplay = findobj(Graphics.radarscreen, 'Tag', 'update');


Graphics.Command.Input.Visible = 'on';
Graphics.Command.Display.Visible = 'on';

Graphics.RadarList.Data = cell(length(flight), 3);
Graphics.RadarList.Data(:,1) = num2cell([flight.id]');
Graphics.RadarList.Data(:,2) = {flight.callsign}';

for FLlen = 1:length(flight)
    
    
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
    
    clr = dec2hex(round(c * 255),2)'; clr = ['#';clr(:)]';
    Graphics.RadarList.Data(FLlen,3) = strcat(['<html><body bgcolor="' clr '" >'], StatusLookUp(flight(FLlen).status));
    
    Graphics.RadarList.Data(FLlen,4) = num2cell(0);
    Graphics.RadarList.Data(FLlen,5) = num2cell(round(flight(FLlen).gentime + flight(FLlen).Reference(6,end)));
    Graphics.RadarList.Data(FLlen,6) = num2cell(0);
    Graphics.RadarList.Data(FLlen,7) = num2cell(0);
%     
%     
%     Graphics.RadarList.Data(FLlen,3) = StatusLookUp(flight(FLlen).status);
end

Graphics.RadarList.Data(:,4) = num2cell([flight.gentime]');



headers = {'ID', ...
           '<html><center>Callsign</center></html>', ...
           '<html><center>Status</center></html>', ...
           '<html><center>TOT<br />(sec)</center></html>', ...
           '<html><center>ELDT<br />(sec)</center></html>', ...
           '<html><center>ALDT<br />(sec)</center></html>', ...
           '<html><center>LDT<br />diff</center></html>' ...
           };

Graphics.RadarList.Object.ColumnName = headers;
% Graphics.RadarList.Object.ColumnWidth = {1 4 1 1};
% Graphics.RadarList.Object.FontSize = 7;

Graphics.RadarList.Object.UserData = config.InitialTarget;

Graphics.RadarList.Data = sortrows(Graphics.RadarList.Data, 4);
Graphics.RadarList.javaobj = findjobj(Graphics.RadarList.Object);
% Graphics.RadarList.PositionOfScroll = Graphics.RadarList.javaobj.getVerticalScrollBar.getValue;
jTable = Graphics.RadarList.javaobj.getViewport.getView;
jTable.setAutoResizeMode(jTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

set(Graphics.RadarList.Object, 'CellSelectionCallback', {@RadarDataBlockCallback, flight, RunTime});

Graphics.RadarList.Object.Units = 'normalized';
Graphics.RadarList.Object.Position = [0.75, 0, 0.25, 1];

Graphics.RadarList.Object.Units = 'points';
widthcorr = Graphics.RadarList.Object.Position(3) - config.ListWidth;
Graphics.RadarList.Object.Position(1) = Graphics.RadarList.Object.Position(1) + widthcorr;
Graphics.RadarList.Object.Position(3) = config.ListWidth;

Graphics.RadarList.Object.ColumnWidth = {50 100 100 'auto' 'auto' 'auto' 'auto'};


Obj = {'PlayBTN';'PauseBTN';'StopBTN';'ListButton';'CommandButton';'TargetAC'};

for ObjList = 1:length(Obj)

    Graphics.Button.(Obj{ObjList}).Units = 'points';
    Graphics.Button.(Obj{ObjList}).Position(4) = 14.25;
    
    if ObjList <= 3
        Graphics.Button.(Obj{ObjList}).Position(3) = 28.5;
    else
        Graphics.Button.(Obj{ObjList}).Position(3) = 65.5;
    end
    
    Graphics.Button.(Obj{ObjList}).Units = 'normalized';
    Graphics.Button.(Obj{ObjList}).Position(2) = 0.95;
end


Graphics.TargetAC = findobj(Graphics.radarscreen, 'Tag', 'TargetAC');
Graphics.TargetAC.String = {flight.callsign};

Graphics.TargetAC.Value = config.InitialTarget;

set(Graphics.TargetAC, 'Callback', {@RadarDataBlockCallback, flight, RunTime});


Graphics.Command.Display.String = sprintf(' [ %d ]    [ %s ]    " %s "', Command.input{1,1}, Command.input{1,2}, Command.input{1,3});

if config.timer ~= 0
    Graphics.RealTimeMode.Value = 1;
else
    Graphics.RealTimeMode.Value = 0;
end
Graphics.UpdateDisplay.String = strcat('x ', num2str(config.update, '%1.1f')); 

end