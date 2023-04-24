function flight = CommandIn(flight, RunTime)

global Command Graphics plan config Airspace Procedure Aerodrome

for CommandLen = 1:length(Command.new)
%         try
    Line = Command.new(CommandLen);
    Output = '';
    String = Command.input{Line,3};
    Valid = 0;
    TrajFlag = 0;
    switch String
        case {'/help' ; '/?'}
            Output = ...
                ['>> ' String sprintf('\n') ...
                '     *** Command Console *** ' sprintf('\n') ...
                '     /pause, /hold : pause simulation' sprintf('\n') ...
                '     /stop, /end, /exit : stop simulation' sprintf('\n') ...
                '     /start, /play, /run : start simulation' sprintf('\n \n') ...
                '     /update [TIME] : set update time to [TIME] (sec)' sprintf('\n') ...
                '     /timer [TIME] : set timer to [TIME] (sec)' sprintf('\n') ...
                '     /simtime [TIME] : set simulation time to [TIME] (sec)' sprintf('\n \n') ...
                '     /fasttime, /ftm : fast-time mode - no timer' sprintf('\n') ...
                '     /realtime, /rtm : real-time mode - set timer & update time to 1 sec' sprintf('\n') ...
                '     /slow : slow mode' sprintf('\n \n') ...
                '     /[CALLSIGN] hold, /[CALLSIGN] pause : hold aircraft[CALLSIGN]' sprintf('\n') ...
                '     /[CALLSIGN] (dynamic ; static) : set aircraft[CALLSIGN] control option to dynamic or static' sprintf('\n') ...
                '     /[CALLSIGN] (hdg[DEG] ; alt[FEET] ; spd[KT]) : set aircraft[CALLSIGN] heading, altitude, airspeed to 000' sprintf('\n \n') ...
                '     ! [INPUT] : MATLAB Direct Input Mode (eval function)'];
            Valid = 1;
            
        case {'/pause' ; '/hold'}
            Output = ['>> ' String sprintf('\n     *** Simulation Pased ***')];
            Graphics.MainWindow.screen.UserData(1) = 1;
            Graphics.MainWindow.screen.UserData(2) = 0;
            Command.run = 1;
            Command.iteration = 0;
            Valid = 1;
            
            
        case {'/stop' ; '/end' ; '/exit' ; '/quit' ; '/esc'}
            Output = ['>> ' String sprintf('\n     *** Simulation Stopped ***')];
            Graphics.MainWindow.screen.UserData(1) = 0;
            Graphics.MainWindow.screen.UserData(2) = 0;
            Command.run = 0;
            Command.iteration = 0;
            Valid = 1;
            
            
        case {'/play';'/run';'/start';'/continue'}
            Output = ['>> ' String sprintf('\n     *** Simulation Started ***')];
            Graphics.MainWindow.screen.UserData(1) = 1;
            Graphics.MainWindow.screen.UserData(2) = 1;
            Command.run = 1;
            Command.iteration = 1;
            Valid = 1;
            
            
        otherwise
            %             if ~isempty(strfind(String, '/'))
            switch String(1)
                case '/'
                    contain = strsplit(String, ' ');
                    target = contain{1};
                    
                    if length(target) == 1
                        % empty Command ('/')
                        
                    else
                        switch target
                            case {'/fasttime' ; '/Fasttime' ; '/Fast'; '/fast' ; '/FTM' ; '/ftm'}
                                config.timer = 0;
                                Graphics.RadarScreen.RealTime.Value = 0;
                                Graphics.RadarScreen.FastTime.Value = 1;
                                Graphics.RadarScreen.SlowMotion.Value = 0;
                                Graphics.RadarScreen.Speed.String = ['Speed x ' num2str(config.update, '%.1f')];
                                Graphics.RadarScreen.Timer.String = ['Timer x ' num2str(config.timer, '%.1f')];
                                Valid = 1;
                                Output = ['>> ' String sprintf('\n     Fast-time mode enabled (timer = 0 sec) ')];
                                
                            case {'/realtime' ; '/Realtime'; '/Real' ; '/real' ; '/RTM' ; '/rtm'}
                                config.timer = 1;
                                config.update = 1;
                                Graphics.RadarScreen.RealTime.Value = 1;
                                Graphics.RadarScreen.FastTime.Value = 0;
                                Graphics.RadarScreen.SlowMotion.Value = 0;
                                Graphics.RadarScreen.Speed.String = ['Speed x ' num2str(config.update, '%.1f')];
                                Graphics.RadarScreen.Timer.String = ['Timer x ' num2str(config.timer, '%.1f')];
                                Valid = 1;
                                Output = ['>> ' String sprintf('\n     Real-time mode enabled (update & timer = 1 sec) ')];
                                
                                
                            case {'/Slow' ; '/slow'}
                                if length(contain) < 2
                                    Output = ['>> ' String sprintf('\n     Slow mode ...error not valid input ')];
                                else
                                    context = contain{2};
                                    if ~isnan(str2double(context))
                                        if str2double(context) > 1
                                            config.timer = str2double(context);
                                            Graphics.RadarScreen.RealTime.Value = 0;
                                            Graphics.RadarScreen.FastTime.Value = 0;
                                            Graphics.RadarScreen.SlowMotion.Value = 1;
                                            Graphics.RadarScreen.Speed.String = ['Speed x ' num2str(config.update, '%.1f')];
                                            Graphics.RadarScreen.Timer.String = ['Timer x ' num2str(config.timer, '%.1f')];
                                            Valid = 1;
                                            Output = ['>> ' String sprintf('\n     Slow mode enabled (timer = %1.1f sec) ', config.timer)];
                                        else
                                            Output = ['>> ' String sprintf('\n     Slow mode ...error slow time must be over 1 sec')];
                                        end
                                    else
                                        Output = ['>> ' String sprintf('\n     Slow mode ...error not valid input ')];
                                    end
                                end
                                
                                
                            case {'/update' ; '/Update' ; '/x' ; '/X'}
                                if length(contain) < 2
                                    Output = ['>> ' String sprintf('\n     Update Time ...error not valid input ')];
                                else
                                    context = contain{2};
                                    if ~isnan(str2double(context))
                                        config.update = str2double(context);
                                        Valid = 1;
                                        Output = ['>> ' String sprintf('\n     Update Time (%1.1f) ', config.update)];
                                        Graphics.RadarScreen.Speed.String =  ['Speed x ' num2str(config.update, '%.1f')];
                                    else
                                        Output = ['>> ' String sprintf('\n     Update Time ...error not valid input ')];
                                    end
                                end
                                
                            case {'/timer' ; '/Timer'}
                                if length(contain) < 2
                                    if config.timer ~= 0
                                        config.timer = 0;
                                    else
                                        config.timer = 1;
                                    end
                                    Valid = 1;
                                    Output = ['>> ' String sprintf('\n     Set Timer (%1.1f) ', config.timer)];
                                else
                                    context = contain{2};
                                    if ~isnan(str2double(context))
                                        config.timer = str2double(context);
                                        Valid = 1;
                                        Output = ['>> ' String sprintf('\n     Set Timer (%1.1f) ', config.timer)];
                                        Graphics.RadarScreen.Timer.String =  ['Timer x ' num2str(config.timer, '%.1f')];
                                    else
                                        Output = ['>> ' String sprintf('\n     Set Timer ...error not valid input ')];
                                    end
                                end
                                
                            case {'/simtime' ; '/Simtime' ; '/Time' ; '/time'}
                                if length(contain) < 2
                                    Output = ['>> ' String sprintf('\n     Simulation Time ...error not valid input ')];
                                else
                                    context = contain{2};
                                    if ~isnan(str2double(context))
                                        config.simtime = str2double(context);
                                        Valid = 1;
                                        Output = ['>> ' String sprintf('\n     Simulation Time (%1.1f) ', config.simtime)];
                                    else
                                        Output = ['>> ' String sprintf('\n     Simulation Time ...error not valid input ')];
                                    end
                                end
                                
                            case {'/hide' ; '/Hide'}
                                if length(contain) < 2
                                    Graphics.RadarScreen.Table.Object.Visible = 'off';
                                    Graphics.MainWindow.Console.Visible = 'off';
                                    Graphics.MainWindow.Display.Visible = 'off';
                                    Valid = 1;
                                    Output = ['>> ' String sprintf('\n     Hide all - table, console, message log')];
                                else
                                    context = contain{2};
                                    switch context
                                        case {'all' ; 'All'}
                                            Graphics.RadarScreen.Table.Object.Visible = 'off';
                                            Graphics.MainWindow.Console.Visible = 'off';
                                            Graphics.MainWindow.Display.Visible = 'off';
                                            Graphics.RadarScreen.Panel.Visible = 'off';
                                            Graphics.RadarScreen.Mode.Visible = 'off';
                                            Graphics.RadarScreen.Timer.Visible = 'off';
                                            Graphics.RadarScreen.Speed.Visible = 'off';
                                            Valid = 1;
                                            Output = ['>> ' String sprintf('\n     Hide all')];
                                        case {'Table' ; 'table' ; 'List' ; 'list'}
                                            Graphics.RadarScreen.Table.Object.Visible = 'off';
                                            Valid = 1;
                                            Output = ['>> ' String sprintf('\n     Hide table')];
                                        case {'Console' ; 'console' ; 'input' ; 'Input' ; 'command' ; 'Command'}
                                            Graphics.MainWindow.Console.Visible = 'off';
                                            Valid = 1;
                                            Output = ['>> ' String sprintf('\n     Hide console')];
                                        case {'message' ; 'Message' ; 'log' ; 'Log'}
                                            Graphics.MainWindow.Display.Visible = 'off';
                                            Valid = 1;
                                            Output = ['>> ' String sprintf('\n     Hide message log')];
                                            
                                    end
                                end
                                
                            case {'/show' ; '/Show' ; '/display' ; '/Display'}
                                if length(contain) < 2
                                    Graphics.RadarScreen.Table.Object.Visible = 'on';
                                    Graphics.MainWindow.Console.Visible = 'on';
                                    Graphics.MainWindow.Display.Visible = 'on';
                                    Valid = 1;
                                    Output = ['>> ' String sprintf('\n     Show all - table, console, message log')];
                                else
                                    context = contain{2};
                                    switch context
                                        case {'all' ; 'All'}
                                            Graphics.RadarScreen.Table.Object.Visible = 'on';
                                            Graphics.MainWindow.Console.Visible = 'on';
                                            Graphics.MainWindow.Display.Visible = 'on';
                                            Graphics.RadarScreen.Panel.Visible = 'on';
                                            Graphics.RadarScreen.Mode.Visible = 'on';
                                            Graphics.RadarScreen.Timer.Visible = 'on';
                                            Graphics.RadarScreen.Speed.Visible = 'on';
                                            Valid = 1;
                                            Output = ['>> ' String sprintf('\n     Show all')];
                                        case {'Table' ; 'table' ; 'List' ; 'list'}
                                            Graphics.RadarScreen.Table.Object.Visible = 'on';
                                            Valid = 1;
                                            Output = ['>> ' String sprintf('\n     Show table')];
                                        case {'Console' ; 'console' ; 'input' ; 'Input' ; 'command' ; 'Command'}
                                            Graphics.MainWindow.Console.Visible = 'on';
                                            Valid = 1;
                                            Output = ['>> ' String sprintf('\n     Show console')];
                                        case {'message' ; 'Message' ; 'log' ; 'Log'}
                                            Graphics.MainWindow.Display.Visible = 'on';
                                            Valid = 1;
                                            Output = ['>> ' String sprintf('\n     Show message log')];
                                            
                                    end
                                end
                                
                                
                            otherwise
