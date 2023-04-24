% Radar
function [Graphics] = InitializeRadar(Graphics, Map)

global config Airspace Aerodrome Procedure

% Center Point

% clear Graphics
% Graphics = struct;

% Graphics.MainWindow.tab_radar = RadarGUI;
% Graphics.radarscreen = RadarGUI;
% Graphics.radarscreen = figure('Parent', Graphics.MainWindow.tab_radar, 'Visible' , 'off');
% pos = get(0, 'ScreenSize');
% Graphics.radarscreen.Visible = 'off';
% 
% Graphics.radarscreen.Name = 'Radar Screen';
% Graphics.radarscreen.Units = 'normalized';
% Graphics.radarscreen.OuterPosition = [0 0.05 1 0.95]; % Taskbar is visible
% 
% Graphics.radarscreen.UserData = [1 ; 1];
Graphics.RadarScreen.radaraxis = axes;
Graphics.RadarScreen.radaraxis.Parent = Graphics.MainWindow.tab_radar;

hold on
grid on
% Graphics.RadarScreen.radaraxis.BoxStyle = 'full';
Graphics.RadarScreen.radaraxis.Color = Graphics.Options.Color.Radar.BackGround;
% Graphics.RadarScreen.radaraxis.Layer = 'top';
Graphics.RadarScreen.radaraxis.Position = [Graphics.MainWindow.tab_radar.Position(3) * -1 ; Graphics.MainWindow.tab_radar.Position(4) * -1 ; Graphics.MainWindow.tab_radar.Position(3) * 3 ; Graphics.MainWindow.tab_radar.Position(4) * 3];
% Graphics.RadarScreen.radaraxis.CameraTarget = [38 126 0];
Graphics.RadarScreen.radaraxis.ActivePositionProperty = 'Position';
% Graphics.RadarScreen.radaraxis.Clipping = 'on';
% Graphics.RadarScreen.radaraxis.ClippingStyle = 'rectangle';
Graphics.RadarScreen.radaraxis.DataAspectRatio = [1 ; 1 ; 40000];
Graphics.RadarScreen.radaraxis.PlotBoxAspectRatio = [1 ; 1 ; 1];
% Graphics.RadarScreen.radaraxis.PlotBoxAspectRatioMode = 'auto';
Graphics.RadarScreen.radaraxis.DataAspectRatioMode = 'manual';
Graphics.RadarScreen.radaraxis.CameraTargetMode = 'auto';
Graphics.RadarScreen.radaraxis.CameraViewAngleMode = 'manual';
% Graphics.RadarScreen.radaraxis.CameraPosition = [0 0 40000];
% Graphics.RadarScreen.radaraxis.CameraPositionMode = 'manual';

% ratio: 16:9 로 메뉴얼 입력
% zoom(10);
Graphics.MainWindow.tab_radar.Units = 'pixels';
screenrate = Graphics.MainWindow.tab_radar.Position(4)/Graphics.MainWindow.tab_radar.Position(3);
Graphics.RadarScreen.radaraxis.XLim = [config.InitCamPoint(1) - config.InitCamMag ; config.InitCamPoint(1) + config.InitCamMag];
Graphics.RadarScreen.radaraxis.YLim = [config.InitCamPoint(2) - (screenrate * config.InitCamMag) ; config.InitCamPoint(2) + (screenrate * config.InitCamMag)];
Graphics.RadarScreen.radaraxis.XLimMode = 'manual';
Graphics.RadarScreen.radaraxis.YLimMode = 'manual';

Graphics.MainWindow.tab_radar.Units = 'normalized';


% Graphics.RadarScreen.radaraxis.CameraTargetMode = 'manual';
% Graphics.RadarScreen.radaraxis.CameraViewAngleMode = 'auto';
% Graphics.RadarScreen.radaraxis.CameraPositionMode = 'manual';
% Graphic.
% axis([112 142 28 41])
% radaraxis.XColor = [1 1 1];
% radaraxis.YColor = [1 1 1];
Graphics.RadarScreen.radaraxis.GridColor = Graphics.Options.Color.Radar.GridLine;
Graphics.RadarScreen.radaraxis.Layer = 'top';
% axis vis3d


load coast

WPlist = {};

