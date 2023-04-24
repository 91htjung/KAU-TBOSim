function Graphics = GUI(Command)
global config 

close all

clear Graphics
Graphics = struct;

Graphics = GraphicOption(Graphics);

Graphics.Parameter.CurrentZoom = 1;
Graphics.Parameter.Pan = struct;
Graphics.Parameter.Modifier = 0; % 0: None, 1:Shift, 2:Ctrl, 3:Alt
Graphics.Parameter.NewGraph = 0;

Graphics.MainWindow.screen = figure('Visible','off', 'Tag', 'main', 'Toolbar', 'none', 'MenuBar', 'figure');
Graphics.MainWindow.screen.Interruptible = 'on';
% 
% pos = get(0, 'ScreenSize');
% Graphics.MainWindow.screen.OuterPosition = pos; % Taskbar is visible
set(Graphics.MainWindow.screen, 'units','pixels','outerposition',[1 1 1366 768]);

% Figure Callback
Graphics.MainWindow.screen.WindowScrollWheelFcn = @MouseWheel_Callback;
Graphics.MainWindow.screen.KeyPressFcn = @KeyPress_Callback;
Graphics.MainWindow.screen.KeyReleaseFcn = @KeyRelease_Callback;
Graphics.MainWindow.screen.WindowButtonDownFcn = @WindowButtonDown_Callback;
Graphics.MainWindow.screen.WindowButtonUpFcn = @WindowButtonUp_Callback;

% Crate Main GUI
Graphics.MainWindow.tgroup = uitabgroup('Parent', Graphics.MainWindow.screen, 'SelectionChangedFcn', @Tab_Selection_Callback);
Graphics.MainWindow.tab_radar = uitab('Parent', Graphics.MainWindow.tgroup, 'Title', 'RadarScreen');
Graphics.MainWindow.tab_plan = uitab('Parent', Graphics.MainWindow.tgroup, 'Title', 'Flight Plan');
Graphics.MainWindow.tab_data = uitab('Parent', Graphics.MainWindow.tgroup, 'Title', 'Data Editor');
Graphics.MainWindow.tab_traj = uitab('Parent', Graphics.MainWindow.tgroup, 'Title', 'Trajectory Generator');
Graphics.MainWindow.tab_log = uitab('Parent', Graphics.MainWindow.tgroup, 'Title', 'Flight Log');
Graphics.MainWindow.tab_config = uitab('Parent', Graphics.MainWindow.tgroup, 'Title', 'Configuration');
Graphics.MainWindow.tab_map = uitab('Parent', Graphics.MainWindow.tgroup, 'Title', 'map');
Graphics.MainWindow.tab_weather = uitab('Parent', Graphics.MainWindow.tgroup, 'Title', 'weather');

Graphics.MainWindow.tgroup.SelectedTab.Title = ['>> ' Graphics.MainWindow.tgroup.SelectedTab.Title];

% Define Menu
Graphics.MainWindow.Menu.File = uimenu(Graphics.MainWindow.screen, 'Label', 'File');
Graphics.MainWindow.Menu.File_Open = uimenu(Graphics.MainWindow.Menu.File, 'Label', 'Open');

% Define Toolbar
Graphics.MainWindow.Toolbar = uitoolbar(Graphics.MainWindow.screen);
BTNlist = {'play' ; 'pause' ; 'stop' ; '/' ; 'slow' ; 'fast' ; '/' ; 'plus' ; 'minus' ; '/' ; 'check' ; 'cancel' ; '/' ; 'left' ; 'right' ; 'down' ; 'up' ; ...
    '/' ; 'list' ; '/' ; 'resize' ; '/' ; 'enter'};
sep = 'off';
for in = 1:length(BTNlist)
    if strcmp(BTNlist{in}, '/')
        sep = 'on';
    else
        [img, map] = imread(fullfile(pwd, 'GraphicData', [BTNlist{in} '.gif']));
        icon = ind2rgb(img, map);
        Graphics.MainWindow.PushButton.(BTNlist{in}) = uipushtool(Graphics.MainWindow.Toolbar,'Separator', sep, 'Tag', BTNlist{in});
        Graphics.MainWindow.PushButton.(BTNlist{in}).CData = icon;
        sep = 'off';
    end
end

set(Graphics.MainWindow.PushButton.play, 'ClickedCallback', @(obj, event)play_ClickedCallback(obj, event));
set(Graphics.MainWindow.PushButton.pause, 'ClickedCallback', @(obj, event)pause_ClickedCallback(obj, event));
set(Graphics.MainWindow.PushButton.stop, 'ClickedCallback', @(obj, event)stop_ClickedCallback(obj, event));
set(Graphics.MainWindow.PushButton.slow, 'ClickedCallback', @(obj, event)slow_ClickedCallback(obj, event));
set(Graphics.MainWindow.PushButton.fast, 'ClickedCallback', @(obj, event)fast_ClickedCallback(obj, event));
set(Graphics.MainWindow.PushButton.plus, 'ClickedCallback', @(obj, event)plus_ClickedCallback(obj, event));
set(Graphics.MainWindow.PushButton.minus, 'ClickedCallback', @(obj, event)minus_ClickedCallback(obj, event));
set(Graphics.MainWindow.PushButton.enter, 'ClickedCallback', @(obj, event)enter_ClickedCallback(obj, event));

Graphics.MainWindow.Console = uicontrol('Style', 'edit', 'Position', [1 ; 0 ; 300 ; 20], 'HorizontalAlignment', 'left', 'Callback', @CommandIn_Callback);


Graphics.MainWindow.Display = uicontrol('Style', 'edit', 'Position',  [1 ; 20 ; 300 ; 120], 'Enable','inactive', ...
    'ListboxTop', 1.0, 'Max', 6.0,'Min', 0.0, 'HorizontalAlignment', 'left');

try
    Graphics.MainWindow.Display.String = sprintf(' [ %d ]    [ %s ]    " %s "', Command.input{1,1}, Command.input{1,2}, Command.input{1,3});
end

% Radar Screen
Graphics.MainWindow.tab_radar.Units = 'pixels';



% Display Panels
Graphics.RadarScreen.MastPanel = uipanel('Parent', Graphics.MainWindow.tab_radar, 'Units', 'pixels', 'Position', [0 ; Graphics.MainWindow.tab_radar.Position(4) - 160 ; 300 ; 160]);
Graphics.RadarScreen.DispPanel = uipanel('Parent', Graphics.MainWindow.tab_radar, 'Units', 'pixels', 'Position', [0 ; 0 ; 300 ; Graphics.MainWindow.tab_radar.Position(4) - 160]);


% Master Panel (Sim Control)
Graphics.RadarScreen.Target.Object = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'popup', 'Units', 'pixels', 'Position', [2 ; 0 ; 90 ; 25], 'String' , 'Aircraft', 'Tag', 'TargetAC');

Graphics.RadarScreen.Target.Follow = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'togglebutton', 'Units', 'pixels', 'Position', [1; 30; 20; 20], 'Callback', @TargetCam_Callback);
[img, map] = imread(fullfile(pwd, 'GraphicData', 'target.gif'));
icon = ind2rgb(img, map);
Graphics.RadarScreen.Target.Follow.CData = icon;

Graphics.RadarScreen.Target.Trajectory = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'togglebutton', 'Units', 'pixels', 'Position', [23; 30; 20; 20], 'Callback', @ViewTraj_Callback);
[img, map] = imread(fullfile(pwd, 'GraphicData', 'trajectory.gif'));
icon = ind2rgb(img, map);
Graphics.RadarScreen.Target.Trajectory.CData = icon;

Graphics.RadarScreen.Target.ControlPoint = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'togglebutton', 'Units', 'pixels', 'Position', [45; 30; 20; 20],'Callback', @ViewCont_Callback);
[img, map] = imread(fullfile(pwd, 'GraphicData', 'controlpoint.gif'));
icon = ind2rgb(img, map);
Graphics.RadarScreen.Target.ControlPoint.CData = icon;
% 
% Graphics.RadarScreen.Target.Waypoint = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'togglebutton', 'Units', 'pixels', 'Position', [67; 30; 20; 20], 'Callback', @ViewWayp_Callback);
% [img, map] = imread(fullfile(pwd, 'GraphicData', 'waypoints.gif'));
% icon = ind2rgb(img, map);
% Graphics.RadarScreen.Target.Waypoint.CData = icon;

Graphics.RadarScreen.Target.Play = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'togglebutton', 'Units', 'pixels', 'Position', [89; 30; 20; 20]);
[img, map] = imread(fullfile(pwd, 'GraphicData', 'ACplay.gif'));
icon = ind2rgb(img, map);
Graphics.RadarScreen.Target.Play.CData = icon;

Graphics.RadarScreen.Target.Pause = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'togglebutton', 'Units', 'pixels', 'Position', [111; 30; 20; 20]);
[img, map] = imread(fullfile(pwd, 'GraphicData', 'ACpause.gif'));
icon = ind2rgb(img, map);
Graphics.RadarScreen.Target.Pause.CData = icon;

Graphics.RadarScreen.Target.Stop = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'togglebutton', 'Units', 'pixels', 'Position', [133; 30; 20; 20]);
[img, map] = imread(fullfile(pwd, 'GraphicData', 'ACexit.gif'));
icon = ind2rgb(img, map);
Graphics.RadarScreen.Target.Stop.CData = icon;

Graphics.RadarScreen.Target.Graph = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [155; 30; 20; 20], 'Callback', @SetGraphTarget);
[img, map] = imread(fullfile(pwd, 'GraphicData', 'graph.gif'));
icon = ind2rgb(img, map);
Graphics.RadarScreen.Target.Graph.CData = icon;




Graphics.RadarScreen.Magnitude = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'slider', 'Units', 'pixels', 'Position', [1; 52; 100; 20], 'Min', -20, 'Max', 20, 'Value', (log10(Graphics.Parameter.CurrentZoom) / log10(config.Zoom)));
Graphics.RadarScreen.MagText = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'text', 'Units', 'pixels', 'Position', [105; 52 ; 45 ; 15], 'HorizontalAlignment', 'Left', 'String', [' x ' num2str(Graphics.Parameter.CurrentZoom, '%.2f')]);

Graphics.RadarScreen.CamTarget = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'popup', 'Units', 'pixels', 'Position', [155; 57 ; 90 ; 20], 'HorizontalAlignment', 'Left', 'String', {'Initial'});

Graphics.RadarScreen.Speed = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'text', 'Units', 'pixels', 'Position', [95 ; 15 ; 70 ; 15],'HorizontalAlignment','Right', 'String' , ['Speed x ' num2str(config.update, '%.1f')]);
Graphics.RadarScreen.Speedup = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [166 ; 15 ; 15 ; 15],'HorizontalAlignment','Center', 'String' , char(9651), 'Callback', @fast_ClickedCallback);
Graphics.RadarScreen.Speeddown = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [182 ; 15 ; 15 ; 15],'HorizontalAlignment','Center', 'String' , char(9661), 'Callback', @slow_ClickedCallback);

Graphics.RadarScreen.Timer = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'text', 'Units', 'pixels', 'Position', [95 ; 0 ; 70 ; 15],'HorizontalAlignment','Right', 'String' , ['Timer x ' num2str(config.timer, '%.1f')]);
Graphics.RadarScreen.Timerup = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [166 ; 0 ; 15 ; 15],'HorizontalAlignment','Center', 'String' , char(9651), 'Callback', @Timerup_Callback);
Graphics.RadarScreen.Timerdown = uicontrol('Parent', Graphics.RadarScreen.MastPanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [182 ; 0 ; 15 ; 15],'HorizontalAlignment','Center', 'String' , char(9661), 'Callback', @Timerdown_Callback);

Graphics.RadarScreen.Mode = uibuttongroup('Parent', Graphics.RadarScreen.MastPanel, 'Units', 'pixels', 'Position', [199 ; 0 ; 100 ; 50]);
Graphics.RadarScreen.RealTime = uicontrol(Graphics.RadarScreen.Mode, 'Style', 'radiobutton', 'String', 'RealTime Mode', 'Units', 'pixels', 'Position', [0 ; 0 ; 100 ; 15], 'Callback', @RealTime_Callback);
Graphics.RadarScreen.FastTime = uicontrol(Graphics.RadarScreen.Mode, 'Style', 'radiobutton', 'String', 'FastTime Mode', 'Units', 'pixels', 'Position', [0 ; 15 ; 100 ; 15], 'Callback', @FastTime_Callback);
Graphics.RadarScreen.SlowMotion = uicontrol(Graphics.RadarScreen.Mode, 'Style', 'radiobutton', 'String', 'Slow Mode', 'Units', 'pixels', 'Position', [0 ; 30 ; 100 ; 15], 'Callback', @SlowMotion_Callback);



% Display Panel (Data Display & AC Control)
Graphics.RadarScreen.Display = uitabgroup('Parent', Graphics.RadarScreen.DispPanel);
Graphics.RadarScreen.Table.Tab = uitab('Parent', Graphics.RadarScreen.Display, 'Title', 'Sch.');
Graphics.RadarScreen.Plan.Tab = uitab('Parent', Graphics.RadarScreen.Display, 'Title', 'Plan');
Graphics.RadarScreen.Trajectory.Tab = uitab('Parent', Graphics.RadarScreen.Display, 'Title', 'Traj.');
Graphics.RadarScreen.Control.Tab = uitab('Parent', Graphics.RadarScreen.Display, 'Title', 'Cont.');
Graphics.RadarScreen.Data.Tab = uitab('Parent', Graphics.RadarScreen.Display, 'Title', 'Data');
Graphics.RadarScreen.Procedure.Tab = uitab('Parent', Graphics.RadarScreen.Display, 'Title', 'Proc.');
Graphics.RadarScreen.Option.Tab = uitab('Parent', Graphics.RadarScreen.Display, 'Title', 'Disp.');