%                                 try
                                    if strcmp(target(2:end), 't') || strcmp(target(2:end), 'T') || strcmp(target(2:end), 'target') || strcmp(target(2:end), 'Target') || strcmp(target(2:end), 'TARGET')
                                        AC = Graphics.RadarScreen.Target.NewID;
                                    elseif ~isnan(str2double(target(2:end)))
                                        if rem(str2double(target(2:end)), 1) == 0 && str2double(target(2:end)) <= length(flight)
                                            AC = str2double(target(2:end));
                                        end
                                    elseif ~isempty(strfind({flight.callsign}, target(2:end)))
                                        % matching Callsign
                                        AC = flight(strcmp({flight.callsign},target(2:end))).id;
                                    else
                                        AC = '';
                                    end
                                    
                                    if ~isempty(AC)
                                        for block = 1:length(contain) - 1
                                            context = contain{block + 1};
                                            
                                            if ~isempty(strfind(context, ':')) % Trajectory Command
                                                strarr = strsplit(context, ':');
                                                bef = strarr{1};
                                                aft = strarr{2};
                                                TrajFlag = 1;
                                                switch bef % Trajectory command category
                                                    case {'direct' ; 'dir' ; 'Direct' ; 'Dir' ; 'DIRECT' ; 'DIR'} % Direct to WP
                                                        
                                                        if ~isempty(strfind(aft, '@'))
                                                            strarr = strsplit(aft, '@');
                                                            inputwp = strarr{1};
                                                            optdes = strarr(2:end);
                                                            
                                                            for optblock = 1:length(optdes)
                                                                optcontext = optdes{optblock};
                                                                if length(optcontext) > 3
                                                                   switch optcontext(1:3)
                                                                       case {'alt' ; 'Alt' ; 'ALT'} % set cruise alt
                                                                           option = optcontext(4:end);
                                                                                                                                                      
                                                                       case {'spd' ; 'Spd' ; 'SPD'} % set cruise spd
                                                                               
                                                                           
                                                                       case {'cta' ; 'Cta' ; 'CTA'} % control arrival time
                                                                           
                                                                   end
                                                                   
                                                                   
                                                                   if isnan(str2double(option))
                                                                       option = ''; % Unable to read option
                                                                   else
                                                                       option = str2double(option);
                                                                   end
                                                                else
                                                                    option = ''; % Unable to read option
                                                                           
                                                                end
                                                            end
                                                        else
                                                            inputwp = aft;
                                                            option = ''; % maintain current state
                                                        end
                                                        
                                                        
                                                        
                                                        
                                                        if any(strcmp(inputwp, {Airspace.Waypoint.Name}))
                                                            ind = strcmp(inputwp, {Airspace.Waypoint.Name});
                                                            value = Airspace.Waypoint(ind).id;
                                                            Valid = 1;
                                                            Output = ['>> ' String sprintf('\n     %s : Fly Direct to %s', flight(AC).callsign, inputwp)];
                                                            TrajFlag = 1;
                                                            if ~isempty(option)
                                                                Output = [Output 'with constraint: ' optcontext ' @' num2str(option)];
                                                                
                                                            end
                                                        else
                                                            TrajFlag = 0;
                                                            Valid = 1;
                                                        end
                                                        
                                                    otherwise % Procedure?
                                                        
                                                        
                                                        
                                                end
                                                
                                                
                                                if TrajFlag
                                                    
                                                    if Valid == 1
                                                        flight(AC).command.status = {'direct'};
                                                        flight(AC).command.origination = {''};
                                                        flight(AC).command.destination = {inputwp};
                                                        flight(AC).command.type = {'waypoint'};
                                                        flight(AC).command.trajectory = {''};
                                                        flight(AC).command.altitude = {''};
                                                    else
                                                    end
                                                    
                                                    for k = 1:length(flight(AC).command.status)
                                                        if isempty(flight(AC).command.origination{k}) == 0
                                                            flight(AC).command.origination{k} = Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, flight(AC).command.origination{k})==1).id;
                                                        end
                                                        if isempty(flight(AC).command.destination{k}) == 0
                                                            flight(AC).command.destination{k} = Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, flight(AC).command.destination{k})==1).id;
                                                        end
                                                        if isempty(flight(AC).command.trajectory{k}) == 0
                                                            flight(AC).command.trajectory{k} = Procedure(strcmp({Procedure.name}, flight(AC).command.trajectory{k})==1).id;
                                                        end
                                                    end
                                                    flight(AC).WaypointFrom = 1;
                                                    flight(AC).WaypointTo = 2;
                                                    flight(AC).gentime = RunTime - config.update;
                                                    flight(AC) = AssignTrajectory_rev(flight(AC), Aerodrome, Airspace, Procedure);
                                                    flight(AC) = BezierCurve_rev(flight(AC), 1, RunTime);
                                                    flight(AC) = FlightEnvelope_rev(flight(AC));
                                                    flight(AC).ReferenceFrom = 1;
                                                    flight(AC).ReferenceTo = 2;
                                                    % Change to Static Mode