for Region = 1:length(config.Map)
    

    
    if strcmp(config.Map{Region}, 'Japan')
        long(7305:7507) = [];
        lat(7305:7507) = [];    
    end
    % Japan
    % 7305 - 7507
    
    
    if strcmp(config.Map{Region}, 'Korea')
        newlong = [long(1:6073)', fliplr(Map.Korea.Segment(2).lon), long(6093:end)'];
        newlat = [lat(1:6073)', fliplr(Map.Korea.Segment(2).lat), lat(6093:end)'];
            
    % South Korea
    %126.1 37.75 -- 128.3 38.67
    % 6073 6093
        
    
    % simple world map
    Graphics.RadarScreen.Coastline(Region) = plot(newlong, newlat, 'Color', Graphics.Options.Color.Radar.LandColor);

    end

    
    
    
    if config.RadarCL
        try
            for Segment = 1:length(Map.(config.Map{Region}).Segment)
                Graphics.RadarScreen.Land(Segment) = fill(Map.(config.Map{Region}).Segment(Segment).lon(:), Map.(config.Map{Region}).Segment(Segment).lat(:), Graphics.Options.Color.Radar.LandColor, 'LineStyle', 'none');
            end
        end
    end
    
    if config.RadarWP
        for WPMark = 1:length(Airspace.Waypoint)
%             try
                switch Airspace.Waypoint(WPMark).Type
                    case 'Waypoint'
                        if Airspace.Waypoint(WPMark).display && strcmp(config.Map{Region}, Airspace.Waypoint(WPMark).Nationality)
                            Graphics.RadarScreen.Waypoint(WPMark).Marker = plot(Airspace.Waypoint(WPMark).Long(:), Airspace.Waypoint(WPMark).Lat(:), 'LineStyle', 'none', 'Marker', Graphics.Options.Markerstyle.Radar.Waypoint, 'MarkerEdgeColor', Graphics.Options.Color.Radar.Waypoint, 'MarkerSize', Graphics.Options.Markersize.Radar.Waypoint);
                            Graphics.RadarScreen.Waypoint(WPMark).Name = text(Airspace.Waypoint(WPMark).Long(:), Airspace.Waypoint(WPMark).Lat(:),sprintf(['\n ' Airspace.Waypoint(WPMark).Name]), 'Color', Graphics.Options.Color.Radar.Waypoint, 'FontSize', Graphics.Options.Fontsize.Radar.Waypoint, 'HorizontalAlignment', 'center');
                            WPlist(end + 1) = cellstr(Airspace.Waypoint(WPMark).Name);
                        end
                end
%             end
        end
    end
    
    

    
    if config.RadarAR
        Graphics.RadarScreen.Procedure.AirRoute.NationalList.String(end + 1) = cellstr(config.Map{Region});

        LongHist = 0;
        LatHist = 0;
        Graphics.RadarScreen.Procview.ARLookup = [];
        Graphics.RadarScreen.Procview.ARTable = {};
        for ARMark = 1:length(Airspace.route)
%             try

            if or(strcmp(Airspace.route(ARMark).nationality, 'International'), any(strcmp(Airspace.route(ARMark).nationality, config.Map)))
                Graphics.RadarScreen.AirRoute(ARMark).Line = plot([Airspace.route(ARMark).trajectory.WP_long], [Airspace.route(ARMark).trajectory.WP_lat], 'Color', Graphics.Options.Color.Radar.Airroute, 'LineWidth', Graphics.Options.Linewidth.Radar.Airroute);
                Graphics.RadarScreen.Procview.ARLookup(end+1,1) = Airspace.route(ARMark).id; % ID
                Graphics.RadarScreen.Procview.ARLookup(end,2) = 1; % Loaded
                Graphics.RadarScreen.Procview.ARLookup(end,3) = 1; % Filter
                Graphics.RadarScreen.Procview.ARLookup(end,4) = 0; % Highlight
                Graphics.RadarScreen.Procview.ARLookup(end,5) = ARMark; % Plot line id
                
                
                Graphics.RadarScreen.Procview.ARTable(end + 1,1) = {Airspace.route(ARMark).id};
                Graphics.RadarScreen.Procview.ARTable(end,2) = cellstr(Airspace.route(ARMark).name);
                Graphics.RadarScreen.Procview.ARTable(end,3) = cellstr(Airspace.route(ARMark).nationality);
                Graphics.RadarScreen.Procview.ARTable(end,4) = {false};


                
                
                for TrajLen = 1:length(Airspace.route(ARMark).trajectory)
                    TextLoc = 1;
                    Loc = 1;
                    if length(Airspace.route(ARMark).trajectory) < TextLoc + 3
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
                    
                    Graphics.RadarScreen.AirRoute(ARMark).Name = text(Airspace.route(ARMark).trajectory(Loc(LocLen)).WP_long * (0.5 + cor) + Airspace.route(ARMark).trajectory(Loc(LocLen) + 1).WP_long * (0.5 - cor), Airspace.route(ARMark).trajectory(Loc(LocLen)).WP_lat * (0.5 + cor) + Airspace.route(ARMark).trajectory(Loc(LocLen) + 1).WP_lat * (0.5 - cor), sprintf(['\n ' Airspace.route(ARMark).name]), 'Color', Graphics.Options.Color.Radar.Airroute, 'FontSize', Graphics.Options.Fontsize.Radar.Airroute, 'HorizontalAlignment', 'center');
                    
                end
            end
        end
        
        
        Graphics.RadarScreen.Procedure.AirRoute.Table.Data = Graphics.RadarScreen.Procview.ARTable;

