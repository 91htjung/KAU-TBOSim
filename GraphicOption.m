% Graphic Option


function Graphics = GraphicOption(Graphics)
global config

% Font Size : Default - 8
Graphics.Options.Fontsize.Panel.Schedule = 8;
Graphics.Options.Fontsize.Panel.PlanStrip = 8;
Graphics.Options.Fontsize.Panel.PlanDetail = 7;

Graphics.Options.Fontsize.Radar.Aerodrome = 8;
Graphics.Options.Fontsize.Radar.Waypoint = 5;
Graphics.Options.Fontsize.Radar.Airroute = 6;
Graphics.Options.Fontsize.Radar.ATSSector = 6;

Graphics.Options.Fontsize.Aircraft.DataBlock = 8;


% Marker Style
Graphics.Options.Markerstyle.Radar.Aerodrome = 's';
Graphics.Options.Markerstyle.Radar.Waypoint = '^';

Graphics.Options.Markerstyle.Aircraft.Position = 'o';

% Marker Size
Graphics.Options.Markersize.Radar.Waypoint = 4;

Graphics.Options.Markersize.Aircraft.Position = 6;

% Color : [R G B]
Graphics.Options.Color.Radar.BackGround = [0.15 0.15 0.25];
Graphics.Options.Color.Radar.GridLine = [0.5 0.5 0.5];
Graphics.Options.Color.Radar.LandColor = [0.4 0.4 0.4];
Graphics.Options.Color.Radar.Aerodrome = [0.4 0.48 0.8];
Graphics.Options.Color.Radar.Waypoint = [0.7 0.7 0.7];
Graphics.Options.Color.Radar.Airroute = [0.7 0.7 0.2];
Graphics.Options.Color.Radar.TMA = [0.8 0.4 0.8];
Graphics.Options.Color.Radar.FIR = [0.4 0.6 0.8];
Graphics.Options.Color.Radar.OtherAirspace = [0.8 0.4 0.8];

Graphics.Options.Color.Aircraft.Trail = [0.6 0.6 0.6];
Graphics.Options.Color.Aircraft.Heading = [0.8 0.8 0.8];
Graphics.Options.Color.Aircraft.InactivePosition = [0.6 0.6 0.6];
Graphics.Options.Color.Aircraft.Datablock = [0.25 0.9 0.55];

% Line Width
Graphics.Options.Linewidth.Radar.AerodromeMarker = 2;
Graphics.Options.Linewidth.Radar.Airroute = 0.5;

Graphics.Options.Linewidth.Aircraft.Trail = 1.5;
Graphics.Options.Linewidth.Aircraft.Heading = 1;
Graphics.Options.Linewidth.Aircraft.Position = 1.5;


% Line Style
Graphics.Options.Linestyle.Aircraft.Trail = ':';
Graphics.Options.Linestyle.Aircraft.Heading = '-';


% Aerodrome Concentric circle Radius
Graphics.Options.ADCircle.Visibility = 1;
Graphics.Options.ADCircle.Color = [0.4 0.48 0.8];
Graphics.Options.ADCircle.Linestyle1 = '--';
Graphics.Options.ADCircle.Linestyle2 = '-';
Graphics.Options.ADCircle.Linewidth = 1;
Graphics.Options.ADCircle.Radius.Large = 20;
Graphics.Options.ADCircle.Radius.Medium = 10;
Graphics.Options.ADCircle.Radius.Small = 5;
Graphics.Options.ADCircle.Radius.Interval = 5;
end