%% for fitting trajectory!!!
close all
load('Cleaned_Radar_Data_2012_0801')

plan = struct([]);
flight = struct([]);
subtable = {'Y71' , 'Y711' ; 'Y72' , 'Y722' ; 'Y52' , 'Z52'};
load map_data

    

radartrackfig = figure('units','normalized','outerPosition',[0 0 1 1]);

hold on
grid on
set(gca, 'color', [0.95 0.95 0.95])
caxis([0 600])
zlim([0 50000])
daspect([1 1 40000])
set(gca, 'ZLimMode', 'manual')
% set(gca,'zlim',[0 100000]);

xlim([122 132]);
ylim([30 40]);

for Segment = 1:length(Map.Korea.Segment)
    fill(Map.Korea.Segment(Segment).long(:), Map.Korea.Segment(Segment).lat(:), [0.15, 0.55, 0.25], 'LineStyle', 'none')
end

for WPMark = 1:length(Airspace.Waypoint)
    switch Airspace.Waypoint(WPMark).Type
        case 'Waypoint'
            if and(Airspace.Waypoint(WPMark).display, strcmp(Airspace.Waypoint(WPMark).Nationality, 'Korea'))
                plot3(Airspace.Waypoint(WPMark).Long(:), Airspace.Waypoint(WPMark).Lat(:), 1500, 'LineStyle', 'none', 'Marker', '^', 'MarkerEdgeColor', 'k', 'MarkerSize', 4)
                text(Airspace.Waypoint(WPMark).Long(:), Airspace.Waypoint(WPMark).Lat(:), 1000, sprintf(['\n ' Airspace.Waypoint(WPMark).Name]), 'FontSize', 6, 'HorizontalAlignment', 'center');
            end
    end
end



for DataLen = 1:length(Radar_Data)
    
    
    
    if length(Radar_Data(DataLen).Time_S) > 1
        
        orig = Radar_Data(DataLen).Origination{1};
        dest = Radar_Data(DataLen).Destination{1};
        
%         if and(strcmp(orig, 'RKPC'), or(strcmp(dest, 'RKSS'), strcmp(dest, 'RKSI')))
        if and(strcmp(orig, 'RKPC'), strcmp(dest, 'RKSS'))
            if isempty(plan)
                nLine = 1;
            else
                nLine = length(plan) + 1;
            end
            
            plan(nLine).id = nLine;
            plan(nLine).callsign = Radar_Data(DataLen).Callsign{1};
            
            
            if ~any(strcmp(fieldnames(Perf), Radar_Data(DataLen).AC_Type{1}))
                ['warning! flight #' num2str(nLine) ' has Aircraft (' Radar_Data(nLine).AC_Type{1} ') out of Performance List... Change into Default Aircraft (A333)']
                plan(nLine).type = 'A333';
            else
                plan(nLine).type = Radar_Data(DataLen).AC_Type{1};
            end
            