% Table Object -> Aircraft Schedule
Graphics.RadarScreen.Table.Tab.Units = 'pixels';
Graphics.RadarScreen.Table.Object = uitable('Parent', Graphics.RadarScreen.Table.Tab, 'Units', 'pixels', 'Position', [1 ; 0 ; 290 ; Graphics.RadarScreen.Table.Tab.Position(4) - 57], 'Fontsize', Graphics.Options.Fontsize.Panel.Schedule, 'Tag', 'RadarList');

Graphics.RadarScreen.Table.FilterButton = uicontrol('Parent', Graphics.RadarScreen.Table.Tab, 'Style', 'checkbox', 'Units', 'pixels', 'Position', [1 ; Graphics.RadarScreen.Table.Tab.Position(4) - 52 ; 50 ; 20], 'Value', 0, 'String', 'Filter', 'Tag', 'FilterButton');
Graphics.RadarScreen.Table.FilterList = uicontrol('Parent', Graphics.RadarScreen.Table.Tab, 'Style', 'popup', 'Units', 'pixels', 'Position', [52 ; Graphics.RadarScreen.Table.Tab.Position(4) - 50 ; 60 ; 18], 'String', {'All'}, 'Tag', 'FilterList');
Graphics.RadarScreen.Table.FilterInbound = uicontrol('Parent', Graphics.RadarScreen.Table.Tab, 'Style', 'checkbox', 'Units', 'pixels', 'Position', [120 ; Graphics.RadarScreen.Table.Tab.Position(4) - 52 ; 70 ; 20], 'Value', 1, 'String', 'Inbound', 'Tag', 'Inbound');
Graphics.RadarScreen.Table.FilterOutbound = uicontrol('Parent', Graphics.RadarScreen.Table.Tab, 'Style', 'checkbox', 'Units', 'pixels', 'Position', [190 ; Graphics.RadarScreen.Table.Tab.Position(4) - 52 ; 70 ; 20], 'Value', 1, 'String', 'Outbound', 'Tag', 'Outbound');

Graphics.RadarScreen.Table.RefreshButton = uicontrol('Parent', Graphics.RadarScreen.Table.Tab, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [262 ; Graphics.RadarScreen.Table.Tab.Position(4) - 52 ; 20 ; 20], 'String', '', 'Tag', 'Refresh');
[img, map] = imread(fullfile(pwd, 'GraphicData', 'refresh.gif'));
icon = ind2rgb(img, map);
Graphics.RadarScreen.Table.RefreshButton.CData = icon;


Graphics.RadarScreen.Table.Object.Units = 'pixels';

Graphics.RadarScreen.Table.Object.ColumnName = {'ID', ...
           '<html><center>Callsign</center></html>', ...
           '<html><center>Status</center></html>', ...
           '<html><center>TOT<br />(sec)</center></html>', ...
           '<html><center>ELDT<br />(sec)</center></html>', ...
           '<html><center>ALDT<br />(sec)</center></html>', ...
           '<html><center>LDT<br />diff</center></html>' ...
           };
Graphics.RadarScreen.Table.Object.RowName = [];
% Graphics.RadarScreen.Table.Object.FontSize = 7;