%     end
    end
    
    if config.RadarAS
        for ASMark = 1:length(Airspace.ATS)
%             try
            switch Airspace.ATS(ASMark).Class
                case 'TMA'
                    ATScolor = Graphics.Options.Color.Radar.TMA;
                case 'FIR'
                    ATScolor = Graphics.Options.Color.Radar.FIR;
                otherwise
                    ATScolor = Graphics.Options.Color.Radar.OtherAirspace;
            end
            if strcmp(Airspace.ATS(ASMark).Nationality, config.Map{Region})
                
                SectorLength = Airspace.ATS(ASMark).Boundary(end).Sector;
%                 Graphics.RadarScreen.CamTarget.String{end + 1} = Airspace.ATS(ASMark).ID;

%                 SectorNameFlag = 0;
                for SectorLen = 1:SectorLength
%                     SectorStart = find([Airspace.ATS(ASMark).Boundary.Sector] == SectorLen, 1);
%                     SectorEnd = find([Airspace.ATS(ASMark).Boundary.Sector] == SectorLen, 1, 'last');

                    
                    SectorLong = [Airspace.ATS(ASMark).Boundary([Airspace.ATS(ASMark).Boundary.Sector] == SectorLen).Long Airspace.ATS(ASMark).Boundary(find([Airspace.ATS(ASMark).Boundary.Sector] == SectorLen, 1)).Long];
                    SectorLat = [Airspace.ATS(ASMark).Boundary([Airspace.ATS(ASMark).Boundary.Sector] == SectorLen).Lat Airspace.ATS(ASMark).Boundary(find([Airspace.ATS(ASMark).Boundary.Sector] == SectorLen, 1)).Lat];
                    Graphics.RadarScreen.Airspace(ASMark).Block(SectorLen) = plot(SectorLong(:), SectorLat(:), '-', 'Color', ATScolor);
%                     for SectorRow = SectorStart:SectorEnd - 1
%                         
%                         plot([Airspace.ATS(ASMark).Boundary(SectorRow).Long ; Airspace.ATS(ASMark).Boundary(SectorRow + 1).Long], [Airspace.ATS(ASMark).Boundary(SectorRow).Lat ; Airspace.ATS(ASMark).Boundary(SectorRow + 1).Lat], '-', 'Color', [0.8 0.4 0.8]);
%                         plot([Airspace.ATS(ASMark).Boundary(SectorRow).Long ; Airspace.ATS(ASMark).Boundary(SectorRow + 1).Long], [Airspace.ATS(ASMark).Boundary(SectorRow).Lat ; Airspace.ATS(ASMark).Boundary(SectorRow + 1).Lat], '-', 'Color', [0.8 0.4 0.8]);
%                         plot([Airspace.ATS(ASMark).Boundary(SectorRow).Long ; Airspace.ATS(ASMark).Boundary(SectorRow).Long], [Airspace.ATS(ASMark).Boundary(SectorRow).Lat ; Airspace.ATS(ASMark).Boundary(SectorRow).Lat], '-', 'Color', [0.8 0.4 0.8]);
%                     end
                    