%             plan(nLine).type = Radar_Data(DataLen).AC_Type{1};
            plan(nLine).departure = Radar_Data(DataLen).Origination{1};
            
            
            plan(nLine).arrival = Radar_Data(DataLen).Destination{1};
            
            
            % RWY Prediction -> closest runway threshold
            % departure
            if ~isempty(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Origination{1}),1))
                if ~isempty(Aerodrome(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Origination{1}),1)).RWY)
                    if ~isempty(find(Radar_Data(DataLen).Altitude > 100,1))
                        
                        ind = find(Radar_Data(DataLen).Altitude > 100,1);
                        
                        initlong = Radar_Data(DataLen).Longitude(ind);
                        initlat = Radar_Data(DataLen).Latitude(ind);
                        initalt = Radar_Data(DataLen).Altitude(ind);
                        inithdg = mod(rad2deg(atan2(Radar_Data(DataLen).Longitude(ind + 1) - Radar_Data(DataLen).Longitude(ind), Radar_Data(DataLen).Latitude(ind + 1) - Radar_Data(DataLen).Latitude(ind))),360);
                        
                        
                        nearest = 1;
                        flag = 0;
                        for runways = 1:length(Aerodrome(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Origination{1}),1)).RWY)
                            
                            rwybrg = Aerodrome(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Origination{1}),1)).RWY(runways).bearing;
                            angdiff = min(360 - mod(inithdg - rwybrg, 360), mod(inithdg - rwybrg, 360));
                            
                            if angdiff >= 90
                                
                            elseif angdiff < 90
                                tgtdist = sqrt((initlat - Aerodrome(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Origination{1}),1)).RWY(nearest).ENDlat)^2 + (initlong - Aerodrome(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Origination{1}),1)).RWY(nearest).ENDlong)^2);
                                chadist = sqrt((initlat - Aerodrome(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Origination{1}),1)).RWY(runways).ENDlat)^2 + (initlong - Aerodrome(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Origination{1}),1)).RWY(runways).ENDlong)^2);
                                
                                if chadist < tgtdist
                                    flag = 1;
                                    nearest = runways;
                                    tgtdist = chadist;
                                else
                                    if nearest == 1
                                        flag = 1;
                                    end
                                end
                                
                                
                            end
                            
                        end
                        
                        if tgtdist <= 0.5 % 30 NM
                            plan(nLine).departure_RWY = Aerodrome(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Origination{1}),1)).RWY(nearest).name;
                        else
                            plan(nLine).departure_RWY = '';
                        end
                    else
                        plan(nLine).departure_RWY = '';
                    end
                else
                    plan(nLine).departure_RWY = '';
                end
                
            else
                plan(nLine).departure_RWY = '';
                
            end
            
            
            % arrival
            
            if ~isempty(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Destination{1}),1))
                if ~isempty(Aerodrome(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Destination{1}),1)).RWY)
                    if ~isempty(find(Radar_Data(DataLen).Altitude <= 8000,1,'last'))
                        
                        ind = find(Radar_Data(DataLen).Altitude <= 8000,1,'last');
                        
                        if ind > length(Radar_Data(DataLen).Altitude) / 3
                            
                            initlong = Radar_Data(DataLen).Longitude(ind);
                            initlat = Radar_Data(DataLen).Latitude(ind);
                            initalt = Radar_Data(DataLen).Altitude(ind);
                            inithdg = mod(rad2deg(atan2(Radar_Data(DataLen).Longitude(ind) - Radar_Data(DataLen).Longitude(ind - 1), Radar_Data(DataLen).Latitude(ind) - Radar_Data(DataLen).Latitude(ind - 1))),360);
                            
                            nearest = 1;
                            flag = 0;
                            for runways = 1:length(Aerodrome(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Destination{1}),1)).RWY)
                                
                                rwybrg = Aerodrome(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Destination{1}),1)).RWY(runways).bearing;
                                angdiff = min(360 - mod(inithdg - rwybrg, 360), mod(inithdg - rwybrg, 360));
                                
                                if angdiff >= 90
                                    
                                elseif angdiff < 90
                                    tgtdist = sqrt((initlat - Aerodrome(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Destination{1}),1)).RWY(nearest).THRlat)^2 + (initlong - Aerodrome(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Destination{1}),1)).RWY(nearest).THRlong)^2);
                                    chadist = sqrt((initlat - Aerodrome(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Destination{1}),1)).RWY(runways).THRlat)^2 + (initlong - Aerodrome(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Destination{1}),1)).RWY(runways).THRlong)^2);
                                    
                                    if chadist < tgtdist
                                        flag = 1;
                                        nearest = runways;
                                        tgtdist = chadist;
                                    else
                                        if nearest == 1
                                            flag = 1;
                                        end
                                    end
                                end
                            end
                            if tgtdist <= 1 % 60 NM
                                %                             [num2str(tgtdist * 60), ' ', num2str(inithdg), ' ', Aerodrome(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Destination{1}),1)).RWY(nearest).name]
                                plan(nLine).arrival_RWY = Aerodrome(find(strcmp({Aerodrome.ID}, Radar_Data(DataLen).Destination{1}),1)).RWY(nearest).name;
                            else
                                plan(nLine).arrival_RWY = '';
                            end
                        else
                            plan(nLine).arrival_RWY = '';
                        end
                    else
                        plan(nLine).arrival_RWY = '';
                    end
                else
                    plan(nLine).arrival_RWY = '';
                end
            else
                plan(nLine).arrival_RWY = '';
            end
            
            
            y = unique(Radar_Data(DataLen).Cruse_Lv);
            
            n = zeros(length(y), 1);
            for iy = 1:length(y)
                if ~isempty(y{iy})
                    n(iy) = length(find(strcmp(y{iy}, Radar_Data(DataLen).Cruse_Lv)));
                end
            end
            [~, itemp] = max(n);
            cruisealt = y(itemp);
            if isempty(cruisealt{1})
                plan(nLine).cruising_alt = max(Radar_Data(DataLen).Altitude);
            else
                str = cruisealt{1};
                plan(nLine).cruising_alt = str2double(str(2:end)) * 100;
            end
            
            
            plan(nLine).desc_profile = 'CDO_flex';
            plan(nLine).desc_angle = 3;
            plan(nLine).desc_rate = 0;
            plan(nLine).climb_profile = 'CCO_flex';
            plan(nLine).climb_angle = 0;
            plan(nLine).climb_rate = 2200;
            plan(nLine).speed_control = 'linear';
            plan(nLine).accel_control = 'linear';
            plan(nLine).mass = 'reference';
            plan(nLine).Curve = 'strict';
            
            plan(nLine).remarks = Radar_Data(DataLen).Route{1};
            
            plan(nLine).route.status={};
            plan(nLine).route.origination={};
            plan(nLine).route.destination={};
            plan(nLine).route.type={};
            plan(nLine).route.trajectory={};
            plan(nLine).route.altitude={};

            remarks = strsplit(Radar_Data(DataLen).Route{1}, ' ');
            remarks(strcmp(remarks, 'DCT')) = [];
            
            from = '';
            to = '';
            cmd = '';
            via = '';
            traj = '';
            alt = '';
            flag = 0;
            for words = 1:length(remarks)
                
                if ~isempty(find(strcmp(subtable(:,1), remarks{words}),1))
                    remarks{words} = subtable{find(strcmp(subtable(:,1), remarks{words}), 1), 2};
                end
                
                
                if strcmp(remarks{words}, 'DCT')
                    % direct
                    if and(flag == 0, words == 1)
                        from = '';
                        cmd = 'direct';
                        via = 'waypoint';
                        flag = 1;
                    elseif and(flag == 1, words == length(remarks))
                        to = '@IAF';
                        cmd = 'direct';
                        via = 'waypoint';
                        flag = 2;
                    else
                        cmd = 'direct';
                        via = 'waypoint';
                    end
                    
                elseif ~isempty(find(strcmp({Airspace.Waypoint.Name}, remarks{words}),1))
                    % Waypoint -> save as origination and destination
                    if flag == 0
                        from = remarks{words};
                        flag = 1;
                    elseif flag == 1
                        if and(or(strcmp(from, 'KALMA'), strcmp(from, 'KAKSO')) ,strcmp(remarks{words}, 'SEL'))
                            to = 'HOKAN';
                            cmd = 'direct';
                            via = 'waypoint';
                            traj = '';
                        else
                            to = remarks{words};
                        end
                        flag = 2;
                    end
                    
                    
                elseif ~isempty(find(strcmp({Airspace.route.name}, remarks{words}),1))
                    % link route between orig & dest
                    
                    cmd = 'route';
                    via = 'route';
                    traj = remarks{words};
                    
                    
                elseif ~isempty(find(strcmp({Procedure.name}, remarks{words}),1))
                    % procedure between orig & dest
                    
                    
                    cmd = 'procedure';
                    via = Procedure(find(strcmp({Procedure.name}, remarks{words}),1)).type;
                    traj = remarks{words};
                    
                    
                else
                    % do not have relevant points
                    
                    
                    
                end
                
                
                
                
                if flag == 2
                    % append SID & STAR with orig/dest and corresponding
                    % runway.
                    if and(~isempty(from), ~isempty(to))
                        plan(nLine).route.status{end + 1} = cmd;
                        plan(nLine).route.origination{end + 1} = from;
                        plan(nLine).route.destination{end + 1} = to;
                        plan(nLine).route.type{end + 1} = via;
                        plan(nLine).route.trajectory{end + 1} = traj;
                        plan(nLine).route.altitude{end + 1} = 'default';
                        
                    
                    end
                    
                    from = to;
                    to = '';
                    cmd = '';
                    via = '';
                    traj = '';
                    alt = '';
                    flag = 1;
                    
                end
            end
            
            
            if ~strcmp(plan(nLine).route.status{1}, 'procedure')
                % append SID for departing airport to first fix
                nnLine = length(plan(nLine).route.status);
                plan(nLine).route.status(2:nnLine + 1) = plan(nLine).route.status(1:nnLine);
                plan(nLine).route.origination(2:nnLine + 1) = plan(nLine).route.origination(1:nnLine);
                plan(nLine).route.destination(2:nnLine + 1) = plan(nLine).route.destination(1:nnLine);
                plan(nLine).route.type(2:nnLine + 1) = plan(nLine).route.type(1:nnLine);
                plan(nLine).route.trajectory(2:nnLine + 1) = plan(nLine).route.trajectory(1:nnLine);
                plan(nLine).route.altitude(2:nnLine + 1) = plan(nLine).route.altitude(1:nnLine);
                
                
                
                
                
                proclist = {Aerodrome(find(strcmp({Aerodrome.ID}, plan(nLine).departure),1)).RWY(find(strcmp({Aerodrome(find(strcmp({Aerodrome.ID}, plan(nLine).departure),1)).RWY.name}, plan(nLine).departure_RWY),1)).SID.name};
                
                trajflag = 1;
                while trajflag
                   for proc = 1:length(proclist) 
                       if ~isempty(find(strcmp({Procedure(find(strcmp({Procedure.name}, proclist{proc}),1)).trajectory.WP_name}, plan(nLine).route.destination{1}), 1))
                            
                           plan(nLine).route.status{1} = 'procedure';
                           plan(nLine).route.type{1} = 'SID';
                           plan(nLine).route.destination{1} = plan(nLine).route.origination{2};
                           plan(nLine).route.origination{1} = Procedure(find(strcmp({Procedure.name}, proclist{proc}),1)).trajectory(1).WP_name;
                           plan(nLine).route.trajectory{1} = proclist{proc};
                           