%                                                     
                                                    flight(AC).manual.cta = [0 ; 0 ; 0];
                                                    flight(AC).manual.spd = [0 ; 0 ; 0];
                                                    flight(AC).manual.hdg = [0 ; 0 ; 0];
                                                    flight(AC).manual.alt = [0 ; 0 ; 0];
                                                    flight(AC).manual.exp = [0;0;0];
                                                    
                                                    Graphics.RadarScreen.Control.Option.Dynamic.Value = 0;
                                                    Graphics.RadarScreen.Control.Option.Static.Value = 1;
                                                    Graphics.RadarScreen.Control.Option.Manual.Value = 0;
                                                else
                                                    if Valid == 1
                                                        Output = ['>> ' String sprintf('\n     %s : Fly Direct to ... error, unknown WP', flight(AC).callsign)];
                                                    end
                                                end
                                                
                                                
                                                
                                                
                                            else
                                                TrajFlag = 0;

                                                switch context
                                                    
                                                    case {'kill' ; 'terminate' ; 'end' ; 'delete'}
                                                        flight(AC).status = 4;
                                                        Valid = 1;
                                                        Output = ['>> ' String sprintf('\n     %s : deleted', flight(AC).callsign)];
                                                        
                                                        
                                                    case {'hold' ; 'pause'}
                                                        if flight(AC).status ~= 5
                                                            flight(AC) = PauseAircraft(flight(AC));
                                                            Valid = 1;
                                                            Output = ['>> ' String sprintf('\n     %s : paused', flight(AC).callsign)];
                                                        else
                                                            flight(AC) = ResumeAircraft(flight(AC));
                                                            Valid = 1;
                                                            Output = ['>> ' String sprintf('\n     %s : resumed', flight(AC).callsign)];
                                                        end
                                                        
                                                    case {'manual' ; 'Manual'}
                                                        flight(AC).manual.cta = [0 ; 0 ; 0];
                                                        flight(AC).manual.spd = [1 ; flight(AC).Vtas_sc ; 0];
                                                        flight(AC).manual.hdg = [1 ; flight(AC).hdg_sc ; 0];
                                                        flight(AC).manual.alt = [1 ; flight(AC).alt_sc ; 0];
                                                        flight(AC).manual.exp = [0 ; 0 ; 0];
                                                        Valid = 1;
                                                        Output = ['>> ' String sprintf('\n     %s : set control option to "Manual Control"', flight(AC).callsign)];
                                                        
                                                        Graphics.RadarScreen.Control.Option.Dynamic.Value = 0;
                                                        Graphics.RadarScreen.Control.Option.Static.Value = 0;
                                                        Graphics.RadarScreen.Control.Option.Manual.Value = 1;
                                                        
                                                        
                                                    case {'static' ; 'Static'}
                                                        flight(AC).manual.cta = [0 ; 0 ; 0];
                                                        flight(AC).manual.spd = [0 ; 0 ; 0];
                                                        flight(AC).manual.hdg = [0 ; 0 ; 0];
                                                        flight(AC).manual.alt = [0 ; 0 ; 0];
                                                        flight(AC).manual.exp = [0;0;0];
                                                        Valid = 1;
                                                        Output = ['>> ' String sprintf('\n     %s : set control option to "Static Control"', flight(AC).callsign)];
                                                        
                                                        Graphics.RadarScreen.Control.Option.Dynamic.Value = 0;
                                                        Graphics.RadarScreen.Control.Option.Static.Value = 1;
                                                        Graphics.RadarScreen.Control.Option.Manual.Value = 0;
                                                        
                                                    case {'dynamic' ; 'Dynamic'}
                                                        flight(AC).manual.cta = [1 ; 0 ; 0];
                                                        flight(AC).manual.spd = [0 ; 0 ; 0];
                                                        flight(AC).manual.hdg = [0 ; 0 ; 0];
                                                        flight(AC).manual.alt = [0 ; 0 ; 0];
                                                        flight(AC).manual.exp = [0;0;0];
                                                        Valid = 1;
                                                        Output = ['>> ' String sprintf('\n     %s : set control option to "Dynamic Control"', flight(AC).callsign)];
                                                        
                                                        Graphics.RadarScreen.Control.Option.Dynamic.Value = 1;
                                                        Graphics.RadarScreen.Control.Option.Static.Value = 0;
                                                        Graphics.RadarScreen.Control.Option.Manual.Value = 0;
                                                        
                                                        
                                                    case {'Info' ; 'info' ; '?'}
                                                        
                                                        if flight(AC).Data
                                                            ACData = 'generated';
                                                        else
                                                            ACData = 'imported';
                                                        end
                                                        
                                                        ControlOpt = '';
                                                        if flight(AC).manual.spd(1)
                                                            ControlOpt = [ControlOpt 'Speed(' num2str(flight(AC).manual.spd(2), '%3.1f') ') kt / '];
                                                        end
                                                        if flight(AC).manual.alt(1)
                                                            ControlOpt = [ControlOpt 'Altitude(' num2str(flight(AC).manual.alt(2), '%5.1f') ') ft / '];
                                                        end
                                                        if flight(AC).manual.hdg(1)
                                                            ControlOpt = [ControlOpt 'Heading(' num2str(flight(AC).manual.hdg(2), '%3.1f') ') / '];
                                                        end
                                                        if flight(AC).manual.cta(1)
                                                            ControlOpt = [ControlOpt 'Dynamic'];
                                                        end
                                                        if isempty(ControlOpt)
                                                            ControlOpt = 'Static';
                                                        end
                                                        
                                                        ETA = round(flight(AC).gentime + flight(AC).Reference(6,end));
                                                        
                                                        StatusLookUp = {'Queued' ; 'Airborne' ; 'Arrived' ; 'Deleted' ; 'Paused'};
                                                        
                                                        Status = StatusLookUp{flight(AC).status};
                                                        
                                                        Valid = 1;
                                                        Output = ['>> ' String sprintf('\n     %s: %s,  ID: %i,  AC type: %s', flight(AC).callsign, ACData, flight(AC).id, flight(AC).type) ...
                                                            sprintf('\n     Control Option: %s', ControlOpt) ...
                                                            sprintf('\n     Departure Time: %.1f,  Estimated Landing Time: %.1f', flight(AC).gentime, ETA) ...
                                                            sprintf('\n     Delay: %.1f,  Status: %s', flight(AC).delay, Status)];
                                                        
                                                        
                                                    otherwise
                                                        
                                                        if length(context) >= 3
                                                            switch context(1:3)
                                                                
                                                                case {'hdg' ; 'Hdg' ; 'HDG'}
                                                                    param = 'hdg';
                                                                    
                                                                    switch length(context(4:end))
                                                                        case 0
                                                                            if  flight(AC).manual.hdg(1) == 1
                                                                                Valid = 2;
                                                                                order = 'clear ';
                                                                            else
                                                                                
                                                                                order = 'set heading to ';
                                                                                
                                                                                value = flight(AC).hdg;
                                                                                option = 0;
                                                                                Valid = 1;
                                                                            end
                                                                        case 3
                                                                            
                                                                            order = 'set heading to ';
                                                                            
                                                                            value = context(4:end);
                                                                            option = 0;
                                                                            Valid = 1;
                                                                            
                                                                        case 4
                                                                            switch context(end) % turn direction
                                                                                case {'r' ; 'R'}
                                                                                    option = 1;
                                                                                    order = 'set heading to (right turn) ';
                                                                                case {'l' ; 'L'}
                                                                                    option = -1;
                                                                                    order = 'set heading to (left turn) ';
                                                                                case {'a' ; 'A'}
                                                                                    option = 0;
                                                                                    order = 'set heading to (auto) ';
                                                                                otherwise
                                                                                    option = 0;
                                                                            end
                                                                            
                                                                            value = context(4:end - 1);
                                                                            Valid = 1;
                                                                            
                                                                        otherwise
                                                                            
                                                                            
                                                                    end
                                                                    
                                                                    Output = ['>>' Output];
                                                                    
                                                                case {'alt' ; 'Alt' ; 'ALT'}
                                                                    param = 'alt';
                                                                    
                                                                    switch length(context(4:end))
                                                                        
                                                                        case 0
                                                                            
                                                                            if  flight(AC).manual.alt(1) == 1
                                                                                Valid = 2;
                                                                                order = 'clear ';
                                                                            else
                                                                                order = 'set altitude to ';
                                                                                value = flight(AC).alt;
                                                                                option = 0;
                                                                                Valid = 1;
                                                                            end
                                                                        otherwise