Graphics.RadarScreen.Table.javaobj = findjobj(Graphics.RadarScreen.Table.Object);
% Graphics.RadarScreen.Table.Object.PositionOfScroll = Graphics.RadarScreen.Table.Object.javaobj.getVerticalScrollBar.getValue;
jTable = Graphics.RadarScreen.Table.javaobj.getViewport.getView;
jTable.setAutoResizeMode(jTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

 
% % Now turn the JIDE sorting on
% jTable.setSortable(true);		% or: set(jtable,'Sortable','on');
% jTable.setAutoResort(true);
% jTable.setMultiColumnSortable(true);
% jTable.setPreserveSelectionsAfterSorting(true);



Graphics.RadarScreen.Table.Object.ColumnWidth = {40 120 100 'auto' 'auto' 'auto' 'auto'};


% Plan Object -> E-STRIP
Graphics.RadarScreen.Plan.Tab.Units = 'pixels';
Graphics.RadarScreen.Plan.Strip = uitable('Parent', Graphics.RadarScreen.Plan.Tab, 'Units', 'pixels', 'Position', [1 ; 300 ; 290 ; Graphics.RadarScreen.Plan.Tab.Position(4) - 300], 'Fontsize', Graphics.Options.Fontsize.Panel.PlanStrip, 'Tag', 'Strip');
Graphics.RadarScreen.Plan.Strip.Units = 'pixels';
Graphics.RadarScreen.Plan.Strip.ColumnName = {'ID', ...
           '<html><center>Callsign</center></html>', ...
           '<html><center>Type</center></html>', ...
           '<html><center>DEP</center></html>', ...
           '<html><center>ARR</center></html>', ...
           '<html><center>TOT</center></html>', ...
           };
Graphics.RadarScreen.Plan.Strip.RowName = [];
Graphics.RadarScreen.Plan.Strip.ColumnWidth = {40 100 50 100 100 'auto'};
Graphics.RadarScreen.Plan.Stripobj = findjobj(Graphics.RadarScreen.Plan.Strip);
jTable = Graphics.RadarScreen.Plan.Stripobj.getViewport.getView;
jTable.setAutoResizeMode(jTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);



Graphics.RadarScreen.Plan.Detail = uitable('Parent', Graphics.RadarScreen.Plan.Tab, 'Units', 'pixels', 'Position', [1 ; 0 ; 290 ; 295], 'Tag', 'Plan', 'FontSize', Graphics.Options.Fontsize.Panel.PlanDetail);
Graphics.RadarScreen.Plan.Detail.Units = 'pixels';

Graphics.RadarScreen.Plan.Detail.ColumnName = {'#', ...
           '<html><center>WP</center></html>', ...
           '<html><center>Phase</center></html>', ...
           '<html><center>Proc</center></html>', ...
           '<html><center>LAT</center></html>', ...
           '<html><center>LONG</center></html>', ...
           '<html><center>ALT</center></html>', ...
           };
Graphics.RadarScreen.Plan.Detail.RowName = [];
Graphics.RadarScreen.Plan.Detail.ColumnWidth = {40 120 80 150 120 120 'auto'};
Graphics.RadarScreen.Plan.Detailobj = findjobj(Graphics.RadarScreen.Plan.Detail);
jTable = Graphics.RadarScreen.Plan.Detailobj.getViewport.getView;
jTable.setAutoResizeMode(jTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

% Control Tab
Graphics.RadarScreen.Control.Tab.Units = 'pixels';
Graphics.RadarScreen.Control.MastPanel = uipanel('Parent', Graphics.RadarScreen.Control.Tab, 'Units', 'pixels', 'Position', [1 ; 455 ; 290 ; Graphics.RadarScreen.Control.Tab.Position(4) - 456], 'Tag', 'MasterPanel');
Graphics.RadarScreen.Control.Heading.Panel = uipanel('Parent', Graphics.RadarScreen.Control.Tab, 'Title', 'Heading', 'Units', 'pixels', 'Position', [1 ; 285; 143 ; 169], 'Tag', 'HeadingPanel');
Graphics.RadarScreen.Control.Altitude.Panel = uipanel('Parent', Graphics.RadarScreen.Control.Tab, 'Title', 'Altitude', 'Units', 'pixels', 'Position', [145 ; 285 ; 143 ; 169], 'Tag', 'AltitudePanel');
Graphics.RadarScreen.Control.Speed.Panel = uipanel('Parent', Graphics.RadarScreen.Control.Tab, 'Title', 'Speed', 'Units', 'pixels', 'Position', [1 ; 115 ; 143 ; 169], 'Tag', 'SpeedPanel');
Graphics.RadarScreen.Control.Direct.Panel = uipanel('Parent', Graphics.RadarScreen.Control.Tab, 'Title', 'Direct To', 'Units', 'pixels', 'Position', [145 ; 115 ; 143 ; 169], 'Tag', 'DirectPanel');
Graphics.RadarScreen.Control.Misc.Panel = uipanel('Parent', Graphics.RadarScreen.Control.Tab, 'Title', 'Holding', 'Units', 'pixels', 'Position', [1 ; 0 ; 290 ; 114], 'Tag', 'MiscPanel');

% Control: MasterPanel
Graphics.RadarScreen.Control.Option.TrajPanel = uibuttongroup('Parent', Graphics.RadarScreen.Control.MastPanel, 'Title', 'Control Option', 'Units', 'pixels', 'Position', [1 ; 4 ; 141 ; Graphics.RadarScreen.Control.MastPanel.Position(4) - 7]);
Graphics.RadarScreen.Control.Option.Dynamic = uicontrol('Parent', Graphics.RadarScreen.Control.Option.TrajPanel, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [4 ; Graphics.RadarScreen.Control.Option.TrajPanel.Position(4) - 33 ; 138 ; 16], 'String', 'Dynamic  - time based', 'UserData' , 'dynamic');
Graphics.RadarScreen.Control.Option.Static = uicontrol('Parent', Graphics.RadarScreen.Control.Option.TrajPanel, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [4 ; Graphics.RadarScreen.Control.Option.TrajPanel.Position(4) - 51 ; 138 ; 16], 'String', 'Static  - speed based', 'UserData', 'static');
Graphics.RadarScreen.Control.Option.Manual = uicontrol('Parent', Graphics.RadarScreen.Control.Option.TrajPanel, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [4 ; Graphics.RadarScreen.Control.Option.TrajPanel.Position(4) - 69 ; 138 ; 16], 'String', 'Manual  - non-trajectory', 'UserData', 'manual');

Graphics.RadarScreen.Control.Option.ManualPanel = uibuttongroup('Parent', Graphics.RadarScreen.Control.MastPanel, 'Title', 'Manual', 'Units', 'pixels', 'Position', [144 ; 4 ; 141 ; Graphics.RadarScreen.Control.MastPanel.Position(4) - 7]);
Graphics.RadarScreen.Control.Option.Heading = uicontrol('Parent', Graphics.RadarScreen.Control.Option.ManualPanel, 'Style', 'checkbox', 'Units', 'pixels', 'Position', [4 ; Graphics.RadarScreen.Control.Option.TrajPanel.Position(4) - 33 ; 138 ; 16], 'String', 'Fix Heading', 'UserData', 'hdg');
Graphics.RadarScreen.Control.Option.Speed = uicontrol('Parent', Graphics.RadarScreen.Control.Option.ManualPanel, 'Style', 'checkbox', 'Units', 'pixels', 'Position', [4 ; Graphics.RadarScreen.Control.Option.TrajPanel.Position(4) - 51 ; 138 ; 16], 'String', 'Fix Speed', 'UserData', 'spd');
Graphics.RadarScreen.Control.Option.Altitude = uicontrol('Parent', Graphics.RadarScreen.Control.Option.ManualPanel, 'Style', 'checkbox', 'Units', 'pixels', 'Position', [4 ; Graphics.RadarScreen.Control.Option.TrajPanel.Position(4) - 69 ; 138 ; 16], 'String', 'Fix Altitude', 'UserData', 'alt');

% Control: Heading
Graphics.RadarScreen.Control.Heading.DegreePanel = uipanel('Parent', Graphics.RadarScreen.Control.Heading.Panel, 'Title', 'Degrees', 'Units', 'pixels', 'Position', [2 ; Graphics.RadarScreen.Control.Heading.Panel.Position(4) - 112 ; 138 ; 97]);
Graphics.RadarScreen.Control.Heading.FromText = uicontrol('Parent', Graphics.RadarScreen.Control.Heading.DegreePanel, 'Style', 'text', 'Units', 'pixels', 'Position', [4 ; 59 ; 30 ; 18],'String', 'From', 'Tag', 'Heading', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Heading.FromValue = uicontrol('Parent', Graphics.RadarScreen.Control.Heading.DegreePanel, 'Style', 'edit', 'Units', 'pixels', 'Position', [34 ; 59 ; 39 ; 18],'String', '000.0˚', 'Tag', 'Heading', 'HorizontalAlignment', 'left', 'Enable', 'off');
Graphics.RadarScreen.Control.Heading.ToText = uicontrol('Parent', Graphics.RadarScreen.Control.Heading.DegreePanel, 'Style', 'text', 'Units', 'pixels', 'Position', [4 ; 42 ; 30 ; 18],'String', 'To', 'Tag', 'Heading', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Heading.ToValue = uicontrol('Parent', Graphics.RadarScreen.Control.Heading.DegreePanel, 'Style', 'edit', 'Units', 'pixels', 'Position', [34 ; 42 ; 39 ; 18],'String', '000.0', 'Tag', 'Heading', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Heading.Up = uicontrol('Parent', Graphics.RadarScreen.Control.Heading.DegreePanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [71 ; 51 ; 16 ; 12],'HorizontalAlignment','Center', 'Tag', 'Heading', 'FontSize', 6, 'String' , char(9651), 'UserData', 10);
Graphics.RadarScreen.Control.Heading.Down = uicontrol('Parent', Graphics.RadarScreen.Control.Heading.DegreePanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [71 ; 41 ; 16 ; 12],'HorizontalAlignment','Center', 'Tag', 'Heading', 'FontSize', 6, 'String' , char(9661), 'UserData', -10);
Graphics.RadarScreen.Control.Heading.TurnDirection = uibuttongroup('Parent', Graphics.RadarScreen.Control.Heading.DegreePanel, 'Title', 'Direction', 'Units', 'pixels', 'Position', [2 ; 3 ; 132 ; 41]);
Graphics.RadarScreen.Control.Heading.Auto = uicontrol('Parent', Graphics.RadarScreen.Control.Heading.TurnDirection, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [1 ; 3 ; 40 ; 20], 'String', 'auto', 'Tag', 'a');
Graphics.RadarScreen.Control.Heading.Left = uicontrol('Parent', Graphics.RadarScreen.Control.Heading.TurnDirection, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [42 ; 3 ; 40 ; 20], 'String', 'left', 'Tag', 'l');
Graphics.RadarScreen.Control.Heading.Right = uicontrol('Parent', Graphics.RadarScreen.Control.Heading.TurnDirection, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [83 ; 3 ; 40 ; 20], 'String', 'right', 'Tag', 'r');

Graphics.RadarScreen.Control.Heading.BankanblePanel = uibuttongroup('Parent', Graphics.RadarScreen.Control.Heading.Panel, 'Title', 'BankAngle', 'Units', 'pixels', 'Position', [2 ; 21 ; 138 ; 37]);
Graphics.RadarScreen.Control.Heading.Nomial = uicontrol('Parent', Graphics.RadarScreen.Control.Heading.BankanblePanel, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [4 ; 3 ; 50 ; 20], 'String', 'nomial', 'Tag', 'n');
Graphics.RadarScreen.Control.Heading.Maximum = uicontrol('Parent', Graphics.RadarScreen.Control.Heading.BankanblePanel, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [59 ; 3 ; 65 ; 20], 'String', 'maximum', 'Tag', 'm');

Graphics.RadarScreen.Control.Heading.Apply = uicontrol('Parent', Graphics.RadarScreen.Control.Heading.Panel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [4 ; 2 ; 50 ; 17],'HorizontalAlignment','Center', 'String' , 'Apply', 'Tag', 'Apply');
% Graphics.RadarScreen.Control.Heading.Cancel = uicontrol('Parent', Graphics.RadarScreen.Control.Heading.Panel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [57 ; 2 ; 50 ; 17],'HorizontalAlignment','Center', 'String' , 'Cancel', 'Tag', 'Cancel');

% Control: Altitude
Graphics.RadarScreen.Control.Altitude.LevelPanel = uipanel('Parent', Graphics.RadarScreen.Control.Altitude.Panel, 'Title', 'Level', 'Units', 'pixels', 'Position', [2 ; Graphics.RadarScreen.Control.Altitude.Panel.Position(4) - 74 ; 137 ; 59]);
Graphics.RadarScreen.Control.Altitude.FromText = uicontrol('Parent', Graphics.RadarScreen.Control.Altitude.LevelPanel, 'Style', 'text', 'Units', 'pixels', 'Position', [4 ; 21 ; 30 ; 18],'String', 'From', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Altitude.FromValue = uicontrol('Parent', Graphics.RadarScreen.Control.Altitude.LevelPanel, 'Style', 'edit', 'Units', 'pixels', 'Position', [34 ; 21 ; 49 ; 18],'String', '15000 ft', 'HorizontalAlignment', 'left', 'Enable', 'off');
Graphics.RadarScreen.Control.Altitude.ToText = uicontrol('Parent', Graphics.RadarScreen.Control.Altitude.LevelPanel, 'Style', 'text', 'Units', 'pixels', 'Position', [4 ; 4 ; 30 ; 18],'String', 'To', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Altitude.ToValue = uicontrol('Parent', Graphics.RadarScreen.Control.Altitude.LevelPanel, 'Style', 'edit', 'Units', 'pixels', 'Position', [34 ; 4 ; 49 ; 18],'String', '15000', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Altitude.Up = uicontrol('Parent', Graphics.RadarScreen.Control.Altitude.LevelPanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [81 ; 13 ; 16 ; 12],'HorizontalAlignment','Center', 'Tag', 'Altitude', 'FontSize', 6, 'String' , char(9651), 'UserData', 100);
Graphics.RadarScreen.Control.Altitude.Down = uicontrol('Parent', Graphics.RadarScreen.Control.Altitude.LevelPanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [81 ; 3 ; 16 ; 12],'HorizontalAlignment','Center', 'Tag', 'Altitude', 'FontSize', 6, 'String' , char(9661), 'UserData', -100);

Graphics.RadarScreen.Control.Altitude.ROCDPanel = uibuttongroup('Parent', Graphics.RadarScreen.Control.Altitude.Panel, 'Title', 'Climb/Descent Rate', 'Units', 'pixels', 'Position', [2 ; 21 ; 137 ; 75]);
Graphics.RadarScreen.Control.Altitude.Nominal = uicontrol('Parent', Graphics.RadarScreen.Control.Altitude.ROCDPanel, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [1 ; 30 ; 60 ; 20], 'String', 'nominal');
Graphics.RadarScreen.Control.Altitude.Expedite = uicontrol('Parent', Graphics.RadarScreen.Control.Altitude.ROCDPanel, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [66 ; 30 ; 60 ; 20], 'String', 'expedite');
Graphics.RadarScreen.Control.Altitude.Manual = uicontrol('Parent', Graphics.RadarScreen.Control.Altitude.ROCDPanel, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [1 ; 10 ; 60 ; 20], 'String', 'manual');
Graphics.RadarScreen.Control.Altitude.ROCDValue = uicontrol('Parent', Graphics.RadarScreen.Control.Altitude.ROCDPanel, 'Style', 'edit', 'Units', 'pixels', 'Position', [62 ; 10 ; 40 ; 18], 'String', '2500');
Graphics.RadarScreen.Control.Altitude.UnitText = uicontrol('Parent', Graphics.RadarScreen.Control.Altitude.ROCDPanel, 'Style', 'text', 'Units', 'pixels', 'Position', [103 ; 10 ; 20 ; 16], 'String', 'ft/s');

Graphics.RadarScreen.Control.Altitude.Apply = uicontrol('Parent', Graphics.RadarScreen.Control.Altitude.Panel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [4 ; 2 ; 50 ; 17],'HorizontalAlignment','Center', 'String' , 'Apply');
% Graphics.RadarScreen.Control.Altitude.Cancel = uicontrol('Parent', Graphics.RadarScreen.Control.Altitude.Panel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [57 ; 2 ; 50 ; 17],'HorizontalAlignment','Center', 'String' , 'Cancel');

% Control: Speed
Graphics.RadarScreen.Control.Speed.AirspeedPanel = uibuttongroup('Parent', Graphics.RadarScreen.Control.Speed.Panel, 'Title', 'Airspeed', 'Units', 'pixels', 'Position', [2 ; Graphics.RadarScreen.Control.Speed.Panel.Position(4) - 109 ; 137 ; 94]);
Graphics.RadarScreen.Control.Speed.TAS = uicontrol('Parent', Graphics.RadarScreen.Control.Speed.AirspeedPanel, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [4 ; 60 ; 120 ; 20], 'String', 'TAS (default)');
Graphics.RadarScreen.Control.Speed.IAS = uicontrol('Parent', Graphics.RadarScreen.Control.Speed.AirspeedPanel, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [4 ; 40 ; 60 ; 20], 'String', 'IAS');
Graphics.RadarScreen.Control.Speed.Mach = uicontrol('Parent', Graphics.RadarScreen.Control.Speed.AirspeedPanel, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [64 ; 40 ; 60 ; 20], 'String', 'Mach');

Graphics.RadarScreen.Control.Speed.FromText = uicontrol('Parent', Graphics.RadarScreen.Control.Speed.AirspeedPanel, 'Style', 'text', 'Units', 'pixels', 'Position', [4 ; 21 ; 30 ; 18],'String', 'From', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Speed.FromValue = uicontrol('Parent', Graphics.RadarScreen.Control.Speed.AirspeedPanel, 'Style', 'edit', 'Units', 'pixels', 'Position', [34 ; 21 ; 49 ; 18],'String', '440 kt', 'HorizontalAlignment', 'left', 'Enable', 'off');
Graphics.RadarScreen.Control.Speed.ToText = uicontrol('Parent', Graphics.RadarScreen.Control.Speed.AirspeedPanel, 'Style', 'text', 'Units', 'pixels', 'Position', [4 ; 4 ; 30 ; 18],'String', 'To', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Speed.ToValue = uicontrol('Parent', Graphics.RadarScreen.Control.Speed.AirspeedPanel, 'Style', 'edit', 'Units', 'pixels', 'Position', [34 ; 4 ; 49 ; 18],'String', '450', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Speed.Up = uicontrol('Parent', Graphics.RadarScreen.Control.Speed.AirspeedPanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [81 ; 13 ; 16 ; 12],'HorizontalAlignment','Center', 'Tag', 'Speed', 'FontSize', 6, 'String' , char(9651), 'UserData', 10);
Graphics.RadarScreen.Control.Speed.Down = uicontrol('Parent', Graphics.RadarScreen.Control.Speed.AirspeedPanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [81 ; 3 ; 16 ; 12],'HorizontalAlignment','Center', 'Tag', 'Speed', 'FontSize', 6, 'String' , char(9661), 'UserData', -10);

Graphics.RadarScreen.Control.Speed.AccelPanel = uibuttongroup('Parent', Graphics.RadarScreen.Control.Speed.Panel, 'Title', 'Acceleration', 'Units', 'pixels', 'Position', [2 ; 21 ; 137 ; 40]);
Graphics.RadarScreen.Control.Speed.Auto = uicontrol('Parent', Graphics.RadarScreen.Control.Speed.AccelPanel, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [4 ; 5 ; 50 ; 20], 'String', 'auto');
Graphics.RadarScreen.Control.Speed.Maximum = uicontrol('Parent', Graphics.RadarScreen.Control.Speed.AccelPanel, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [56 ; 5 ; 70 ; 20], 'String', 'maximum');

Graphics.RadarScreen.Control.Speed.Apply = uicontrol('Parent', Graphics.RadarScreen.Control.Speed.Panel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [4 ; 2 ; 50 ; 17],'HorizontalAlignment','Center', 'String' , 'Apply');
% Graphics.RadarScreen.Control.Speed.Cancel = uicontrol('Parent', Graphics.RadarScreen.Control.Speed.Panel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [57 ; 2 ; 50 ; 17],'HorizontalAlignment','Center', 'String' , 'Cancel');

% Control: Direct To
Graphics.RadarScreen.Control.Direct.Destination = uibuttongroup('Parent', Graphics.RadarScreen.Control.Direct.Panel, 'Units', 'pixels', 'Position', [2 ; 21 ; 137 ; Graphics.RadarScreen.Control.Direct.Panel.Position(4) - 22]);
Graphics.RadarScreen.Control.Direct.WPButton = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'radiobutton', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [4 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 35 ; 100 ; 20], 'String', 'Waypoint');
Graphics.RadarScreen.Control.Direct.WPNameText = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'text', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [13 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 53 ; 28 ; 16], 'String', 'name', 'HorizontalAlignment', 'right');
Graphics.RadarScreen.Control.Direct.WPName = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'edit', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [41 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 53 ; 46 ; 18], 'String', 'OLMEN', 'UserData', 1);
Graphics.RadarScreen.Control.Direct.WPIDText = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'text', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [88 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 53 ; 15 ; 16], 'String', 'id', 'HorizontalAlignment', 'right');
Graphics.RadarScreen.Control.Direct.WPID = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'edit', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [104 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 53 ; 25 ; 18], 'String', '32', 'UserData', 2);% Graphics.RadarScreen.Control.Direct.WPID = 
Graphics.RadarScreen.Control.Direct.WPList = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'popup', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [41 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 72 ; 88 ; 16], 'String', 'OLMEN', 'UserData', 3);

Graphics.RadarScreen.Control.Direct.CoordButton = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'radiobutton', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [4 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 102 ; 100 ; 20], 'String', 'Coordinate');
Graphics.RadarScreen.Control.Direct.LatNS = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'edit', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [10 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 120 ; 18 ; 18], 'HorizontalAlignment', 'left', 'String', 'N');
Graphics.RadarScreen.Control.Direct.LatDeg = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'edit', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [30 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 120 ; 18 ; 18], 'String', '32');
Graphics.RadarScreen.Control.Direct.LatDegText = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'text', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [48 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 120 ; 10 ; 16], 'String', '˚', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Direct.LatMin = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'edit', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [59 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 120 ; 18 ; 18], 'String', '56');
Graphics.RadarScreen.Control.Direct.LatMinText = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'text', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [77 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 120 ; 10 ; 16], 'String', char(39), 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Direct.LatSec = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'edit', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [89 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 120 ; 25 ; 18], 'String', '25.7');
Graphics.RadarScreen.Control.Direct.LatSecText = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'text', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [114 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 120 ; 10 ; 16], 'String', '"', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Direct.LongEW = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'edit', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [10 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 140 ; 18 ; 18], 'HorizontalAlignment', 'left', 'String', 'E');
Graphics.RadarScreen.Control.Direct.LongDeg = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'edit', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [30 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 140 ; 25 ; 18], 'String', '126');
Graphics.RadarScreen.Control.Direct.LongDegText = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'text', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [55 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 140 ; 10 ; 16], 'String', '˚', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Direct.LongMin = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'edit', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [66 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 140 ; 18 ; 18], 'String', '33');
Graphics.RadarScreen.Control.Direct.LongMinText = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'text', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [84 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 140 ; 10 ; 16], 'String', char(39), 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Direct.LongSec = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'edit', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [95 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 140 ; 25 ; 18], 'String', '85.7');
Graphics.RadarScreen.Control.Direct.LongSecText = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Destination, 'Style', 'text', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [120 ; Graphics.RadarScreen.Control.Direct.Destination.Position(4) - 140 ; 10 ; 16], 'String', '"', 'HorizontalAlignment', 'left');