%                            Procedure(find(strcmp({Procedure.name}, proclist{proc}),1)).trajectory
                           trajflag = 0;
                           break
                       end
                   end
                   
                   if trajflag == 1
                       plan(nLine).route.status{1} = 'direct';
                       plan(nLine).route.type{1} = 'waypoint';
                       plan(nLine).route.destination{1} = plan(nLine).route.origination{2};
                       plan(nLine).route.origination{1} = Airspace.Waypoint(Aerodrome(find(strcmp({Aerodrome.ID}, plan(nLine).departure),1)).RWY(find(strcmp({Aerodrome(find(strcmp({Aerodrome.ID}, plan(nLine).departure),1)).RWY.name}, plan(nLine).departure_RWY),1)).WP_id{1}).Name;
                       plan(nLine).route.trajectory{1} = proclist{proc};
                       
                       trajflag = 0;
                       break
                   end
                   
                   
                end
                
            end
            
            
            
            if and(strcmp(plan(nLine).route.status{end}, 'direct'), strcmp(plan(nLine).route.destination{end}, '@IAF'))
            % find the nearest IAF and append INST

                proclist = {Aerodrome(find(strcmp({Aerodrome.ID}, plan(nLine).arrival),1)).RWY(find(strcmp({Aerodrome(find(strcmp({Aerodrome.ID}, plan(nLine).arrival),1)).RWY.name}, plan(nLine).arrival_RWY),1)).INST.name};

                curlat = Airspace.Waypoint(find(strcmp({Airspace.Waypoint.Name}, plan(nLine).route.origination{end}), 1)).Lat;
                curlong = Airspace.Waypoint(find(strcmp({Airspace.Waypoint.Name}, plan(nLine).route.origination{end}), 1)).Long;

                ind = 1;
                curdist = 0;
                for proc = 1:length(proclist)
                    IAFlat = Procedure(find(strcmp({Procedure.name}, proclist{proc}), 1)).trajectory(1).WP_lat;
                    IAFlong = Procedure(find(strcmp({Procedure.name}, proclist{proc}), 1)).trajectory(1).WP_long;
                    
                    dist = sqrt((curlat - IAFlat)^2 + (curlong - IAFlong)^2);
                    if proc == 1
                        curdist = dist;
                    else
                        if dist < curdist
                            ind = proc;
                            curdist = dist;
                        end
                    end
                    
                end

                plan(nLine).route.destination{end} = Procedure(find(strcmp({Procedure.name}, proclist{ind}), 1)).trajectory(1).WP_name;
                
                
                plan(nLine).route.status{end + 1} = 'procedure';
                plan(nLine).route.origination{end + 1} = Procedure(find(strcmp({Procedure.name}, proclist{ind}), 1)).trajectory(1).WP_name;
                plan(nLine).route.destination{end + 1} = Procedure(find(strcmp({Procedure.name}, proclist{ind}), 1)).trajectory(end).WP_name;
                plan(nLine).route.type{end + 1} = 'INST';
                plan(nLine).route.trajectory{end + 1} = proclist{ind};
                plan(nLine).route.altitude{end + 1} = 'default';
                
                
                
            elseif ~strcmp(plan(nLine).route.status{end}, 'procedure')
            % Append STAR & INST into last route

                flag = 0;
                % if route ends at STAR waypoint -> get STAR

                proclist = {Aerodrome(find(strcmp({Aerodrome.ID}, plan(nLine).arrival),1)).RWY(find(strcmp({Aerodrome(find(strcmp({Aerodrome.ID}, plan(nLine).arrival),1)).RWY.name}, plan(nLine).arrival_RWY),1)).STAR.name};
                if ~isempty(proclist)
                    ind = 0;
                    for proc = 1:length(proclist)
                        if ~isempty(find(strcmp({Procedure(find(strcmp({Procedure.name}, proclist{proc}), 1)).trajectory.WP_name}, plan(nLine).route.destination{end}), 1))
                            ind = proc;
                            break
                        end
                    end
                    
                    if ind ~= 0
                        plan(nLine).route.status{end + 1} = 'procedure';