%                     plot([Airspace.ATS(ASMark).Boundary(SectorEnd).Long ; Airspace.ATS(ASMark).Boundary(SectorStart).Long], [Airspace.ATS(ASMark).Boundary(SectorEnd).Lat ; Airspace.ATS(ASMark).Boundary(SectorStart).Lat], '-', 'Color', [0.8 0.4 0.8]);
%                     plot([Airspace.ATS(ASMark).Boundary(SectorEnd).Long ; Airspace.ATS(ASMark).Boundary(SectorStart).Long], [Airspace.ATS(ASMark).Boundary(SectorEnd).Lat ; Airspace.ATS(ASMark).Boundary(SectorStart).Lat], '-', 'Color', [0.8 0.4 0.8]);
%                     if ~SectorNameFlag
                        Graphics.RadarScreen.Airspace(ASMark).Name(SectorLen) = text((SectorLong(1) + SectorLong(2)) / 2, (SectorLat(1) + SectorLat(2)) / 2, sprintf(['\n ' Airspace.ATS(ASMark).Name '_' num2str(Airspace.ATS(ASMark).Boundary(find([Airspace.ATS(ASMark).Boundary.Sector] == SectorLen, 1)).SectorName)]), 'Color', ATScolor, 'FontSize', Graphics.Options.Fontsize.Radar.ATSSector, 'HorizontalAlignment', 'center', 'Interpreter','none');
%                         SectorNameFlag = 1;
%                     end
%                     text((Airspace.ATS(ASMark).Boundary(SectorStart).Long + Airspace.ATS(ASMark).Boundary(SectorStart + 1).Long) / 2, (Airspace.ATS(ASMark).Boundary(SectorStart).Lat + Airspace.ATS(ASMark).Boundary(SectorStart + 1).Lat) / 2, sprintf(['\n ' Airspace.ATS(ASMark).Name '_' num2str(Airspace.ATS(ASMark).Boundary(SectorStart).SectorName)]), 'Color', [0.8 0.4 0.8], 'FontSize', 6, 'HorizontalAlignment', 'center', 'Interpreter','none');

                    
                end
            end
%         end
        end
    end
    
    
    if config.RadarAD
        for ADMark = 1:length(Aerodrome)
%             try
            if strcmp(Aerodrome(ADMark).Nationality, config.Map{Region})
                
                Graphics.RadarScreen.Aerodrome(ADMark).Marker = scatter(Aerodrome(ADMark).Long, Aerodrome(ADMark).Lat, 40, Graphics.Options.Markerstyle.Radar.Aerodrome, 'MarkerEdgeColor', Graphics.Options.Color.Radar.Aerodrome, 'MarkerFaceColor', Graphics.Options.Color.Radar.Aerodrome, 'LineWidth', Graphics.Options.Linewidth.Radar.AerodromeMarker);
                Graphics.RadarScreen.Aerodrome(ADMark).Name = text(Aerodrome(ADMark).Long, Aerodrome(ADMark).Lat - nm2deg(2.5), ['\bf ' Aerodrome(ADMark).ID], 'Color', Graphics.Options.Color.Radar.Aerodrome, 'FontSize', Graphics.Options.Fontsize.Radar.Aerodrome, 'HorizontalAlignment', 'center');
                
                % Aerodrome Distance Marker
                th = 0:pi/50:2*pi;
                ln = 0;
                
                switch Aerodrome(ADMark).Size
                    case 'Large'
                        rend = Graphics.Options.ADCircle.Radius.Large;
                    case 'Medium'
                        rend = Graphics.Options.ADCircle.Radius.Medium;
                    case 'Small'
                        rend = Graphics.Options.ADCircle.Radius.Small;
                end
                
                for r = Graphics.Options.ADCircle.Radius.Interval:Graphics.Options.ADCircle.Radius.Interval:rend
                    xunit = nm2deg(r) * cos(th) + Aerodrome(ADMark).Long;
                    yunit = nm2deg(r) * sin(th) + Aerodrome(ADMark).Lat;
                    ln = ~ln;
                    if ln
                        if r == Graphics.Options.ADCircle.Radius.Interval
                            Graphics.RadarScreen.Aerodrome(ADMark).Concentric(1) = plot(xunit, yunit, 'LineStyle', Graphics.Options.ADCircle.Linestyle1, 'Color', Graphics.Options.ADCircle.Color, 'LineWidth', Graphics.Options.ADCircle.Linewidth);
                        else
                            Graphics.RadarScreen.Aerodrome(ADMark).Concentric(end + 1) = plot(xunit, yunit, 'LineStyle', Graphics.Options.ADCircle.Linestyle1, 'Color', Graphics.Options.ADCircle.Color, 'LineWidth', Graphics.Options.ADCircle.Linewidth);
                        end
                    else
                        Graphics.RadarScreen.Aerodrome(ADMark).Concentric(end + 1) = plot(xunit, yunit, 'LineStyle', Graphics.Options.ADCircle.Linestyle2, 'Color', Graphics.Options.ADCircle.Color, 'LineWidth', Graphics.Options.ADCircle.Linewidth);
                    end
                end
                
                for RWYMark = 1:length(Aerodrome(ADMark).RWY)
                    Graphics.RadarScreen.Aerodrome(ADMark).Runway(RWYMark) = plot([Aerodrome(ADMark).RWY(RWYMark).THRlong Aerodrome(ADMark).RWY(RWYMark).ENDlong], [Aerodrome(ADMark).RWY(RWYMark).THRlat Aerodrome(ADMark).RWY(RWYMark).ENDlat], 'Color', [0.3, 0.3, 0.3], 'LineStyle', '-', 'LineWidth', 2);
                end
                
                Graphics.RadarScreen.CamTarget.String{end + 1} = Aerodrome(ADMark).ID;
                Graphics.RadarScreen.Table.FilterList.String{end + 1} = Aerodrome(ADMark).ID;
                
            end