Graphics.RadarScreen.Control.Direct.Apply = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Panel, 'Style', 'pushbutton', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [4 ; 2 ; 50 ; 17],'HorizontalAlignment','Center', 'String' , 'Apply');
% Graphics.RadarScreen.Control.Direct.Cancel = uicontrol('Parent', Graphics.RadarScreen.Control.Direct.Panel, 'Style', 'pushbutton', 'Units', 'pixels', 'Tag', 'Direct', 'Position', [57 ; 2 ; 50 ; 17],'HorizontalAlignment','Center', 'String' , 'Cancel');

% Control: Misc(Holding, Cross, Deviation)

Graphics.RadarScreen.Control.Misc.WPPanel = uibuttongroup('Parent', Graphics.RadarScreen.Control.Misc.Panel, 'Units', 'pixels', 'Position', [2 ; 2 ; 137 ; Graphics.RadarScreen.Control.Misc.Panel.Position(4) - 19]);
Graphics.RadarScreen.Control.Misc.WPButton = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.WPPanel, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [4 ; Graphics.RadarScreen.Control.Misc.WPPanel.Position(4) - 22 ; 100 ; 20], 'String', 'Waypoint');
Graphics.RadarScreen.Control.Misc.WPNameText = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.WPPanel, 'Style', 'text', 'Units', 'pixels', 'Tag', 'Holding', 'Position', [13 ; Graphics.RadarScreen.Control.Misc.WPPanel.Position(4) - 40 ; 28 ; 16], 'String', 'name', 'HorizontalAlignment', 'right');
Graphics.RadarScreen.Control.Misc.WPName = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.WPPanel, 'Style', 'edit', 'Units', 'pixels', 'Tag', 'Holding', 'Position', [41 ; Graphics.RadarScreen.Control.Misc.WPPanel.Position(4) - 40 ; 46 ; 18], 'String', 'OLMEN', 'UserData', 1);
Graphics.RadarScreen.Control.Misc.WPIDText = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.WPPanel, 'Style', 'text', 'Units', 'pixels', 'Tag', 'Holding', 'Position', [88 ; Graphics.RadarScreen.Control.Misc.WPPanel.Position(4) - 40 ; 15 ; 16], 'String', 'id', 'HorizontalAlignment', 'right');
Graphics.RadarScreen.Control.Misc.WPID = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.WPPanel, 'Style', 'edit', 'Units', 'pixels', 'Tag', 'Holding', 'Position', [104 ; Graphics.RadarScreen.Control.Misc.WPPanel.Position(4) - 40 ; 25 ; 18], 'String', '32', 'UserData', 2);
Graphics.RadarScreen.Control.Misc.WPList = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.WPPanel, 'Style', 'popup', 'Units', 'pixels', 'Tag', 'Holding', 'Position', [41 ; Graphics.RadarScreen.Control.Misc.WPPanel.Position(4) - 59 ; 88 ; 16], 'String', 'OLMEN', 'UserData', 3);
Graphics.RadarScreen.Control.Misc.CurrentPos = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.WPPanel, 'Style', 'radiobutton', 'Units', 'pixels', 'Tag', 'Holding', 'Position', [4 ; 1 ; 100 ; 20], 'String', 'Current Position');


Graphics.RadarScreen.Control.Misc.CommandPanel = uibuttongroup('Parent', Graphics.RadarScreen.Control.Misc.Panel, 'Units', 'pixels', 'Position', [140 ; 2 ; Graphics.RadarScreen.Control.Misc.Panel.Position(3) - 142 ; Graphics.RadarScreen.Control.Misc.Panel.Position(4) - 19]);
Graphics.RadarScreen.Control.Misc.BearingText = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.CommandPanel, 'Style', 'text', 'Units', 'pixels', 'Position', [4 ; Graphics.RadarScreen.Control.Misc.CommandPanel.Position(4) - 25 ; 70 ; 18],'String', 'Bearing (deg)', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Misc.BearingValue = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.CommandPanel, 'Style', 'edit', 'Units', 'pixels', 'Position', [74 ; Graphics.RadarScreen.Control.Misc.CommandPanel.Position(4) - 25 ; 40 ; 18],'String', '250', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Misc.BearingUp = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.CommandPanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [114 ; Graphics.RadarScreen.Control.Misc.CommandPanel.Position(4) - 16 ; 16 ; 12],'HorizontalAlignment','Center', 'Tag', 'Bearing', 'FontSize', 6, 'String' , char(9651), 'UserData', 10);
Graphics.RadarScreen.Control.Misc.BearingDown = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.CommandPanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [114 ; Graphics.RadarScreen.Control.Misc.CommandPanel.Position(4) - 26 ; 16 ; 12],'HorizontalAlignment','Center', 'Tag', 'Bearing', 'FontSize', 6, 'String' , char(9661), 'UserData', -10);

Graphics.RadarScreen.Control.Misc.LevelText = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.CommandPanel, 'Style', 'text', 'Units', 'pixels', 'Position', [4 ; Graphics.RadarScreen.Control.Misc.CommandPanel.Position(4) - 45 ; 70 ; 18],'String', 'Altitude (ft)', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Misc.LevelValue = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.CommandPanel, 'Style', 'edit', 'Units', 'pixels', 'Position', [74 ; Graphics.RadarScreen.Control.Misc.CommandPanel.Position(4) - 45 ; 40 ; 18],'String', '25000', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Misc.LevelUp = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.CommandPanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [114 ; Graphics.RadarScreen.Control.Misc.CommandPanel.Position(4) - 36 ; 16 ; 12],'HorizontalAlignment','Center', 'Tag', 'Level', 'FontSize', 6, 'String' , char(9651), 'UserData', 100);
Graphics.RadarScreen.Control.Misc.LevelDown = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.CommandPanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [114 ; Graphics.RadarScreen.Control.Misc.CommandPanel.Position(4) - 46 ; 16 ; 12],'HorizontalAlignment','Center', 'Tag', 'Level', 'FontSize', 6, 'String' , char(9661), 'UserData', -100);

Graphics.RadarScreen.Control.Misc.TimeText = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.CommandPanel, 'Style', 'text', 'Units', 'pixels', 'Position', [4 ; Graphics.RadarScreen.Control.Misc.CommandPanel.Position(4) - 65 ; 70 ; 18],'String', 'Time (sec)', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Misc.TimeValue = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.CommandPanel, 'Style', 'edit', 'Units', 'pixels', 'Position', [74 ; Graphics.RadarScreen.Control.Misc.CommandPanel.Position(4) - 65 ; 40 ; 18],'String', '180', 'HorizontalAlignment', 'left');
Graphics.RadarScreen.Control.Misc.TimeUp = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.CommandPanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [114 ; Graphics.RadarScreen.Control.Misc.CommandPanel.Position(4) - 56 ; 16 ; 12],'HorizontalAlignment','Center', 'Tag', 'Time', 'FontSize', 6, 'String' , char(9651), 'UserData', 1);
Graphics.RadarScreen.Control.Misc.TimeDown = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.CommandPanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [114 ; Graphics.RadarScreen.Control.Misc.CommandPanel.Position(4) - 66 ; 16 ; 12],'HorizontalAlignment','Center', 'Tag', 'Time', 'FontSize', 6, 'String' , char(9661), 'UserData', -1);

Graphics.RadarScreen.Control.Misc.LeftTurn = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.CommandPanel, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [4 ; 2 ; 40 ; 20], 'String', 'Left');
Graphics.RadarScreen.Control.Misc.RightTurn = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.CommandPanel, 'Style', 'radiobutton', 'Units', 'pixels', 'Position', [46 ; 2 ; 50 ; 20], 'String', 'Right');

Graphics.RadarScreen.Control.Misc.Hold = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.CommandPanel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [100 ; 2 ; 45 ; 17],'HorizontalAlignment','Center', 'String' , 'Hold');
% Graphics.RadarScreen.Control.Misc.Cancel = uicontrol('Parent', Graphics.RadarScreen.Control.Misc.Panel, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', [57 ; 2 ; 50 ; 17],'HorizontalAlignment','Center', 'String' , 'Cancel');


% DataTab / Table & Graph
Graphics.RadarScreen.Data.Tab.Units = 'pixels';
Graphics.RadarScreen.Data.Number.Panel = uipanel('Parent', Graphics.RadarScreen.Data.Tab, 'Units', 'pixels', 'Position', [1 ; 365 ; 290 ; Graphics.RadarScreen.Data.Tab.Position(4) - 366], 'Tag', 'DataTable');
Graphics.RadarScreen.Data.Number.ID = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [5 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 20 ; 50 ; 15], 'HorizontalAlignment', 'left', 'String', ['ID #0']);
Graphics.RadarScreen.Data.Number.Callsign = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [60 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 20 ; 60 ; 15], 'HorizontalAlignment', 'left', 'String', ['Callsign']);
Graphics.RadarScreen.Data.Number.Type = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [125 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 20 ; 50 ; 15], 'HorizontalAlignment', 'left', 'String', ['AC Type']);
Graphics.RadarScreen.Data.Number.Squawk = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [180 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 20 ; 100 ; 15], 'HorizontalAlignment', 'left', 'String', ['Squawk']);
Graphics.RadarScreen.Data.Number.Status = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [5 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 37 ; 50 ; 15], 'HorizontalAlignment', 'left', 'String', ['Status']);
Graphics.RadarScreen.Data.Number.DataOrig = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [60 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 37 ; 200 ; 15], 'HorizontalAlignment', 'left', 'String', ['Data Input']);