%                         plan(nLine).route.origination{end + 1} = Procedure(find(strcmp({Procedure.name}, proclist{ind}), 1)).trajectory(1).WP_name;
                        plan(nLine).route.origination{end + 1} = plan(nLine).route.destination{end};
                        plan(nLine).route.destination{end + 1} = Procedure(find(strcmp({Procedure.name}, proclist{ind}), 1)).trajectory(end).WP_name;
                        plan(nLine).route.type{end + 1} = 'STAR';
                        plan(nLine).route.trajectory{end + 1} = proclist{ind};
                        plan(nLine).route.altitude{end + 1} = 'default';
                        flag = 1;
                        
                        
                        
                        proclist = {Aerodrome(find(strcmp({Aerodrome.ID}, plan(nLine).arrival),1)).RWY(find(strcmp({Aerodrome(find(strcmp({Aerodrome.ID}, plan(nLine).arrival),1)).RWY.name}, plan(nLine).arrival_RWY),1)).INST.name};
                        
                        curlat = Airspace.Waypoint(find(strcmp({Airspace.Waypoint.Name}, plan(nLine).route.origination{end}), 1)).Lat;
                        curlong = Airspace.Waypoint(find(strcmp({Airspace.Waypoint.Name}, plan(nLine).route.origination{end}), 1)).Long;
                        
                        ind = 1;
                        curdist = 0;
                        for proc = 1:length(proclist)
                            IAFlat = Procedure(find(strcmp({Procedure.name}, proclist{proc}), 1)).trajectory(1).WP_lat;
                            IAFlong = Procedure(find(strcmp({Procedure.name}, proclist{proc}), 1)).trajectory(1).WP_long;
                            
                            dist = sqrt((curlat - IAFlat)^2 + (curlong - IAFlong)^2);
                            if proc == 1
                                curdist = dist;
                            else
                                if dist < curdist
                                    ind = proc;
                                    curdist = dist;
                                end
                            end
                            
                        end
                        
                        
                        plan(nLine).route.status{end + 1} = 'procedure';
                        plan(nLine).route.origination{end + 1} = Procedure(find(strcmp({Procedure.name}, proclist{ind}), 1)).trajectory(1).WP_name;
                        plan(nLine).route.destination{end + 1} = Procedure(find(strcmp({Procedure.name}, proclist{ind}), 1)).trajectory(end).WP_name;
                        plan(nLine).route.type{end + 1} = 'INST';
                        plan(nLine).route.trajectory{end + 1} = proclist{ind};
                        plan(nLine).route.altitude{end + 1} = 'default';
                        
                    end
                end
            
                % else, go direct IAF
            
                if ~flag
                    
                    proclist = {Aerodrome(find(strcmp({Aerodrome.ID}, plan(nLine).arrival),1)).RWY(find(strcmp({Aerodrome(find(strcmp({Aerodrome.ID}, plan(nLine).arrival),1)).RWY.name}, plan(nLine).arrival_RWY),1)).INST.name};
                    
                    curlat = Airspace.Waypoint(find(strcmp({Airspace.Waypoint.Name}, plan(nLine).route.origination{end}), 1)).Lat;
                    curlong = Airspace.Waypoint(find(strcmp({Airspace.Waypoint.Name}, plan(nLine).route.origination{end}), 1)).Long;
                    
                    ind = 1;
                    curdist = 0;
                    for proc = 1:length(proclist)
                        IAFlat = Procedure(find(strcmp({Procedure.name}, proclist{proc}), 1)).trajectory(1).WP_lat;
                        IAFlong = Procedure(find(strcmp({Procedure.name}, proclist{proc}), 1)).trajectory(1).WP_long;
                        
                        dist = sqrt((curlat - IAFlat)^2 + (curlong - IAFlong)^2);
                        if proc == 1
                            curdist = dist;
                        else
                            if dist < curdist
                                ind = proc;
                                curdist = dist;
                            end
                        end
                        
                    end
                    
                    
                    plan(nLine).route.status{end + 1} = 'direct';
                    plan(nLine).route.origination{end + 1} =  plan(nLine).route.destination{end};
                    plan(nLine).route.destination{end + 1} = Procedure(find(strcmp({Procedure.name}, proclist{ind}), 1)).trajectory(1).WP_name;
                    plan(nLine).route.type{end + 1} = 'waypoint';
                    plan(nLine).route.trajectory{end + 1} = '';
                    plan(nLine).route.altitude{end + 1} = 'default';
                    
                    plan(nLine).route.status{end + 1} = 'procedure';
                    plan(nLine).route.origination{end + 1} = Procedure(find(strcmp({Procedure.name}, proclist{ind}), 1)).trajectory(1).WP_name;
                    plan(nLine).route.destination{end + 1} = Procedure(find(strcmp({Procedure.name}, proclist{ind}), 1)).trajectory(end).WP_name;
                    plan(nLine).route.type{end + 1} = 'INST';
                    plan(nLine).route.trajectory{end + 1} = proclist{ind};
                    plan(nLine).route.altitude{end + 1} = 'default';
                    
                    
                    
                end
            
                
                
            end
            
            
            flight(nLine).RadarTrack = [];
            
            flight(nLine).RadarTrack = [flight(nLine).RadarTrack ; ones(1, length(Radar_Data(DataLen).Longitude)) ; [Radar_Data(DataLen).Longitude(:)]' ; ...
                [Radar_Data(DataLen).Latitude]' ; max(0, [Radar_Data(DataLen).Altitude])' ; [Radar_Data(DataLen).Speed]' * 3600 ];
            
            
            flight(nLine).id = plan(nLine).id;
            flight(nLine).callsign = plan(nLine).callsign;
            flight(nLine).type = plan(nLine).type;
            flight(nLine).squawk = str2double(dec2base(nLine, 8));
            
            flight(nLine).Data = 1;
            
            flight(nLine).Vtas = deg2nm(sqrt((Radar_Data(DataLen).Longitude(2) - Radar_Data(DataLen).Longitude(1))^2 + (Radar_Data(DataLen).Latitude(2) - Radar_Data(DataLen).Latitude(1))^2));
            flight(nLine).lat = Radar_Data(DataLen).Latitude(1);
            flight(nLine).long = Radar_Data(DataLen).Longitude(1);
            flight(nLine).hdg = mod(rad2deg(atan2((Radar_Data(DataLen).Longitude(2) - Radar_Data(DataLen).Longitude(1)), (Radar_Data(DataLen).Latitude(2) - Radar_Data(DataLen).Latitude(1)))), 360);
            flight(nLine).alt = Radar_Data(DataLen).Altitude(1);
            
            flight(nLine).FS = 'TO'; 
            
            
            flight(nLine).WaypointFrom = 1;
            flight(nLine).WaypointTo = 2;
            
            
            
            switch plan(nLine).mass
                case 'reference'
                    flight(nLine).mass = Perf.(flight(nLine).type).Mass_ref; %일단 reference 질량으로 하자
                case 'maximum'
                    flight(nLine).mass = Perf.(flight(nLine).type).Mass_max;
                case 'minimum'
                    flight(nLine).mass = Perf.(flight(nLine).type).Mass_min;
                otherwise
                    if isnan(str2double(plan(nLine).mass))
                        switch plan(nLine).mass(isstrprop(plan(nLine).mass, 'alpha'))
                            case 'reference'
                                flight(nLine).mass = str2double(strrep(plan(nLine).mass, plan(nLine).mass(isstrprop(plan(nLine).mass, 'alpha')), '')) * Perf.(flight(nLine).type).Mass_ref;
                            case 'maximum'
                                flight(nLine).mass = str2double(strrep(plan(nLine).mass, plan(nLine).mass(isstrprop(plan(nLine).mass, 'alpha')), '')) * Perf.(flight(nLine).type).Mass_max;
                            case 'minimum'
                                flight(nLine).mass = str2double(strrep(plan(nLine).mass, plan(nLine).mass(isstrprop(plan(nLine).mass, 'alpha')), '')) * Perf.(flight(nLine).type).Mass_min;
                            otherwise
                                ['warning! cannot understand mass input in flight #' num2str(nLine) ', switching to reference mass']
                                flight(nLine).mass = str2double(strrep(plan(nLine).mass, plan(nLine).mass(isstrprop(plan(nLine).mass, 'alpha')), '')) * Perf.(flight(nLine).type).Mass_ref;

                        end
                    else
                        if plan(nLine).mass < Perf.(flight(nLine).type).Mass_min
                            ['error! ' num2str(nLine) 'th aircraft has planned mass(' num2str(plan(nLine).mass) ') which is less than minimum mass(' num2str(Perf.(flight(nLine).type).Mass_min) ') switching to minimum mass']
                            flight(nLine).mass = Perf.(flight(nLine).type).Mass_min;
                        elseif plan(nLine).mass > Perf.(flight(nLine).type).Mass_max
                            ['error! ' num2str(nLine) 'th aircraft has planned mass(' num2str(plan(nLine).mass) ') which is grater than maximum mass(' num2str(Perf.(flight(nLine).type).Mass_max) ') switching to maximum mass']
                            flight(nLine).mass = Perf.(flight(nLine).type).Mass_max;
                        else
                            flight(nLine).mass = str2double(plan(nLine).mass);
                        end
                    end
            end
            
            
            
            flight(nLine).command = struct([]);
            flight(nLine).command = plan(nLine).route;
            
            
            
            % name to id 변환 코드
            for k = 1:length(flight(nLine).command.status)
                if isempty(flight(nLine).command.origination{k}) == 0
                    flight(nLine).command.origination{k} = Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, flight(nLine).command.origination{k})==1).id;
                end
                if isempty(flight(nLine).command.destination{k}) == 0
                    flight(nLine).command.destination{k} = Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, flight(nLine).command.destination{k})==1).id;
                end
                if isempty(flight(nLine).command.trajectory{k}) == 0
                    flight(nLine).command.trajectory{k} = Procedure(strcmp({Procedure.name}, flight(nLine).command.trajectory{k})==1).id;
                end
            end
            
            
            if ~isempty(flight(nLine).RadarTrack)
                surface([flight(nLine).RadarTrack(2,:); flight(nLine).RadarTrack(2,:)], [flight(nLine).RadarTrack(3,:); flight(nLine).RadarTrack(3,:)], [flight(nLine).RadarTrack(4,:); flight(nLine).RadarTrack(4,:)], [flight(nLine).RadarTrack(5,:); flight(nLine).RadarTrack(5,:)], 'facecol','no', 'edgecol','interp', 'linew',1.5);            
            end
            
            
            
            plan(nLine).gentime = 0;
            
        end
    end
    
    
    
    