%         end
        end
        
    end
    
end
if config.RadarWP
    WPlist = sort(WPlist);
    Graphics.RadarScreen.Control.Direct.WPList.String = WPlist;
    Graphics.RadarScreen.Control.Direct.WPName.String = WPlist{1};
    Graphics.RadarScreen.Control.Direct.WPID.String = Airspace.Waypoint(strcmp({Airspace.Waypoint.Name},WPlist{1})).id;
    Graphics.RadarScreen.Control.Misc.WPList.String = WPlist;
    Graphics.RadarScreen.Control.Misc.WPName.String = WPlist{1};
    Graphics.RadarScreen.Control.Misc.WPID.String = Airspace.Waypoint(strcmp({Airspace.Waypoint.Name},WPlist{1})).id;
end


if config.VisibleFilter
    th = 0:pi/50:2*pi;
    
    xunit = nm2deg(config.VisibleRange) * cos(th) + config.VisibleCenter(1);
    yunit = nm2deg(config.VisibleRange) * sin(th) + config.VisibleCenter(2);
    
    Graphics.RadarScreen.visiblerange = plot(xunit, yunit, 'LineStyle', Graphics.Options.ADCircle.Linestyle1, 'Color', Graphics.Options.Color.Radar.GridLine, 'LineWidth', Graphics.Options.ADCircle.Linewidth);

    if config.EXPTEST
        
        xunit = nm2deg(config.SWITCHRANGE) * cos(th) + config.TGTAD(1);
        yunit = nm2deg(config.SWITCHRANGE) * sin(th) + config.TGTAD(2);
        Graphics.RadarScreen.switchrange = plot(xunit, yunit, 'LineStyle', Graphics.Options.ADCircle.Linestyle2, 'Color', Graphics.Options.Color.Radar.GridLine, 'LineWidth', Graphics.Options.ADCircle.Linewidth);
    end
    
end
    
% Unstable
if config.RadarIMG
    
%     
%     % This creates the 'background' axes
%     ha = axes('units','normalized', ...
%         'position',[0 0 1 1]);
%     
%         % Move the background axes to the bottom
%     uistack(ha,'bottom');
    
    export_fig(Graphics.RadarScreen.radaraxis, 'radar.png');
    delete(get(Graphics.RadarScreen.radaraxis, 'children'));   

        % Load in a background image and display it using the correct colors
    % The image used below, is in the Image Processing Toolbox.  If you do not have %access to this toolbox, you can use another image file instead.
    I=imread('radar.png');
%     Graphics.RadarScreen.BGimage = imshow(I, 'Parent', Graphics.RadarScreen.radaraxis);
    Graphics.RadarScreen.BGimage = imagesc(Graphics.RadarScreen.radaraxis.XLim * 2, Graphics.RadarScreen.radaraxis.YLim * 2, flipud(I));

%     imshow(I, 'Parent', Graphics.RadarScreen.radaraxis)
%     imagesc(I)


    % Turn the handlevisibility off so that we don't inadvertently plot into the axes again
    % Also, make the axes invisible
%     set(ha,'handlevisibility','off', ...
%         'visible','off')
    % Now we can use the figure, as required.
    % For example, we can put a plot in an axes
%     axes('position',[0.3,0.35,0.4,0.4])
%     plot(rand(10))
    

end


end