Graphics.RadarScreen.Data.Number.Latitude.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [1 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 58 ; 60 ; 15], 'HorizontalAlignment', 'right', 'String', 'Latitude');
Graphics.RadarScreen.Data.Number.Latitude.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [63 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 58 ; 70 ; 15], 'HorizontalAlignment', 'left', 'String', ['31?5' char(39) '26.1"'], 'Enable', 'off');
Graphics.RadarScreen.Data.Number.Longitude.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [150 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 58 ; 60 ; 15], 'HorizontalAlignment', 'right', 'String', 'Longitude');
Graphics.RadarScreen.Data.Number.Longitude.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [212 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 58 ; 70 ; 15], 'HorizontalAlignment', 'left', 'String', ['131?5' char(39) '26.1"'], 'Enable', 'off');
Graphics.RadarScreen.Data.Number.Altitude.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [1 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 75 ; 60 ; 15], 'HorizontalAlignment', 'right', 'String', 'Altitude');
Graphics.RadarScreen.Data.Number.Altitude.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [63 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 75 ; 70 ; 15], 'HorizontalAlignment', 'left', 'String', '52325.12 ft', 'Enable', 'off');
Graphics.RadarScreen.Data.Number.FlapSetting.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [150 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 75 ; 60 ; 15], 'HorizontalAlignment', 'right', 'String', 'Flap Setting');
Graphics.RadarScreen.Data.Number.FlapSetting.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [212 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 75 ; 70 ; 15], 'HorizontalAlignment', 'left', 'String', 'Cruise', 'Enable', 'off');
Graphics.RadarScreen.Data.Number.Heading.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [1 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 95 ; 30 ; 15], 'HorizontalAlignment', 'right', 'String', 'HDG');
Graphics.RadarScreen.Data.Number.Heading.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [33 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 95 ; 55 ; 15], 'HorizontalAlignment', 'left', 'String', '312.5˚', 'Enable', 'off');
Graphics.RadarScreen.Data.Number.Speed.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [95 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 95 ; 30 ; 15], 'HorizontalAlignment', 'right', 'String', 'TAS');
Graphics.RadarScreen.Data.Number.Speed.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [127 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 95 ; 55 ; 15], 'HorizontalAlignment', 'left', 'String', '192.5 kt', 'Enable', 'off');
Graphics.RadarScreen.Data.Number.VertSpeed.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [184 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 95 ; 30 ; 15], 'HorizontalAlignment', 'right', 'String', 'VS');
Graphics.RadarScreen.Data.Number.VertSpeed.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [216 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 95 ; 60 ; 15], 'HorizontalAlignment', 'left', 'String', '-2200.5 ft/s', 'Enable', 'off');
Graphics.RadarScreen.Data.Number.LongAccel.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [1 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 112 ; 30 ; 15], 'HorizontalAlignment', 'right', 'String', 'L.A');
Graphics.RadarScreen.Data.Number.LongAccel.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [33 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 112 ; 55 ; 15], 'HorizontalAlignment', 'left', 'String', '-5.52 ft/s²', 'Enable', 'off');
Graphics.RadarScreen.Data.Number.VertAccel.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [95 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 112 ; 30 ; 15], 'HorizontalAlignment', 'right', 'String', 'V.A.');
Graphics.RadarScreen.Data.Number.VertAccel.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [127 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 112 ; 55 ; 15], 'HorizontalAlignment', 'left', 'String', '+0.02 ft/s²', 'Enable', 'off');
Graphics.RadarScreen.Data.Number.RateOfTurn.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [184 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 112 ; 30 ; 15], 'HorizontalAlignment', 'right', 'String', 'ROT.');
Graphics.RadarScreen.Data.Number.RateOfTurn.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [216 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 112 ; 60 ; 15], 'HorizontalAlignment', 'left', 'String', '+1.2 deg/s', 'Enable', 'off');
Graphics.RadarScreen.Data.Number.Thrust.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [1 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 129 ; 30 ; 15], 'HorizontalAlignment', 'right', 'String', 'Thr.');
Graphics.RadarScreen.Data.Number.Thrust.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [33 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 129 ; 55 ; 15], 'HorizontalAlignment', 'left', 'String', '153829 N', 'Enable', 'off');
Graphics.RadarScreen.Data.Number.Drag.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [95 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 129 ; 30 ; 15], 'HorizontalAlignment', 'right', 'String', 'Drag');
Graphics.RadarScreen.Data.Number.Drag.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [127 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 129 ; 55 ; 15], 'HorizontalAlignment', 'left', 'String', '153829 N', 'Enable', 'off');
Graphics.RadarScreen.Data.Number.Lift.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [184 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 129 ; 30 ; 15], 'HorizontalAlignment', 'right', 'String', 'Lift');
Graphics.RadarScreen.Data.Number.Lift.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [216 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 129 ; 60 ; 15], 'HorizontalAlignment', 'left', 'String', '153829 N', 'Enable', 'off');
Graphics.RadarScreen.Data.Number.Mass.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [1 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 146 ; 30 ; 15], 'HorizontalAlignment', 'right', 'String', 'Mass');
Graphics.RadarScreen.Data.Number.Mass.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [33 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 146 ; 55 ; 15], 'HorizontalAlignment', 'left', 'String', '35.25 t', 'Enable', 'off');
Graphics.RadarScreen.Data.Number.FuelFlow.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [95 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 146 ; 30 ; 15], 'HorizontalAlignment', 'right', 'String', 'F.F.');
Graphics.RadarScreen.Data.Number.FuelFlow.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [127 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 146 ; 55 ; 15], 'HorizontalAlignment', 'left', 'String', '0.15 kg/min', 'Enable', 'off');
Graphics.RadarScreen.Data.Number.FuelCon.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [184 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 146 ; 30 ; 15], 'HorizontalAlignment', 'right', 'String', 'Fuel');
Graphics.RadarScreen.Data.Number.FuelCon.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [216 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 146 ; 60 ; 15], 'HorizontalAlignment', 'left', 'String', '1025 kg', 'Enable', 'off');
Graphics.RadarScreen.Data.Number.GenTime.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [1 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 163 ; 30 ; 15], 'HorizontalAlignment', 'right', 'String', 'TOT');
Graphics.RadarScreen.Data.Number.GenTime.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [33 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 163 ; 55 ; 15], 'HorizontalAlignment', 'left', 'String', '2100', 'Enable', 'off');
Graphics.RadarScreen.Data.Number.ELDT.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [95 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 163 ; 30 ; 15], 'HorizontalAlignment', 'right', 'String', 'ELDT');
Graphics.RadarScreen.Data.Number.ELDT.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [127 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 163 ; 55 ; 15], 'HorizontalAlignment', 'left', 'String', '16200', 'Enable', 'off');
Graphics.RadarScreen.Data.Number.AirTime.Text = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [184 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 163 ; 30 ; 15], 'HorizontalAlignment', 'right', 'String', 'A.T.');
Graphics.RadarScreen.Data.Number.AirTime.Value = uicontrol('Parent', Graphics.RadarScreen.Data.Number.Panel, 'Style', 'edit', 'Units', 'pixels', 'Position', [216 ; Graphics.RadarScreen.Data.Number.Panel.Position(4) - 163 ; 60 ; 15], 'HorizontalAlignment', 'left', 'String', '10000', 'Enable', 'off');

Graphics.RadarScreen.Data.Graph.Panel = uipanel('Parent', Graphics.RadarScreen.Data.Tab, 'Units', 'pixels', 'Position', [1 ; 0 ; 290 ; 363], 'Tag', 'DataGraph');
Graphics.RadarScreen.Data.Graph.Target = uicontrol('Parent', Graphics.RadarScreen.Data.Graph.Panel, 'Style', 'text', 'Units', 'pixels', 'Position', [1 ; 340 ; 289 ; 15], 'String', ['Target ID: #' num2str(config.GraphTarget)], 'HorizontalAlignment', 'center');
Graphics.RadarScreen.Data.Graph.Altitude = axes('Parent', Graphics.RadarScreen.Data.Graph.Panel, 'Units', 'pixels', 'Position', [21 ; 280 ; 120 ; 45], 'Tag', 'Altitude', 'FontSize',8 , 'XGrid', 'on', 'YAxisLocation', 'left', 'XLim', [-config.GraphRange config.GraphRange], 'YLim', [-100 60000], 'XTick', [0:30:config.simtime]);
Graphics.RadarScreen.Data.Graph.Heading = axes('Parent', Graphics.RadarScreen.Data.Graph.Panel, 'Units', 'pixels', 'Position', [165 ; 280 ; 120 ; 45], 'Tag', 'Heading', 'FontSize',8 , 'XGrid', 'on', 'YAxisLocation', 'left', 'XLim', [-config.GraphRange config.GraphRange], 'YLim', [-3 363], 'XTick', [0:30:config.simtime]);
Graphics.RadarScreen.Data.Graph.Speed = axes('Parent', Graphics.RadarScreen.Data.Graph.Panel, 'Units', 'pixels', 'Position', [21 ; 215 ; 120 ; 45], 'Tag', 'Speed', 'FontSize',8 , 'XGrid', 'on', 'YAxisLocation', 'left', 'XLim', [-config.GraphRange config.GraphRange], 'YLim', [-5 inf], 'XTick', [0:30:config.simtime]);
Graphics.RadarScreen.Data.Graph.VertSpeed = axes('Parent', Graphics.RadarScreen.Data.Graph.Panel, 'Units', 'pixels', 'Position', [165 ; 215 ; 120 ; 45], 'Tag', 'VertSpeed', 'FontSize',8 , 'XGrid', 'on', 'YAxisLocation', 'left', 'XLim', [-config.GraphRange config.GraphRange], 'YLim', [-inf inf], 'XTick', [0:30:config.simtime]);
Graphics.RadarScreen.Data.Graph.LongAccel = axes('Parent', Graphics.RadarScreen.Data.Graph.Panel, 'Units', 'pixels', 'Position', [21 ; 150 ; 120 ; 45], 'Tag', 'LongAccel', 'FontSize',8 , 'XGrid', 'on', 'YAxisLocation', 'left', 'XLim', [-config.GraphRange config.GraphRange], 'YLim', [-5.5 5.5], 'XTick', [0:30:config.simtime]);
Graphics.RadarScreen.Data.Graph.VertAccel = axes('Parent', Graphics.RadarScreen.Data.Graph.Panel, 'Units', 'pixels', 'Position', [165 ; 150 ; 120 ; 45], 'Tag', 'VertAccel', 'FontSize',8 , 'XGrid', 'on', 'YAxisLocation', 'left', 'XLim', [-config.GraphRange config.GraphRange], 'YLim', [-5.5 5.5], 'XTick', [0:30:config.simtime]);
Graphics.RadarScreen.Data.Graph.Thrust = axes('Parent', Graphics.RadarScreen.Data.Graph.Panel, 'Units', 'pixels', 'Position', [21 ; 85 ; 120 ; 45], 'Tag', 'Thrust', 'FontSize',8 , 'XGrid', 'on', 'YAxisLocation', 'left', 'XLim', [-config.GraphRange config.GraphRange], 'YLim', [-10 inf], 'XTick', [0:30:config.simtime]);
Graphics.RadarScreen.Data.Graph.Mass = axes('Parent', Graphics.RadarScreen.Data.Graph.Panel, 'Units', 'pixels', 'Position', [165 ; 85 ; 120 ; 45], 'Tag', 'Mass', 'FontSize',8 , 'XGrid', 'on', 'YAxisLocation', 'left', 'XLim', [-config.GraphRange config.GraphRange], 'YLim', [0 inf], 'XTick', [0:30:config.simtime]);
Graphics.RadarScreen.Data.Graph.Lift = axes('Parent', Graphics.RadarScreen.Data.Graph.Panel, 'Units', 'pixels', 'Position', [21 ; 20 ; 120 ; 45], 'Tag', 'Lift', 'FontSize',8 , 'XGrid', 'on', 'YAxisLocation', 'left', 'XLim', [-config.GraphRange config.GraphRange], 'YLim', [0 inf], 'XTick', [0:30:config.simtime]);
Graphics.RadarScreen.Data.Graph.Drag = axes('Parent', Graphics.RadarScreen.Data.Graph.Panel, 'Units', 'pixels', 'Position', [165 ; 20 ; 120 ; 45], 'Tag', 'Drag', 'FontSize',8 , 'XGrid', 'on', 'YAxisLocation', 'left', 'XLim', [-config.GraphRange config.GraphRange], 'YLim', [0 inf], 'XTick', [0:30:config.simtime]);

Graphics.RadarScreen.Data.Graph.Altitude.Title.String = 'Altitude (ft)';
Graphics.RadarScreen.Data.Graph.Altitude.XAxis.Visible = 'off';
Graphics.RadarScreen.Data.Graph.Heading.Title.String = 'Heading (?';
Graphics.RadarScreen.Data.Graph.Heading.XAxis.Visible = 'off';
Graphics.RadarScreen.Data.Graph.Speed.Title.String = 'Ground Airspeed (kt)';
Graphics.RadarScreen.Data.Graph.Speed.XAxis.Visible = 'off';
Graphics.RadarScreen.Data.Graph.VertSpeed.Title.String = 'Vertical Speed (ft/sec)';
Graphics.RadarScreen.Data.Graph.VertSpeed.XAxis.Visible = 'off';
Graphics.RadarScreen.Data.Graph.LongAccel.Title.String = 'Longitudinal Acceleration (ft/s?';
Graphics.RadarScreen.Data.Graph.LongAccel.XAxis.Visible = 'off';
Graphics.RadarScreen.Data.Graph.VertAccel.Title.String = 'Vertical Acceleration (ft/s?';
Graphics.RadarScreen.Data.Graph.VertAccel.XAxis.Visible = 'off';
Graphics.RadarScreen.Data.Graph.Thrust.Title.String = 'Thrust (N)';
Graphics.RadarScreen.Data.Graph.Thrust.XAxis.Visible = 'off';
Graphics.RadarScreen.Data.Graph.Mass.Title.String = 'Mass (t)';
Graphics.RadarScreen.Data.Graph.Mass.XAxis.Visible = 'off';
Graphics.RadarScreen.Data.Graph.Lift.Title.String = 'Lift (N)';
Graphics.RadarScreen.Data.Graph.Lift.XAxis.Visible = 'off';
Graphics.RadarScreen.Data.Graph.Drag.Title.String = 'Drag (N)';
Graphics.RadarScreen.Data.Graph.Drag.XAxis.Visible = 'off';

% Procedure View
Graphics.RadarScreen.Procedure.Tab.Units = 'pixels';
Graphics.RadarScreen.Procedure.AirRoute.Panel = uipanel('Parent', Graphics.RadarScreen.Procedure.Tab, 'Units', 'pixels', 'Title', 'Air Route', 'Position', [1 ; 365 ; 290 ; Graphics.RadarScreen.Procedure.Tab.Position(4) - 366]);
Graphics.RadarScreen.Procedure.AirRoute.NationalList = uicontrol('Parent', Graphics.RadarScreen.Procedure.AirRoute.Panel, 'Style', 'popup', 'Units', 'pixels', 'Position', [1 ; Graphics.RadarScreen.Procedure.AirRoute.Panel.Position(4) - 40 ; 100 ; 18], 'String', {'All' ; 'International'}, 'Tag', 'ARFilterList');
Graphics.RadarScreen.Procedure.AirRoute.WaypointOpt = uicontrol('Parent', Graphics.RadarScreen.Procedure.AirRoute.Panel, 'Style', 'checkbox', 'Units', 'pixels', 'Position', [110 ; Graphics.RadarScreen.Procedure.AirRoute.Panel.Position(4) - 40 ; 130 ; 20], 'Value', 0, 'String', 'Show Waypoints', 'Tag', 'WaypointOpt');

Graphics.RadarScreen.Procedure.AirRoute.Table = uitable('Parent', Graphics.RadarScreen.Procedure.AirRoute.Panel, 'Units', 'pixels', 'Position', [1 ; 0 ; 290 ; Graphics.RadarScreen.Procedure.AirRoute.Panel.Position(4) - 50], 'Fontsize', 8, 'Tag', 'AirRouteList', 'ColumnEditable', [false false false true]);


Graphics.RadarScreen.Procedure.AirRoute.Table.Units = 'pixels';

Graphics.RadarScreen.Procedure.AirRoute.Table.ColumnName = {'ID', ...
           '<html><center>Name</center></html>', ...
           '<html><center>Region</center></html>', ...
           '<html><center>Highlight</center></html>'
           };
       