end


flight = AssignTrajectory(flight, Aerodrome, Airspace, Procedure);

for i=length(flight):-1:1
    if isempty(flight(i).id)
        flight(i) = [];
        plan(i) = [];
    end
end
for i = 1:length(flight)
    flight(i).id = i;
    plan(i).id = i;
   
end
flight = BezierCurve(flight);




genrajfig = figure('units','normalized','outerPosition',[0 0 1 1]);

hold on
grid on
set(gca, 'color', [0.95 0.95 0.95])
caxis([0 600])
zlim([0 50000])
daspect([1 1 40000])
set(gca, 'ZLimMode', 'manual')
% set(gca,'zlim',[0 100000]);

xlim([122 132]);
ylim([30 40]);

for Segment = 1:length(Map.Korea.Segment)
    fill(Map.Korea.Segment(Segment).long(:), Map.Korea.Segment(Segment).lat(:), [0.15, 0.55, 0.25], 'LineStyle', 'none')
end

for WPMark = 1:length(Airspace.Waypoint)
    switch Airspace.Waypoint(WPMark).Type
        case 'Waypoint'
            if and(Airspace.Waypoint(WPMark).display, strcmp(Airspace.Waypoint(WPMark).Nationality, 'Korea'))
                plot3(Airspace.Waypoint(WPMark).Long(:), Airspace.Waypoint(WPMark).Lat(:), 1500, 'LineStyle', 'none', 'Marker', '^', 'MarkerEdgeColor', 'k', 'MarkerSize', 4)
                text(Airspace.Waypoint(WPMark).Long(:), Airspace.Waypoint(WPMark).Lat(:), 1000, sprintf(['\n ' Airspace.Waypoint(WPMark).Name]), 'FontSize', 6, 'HorizontalAlignment', 'center');
            end
    end