%                                                                             value = context(4:end);
%                                                                             option = 0;
%                                                                             Valid = 1;
%                                                                         case 4
                                                                            % ??? ?? ??
                                                                            if ~isnan(str2double(context(4:end)))
                                                                                order = 'set altitude to ';
                                                                                value = context(4:end);
                                                                                option = 0;
                                                                                Valid = 1;
                                                                            else % ?? ?? ??
                                                                                if length(context) > 4
                                                                                    if ~isnan(str2double(context(4:end - 1)))
                                                                                        switch context(end)
                                                                                            case {'n' ; 'N'}
                                                                                                option = 0;
                                                                                                order = 'set altitude to (Nomial ROCD) ';
                                                                                                value = context(4:end - 1);
                                                                                                Valid = 1;
                                                                                                
                                                                                            case {'m' ; 'M'}
                                                                                                option = -1;
                                                                                                order = 'set heading to (maximum ROCD) ';
                                                                                                value = context(4:end - 1);
                                                                                                Valid = 1;
                                                                                        end
                                                                                    end
                                                                                end
                                                                                
                                                                                
                                                                            end
                                                                    end
                                                                    
                                                                    
                                                                    Output = ['>>' Output];
                                                                case {'spd' ; 'Spd' ; 'SPD'}
                                                                    param = 'spd';
                                                                    order = 'set airspeed to ';
                                                                    
                                                                    switch length(context(4:end))
                                                                        case 0
                                                                            
                                                                            if  flight(AC).manual.spd(1) == 1
                                                                                Valid = 2;
                                                                                order = 'clear ';
                                                                            else
                                                                                value = flight(AC).Vtas;
                                                                                option = 0;
                                                                                Valid = 1;
                                                                            end
                                                                        case 3
                                                                            
                                                                            value = context(4:end);
                                                                            option = 0;
                                                                            Valid = 1;
                                                                    end
                                                                    
                                                                    Output = ['>>' Output];
                                                                case {'cta' ; 'Cta' ; 'CTA' ; 'rta' ; 'Rta' ; 'RTA'}
                                                                    param = 'cta';
                                                                    order = 'set CTA to ';
                                                                    
                                                                    if length(context) == 3
                                                                        if  flight(AC).manual.cta(1) == 1
                                                                            Valid = 2;
                                                                            order = 'clear ';
                                                                        else
                                                                            value = context(4:end);
                                                                            option = 0;
                                                                            Valid = 1;
                                                                        end
                                                                    else
                                                                        value = context(4:end);
                                                                        option = 0;
                                                                        Valid = 1;
                                                                    end
                                                                    
                                                                    Output = ['>>' Output];
                                                                    
                                                                    
                                                                case {'ban' ; 'Ban' ; 'BAN'}
                                                                    param = 'ban';
                                                                    order = 'set Bank Angle to ';
                                                                    
                                                                    if length(context) == 3
                                                                        
                                                                        if  flight(AC).manual.ban(1) == 1
                                                                            Valid = 2;
                                                                            order = 'clear ';
                                                                        else
                                                                            switch flight(AC).FS
                                                                                case {'TO';'LD'}
                                                                                    value = '25';
                                                                                otherwise
                                                                                    value = '35';
                                                                            end
                                                                            option = 0;
                                                                            Valid = 1;
                                                                        end
                                                                        
                                                                    else
                                                                        
                                                                        switch context(4:end)
                                                                            case {'m'; 'M' ; 'max' ; 'Max' ; 'MAX'}
                                                                                switch flight(AC).FS
                                                                                    case {'TO';'LD'}
                                                                                        value = '25';
                                                                                    otherwise
                                                                                        value = '45';
                                                                                end
                                                                                option = 0;
                                                                                Valid = 1;
                                                                                
                                                                            case {'n' ; 'N' ; 'nom' ; 'Nom' ; 'NOM'}
                                                                                switch flight(AC).FS
                                                                                    case {'TO';'LD'}
                                                                                        value = '15';
                                                                                    otherwise
                                                                                        value = '35';
                                                                                end
                                                                                option = 0;
                                                                                Valid = 1;
                                                                                
                                                                            otherwise
                                                                                if ~isnan(str2double(context(4:end)))
                                                                                    switch flight(AC).FS
                                                                                        case {'TO';'LD'}
                                                                                            if abs(str2double(context(4:end))) < 25
                                                                                                value = abs(str2double(context(4:end)));
                                                                                            else
                                                                                                value = '25';
                                                                                            end
                                                                                        otherwise
                                                                                            if abs(str2double(context(4:end))) < 45
                                                                                                value = abs(str2double(context(4:end)));
                                                                                            else
                                                                                                value = '45';
                                                                                            end
                                                                                    end
                                                                                end
                                                                                option = 0;
                                                                                Valid = 1;
                                                                        end
                                                                        
                                                                        
                                                                    end
                                                                    
                                                                    
                                                                otherwise
                                                                    % 기타 명령들 case로 추가하자
                                                                    
                                                                    switch context
                                                                        case {'Brake' ; 'BRAKE' ; 'brake'}
                                                                            if ~isempty(flight(AC).FixFlap)
                                                                                flight(AC).FS = flight(AC).FixFlap;
                                                                                flight(AC).FixFlap = '';
                                                                                flight(AC).FixFlapCount = 0;
                                                                                
                                                                                Valid = 3;
                                                                                order = 'Deactivate Speed Brake... Flap Setting to ';
                                                                                value = flight(AC).FS;
                                                                            else
                                                                                switch flight(AC).FS
                                                                                    case 'IC'
                                                                                        flight(AC).FixFlap = 'TO';
                                                                                        flight(AC).FixFlapCount = 0;
                                                                                        Valid = 3;
                                                                                        order = 'Activate Speed Brake... Flap Setting to ';
                                                                                        value = 'TO';
                                                                                    case 'CR'
                                                                                        flight(AC).FixFlap = 'AP';
                                                                                        flight(AC).FixFlapCount = 0;
                                                                                        Valid = 3;
                                                                                        order = 'Activate Speed Brake... Flap Setting to ';
                                                                                        value = 'AP';
                                                                                    case 'AP'
                                                                                        flight(AC).FixFlap = 'LD';
                                                                                        flight(AC).FixFlapCount = 0;
                                                                                        Valid = 3;
                                                                                        order = 'Activate Speed Brake... Flap Setting to ';
                                                                                        value = 'LD';
                                                                                    otherwise
                                                                                        flight(AC).FixFlap = '';
                                                                                        Valid = 3;
                                                                                        order = 'Unable to activate speed brake ';
                                                                                        value = flight(AC).FS;
                                                                                end
                                                                            end
                                                                            
                                                                            
                                                                            Output = ['>>' Output];
                                                                            
                                                                            
                                                                        otherwise
                                                                    end
                                                                    
                                                                    
                                                                    
                                                            end
                                                            
                                                            if Valid == 1
                                                                value = str2double(value);
                                                                if isnan(value)
                                                                    Output = [Output String sprintf('\n     %s : %s %s', flight(AC).callsign, order, '...error not valid input')];
                                                                    
                                                                else
                                                                    flight(AC).manual.(param) = [1 ; value ; option];
                                                                    Output = [Output String sprintf('\n     %s : "%s" %5.2f', flight(AC).callsign, order, value)];
                                                                end
                                                            elseif Valid == 2 % Clearing
                                                                flight(AC).manual.(param) = [0 ; 0 ; 0];
                                                                Output = [Output String sprintf('\n     %s : "%s" %5.2f', flight(AC).callsign, order)];
                                                                Valid = 1;
                                                            elseif Valid == 3 % Other inputs
                                                                Output = [Output String sprintf('\n     %s : "%s" %s', flight(AC).callsign, order, value)];
                                                                Valid = 1;
                                                            end
                                                            
                                                        else
                                                            % 3 보다 짧다면
                                                            
                                                            
                                                            
                                                        end
                                                end
                                                
                                                
                                            end
                                        end
                                        
                                        
                                        
                                        
                                        % Auto Manual correction -> e.g. heading만 입력된 경우 자동으로
                                        % altitude, speed 현재값 유지
                                        if and(flight(AC).manual.hdg(1), ~flight(AC).manual.spd(1))
                                            flight(AC).manual.spd = [1 ; flight(AC).Vtas_sc ; 0];
                                            flight(AC).manual.cta = [0 ; 0 ; 0];
                                            
                                            Graphics.RadarScreen.Control.Option.Dynamic.Value = 0;
                                            Graphics.RadarScreen.Control.Option.Static.Value = 0;
                                            Graphics.RadarScreen.Control.Option.Manual.Value = 1;
                                        end
                                        
                                        if and(flight(AC).manual.hdg(1), ~flight(AC).manual.alt(1))
                                            flight(AC).manual.alt = [1 ; flight(AC).alt_sc ; 0];
                                            flight(AC).manual.cta = [0 ; 0 ; 0];
                                            
                                            Graphics.RadarScreen.Control.Option.Dynamic.Value = 0;
                                            Graphics.RadarScreen.Control.Option.Static.Value = 0;
                                            Graphics.RadarScreen.Control.Option.Manual.Value = 1;
                                        end
                                        
                                        if flight(AC).manual.spd(1)
                                            flight(AC).manual.cta = [0 ; 0 ; 0];
                                        elseif flight(AC).manual.cta(1)
                                            flight(AC).manual.spd = [0 ; 0 ; 0];
                                        end
                                        
                                        
                                        if or(flight(AC).manual.hdg(1), flight(AC).manual.alt(1))
                                            if flight(AC).manual.spd(1)
                                                Graphics.RadarScreen.Control.Option.Dynamic.Value = 0;
                                                Graphics.RadarScreen.Control.Option.Static.Value = 1;
                                                Graphics.RadarScreen.Control.Option.Manual.Value = 0;
                                            elseif flight(AC).manual.cta(1)
                                                
                                                Graphics.RadarScreen.Control.Option.Dynamic.Value = 1;
                                                Graphics.RadarScreen.Control.Option.Static.Value = 0;
                                                Graphics.RadarScreen.Control.Option.Manual.Value = 0;
                                            end
                                            
                                        end
                                        
                                        Graphics.RadarScreen.Control.Option.Heading.Value = flight(AC).manual.hdg(1);
                                        Graphics.RadarScreen.Control.Option.Speed.Value = flight(AC).manual.spd(1);
                                        Graphics.RadarScreen.Control.Option.Altitude.Value = flight(AC).manual.alt(1);
                                        
                                        
                                    else
                                        % no matching Callsign
                                        
                                        
                                    end
%                                 end
                        end
                    end
                    
                case '!'
                    % Direct Input
                    Direct = String(2:end);
                    try
                        eval(Direct)
                        Valid = 1;
                        Output = ['** Direct Command Input' sprintf('\n     %s', Direct)];
                    catch
                        Valid = 1;
                        Output = ['** Direct Command Input' sprintf('\n     Error Invalid Input')];
                    end
                    
                otherwise
                    % no aircraft command
                    
            end
    end
    
    
    if Valid
        currString = cellstr(get(Graphics.MainWindow.Display,'String'));
        currString = flip(currString);
        if iscell(currString)
            currString{end+1}=sprintf(' %s', Output);
        else
            currString = [currString sprintf('\n') sprintf(' %s', Output)];
            
        end
        currString = flip(currString);
        set(Graphics.MainWindow.Display,'String',currString);
        
        
    end
    
%     end
end

Graphics.RadarScreen.DisplayData = DisplayDataUpdate(Graphics.RadarScreen.DisplayData, Graphics.RadarScreen.Trajectory, flight, RunTime);

Command.new = [];

end