Graphics.RadarScreen.Procedure.AirRoute.Table.RowName = [];

Graphics.RadarScreen.Procedure.AirRoute.Table.ColumnWidth = {30 45 60 'auto'};

Graphics.RadarScreen.Procedure.AirRouteobj = findjobj(Graphics.RadarScreen.Procedure.AirRoute.Table);
arTable = Graphics.RadarScreen.Procedure.AirRouteobj.getViewport.getView;
arTable.setAutoResizeMode(arTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

Graphics.RadarScreen.Procedure.Procedure.Panel = uipanel('Parent', Graphics.RadarScreen.Procedure.Tab, 'Units', 'pixels', 'Title', 'Procedure',  'Position', [1 ; 1 ; 290 ; 364]);

Graphics.RadarScreen.Procedure.Procedure.NationalList = uicontrol('Parent', Graphics.RadarScreen.Procedure.Procedure.Panel, 'Style', 'popup', 'Units', 'pixels', 'Position', [1 ; Graphics.RadarScreen.Procedure.Procedure.Panel.Position(4) - 45 ; 60 ; 18], 'String', {'All'}, 'Tag', 'ProcNationFilterList');
Graphics.RadarScreen.Procedure.Procedure.AirportList = uicontrol('Parent', Graphics.RadarScreen.Procedure.Procedure.Panel, 'Style', 'popup', 'Units', 'pixels', 'Position', [64 ; Graphics.RadarScreen.Procedure.Procedure.Panel.Position(4) - 45 ; 60 ; 18], 'String', {'All'}, 'Tag', 'ProcAirportFilterList');
Graphics.RadarScreen.Procedure.Procedure.SIDcheck = uicontrol('Parent', Graphics.RadarScreen.Procedure.Procedure.Panel, 'Style', 'checkbox', 'Units', 'pixels', 'Position', [127 ; Graphics.RadarScreen.Procedure.Procedure.Panel.Position(4) - 35 ; 50 ; 15], 'Value', 1, 'String', 'SID', 'Tag', 'SIDCheck');
Graphics.RadarScreen.Procedure.Procedure.STARcheck = uicontrol('Parent', Graphics.RadarScreen.Procedure.Procedure.Panel, 'Style', 'checkbox', 'Units', 'pixels', 'Position', [127 ; Graphics.RadarScreen.Procedure.Procedure.Panel.Position(4) - 50 ; 50 ; 15], 'Value', 1, 'String', 'STAR', 'Tag', 'STARCheck');
Graphics.RadarScreen.Procedure.Procedure.INSTcheck = uicontrol('Parent', Graphics.RadarScreen.Procedure.Procedure.Panel, 'Style', 'checkbox', 'Units', 'pixels', 'Position', [179 ; Graphics.RadarScreen.Procedure.Procedure.Panel.Position(4) - 35 ; 110 ; 15], 'Value', 1, 'String', 'Instrument App', 'Tag', 'INSTCheck');
Graphics.RadarScreen.Procedure.Procedure.MISScheck = uicontrol('Parent', Graphics.RadarScreen.Procedure.Procedure.Panel, 'Style', 'checkbox', 'Units', 'pixels', 'Position', [179 ; Graphics.RadarScreen.Procedure.Procedure.Panel.Position(4) - 50 ; 110 ; 15], 'Value', 1, 'String', 'Missed App', 'Tag', 'MISSCheck');


Graphics.RadarScreen.Procedure.Procedure.Table = uitable('Parent', Graphics.RadarScreen.Procedure.Procedure.Panel, 'Units', 'pixels', 'Position', [1 ; 0 ; 290 ; Graphics.RadarScreen.Procedure.Procedure.Panel.Position(4) - 60], 'Fontsize', 8, 'Tag', 'AirRouteList', 'ColumnEditable', [false false false true]);


Graphics.RadarScreen.Procedure.Procedure.Table.Units = 'pixels';

Graphics.RadarScreen.Procedure.Procedure.Table.ColumnName = {'ID', ...
           '<html><center>Name</center></html>', ...
           '<html><center>Region</center></html>', ...
           '<html><center>Highlight</center></html>'
           };
       

Graphics.RadarScreen.Procedure.Procedure.Table.RowName = [];

Graphics.RadarScreen.Procedure.Procedure.Table.ColumnWidth = {30 45 60 'auto'};

Graphics.RadarScreen.Procedure.Procedureobj = findjobj(Graphics.RadarScreen.Procedure.Procedure.Table);
prTable = Graphics.RadarScreen.Procedure.Procedureobj.getViewport.getView;
prTable.setAutoResizeMode(prTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);



% Display Options
Graphics.RadarScreen.Option.Tab.Units = 'pixels';
Graphics.RadarScreen.Option.ACpanel = uipanel('Parent', Graphics.RadarScreen.Option.Tab, 'Units', 'pixels', 'Title', 'Aircraft', 'Position', [1 ; 365 ; 290 ; Graphics.RadarScreen.Option.Tab.Position(4) - 366], 'Tag', 'ACPanel');
Graphics.RadarScreen.Option.ENVpanel = uipanel('Parent', Graphics.RadarScreen.Option.Tab, 'Units', 'pixels', 'Title', 'Environment',  'Position', [1 ; 1 ; 290 ; 364], 'Tag', 'ACPanel');

% Initialize Size
Graphics.MainWindow.screen.Units = 'normalized';
Graphics.MainWindow.tgroup.Units = 'normalized';
Graphics.MainWindow.tab_radar.Units = 'normalized';
Graphics.MainWindow.tab_plan.Units = 'normalized';
Graphics.MainWindow.tab_data.Units = 'normalized';
Graphics.MainWindow.tab_traj.Units = 'normalized';
Graphics.MainWindow.tab_log.Units = 'normalized';
Graphics.MainWindow.tab_config.Units = 'normalized';
Graphics.MainWindow.tab_map.Units = 'normalized';
Graphics.MainWindow.tab_weather.Units = 'normalized';
Graphics.MainWindow.Console.Units = 'normalized';
Graphics.MainWindow.Display.Units = 'normalized';

Graphics.RadarScreen.MastPanel.Units = 'normalized';


Graphics.RadarScreen.Target.Object.Units = 'normalized';
Graphics.RadarScreen.Target.Follow.Units = 'normalized';
Graphics.RadarScreen.Target.Trajectory.Units = 'normalized';
Graphics.RadarScreen.Target.ControlPoint.Units = 'normalized';
% Graphics.RadarScreen.Target.Waypoint.Units = 'normalized';
Graphics.RadarScreen.Target.Play.Units = 'normalized';
Graphics.RadarScreen.Target.Pause.Units = 'normalized';
Graphics.RadarScreen.Target.Stop.Units = 'normalized';
Graphics.RadarScreen.Target.Graph.Units = 'normalized';

Graphics.RadarScreen.Magnitude.Units = 'normalized';
Graphics.RadarScreen.MagText.Units = 'normalized';
Graphics.RadarScreen.Speed.Units = 'normalized';
Graphics.RadarScreen.Speedup.Units = 'normalized';
Graphics.RadarScreen.Speeddown.Units = 'normalized';
Graphics.RadarScreen.Timer.Units = 'normalized';
Graphics.RadarScreen.Timerup.Units = 'normalized';
Graphics.RadarScreen.Timerdown.Units = 'normalized';
Graphics.RadarScreen.Mode.Units = 'normalized';
Graphics.RadarScreen.RealTime.Units = 'normalized';
Graphics.RadarScreen.FastTime.Units = 'normalized';
Graphics.RadarScreen.SlowMotion.Units = 'normalized';
Graphics.RadarScreen.CamTarget.Units = 'normalized';

Graphics.RadarScreen.DispPanel.Units = 'normalized';

Graphics.RadarScreen.Table.Tab.Units = 'normalized';
Graphics.RadarScreen.Table.Object.Units = 'normalized';

Graphics.RadarScreen.Table.FilterButton.Units = 'normalized';
Graphics.RadarScreen.Table.FilterList.Units = 'normalized';
Graphics.RadarScreen.Table.FilterInbound.Units = 'normalized';
Graphics.RadarScreen.Table.FilterOutbound.Units = 'normalized';
Graphics.RadarScreen.Table.RefreshButton.Units = 'normalized';

Graphics.RadarScreen.Plan.Tab.Units = 'normalized';
Graphics.RadarScreen.Plan.Strip.Units = 'normalized';
Graphics.RadarScreen.Plan.Detail.Units = 'normalized';

Graphics.RadarScreen.Trajectory.Tab.Units = 'normalized';

Graphics.RadarScreen.Control.Tab.Units = 'normalized';
Graphics.RadarScreen.Control.MastPanel.Units = 'normalized';

Graphics.RadarScreen.Control.Option.TrajPanel.Units = 'normalized';
Graphics.RadarScreen.Control.Option.Dynamic.Units = 'normalized';
Graphics.RadarScreen.Control.Option.Static.Units = 'normalized';
Graphics.RadarScreen.Control.Option.Manual.Units = 'normalized';

Graphics.RadarScreen.Control.Option.ManualPanel.Units = 'normalized';
Graphics.RadarScreen.Control.Option.Heading.Units = 'normalized';
Graphics.RadarScreen.Control.Option.Speed.Units = 'normalized';
Graphics.RadarScreen.Control.Option.Altitude.Units = 'normalized';

Graphics.RadarScreen.Control.Heading.Panel.Units = 'normalized';
Graphics.RadarScreen.Control.Heading.DegreePanel.Units = 'normalized';
Graphics.RadarScreen.Control.Heading.FromText.Units = 'normalized';
Graphics.RadarScreen.Control.Heading.FromValue.Units = 'normalized';
Graphics.RadarScreen.Control.Heading.ToText.Units = 'normalized';
Graphics.RadarScreen.Control.Heading.ToValue.Units = 'normalized';
Graphics.RadarScreen.Control.Heading.Up.Units = 'normalized';
Graphics.RadarScreen.Control.Heading.Down.Units = 'normalized';
Graphics.RadarScreen.Control.Heading.TurnDirection.Units = 'normalized';
Graphics.RadarScreen.Control.Heading.Auto.Units = 'normalized';
Graphics.RadarScreen.Control.Heading.Left.Units = 'normalized';
Graphics.RadarScreen.Control.Heading.Right.Units = 'normalized';
Graphics.RadarScreen.Control.Heading.BankanblePanel.Units = 'normalized';
Graphics.RadarScreen.Control.Heading.Nomial.Units = 'normalized';
Graphics.RadarScreen.Control.Heading.Maximum.Units = 'normalized';
Graphics.RadarScreen.Control.Heading.Apply.Units = 'normalized';
Graphics.RadarScreen.Control.Heading.Cancel.Units = 'normalized';

Graphics.RadarScreen.Control.Altitude.Panel.Units = 'normalized';
Graphics.RadarScreen.Control.Altitude.LevelPanel.Units = 'normalized';
Graphics.RadarScreen.Control.Altitude.FromText.Units = 'normalized';
Graphics.RadarScreen.Control.Altitude.FromValue.Units = 'normalized';
Graphics.RadarScreen.Control.Altitude.ToText.Units = 'normalized';
Graphics.RadarScreen.Control.Altitude.ToValue.Units = 'normalized';
Graphics.RadarScreen.Control.Altitude.Up.Units = 'normalized';
Graphics.RadarScreen.Control.Altitude.Down.Units = 'normalized';
Graphics.RadarScreen.Control.Altitude.ROCDPanel.Units = 'normalized';
Graphics.RadarScreen.Control.Altitude.Nominal.Units = 'normalized';
Graphics.RadarScreen.Control.Altitude.Expedite.Units = 'normalized';
Graphics.RadarScreen.Control.Altitude.Manual.Units = 'normalized';
Graphics.RadarScreen.Control.Altitude.ROCDValue.Units = 'normalized';
Graphics.RadarScreen.Control.Altitude.UnitText.Units = 'normalized';
Graphics.RadarScreen.Control.Altitude.Apply.Units = 'normalized';
Graphics.RadarScreen.Control.Altitude.Cancel.Units = 'normalized';

Graphics.RadarScreen.Control.Speed.Panel.Units = 'normalized';
Graphics.RadarScreen.Control.Speed.AirspeedPanel.Units = 'normalized';
Graphics.RadarScreen.Control.Speed.TAS.Units = 'normalized';
Graphics.RadarScreen.Control.Speed.IAS.Units = 'normalized';
Graphics.RadarScreen.Control.Speed.Mach.Units = 'normalized';
Graphics.RadarScreen.Control.Speed.FromText.Units = 'normalized';
Graphics.RadarScreen.Control.Speed.FromValue.Units = 'normalized';
Graphics.RadarScreen.Control.Speed.ToText.Units = 'normalized';
Graphics.RadarScreen.Control.Speed.ToValue.Units = 'normalized';
Graphics.RadarScreen.Control.Speed.Up.Units = 'normalized';
Graphics.RadarScreen.Control.Speed.Down.Units = 'normalized';
Graphics.RadarScreen.Control.Speed.AccelPanel.Units = 'normalized';
Graphics.RadarScreen.Control.Speed.Auto.Units = 'normalized';
Graphics.RadarScreen.Control.Speed.Maximum.Units = 'normalized';
Graphics.RadarScreen.Control.Speed.Apply.Units = 'normalized';
Graphics.RadarScreen.Control.Speed.Cancel.Units = 'normalized';

Graphics.RadarScreen.Control.Direct.Panel.Units = 'normalized';

Graphics.RadarScreen.Control.Direct.Destination.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.WPButton.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.WPNameText.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.WPName.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.WPIDText.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.WPID.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.WPList.Units = 'normalized';

Graphics.RadarScreen.Control.Direct.CoordButton.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.LatNS.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.LatDeg.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.LatDegText.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.LatMin.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.LatMinText.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.LatSec.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.LatSecText.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.LongEW.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.LongDeg.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.LongDegText.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.LongMin.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.LongMinText.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.LongSec.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.LongSecText.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.Apply.Units = 'normalized';
Graphics.RadarScreen.Control.Direct.Cancel.Units = 'normalized';

Graphics.RadarScreen.Control.Misc.Panel.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.WPPanel.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.WPButton.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.WPNameText.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.WPName.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.WPIDText.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.WPID.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.WPList.Units = 'normalized';


Graphics.RadarScreen.Control.Misc.CommandPanel.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.BearingText.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.BearingValue.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.BearingUp.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.BearingDown.Units = 'normalized';

Graphics.RadarScreen.Control.Misc.LevelText.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.LevelValue.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.LevelUp.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.LevelDown.Units = 'normalized';

Graphics.RadarScreen.Control.Misc.TimeText.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.TimeValue.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.TimeUp.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.TimeDown.Units = 'normalized';

Graphics.RadarScreen.Control.Misc.LeftTurn.Units = 'normalized';
Graphics.RadarScreen.Control.Misc.RightTurn.Units = 'normalized';

Graphics.RadarScreen.Control.Misc.Hold.Units = 'normalized';

Graphics.RadarScreen.Data.Tab.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Panel.Units = 'normalized';
Graphics.RadarScreen.Data.Number.ID.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Callsign.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Type.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Squawk.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Status.Units = 'normalized';
Graphics.RadarScreen.Data.Number.DataOrig.Units = 'normalized';

Graphics.RadarScreen.Data.Number.Latitude.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Longitude.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Altitude.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.FlapSetting.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Heading.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Speed.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.VertSpeed.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.LongAccel.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.VertAccel.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.RateOfTurn.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Thrust.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Drag.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Lift.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Mass.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.FuelFlow.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.FuelCon.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.GenTime.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.ELDT.Text.Units = 'normalized';
Graphics.RadarScreen.Data.Number.AirTime.Text.Units = 'normalized';

Graphics.RadarScreen.Data.Number.Latitude.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Longitude.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Altitude.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.FlapSetting.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Heading.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Speed.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.VertSpeed.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.LongAccel.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.VertAccel.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.RateOfTurn.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Thrust.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Drag.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Lift.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.Mass.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.FuelFlow.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.FuelCon.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.GenTime.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.ELDT.Value.Units = 'normalized';
Graphics.RadarScreen.Data.Number.AirTime.Value.Units = 'normalized';

Graphics.RadarScreen.Data.Graph.Panel.Units = 'normalized';
Graphics.RadarScreen.Data.Graph.Target.Units = 'normalized';
Graphics.RadarScreen.Data.Graph.Altitude.Units = 'normalized';
Graphics.RadarScreen.Data.Graph.Heading.Units = 'normalized';
Graphics.RadarScreen.Data.Graph.Speed.Units = 'normalized';
Graphics.RadarScreen.Data.Graph.VertSpeed.Units = 'normalized';
Graphics.RadarScreen.Data.Graph.LongAccel.Units = 'normalized';
Graphics.RadarScreen.Data.Graph.VertAccel.Units = 'normalized';
Graphics.RadarScreen.Data.Graph.Thrust.Units = 'normalized';
Graphics.RadarScreen.Data.Graph.Mass.Units = 'normalized';
Graphics.RadarScreen.Data.Graph.Lift.Units = 'normalized';
Graphics.RadarScreen.Data.Graph.Drag.Units = 'normalized';

Graphics.RadarScreen.Procedure.Tab.Units = 'normalized';
Graphics.RadarScreen.Procedure.AirRoute.Panel.Units = 'normalized';
Graphics.RadarScreen.Procedure.AirRoute.NationalList.Units = 'normalized';
Graphics.RadarScreen.Procedure.AirRoute.WaypointOpt.Units = 'normalized';
Graphics.RadarScreen.Procedure.AirRoute.Table.Units = 'normalized';

Graphics.RadarScreen.Procedure.Procedure.Panel.Units = 'normalized';
Graphics.RadarScreen.Procedure.Procedure.NationalList.Units = 'normalized';
Graphics.RadarScreen.Procedure.Procedure.AirportList.Units = 'normalized';
Graphics.RadarScreen.Procedure.Procedure.SIDcheck.Units = 'normalized';
Graphics.RadarScreen.Procedure.Procedure.STARcheck.Units = 'normalized';
Graphics.RadarScreen.Procedure.Procedure.INSTcheck.Units = 'normalized';
Graphics.RadarScreen.Procedure.Procedure.MISScheck.Units = 'normalized';

Graphics.RadarScreen.Procedure.Procedure.Table.Units = 'normalized';

Graphics.RadarScreen.Option.Tab.Units = 'normalized';
Graphics.RadarScreen.Option.ACpanel.Units = 'normalized';
Graphics.RadarScreen.Option.ENVpanel.Units = 'normalized';


% Callbacks

    function play_ClickedCallback(hObject, eventdata)
        disp('Play');
        hObject.Parent.Parent.UserData(1) = 1;
        hObject.Parent.Parent.UserData(2) = 1;
        drawnow;
    end

    function pause_ClickedCallback(hObject, eventdata)
        disp('Pause');
        hObject.Parent.Parent.UserData(1) = 1;
        hObject.Parent.Parent.UserData(2) = 0;
        drawnow;
    end

    function stop_ClickedCallback(hObject, eventdata)
        disp('Stop');
        hObject.Parent.Parent.UserData(1) = 0;
        hObject.Parent.Parent.UserData(2) = 0;
        drawnow;
    end

    function Tab_Selection_Callback(Old, New, source,eventdata)
        % Display mesh plot of the currently selected data.
        New.OldValue.ForegroundColor = [0 0 0];
        New.OldValue.Title = New.OldValue.Title(4:end);
        New.NewValue.ForegroundColor = [0 0 0];
        New.NewValue.Title = ['>> ' New.NewValue.Title];
    end



Graphics.MainWindow.screen.Visible = 'on';

end


function MouseWheel_Callback(src,callbackdata)
global Graphics config
MouseLoc = Graphics.MainWindow.screen.CurrentPoint;
if MouseLoc(1,1) < Graphics.RadarScreen.DispPanel.Position(3)
else
    if callbackdata.VerticalScrollCount < 0
        mag = config.Zoom;
        maglim = 1 / config.Zoom;
        
        if log10(Graphics.Parameter.CurrentZoom * mag) / log10(config.Zoom) < 20
            
            Loc = Graphics.RadarScreen.radaraxis.CurrentPoint;
            XNew = Loc(1,1);
            YNew = Loc(1,2);
            XMean = (Graphics.RadarScreen.radaraxis.XLim(1) + Graphics.RadarScreen.radaraxis.XLim(2)) / 2;
            YMean = (Graphics.RadarScreen.radaraxis.YLim(1) + Graphics.RadarScreen.radaraxis.YLim(2)) / 2;
            XLow = XNew + maglim * (Graphics.RadarScreen.radaraxis.XLim(1) - XMean);
            XHigh = XNew + maglim * (Graphics.RadarScreen.radaraxis.XLim(2) - XMean);
            YLow = YNew + maglim * (Graphics.RadarScreen.radaraxis.YLim(1) - YMean);
            YHigh = YNew + maglim * (Graphics.RadarScreen.radaraxis.YLim(2) - YMean);
        end
    elseif callbackdata.VerticalScrollCount > 0
        mag = 1 / config.Zoom;
        maglim = config.Zoom;
        if log10(Graphics.Parameter.CurrentZoom * mag) / log10(config.Zoom) > -20
            XMean = (Graphics.RadarScreen.radaraxis.XLim(1) + Graphics.RadarScreen.radaraxis.XLim(2)) / 2;
            YMean = (Graphics.RadarScreen.radaraxis.YLim(1) + Graphics.RadarScreen.radaraxis.YLim(2)) / 2;
            XLow = XMean + maglim * (Graphics.RadarScreen.radaraxis.XLim(1) - XMean);
            XHigh = XMean + maglim * (Graphics.RadarScreen.radaraxis.XLim(2) - XMean);
            YLow = YMean + maglim * (Graphics.RadarScreen.radaraxis.YLim(1) - YMean);
            YHigh = YMean + maglim * (Graphics.RadarScreen.radaraxis.YLim(2) - YMean);
        end
        
    end
    
    
    Graphics.Parameter.CurrentZoom = Graphics.Parameter.CurrentZoom * mag;
    camzoom(Graphics.RadarScreen.radaraxis, mag)
    
    
    
    Graphics.RadarScreen.radaraxis.XLim = [XLow ; XHigh];
    Graphics.RadarScreen.radaraxis.YLim = [YLow ; YHigh];
    
    
    Graphics.RadarScreen.MagText.String = [' x ' num2str(Graphics.Parameter.CurrentZoom, '%.2f')];
    Graphics.RadarScreen.Magnitude.Value = (log10(Graphics.Parameter.CurrentZoom) / log10(config.Zoom));
ReposDisplayData([XLow ; XHigh], [YLow ; YHigh], Graphics.Parameter.CurrentZoom);
end




end

function KeyPress_Callback(src,callbackdata)
global Graphics
if ~isempty(callbackdata.Modifier)
    switch callbackdata.Modifier{1}
        case 'shift'
            Graphics.Parameter.Modifier = 1;
            Graphics.MainWindow.screen.Pointer = 'fleur';
        case 'control'
            Graphics.Parameter.Modifier = 2;
        case 'alt'
            Graphics.Parameter.Modifier = 3;
    end
else

end
    switch callbackdata.Key
        case 'rightarrow'
            switch Graphics.Parameter.Modifier
                case 1
                    move = (1 / Graphics.Parameter.CurrentZoom) * 0.25;
                    Graphics.RadarScreen.radaraxis.XLim = [Graphics.RadarScreen.radaraxis.XLim(1) + move ; Graphics.RadarScreen.radaraxis.XLim(2) + move];
                case 2
                case 3
                otherwise
            end
        case 'leftarrow'
            switch Graphics.Parameter.Modifier
                case 1
                    move = (1 / Graphics.Parameter.CurrentZoom) * 0.25;
                    Graphics.RadarScreen.radaraxis.XLim = [Graphics.RadarScreen.radaraxis.XLim(1) - move ; Graphics.RadarScreen.radaraxis.XLim(2) - move];
                case 2
                case 3
                otherwise
            end
            
        case 'uparrow'
            switch Graphics.Parameter.Modifier
                case 1
                    move = (1 / Graphics.Parameter.CurrentZoom) * 0.25;
                    Graphics.RadarScreen.radaraxis.YLim = [Graphics.RadarScreen.radaraxis.YLim(1) + move ; Graphics.RadarScreen.radaraxis.YLim(2) + move];
                case 2
                case 3
                otherwise
            end
            
        case 'downarrow'
            switch Graphics.Parameter.Modifier
                case 1
                    move = (1 / Graphics.Parameter.CurrentZoom) * 0.25;
                    Graphics.RadarScreen.radaraxis.YLim = [Graphics.RadarScreen.radaraxis.YLim(1) - move ; Graphics.RadarScreen.radaraxis.YLim(2) - move];
                    
                case 2
                case 3
                otherwise
            end
            
        case 'backquote'
            if strcmp(Graphics.MainWindow.Console.Visible, 'off')
                Graphics.MainWindow.Console.Visible = 'on';
                Graphics.MainWindow.Display.Visible = 'on';
            else
                Graphics.MainWindow.Console.Visible = 'off';
                Graphics.MainWindow.Display.Visible = 'off';
            end
                
        case 'hyphen'
            switch Graphics.Parameter.Modifier
                case 0 % "-"
                    minus_ClickedCallback
            end
        case 'equal'
            switch Graphics.Parameter.Modifier
                case 1 % "+"
                    plus_ClickedCallback
            end
        case 'comma'
            switch Graphics.Parameter.Modifier
                case 1 % "<"
                    slow_ClickedCallback
            end
        case 'period'
            switch Graphics.Parameter.Modifier
                case 1 % ">"
                    fast_ClickedCallback
            end
    end

end

function KeyRelease_Callback(src,callbackdata)
global Graphics
switch callbackdata.Key
    case {'shift' ; 'control' ; 'alt'}
        Graphics.Parameter.Modifier = 0;
        Graphics.MainWindow.screen.Pointer = 'arrow';
end
% 그 외 key 인 경우
    
    
end

function WindowButtonDown_Callback(src,callbackdata)
global Graphics
if Graphics.MainWindow.screen.CurrentPoint(1,1) < Graphics.RadarScreen.DispPanel.Position(3)
else
    if Graphics.Parameter.Modifier == 1
        Loc = Graphics.RadarScreen.radaraxis.CurrentPoint;
        Graphics.Parameter.Pan.XOld = Loc(1,1);
        Graphics.Parameter.Pan.YOld = Loc(1,2);
        
        Graphics.MainWindow.screen.WindowButtonMotionFcn = @PanMotion;
    end
end



end

function PanMotion(src,callbackdata)
global Graphics
if Graphics.MainWindow.screen.CurrentPoint(1,1) < Graphics.RadarScreen.DispPanel.Position(3)
else
    if Graphics.Parameter.Modifier == 1
        Loc = Graphics.RadarScreen.radaraxis.CurrentPoint;
        Graphics.Parameter.Pan.XNew = Loc(1,1);
        Graphics.Parameter.Pan.YNew = Loc(1,2);
        
        dx = Graphics.Parameter.Pan.XOld - Graphics.Parameter.Pan.XNew;
        dy = Graphics.Parameter.Pan.YOld - Graphics.Parameter.Pan.YNew;
        
        Graphics.RadarScreen.radaraxis.XLim = [Graphics.RadarScreen.radaraxis.XLim(1) + dx ; Graphics.RadarScreen.radaraxis.XLim(2) + dx];
        Graphics.RadarScreen.radaraxis.YLim = [Graphics.RadarScreen.radaraxis.YLim(1) + dy ; Graphics.RadarScreen.radaraxis.YLim(2) + dy];
        
        Graphics.Parameter.Pan.XOld = Loc(1,1);
        Graphics.Parameter.Pan.YOld = Loc(1,2);
    end
end



end

function WindowButtonUp_Callback(src,callbackdata)
global Graphics
if Graphics.MainWindow.screen.CurrentPoint(1,1) < Graphics.RadarScreen.DispPanel.Position(3)
else
    if Graphics.Parameter.Modifier == 1
        Graphics.Parameter.Pan.XOld = '';
        Graphics.Parameter.Pan.YOld = '';
        Graphics.Parameter.Pan.XNew = '';
        Graphics.Parameter.Pan.YNew = '';
        Graphics.MainWindow.screen.WindowButtonMotionFcn = '';
    end
end


end

function slow_ClickedCallback(hObject, eventdata)
global config Graphics
config.update = max(1, config.update - 1);
Graphics.RadarScreen.Speed.String = ['Speed x ' num2str(config.update, '%.1f')];
Checkmode
end

function fast_ClickedCallback(hObject, eventdata)
global config Graphics
config.update = max(1, config.update + 1);
Graphics.RadarScreen.Speed.String = ['Speed x ' num2str(config.update, '%.1f')];
Checkmode
end

function Timerup_Callback(hObject, eventdata)
global config Graphics
config.timer = max(0, config.timer + 1);
Graphics.RadarScreen.Timer.String = ['Timer x ' num2str(config.timer, '%.1f')];
Checkmode
end

function Timerdown_Callback(hObject, eventdata)
global config Graphics
config.timer = max(0, config.timer - 1);
Graphics.RadarScreen.Timer.String = ['Timer x ' num2str(config.timer, '%.1f')];
Checkmode
end

function Checkmode
global config Graphics
if config.update == config.timer
    Graphics.RadarScreen.RealTime.Value = 1;
    Graphics.RadarScreen.FastTime.Value = 0;
    Graphics.RadarScreen.SlowMotion.Value = 0;
elseif config.timer == 0
    Graphics.RadarScreen.RealTime.Value = 0;
    Graphics.RadarScreen.FastTime.Value = 1;
    Graphics.RadarScreen.SlowMotion.Value = 0;
elseif config.update > config.timer
    Graphics.RadarScreen.RealTime.Value = 0;
    Graphics.RadarScreen.FastTime.Value = 1;
    Graphics.RadarScreen.SlowMotion.Value = 0;
else
    Graphics.RadarScreen.RealTime.Value = 0;
    Graphics.RadarScreen.FastTime.Value = 0;
    Graphics.RadarScreen.SlowMotion.Value = 1;
end
end

function plus_ClickedCallback(hObject, eventdata)
global Graphics config
mag = config.Zoom;
maglim = 1 / config.Zoom;
if log10(Graphics.Parameter.CurrentZoom * mag) / log10(config.Zoom) < 20
Graphics.Parameter.CurrentZoom = Graphics.Parameter.CurrentZoom * mag;

camzoom(Graphics.RadarScreen.radaraxis, mag)

XMean = (Graphics.RadarScreen.radaraxis.XLim(1) + Graphics.RadarScreen.radaraxis.XLim(2)) / 2;
YMean = (Graphics.RadarScreen.radaraxis.YLim(1) + Graphics.RadarScreen.radaraxis.YLim(2)) / 2;

XLow = XMean + maglim * (Graphics.RadarScreen.radaraxis.XLim(1) - XMean);
XHigh = XMean + maglim * (Graphics.RadarScreen.radaraxis.XLim(2) - XMean);
YLow = YMean + maglim * (Graphics.RadarScreen.radaraxis.YLim(1) - YMean);
YHigh = YMean + maglim * (Graphics.RadarScreen.radaraxis.YLim(2) - YMean);

Graphics.RadarScreen.radaraxis.XLim = [XLow ; XHigh];
Graphics.RadarScreen.radaraxis.YLim = [YLow ; YHigh];

Graphics.RadarScreen.MagText.String = [' x ' num2str(Graphics.Parameter.CurrentZoom, '%.2f')];
Graphics.RadarScreen.Magnitude.Value = (log10(Graphics.Parameter.CurrentZoom) / log10(config.Zoom));
else

end


ReposDisplayData([XLow ; XHigh], [YLow ; YHigh], Graphics.Parameter.CurrentZoom);

end

function minus_ClickedCallback(hObject, eventdata)
global Graphics config
mag = 1 / config.Zoom;
maglim = config.Zoom;
if log10(Graphics.Parameter.CurrentZoom * mag) / log10(config.Zoom) > -20
Graphics.Parameter.CurrentZoom = Graphics.Parameter.CurrentZoom * mag;
camzoom(Graphics.RadarScreen.radaraxis, mag)

XMean = (Graphics.RadarScreen.radaraxis.XLim(1) + Graphics.RadarScreen.radaraxis.XLim(2)) / 2;
YMean = (Graphics.RadarScreen.radaraxis.YLim(1) + Graphics.RadarScreen.radaraxis.YLim(2)) / 2;

XLow = XMean + maglim * (Graphics.RadarScreen.radaraxis.XLim(1) - XMean);
XHigh = XMean + maglim * (Graphics.RadarScreen.radaraxis.XLim(2) - XMean);
YLow = YMean + maglim * (Graphics.RadarScreen.radaraxis.YLim(1) - YMean);
YHigh = YMean + maglim * (Graphics.RadarScreen.radaraxis.YLim(2) - YMean);

Graphics.RadarScreen.radaraxis.XLim = [XLow ; XHigh];
Graphics.RadarScreen.radaraxis.YLim = [YLow ; YHigh];

Graphics.RadarScreen.MagText.String = [' x ' num2str(Graphics.Parameter.CurrentZoom, '%.2f')];
Graphics.RadarScreen.Magnitude.Value = (log10(Graphics.Parameter.CurrentZoom) / log10(config.Zoom));

ReposDisplayData([XLow ; XHigh], [YLow ; YHigh], Graphics.Parameter.CurrentZoom);

end


end

function enter_ClickedCallback(hObject, eventdata)
global Graphics
Graphics.MainWindow.Console.Visible = 'on';
Graphics.MainWindow.Display.Visible = 'on';
end

function RealTime_Callback(hObject, eventdata, handles)
global config Graphics
if get(hObject, 'Value')
    config.timer = 1;
    config.update = 1;
    Graphics.RadarScreen.FastTime.Value = 0;
    Graphics.RadarScreen.SlowMotion.Value = 0;
    Graphics.RadarScreen.Speed.String = ['Speed x ' num2str(config.update, '%.1f')];
    Graphics.RadarScreen.Timer.String = ['Timer x ' num2str(config.timer, '%.1f')];
end
end

function FastTime_Callback(hObject, eventdata, handles)
global config Graphics
if get(hObject, 'Value')
    config.timer = 0;
    Graphics.RadarScreen.RealTime.Value = 0;
    Graphics.RadarScreen.SlowMotion.Value = 0;
    Graphics.RadarScreen.Speed.String = ['Speed x ' num2str(config.update, '%.1f')];
    Graphics.RadarScreen.Timer.String = ['Timer x ' num2str(config.timer, '%.1f')];
end
end

function SlowMotion_Callback(hObject, eventdata, handles)
global config Graphics
if get(hObject, 'Value')
    config.timer = config.update * 2;
    Graphics.RadarScreen.RealTime.Value = 0;
    Graphics.RadarScreen.FastTime.Value = 0;
    Graphics.RadarScreen.Speed.String = ['Speed x ' num2str(config.update, '%.1f')];
    Graphics.RadarScreen.Timer.String = ['Timer x ' num2str(config.timer, '%.1f')];
end
end

function TargetCam_Callback(hObject, eventdata, handles)
global config Graphics
if get(hObject, 'Value')
    config.AircraftCam = 1;
    Graphics.RadarScreen.radaraxis.CameraTargetMode = 'auto';
    Graphics.RadarScreen.radaraxis.CameraViewAngleMode = 'manual';
else
    config.AircraftCam = 0;
    Graphics.RadarScreen.radaraxis.CameraTargetMode = 'manual';
    Graphics.RadarScreen.radaraxis.CameraViewAngleMode = 'auto';
end

% Graphics.RadarScreen.Limit.XCur = Graphics.RadarScreen.radaraxis.XLim;
% Graphics.RadarScreen.Limit.YCur = Graphics.RadarScreen.radaraxis.YLim;

% zoom(Graphics.MainWindow.screen, 'reset');

% Graphics.RadarScreen.radaraxis.XLim = Graphics.RadarScreen.Limit.XCur;
% Graphics.RadarScreen.radaraxis.YLim = Graphics.RadarScreen.Limit.YCur;
end

function ViewTraj_Callback(hObject, eventdata, handles)
global config Graphics
if get(hObject, 'Value')
    config.ViewTraj = 1;
    Graphics.RadarScreen.Trajectory.Line.Visible = 'on';
else
    config.ViewTraj = 0;
    Graphics.RadarScreen.Trajectory.Line.Visible = 'off';
end
end


function ViewCont_Callback(hObject, eventdata, handles)
global config Graphics
if get(hObject, 'Value')
    config.ViewCont = 1;
    Graphics.RadarScreen.Trajectory.From.Visible = 'on';
    Graphics.RadarScreen.Trajectory.To.Visible = 'on';
else
    config.ViewCont = 0;
    Graphics.RadarScreen.Trajectory.From.Visible = 'off';
    Graphics.RadarScreen.Trajectory.To.Visible = 'off';
end
end


function SetGraphTarget(hObject, eventdata, handles)
global config Graphics
    config.GraphTarget = Graphics.RadarScreen.Target.OldID;
    Graphics.Parameter.NewGraph = 1;
    
end


% function ViewWayp_Callback(hObject, eventdata, handles)
% global config Graphics
% if get(hObject, 'Value')
%     config.ViewWayp = 1;
%     Graphics.RadarScreen.Trajectory.Waypoints.Visible = 'on';
%     for index_WPName = 1:length(Graphics.RadarScreen.Trajectory.WPName)
%         Graphics.RadarScreen.Trajectory.WPName(index_WPName).Visible = 'on';
%     end
% else
%     config.ViewWayp = 0;
%     Graphics.RadarScreen.Trajectory.Waypoints.Visible = 'off';
%     for index_WPName = 1:length(Graphics.RadarScreen.Trajectory.WPName)
%         Graphics.RadarScreen.Trajectory.WPName(index_WPName).Visible = 'off';
%     end
% end
% end





function CommandIn_Callback(hObject, eventdata, handles)
global Graphics Command
% Hints: get(hObject,'String') returns contents of CommandIn as text
%        str2double(get(hObject,'String')) returns contents of CommandIn as a double
Input = get(hObject, 'String');
if ~isempty(Input)
    Loglen = Command.input{end,1};
    
    Command.input(Loglen + 1, 1) = num2cell(Loglen + 1);
    Command.input(Loglen + 1, 2) = cellstr(datestr(datetime('now')));
    Command.input(Loglen + 1, 3) = cellstr(Input);
    Command.new = [Command.new ; Loglen + 1];
    
    hObject.String = '';
    
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

end

function ReposDisplayData(XLim, YLim, Mag)
global Graphics

Graphics.RadarScreen.DisplayData.Timer.Units = 'data';
Graphics.RadarScreen.DisplayData.GlobalData.Units = 'data';
Graphics.RadarScreen.DisplayData.Target.Units = 'data';

XHigh = XLim(2);
XLow = XLim(1);

YHigh = YLim(2);
YLow = YLim(1);

Graphics.RadarScreen.DisplayData.Timer.Position = [0.6 * XHigh + 0.4 * XLow ; 0.67 * YHigh + 0.33 * YLow];
Graphics.RadarScreen.DisplayData.GlobalData.Position = [0.6 * XHigh + 0.4 * XLow ; 0.64 * YHigh + 0.36 * YLow];
Graphics.RadarScreen.DisplayData.Target.Position = [0.6 * XHigh + 0.4 * XLow ; 0.59 * YHigh + 0.41 * YLow];

% plot(Graphics.RadarScreen.DisplayData.Timer.Position(1), Graphics.RadarScreen.DisplayData.Timer.Position(2), 'o')

Graphics.RadarScreen.DisplayData.Timer.Units = 'normalized';
Graphics.RadarScreen.DisplayData.GlobalData.Units = 'normalized';
Graphics.RadarScreen.DisplayData.Target.Units = 'normalized';
end