end


for traj = 1:length(flight)
    surface([flight(traj).Reference(2,:); flight(traj).Reference(2,:)], [flight(traj).Reference(3,:); flight(traj).Reference(3,:)], [flight(traj).Reference(4,:); flight(traj).Reference(4,:)], [flight(traj).Reference(5,:); flight(traj).Reference(5,:)], 'facecol','no', 'edgecol','interp', 'linew',1.5);
%     plot3(flight(traj).ControlFix(1,:), flight(traj).ControlFix(2,:), flight(traj).ControlFix(3,:), 'LineStyle', 'none', 'Marker', 'x', 'MarkerEdgeColor', 'b', 'MarkerSize', 4)
%     plot3(flight(traj).ControlFix(4,:), flight(traj).ControlFix(5,:), flight(traj).ControlFix(6,:), 'LineStyle', 'none', 'Marker', 'x', 'MarkerEdgeColor', 'r', 'MarkerSize', 4)
%     plot3(flight(traj).CurveFix(1,:), flight(traj).CurveFix(2,:), flight(traj).CurveFix(3,:), 'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', 'b', 'MarkerSize', 4)
%     plot3(flight(traj).CurveFix(4,:), flight(traj).CurveFix(5,:), flight(traj).CurveFix(6,:), 'LineStyle', 'none', 'Marker', 'o', 'MarkerEdgeColor', 'r', 'MarkerSize', 4)
end


% flight = CurveFitting(flight)


