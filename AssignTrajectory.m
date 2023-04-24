%% Assign Trajectory
function flight=AssignTrajectory(flight, Aerodrome, Airspace, Procedure)
global unit Perf plan

for i = 1:length(flight)
    try
    DepFE = 0;
    ArrFE = 0;
    Cr_alt = 0;
    flight(i).FalseFix = [];
    flight(i).old_FalseFix = struct;
    flight(i).old_trajectory = struct;



    % 일단 hard 코딩으로 direct로 했지만, 나중에는 current_position이 절차를 시작하는 지점보다 앞인지
    % 뒤인지 파악해서 direct를 뺄지 결정하도록 할 것
    if strcmp(flight(i).FS, 'TX') == 0
        % ground가 아닌 상황이면 다음 fix 까지 direct로 가자
        TRAJ_num=1;
        flight(i).trajectory=struct;
        flight(i).trajectory(TRAJ_num).TRAJ_num = 1;
        flight(i).trajectory(TRAJ_num).type = 'direct';
        flight(i).trajectory(TRAJ_num).traj_name = 'direct';
        flight(i).trajectory(TRAJ_num).wp_name = 'trajectory_assigned';
        flight(i).trajectory(TRAJ_num).lat = flight(i).lat;
        flight(i).trajectory(TRAJ_num).long = flight(i).long;
        flight(i).trajectory(TRAJ_num).alt = flight(i).alt;
        flight(i).trajectory(TRAJ_num).Vcas = tas2cas(flight(i).Vtas, flight(i).alt);
        flight(i).trajectory(TRAJ_num).Vmach = '';
        flight(i).trajectory(TRAJ_num).Vtas = flight(i).Vtas;
        flight(i).trajectory(TRAJ_num).flyover = false;
        flight(i).trajectory(TRAJ_num).lowalt = flight(i).alt;
        flight(i).trajectory(TRAJ_num).highalt = flight(i).alt;
        flight(i).trajectory(TRAJ_num).lowspd = flight(i).Vtas;
        flight(i).trajectory(TRAJ_num).highspd = flight(i).Vtas;
        flight(i).trajectory(TRAJ_num).mass = flight(i).mass;
        
    
    else
        % ground 라면, TO 이전 상황으로, RWY_THR 이동 -> airbourne 지점을 찍자
        if strcmp(flight(i).command.type{1}, 'SID') == 1

            DepFE = Aerodrome(strcmp(plan(flight(i).id).departure, {Aerodrome.ID})).RWY(strcmp(plan(flight(i).id).departure_RWY, {Aerodrome(strcmp(plan(flight(i).id).departure, {Aerodrome.ID})).RWY.name})).elevation;
            
            TRAJ_num = 1;
            flight(i).trajectory=struct;
            
            if TRAJ_num == 1
                % 첫번째 fix와 두번째 fix가 반경 0.3NM 이내라면 같은 픽스로 취급하자
                FirstTrajDiff = distance(flight(i).lat, flight(i).long, Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight(i).id).departure, '_', plan(flight(i).id).departure_RWY, '_THR'))==1).Lat, Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight(i).id).departure, '_', plan(flight(i).id).departure_RWY, '_THR'))==1).Long);
                if deg2nm(FirstTrajDiff) > 0.3
                    flight(i).trajectory(TRAJ_num).TRAJ_num = 1;
                    flight(i).trajectory(TRAJ_num).type = 'ground';
                    flight(i).trajectory(TRAJ_num).traj_name = 'line-up';
                    flight(i).trajectory(TRAJ_num).wp_name = 'trajectory_assigned';
                    flight(i).trajectory(TRAJ_num).lat = flight(i).lat;
                    flight(i).trajectory(TRAJ_num).long = flight(i).long;
                    flight(i).trajectory(TRAJ_num).alt = DepFE;
                    flight(i).trajectory(TRAJ_num).Vcas = 35;
                    flight(i).trajectory(TRAJ_num).Vmach = '';
                    flight(i).trajectory(TRAJ_num).Vtas = 35;
                    flight(i).trajectory(TRAJ_num).flyover = false;
                    flight(i).trajectory(TRAJ_num).lowalt = flight(i).trajectory(TRAJ_num).alt;
                    flight(i).trajectory(TRAJ_num).highalt = flight(i).trajectory(TRAJ_num).alt;
                    flight(i).trajectory(TRAJ_num).lowspd = 0;
                    flight(i).trajectory(TRAJ_num).highspd = 35;
                    flight(i).trajectory(TRAJ_num).mass = flight(i).mass;
                    TRAJ_num = TRAJ_num + 1;
                end
            end
            
            flight(i).trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
            flight(i).trajectory(TRAJ_num).id = Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight(i).id).departure, '_', plan(flight(i).id).departure_RWY, '_THR'))==1).id;
            flight(i).trajectory(TRAJ_num).type = 'ground';
            flight(i).trajectory(TRAJ_num).traj_name = 'rolling';
            % 원래는 lineup 위치인데, 일단 THR로 잡고 나중에 구현하자
            flight(i).trajectory(TRAJ_num).wp_name = strcat(plan(flight(i).id).departure, '_', plan(flight(i).id).departure_RWY, '_THR');
            flight(i).trajectory(TRAJ_num).lat = Airspace.Waypoint([Airspace.Waypoint.id] == flight(i).trajectory(TRAJ_num).id).Lat;
            flight(i).trajectory(TRAJ_num).long = Airspace.Waypoint([Airspace.Waypoint.id] == flight(i).trajectory(TRAJ_num).id).Long;
            flight(i).trajectory(TRAJ_num).alt = DepFE;
            flight(i).trajectory(TRAJ_num).Vcas = 35;
            flight(i).trajectory(TRAJ_num).Vmach = '';
            flight(i).trajectory(TRAJ_num).Vtas = 35;
            flight(i).trajectory(TRAJ_num).flyover = false;
            flight(i).trajectory(TRAJ_num).lowalt = flight(i).trajectory(TRAJ_num).alt;
            flight(i).trajectory(TRAJ_num).highalt = flight(i).trajectory(TRAJ_num).alt;
            flight(i).trajectory(TRAJ_num).lowspd = 0;
            flight(i).trajectory(TRAJ_num).highspd = 35;
            
            %Airbourne 지점, 일단 rwy 3/5으로 잡았음.
            TRAJ_num = TRAJ_num + 1;
            flight(i).trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
            flight(i).trajectory(TRAJ_num).type = 'SID';
            flight(i).trajectory(TRAJ_num).traj_name = Procedure(flight(i).command.trajectory{1}).name;
            flight(i).trajectory(TRAJ_num).wp_name = strcat(plan(flight(i).id).departure, '_', plan(flight(i).id).departure_RWY, '_Airbourne');
            flight(i).trajectory(TRAJ_num).lat = (Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight(i).id).departure, '_', plan(flight(i).id).departure_RWY, '_THR'))==1).Lat * 2 + Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight(i).id).departure, '_', plan(flight(i).id).departure_RWY, '_END'))==1).Lat * 3) / 5;
            flight(i).trajectory(TRAJ_num).long = (Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight(i).id).departure, '_', plan(flight(i).id).departure_RWY, '_THR'))==1).Long * 2 + Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight(i).id).departure, '_', plan(flight(i).id).departure_RWY, '_END'))==1).Long * 3) / 5;
            flight(i).trajectory(TRAJ_num).alt = DepFE;
            if strcmp(Perf.(flight(i).type).Engtype,'Jet')==1
                flight(i).trajectory(TRAJ_num).Vcas = 1.2*sqrt(flight(i).mass/Perf.(flight(i).type).Mass_ref)*Perf.(flight(i).type).Vstall_TO + 15;
                flight(i).trajectory(TRAJ_num).Vtas = cas2tas(1.2*sqrt(flight(i).mass/Perf.(flight(i).type).Mass_ref)*Perf.(flight(i).type).Vstall_TO+5,flight(i).trajectory(TRAJ_num).alt);
            else
                flight(i).trajectory(TRAJ_num).Vcas = 1.2*sqrt(flight(i).mass/Perf.(flight(i).type).Mass_ref)*Perf.(flight(i).type).Vstall_TO + 30;
                flight(i).trajectory(TRAJ_num).Vtas = cas2tas(1.2*sqrt(flight(i).mass/Perf.(flight(i).type).Mass_ref)*Perf.(flight(i).type).Vstall_TO+20,flight(i).trajectory(TRAJ_num).alt);
            end
            flight(i).trajectory(TRAJ_num).Vmach = '';
            flight(i).trajectory(TRAJ_num).flyover = false;
            flight(i).trajectory(TRAJ_num).lowalt = flight(i).trajectory(TRAJ_num).alt;
            flight(i).trajectory(TRAJ_num).highalt = flight(i).trajectory(TRAJ_num).alt;
            flight(i).trajectory(TRAJ_num).lowspd = 1.2*sqrt(flight(i).mass/Perf.(flight(i).type).Mass_ref)*Perf.(flight(i).type).Vstall_TO;
            flight(i).trajectory(TRAJ_num).highspd = 9999;
            
        else
            % ground movement
            ['warning! flight #' num2str(i) ' has trajectory other than SID']
        end
    end
    
    for j = 1:length(flight(i).command.status)
        
        switch flight(i).command.status{j}
            case {'procedure' 'route'}
                origin = Procedure(flight(i).command.trajectory{j}).trajectory([Procedure(flight(i).command.trajectory{j}).trajectory.WP_id] == flight(i).command.origination{j}).WP_num;
                dest = Procedure(flight(i).command.trajectory{j}).trajectory([Procedure(flight(i).command.trajectory{j}).trajectory.WP_id] == flight(i).command.destination{j}).WP_num;
                TRAJ_num=length(flight(i).trajectory);
                
                if (j > 1) + (TRAJ_num > 1) == 2
                    if flight(i).command.destination{j-1} == flight(i).command.origination{j}
                        IMP_TRAJ_num = 0;
                    else
                        ['warning! flight #' num2str(i) ' has different origin(' Procedure(flight(i).command.trajectory{j}).trajectory(origin).WP_name ') & destiation (' Procedure(flight(i).command.trajectory{j-1}).trajectory(dest).WP_name ') in connecting trajectory waypoint # ' num2str(TRAJ_num)]
                        IMP_TRAJ_num = 1;
                    end
                else
                    IMP_TRAJ_num = 1;
                end
                
                if strcmp(flight(i).command.status{j}, 'route')
                    if origin <= dest
                        kstep = 1;
                    else
                        kstep = -1;
                    end
                else
                    kstep = 1;
                end


                for k = origin:kstep:dest
                    if IMP_TRAJ_num == 0;
                        if flight(i).trajectory(TRAJ_num).TRAJ_num ~= TRAJ_num;
                            ['error! flight #' num2str(i) ' has error in TRAJ_num (' num2str(TRAJ_num) ') trajectory waypoint # ' num2str(TRAJ_num)]
                        end
                        if flight(i).trajectory(TRAJ_num).id ~= Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_id;
                            ['error! flight #' num2str(i) ' has error in WP_id (' flight(i).trajectory(TRAJ_num).id ') trajectory waypoint # ' num2str(TRAJ_num)]
                        end
                        if strcmp(flight(i).trajectory(TRAJ_num).wp_name, Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_name) == 0;
                            ['error! flight #' num2str(i) ' has error in WP_name (' flight(i).trajectory(TRAJ_num).wp_name ') trajectory waypoint # ' num2str(TRAJ_num)]
                        end
                        if flight(i).trajectory(TRAJ_num).lat ~= Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_lat;
                            ['error! flight #' num2str(i) ' has error in WP_lat (' num2str(flight(i).trajectory(TRAJ_num).lat) ') trajectory waypoint # ' num2str(TRAJ_num)]
                        end
                        if flight(i).trajectory(TRAJ_num).long ~= Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_long;
                            ['error! flight #' num2str(i) ' has error in WP_long (' num2str(flight(i).trajectory(TRAJ_num).long) ') trajectory waypoint # ' num2str(TRAJ_num)]
                        end
                        
                        flight(i).trajectory(TRAJ_num).lowalt = max(flight(i).trajectory(TRAJ_num).lowalt, Procedure(flight(i).command.trajectory{j}).trajectory(k).lowalt);
                        flight(i).trajectory(TRAJ_num).highalt = min(flight(i).trajectory(TRAJ_num).highalt, Procedure(flight(i).command.trajectory{j}).trajectory(k).highalt);
                        
                        if strcmp(flight(i).command.status{j}, 'procedure') == 1
                            flight(i).trajectory(TRAJ_num).lowspd = max(flight(i).trajectory(TRAJ_num).lowspd, Procedure(flight(i).command.trajectory{j}).trajectory(k).lowspd);
                            flight(i).trajectory(TRAJ_num).highspd = min(flight(i).trajectory(TRAJ_num).highspd, Procedure(flight(i).command.trajectory{j}).trajectory(k).highspd);
                        end
                        
                        
                    else
                        
                        if TRAJ_num == 1
                            % 첫번째 fix와 두번째 fix가 반경 0.3NM 이내라면 같은 픽스로 취급하자
                            FirstTrajDiff = distance(flight(i).trajectory(1).lat, flight(i).trajectory(1).long, Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_lat, Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_long);
                            if deg2nm(FirstTrajDiff) <= 0.3
                                flight(i).trajectory(TRAJ_num).id = Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_id;
                                flight(i).trajectory(TRAJ_num).type = flight(i).command.type{j};
                                flight(i).trajectory(TRAJ_num).traj_name = Procedure(flight(i).command.trajectory{j}).name;
                                flight(i).trajectory(TRAJ_num).wp_name = Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_name;
                                flight(i).trajectory(TRAJ_num).lat = Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_lat;
                                flight(i).trajectory(TRAJ_num).long = Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_long;
                                flight(i).trajectory(TRAJ_num).lowalt = Procedure(flight(i).command.trajectory{j}).trajectory(k).lowalt;
                                flight(i).trajectory(TRAJ_num).highalt = Procedure(flight(i).command.trajectory{j}).trajectory(k).highalt;
                                
                                if strcmp(flight(i).command.status{j}, 'procedure') == 1
                                    flight(i).trajectory(TRAJ_num).flyover = Procedure(flight(i).command.trajectory{j}).trajectory(k).flyover;
                                    flight(i).trajectory(TRAJ_num).lowspd = Procedure(flight(i).command.trajectory{j}).trajectory(k).lowspd;
                                    flight(i).trajectory(TRAJ_num).highspd = Procedure(flight(i).command.trajectory{j}).trajectory(k).highspd;
                                    
                                elseif strcmp(flight(i).command.status{j}, 'route') == 1
                                    flight(i).trajectory(TRAJ_num).flyover = false;
                                    flight(i).trajectory(TRAJ_num).lowspd = 0;
                                    flight(i).trajectory(TRAJ_num).highspd = 9999;
                                end
                            else
                                TRAJ_num = TRAJ_num + 1;
                                flight(i).trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                                flight(i).trajectory(TRAJ_num).id = Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_id;
                                flight(i).trajectory(TRAJ_num).type = flight(i).command.type{j};
                                flight(i).trajectory(TRAJ_num).traj_name = Procedure(flight(i).command.trajectory{j}).name;
                                flight(i).trajectory(TRAJ_num).wp_name = Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_name;
                                flight(i).trajectory(TRAJ_num).lat = Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_lat;
                                flight(i).trajectory(TRAJ_num).long = Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_long;
                                flight(i).trajectory(TRAJ_num).lowalt = Procedure(flight(i).command.trajectory{j}).trajectory(k).lowalt;
                                flight(i).trajectory(TRAJ_num).highalt = Procedure(flight(i).command.trajectory{j}).trajectory(k).highalt;
                                
                                if strcmp(flight(i).command.status{j}, 'procedure') == 1
                                    flight(i).trajectory(TRAJ_num).flyover = Procedure(flight(i).command.trajectory{j}).trajectory(k).flyover;
                                    flight(i).trajectory(TRAJ_num).lowspd = Procedure(flight(i).command.trajectory{j}).trajectory(k).lowspd;
                                    flight(i).trajectory(TRAJ_num).highspd = Procedure(flight(i).command.trajectory{j}).trajectory(k).highspd;
                                    
                                elseif strcmp(flight(i).command.status{j}, 'route') == 1
                                    flight(i).trajectory(TRAJ_num).flyover = false;
                                    flight(i).trajectory(TRAJ_num).lowspd = 0;
                                    flight(i).trajectory(TRAJ_num).highspd = 9999;
                                end
                                
                            end
                        else
                            TRAJ_num = TRAJ_num + 1;
                            flight(i).trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                            flight(i).trajectory(TRAJ_num).id = Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_id;
                            flight(i).trajectory(TRAJ_num).type = flight(i).command.type{j};
                            flight(i).trajectory(TRAJ_num).traj_name = Procedure(flight(i).command.trajectory{j}).name;
                            flight(i).trajectory(TRAJ_num).wp_name = Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_name;
                            flight(i).trajectory(TRAJ_num).lat = Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_lat;
                            flight(i).trajectory(TRAJ_num).long = Procedure(flight(i).command.trajectory{j}).trajectory(k).WP_long;
                            flight(i).trajectory(TRAJ_num).lowalt = Procedure(flight(i).command.trajectory{j}).trajectory(k).lowalt;
                            flight(i).trajectory(TRAJ_num).highalt = Procedure(flight(i).command.trajectory{j}).trajectory(k).highalt;
                            
                            if strcmp(flight(i).command.status{j}, 'procedure') == 1
                                flight(i).trajectory(TRAJ_num).flyover = Procedure(flight(i).command.trajectory{j}).trajectory(k).flyover;
                                flight(i).trajectory(TRAJ_num).lowspd = Procedure(flight(i).command.trajectory{j}).trajectory(k).lowspd;
                                flight(i).trajectory(TRAJ_num).highspd = Procedure(flight(i).command.trajectory{j}).trajectory(k).highspd;
                                
                            elseif strcmp(flight(i).command.status{j}, 'route') == 1
                                flight(i).trajectory(TRAJ_num).flyover = false;
                                flight(i).trajectory(TRAJ_num).lowspd = 0;
                                flight(i).trajectory(TRAJ_num).highspd = 9999;
                            end
                        end
                        
                    end
                    
                    IMP_TRAJ_num = IMP_TRAJ_num + 1;
                    
                    if k == dest
                        switch flight(i).command.type{j}
                            case 'INST'
                                % INST 마지막에는 RWY를 trajectory에 넣어주자

                                if strcmp(flight(i).trajectory(TRAJ_num).wp_name, strcat(plan(flight(i).id).arrival, '_', plan(flight(i).id).arrival_RWY, '_THR')) == 1
                                    ArrFE = Aerodrome(strcmp(plan(flight(i).id).arrival, {Aerodrome.ID})).RWY(strcmp(plan(flight(i).id).arrival_RWY, {Aerodrome(strcmp(plan(flight(i).id).arrival, {Aerodrome.ID})).RWY.name})).elevation;

                                    if Procedure(flight(i).command.trajectory{j}).trajectory(k).RDH == 0;
                                        Procedure(flight(i).command.trajectory{j}).trajectory(k).RDH = '-3.0';
                                    end
                                        % RWY End 지점이 존재한다 -> 이후 TDZ는 RDH에 따른다.
                                        
                                        %Touchdown 지점, RDH로 reckon함수로 구하자
                                        TRAJ_num = TRAJ_num + 1;
                                        flight(i).trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                                        flight(i).trajectory(TRAJ_num).type = 'INST';
                                        flight(i).trajectory(TRAJ_num).traj_name = Procedure(flight(i).command.trajectory{j}).name;
                                        flight(i).trajectory(TRAJ_num).wp_name = strcat(plan(flight(i).id).arrival, '_', plan(flight(i).id).arrival_RWY, '_TouchDown');
                                        
                                        % Low Alt를 기준으로 잡자.
                                        DescRate_RDH = tan(deg2rad(str2double(Procedure(flight(i).command.trajectory{j}).trajectory(k).RDH))) * unit.nm2meter / unit.ft2meter;
                                        THR2TDZ = -1 * (flight(i).trajectory(TRAJ_num - 1).lowalt / DescRate_RDH);
                                        bearing = azimuth(flight(i).trajectory(TRAJ_num - 2).lat, flight(i).trajectory(TRAJ_num - 2).long, flight(i).trajectory(TRAJ_num - 1).lat, flight(i).trajectory(TRAJ_num - 1).long);
                                        
                                        [flight(i).trajectory(TRAJ_num).lat, flight(i).trajectory(TRAJ_num).long] = reckon(flight(i).trajectory(TRAJ_num - 1).lat, flight(i).trajectory(TRAJ_num - 1).long, nm2deg(THR2TDZ), bearing);
                                        flight(i).trajectory(TRAJ_num).alt = ArrFE;
                                        flight(i).trajectory(TRAJ_num).Vcas = 1.3*sqrt(flight(i).mass/Perf.(flight(i).type).Mass_ref)*Perf.(flight(i).type).Vstall_LD + 5;
                                        flight(i).trajectory(TRAJ_num).Vtas = cas2tas(1.3*sqrt(flight(i).mass/Perf.(flight(i).type).Mass_ref)*Perf.(flight(i).type).Vstall_LD + 5,flight(i).trajectory(TRAJ_num).alt);
                                        flight(i).trajectory(TRAJ_num).flyover = false;
                                        
                                        flight(i).trajectory(TRAJ_num).lowalt = flight(i).trajectory(TRAJ_num).alt;
                                        flight(i).trajectory(TRAJ_num).highalt = flight(i).trajectory(TRAJ_num).alt;
                                        flight(i).trajectory(TRAJ_num).lowspd = flight(i).trajectory(TRAJ_num).Vtas;
                                        flight(i).trajectory(TRAJ_num).highspd = 9999;
                                        
                                        
                                        %Taxi Segment -> brake로 약
                                        %0.5NM(3000ft)로 잡음
                                        TRAJ_num = TRAJ_num + 1;
                                        flight(i).trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                                        flight(i).trajectory(TRAJ_num).type = 'ground';
                                        flight(i).trajectory(TRAJ_num).traj_name = 'brake';
                                        flight(i).trajectory(TRAJ_num).wp_name = strcat(plan(flight(i).id).arrival, '_', plan(flight(i).id).arrival_RWY, '_Brake');
                                        
                                        [flight(i).trajectory(TRAJ_num).lat, flight(i).trajectory(TRAJ_num).long] = reckon(flight(i).trajectory(TRAJ_num - 1).lat, flight(i).trajectory(TRAJ_num - 1).long, nm2deg(0.5), bearing);
                                        flight(i).trajectory(TRAJ_num).alt = ArrFE;
                                        flight(i).trajectory(TRAJ_num).Vcas = '';
                                        flight(i).trajectory(TRAJ_num).Vtas = '';
                                        flight(i).trajectory(TRAJ_num).flyover = false;
                                        
                                        flight(i).trajectory(TRAJ_num).lowalt = flight(i).trajectory(TRAJ_num).alt;
                                        flight(i).trajectory(TRAJ_num).highalt = flight(i).trajectory(TRAJ_num).alt;
                                        flight(i).trajectory(TRAJ_num).lowspd = 0;
                                        flight(i).trajectory(TRAJ_num).highspd = 9999;
                                        
                                        

                                    
                                    
                                else
                                    TRAJ_num = TRAJ_num + 1;
                                    flight(i).trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                                    flight(i).trajectory(TRAJ_num).id = Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight(i).id).arrival, '_', plan(flight(i).id).arrival_RWY, '_THR'))==1).id;
                                    flight(i).trajectory(TRAJ_num).type = 'INST';
                                    flight(i).trajectory(TRAJ_num).traj_name = Procedure(flight(i).command.trajectory{j}).name;
                                    flight(i).trajectory(TRAJ_num).wp_name = strcat(plan(flight(i).id).arrival, '_', plan(flight(i).id).arrival_RWY, '_THR');
                                    flight(i).trajectory(TRAJ_num).lat = Airspace.Waypoint([Airspace.Waypoint.id] == flight(i).trajectory(TRAJ_num).id).Lat;
                                    flight(i).trajectory(TRAJ_num).long = Airspace.Waypoint([Airspace.Waypoint.id] == flight(i).trajectory(TRAJ_num).id).Long;
                                    flight(i).trajectory(TRAJ_num).alt = '';
                                    flight(i).trajectory(TRAJ_num).Vcas = 1.3 * sqrt(flight(i).mass/Perf.(flight(i).type).Mass_ref) * Perf.(flight(i).type).Vstall_LD + 5;
                                    flight(i).trajectory(TRAJ_num).Vmach = '';
                                    flight(i).trajectory(TRAJ_num).Vtas = cas2tas(1.3 * sqrt(flight(i).mass/Perf.(flight(i).type).Mass_ref) * Perf.(flight(i).type).Vstall_LD + 5, 0);
                                    flight(i).trajectory(TRAJ_num).flyover = false;
                                    flight(i).trajectory(TRAJ_num).lowalt = 0;
                                    flight(i).trajectory(TRAJ_num).highalt = 100000;
                                    flight(i).trajectory(TRAJ_num).lowspd = flight(i).trajectory(TRAJ_num).Vtas;
                                    flight(i).trajectory(TRAJ_num).highspd = 9999;
                                    
                                    %Touchdown 지점, 일단 rwy 1/4 지점으로 잡았음.
                                    TRAJ_num = TRAJ_num + 1;
                                    flight(i).trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                                    flight(i).trajectory(TRAJ_num).type = 'INST';
                                    flight(i).trajectory(TRAJ_num).traj_name = Procedure(flight(i).command.trajectory{j}).name;
                                    flight(i).trajectory(TRAJ_num).wp_name = strcat(plan(flight(i).id).arrival, '_', plan(flight(i).id).arrival_RWY, '_TouchDown');
                                    flight(i).trajectory(TRAJ_num).lat = (Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight(i).id).arrival, '_', plan(flight(i).id).arrival_RWY, '_THR'))==1).Lat * 3 + Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight(i).id).arrival, '_', plan(flight(i).id).arrival_RWY, '_END'))==1).Lat) / 4;
                                    flight(i).trajectory(TRAJ_num).long = (Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight(i).id).arrival, '_', plan(flight(i).id).arrival_RWY, '_THR'))==1).Long * 3 + Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight(i).id).arrival, '_', plan(flight(i).id).arrival_RWY, '_END'))==1).Long) / 4;
                                    flight(i).trajectory(TRAJ_num).alt = ArrFE;
                                    flight(i).trajectory(TRAJ_num).Vcas = 1.3*sqrt(flight(i).mass/Perf.(flight(i).type).Mass_ref)*Perf.(flight(i).type).Vstall_LD + 5;
                                    flight(i).trajectory(TRAJ_num).Vmach = '';
                                    flight(i).trajectory(TRAJ_num).Vtas = cas2tas(1.3*sqrt(flight(i).mass/Perf.(flight(i).type).Mass_ref)*Perf.(flight(i).type).Vstall_LD + 5,flight(i).trajectory(TRAJ_num).alt);
                                    flight(i).trajectory(TRAJ_num).flyover = false;
                                    
                                    flight(i).trajectory(TRAJ_num).lowalt = flight(i).trajectory(TRAJ_num).alt;
                                    flight(i).trajectory(TRAJ_num).highalt = flight(i).trajectory(TRAJ_num).alt;
                                    flight(i).trajectory(TRAJ_num).lowspd = 1.3*sqrt(flight(i).mass/Perf.(flight(i).type).Mass_ref)*Perf.(flight(i).type).Vstall_LD;
                                    flight(i).trajectory(TRAJ_num).highspd = 9999;
                                    
                                    
                                    %Taxi Segment -> brake로 약
                                    %0.5NM(3000ft)로 잡음
                                    TRAJ_num = TRAJ_num + 1;
                                    flight(i).trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                                    flight(i).trajectory(TRAJ_num).type = 'ground';
                                    flight(i).trajectory(TRAJ_num).traj_name = 'Brake';
                                    flight(i).trajectory(TRAJ_num).wp_name = strcat(plan(flight(i).id).arrival, '_', plan(flight(i).id).arrival_RWY, '_Brake');
                                    bearing = azimuth(flight(i).trajectory(TRAJ_num - 2).lat, flight(i).trajectory(TRAJ_num - 2).long, flight(i).trajectory(TRAJ_num - 1).lat, flight(i).trajectory(TRAJ_num - 1).long);
                                    [flight(i).trajectory(TRAJ_num).lat, flight(i).trajectory(TRAJ_num).long] = reckon(flight(i).trajectory(TRAJ_num - 1).lat, flight(i).trajectory(TRAJ_num - 1).long, nm2deg(0.5), bearing);
                                    
                                    flight(i).trajectory(TRAJ_num).alt = ArrFE;
                                    flight(i).trajectory(TRAJ_num).Vcas = '';
                                    flight(i).trajectory(TRAJ_num).Vmach = '';
                                    flight(i).trajectory(TRAJ_num).Vtas = '';
                                    flight(i).trajectory(TRAJ_num).flyover = false;
                                    
                                    flight(i).trajectory(TRAJ_num).lowalt = flight(i).trajectory(TRAJ_num).alt;
                                    flight(i).trajectory(TRAJ_num).highalt = flight(i).trajectory(TRAJ_num).alt;
                                    flight(i).trajectory(TRAJ_num).lowspd = 0;
                                    flight(i).trajectory(TRAJ_num).highspd = 9999;
                                    
                                    
                                end
                                
                                
                        end
                    end
                end
                
            case'direct'
                TRAJ_num = length(flight(i).trajectory);
                if strcmp(flight(i).trajectory(TRAJ_num).wp_name, Airspace.Waypoint([Airspace.Waypoint.id] == flight(i).command.destination{j}).Name) == 1
                    ['warning! flight #' num2str(i) ' has same direct waypoint(' flight(i).trajectory(TRAJ_num).name ') in connecting trajectory waypoint # ' num2str(TRAJ_num)]
                else
                    TRAJ_num = TRAJ_num + 1;
                    flight(i).trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                    flight(i).trajectory(TRAJ_num).id = flight(i).command.destination{j};
                    flight(i).trajectory(TRAJ_num).type = flight(i).command.type{j};
                    flight(i).trajectory(TRAJ_num).traj_name = 'direct';
                    flight(i).trajectory(TRAJ_num).wp_name = Airspace.Waypoint([Airspace.Waypoint.id] == flight(i).command.destination{j}).Name;
                    flight(i).trajectory(TRAJ_num).lat = Airspace.Waypoint([Airspace.Waypoint.id] == flight(i).command.destination{j}).Lat;
                    flight(i).trajectory(TRAJ_num).long = Airspace.Waypoint([Airspace.Waypoint.id] == flight(i).command.destination{j}).Long;
                    flight(i).trajectory(TRAJ_num).flyover = false;
                    
                    if strcmp(flight(i).command.altitude{j}, 'default')
                        
                        flight(i).trajectory(TRAJ_num).alt = flight(i).trajectory(TRAJ_num - 1).alt;
                        
                    elseif ~isnan(str2double(flight(i).command.altitude{j}))
                        flight(i).trajectory(TRAJ_num).alt = str2double(flight(i).command.altitude{j});
                    else
                        ['cannot read altitude command of flight #' num2str(i) ' Trajectory #' num2str(TRAJ_num) ' check altitude command in ' num2str(j)]
                        flight(i).trajectory(TRAJ_num).alt = flight(i).trajectory(TRAJ_num - 1).alt;
                    end
                    flight(i).trajectory(TRAJ_num).lowalt = 0;
                    flight(i).trajectory(TRAJ_num).highalt = 100000;
                    flight(i).trajectory(TRAJ_num).lowspd = 0;
                    flight(i).trajectory(TRAJ_num).highspd = 9999;
                end
                
            case 'vectoring'
                TRAJ_num=length(flight(i).trajectory) + 1;
                
                % 3rd order Bezier Curve Setting
                
                % P0 -> Origination
                flight(i).trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                flight(i).trajectory(TRAJ_num).id = flight(i).command.origination{j};
                flight(i).trajectory(TRAJ_num).type = flight(i).command.type{j};
                flight(i).trajectory(TRAJ_num).traj_name = 'vectoring';
                flight(i).trajectory(TRAJ_num).wp_name = Airspace.Waypoint([Airspace.Waypoint.id] == flight(i).command.origination{j}).Name;
                flight(i).trajectory(TRAJ_num).lat = Airspace.Waypoint([Airspace.Waypoint.id] == flight(i).command.origination{j}).Lat;
                flight(i).trajectory(TRAJ_num).long = Airspace.Waypoint([Airspace.Waypoint.id] == flight(i).command.origination{j}).Long;
                flight(i).trajectory(TRAJ_num).flyover = false;
                
                if strcmp(flight(i).command.altitude{j}, 'default')
                    flight(i).trajectory(TRAJ_num).alt = flight(i).trajectory(TRAJ_num - 1).alt;
                elseif ~isnan(str2double(flight(i).command.altitude{j}))
                    flight(i).trajectory(TRAJ_num).alt = str2double(flight(i).command.altitude{j});
                else
                    ['cannot read altitude command of flight #' num2str(i) ' Trajectory #' num2str(TRAJ_num) ' check altitude command in ' num2str(j)]
                    flight(i).trajectory(TRAJ_num).alt = flight(i).trajectory(TRAJ_num - 1).alt;
                end
                
                flight(i).trajectory(TRAJ_num).lowalt = 0;
                flight(i).trajectory(TRAJ_num).highalt = 100000;
                flight(i).trajectory(TRAJ_num).lowspd = 0;
                flight(i).trajectory(TRAJ_num).highspd = 9999;
                
                % P1 -> 임의의 점
                TRAJ_num = TRAJ_num + 1;
                flight(i).trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                flight(i).trajectory(TRAJ_num).type = flight(i).command.type{j};
                flight(i).trajectory(TRAJ_num).traj_name = 'vectoring';
                flight(i).trajectory(TRAJ_num).wp_name = 'P1';
                flight(i).trajectory(TRAJ_num).flyover = false;
                
                if strcmp(flight(i).command.altitude{j}, 'default')
                    flight(i).trajectory(TRAJ_num).alt = flight(i).trajectory(TRAJ_num - 1).alt;
                elseif ~isnan(str2double(flight(i).command.altitude{j}))
                    flight(i).trajectory(TRAJ_num).alt = str2double(flight(i).command.altitude{j});
                else
                    ['cannot read altitude command of flight #' num2str(i) ' Trajectory #' num2str(TRAJ_num) ' check altitude command in ' num2str(j)]
                    flight(i).trajectory(TRAJ_num).alt = flight(i).trajectory(TRAJ_num - 1).alt;
                end
                
                
                flight(i).trajectory(TRAJ_num).lowalt = 0;
                flight(i).trajectory(TRAJ_num).highalt = 100000;
                flight(i).trajectory(TRAJ_num).lowspd = 0;
                flight(i).trajectory(TRAJ_num).highspd = 9999;
                
                % P2 -> 임의의 점
                TRAJ_num = TRAJ_num + 1;
                flight(i).trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                flight(i).trajectory(TRAJ_num).type = flight(i).command.type{j};
                flight(i).trajectory(TRAJ_num).traj_name = 'vectoring';
                flight(i).trajectory(TRAJ_num).wp_name = 'P2';
                flight(i).trajectory(TRAJ_num).flyover = false;
                
                if strcmp(flight(i).command.altitude{j}, 'default')
                    flight(i).trajectory(TRAJ_num).alt = flight(i).trajectory(TRAJ_num - 1).alt;
                elseif ~isnan(str2double(flight(i).command.altitude{j}))
                    flight(i).trajectory(TRAJ_num).alt = str2double(flight(i).command.altitude{j});
                else
                    ['cannot read altitude command of flight #' num2str(i) ' Trajectory #' num2str(TRAJ_num) ' check altitude command in ' num2str(j)]
                    flight(i).trajectory(TRAJ_num).alt = flight(i).trajectory(TRAJ_num - 1).alt;
                end
                
                flight(i).trajectory(TRAJ_num).lowalt = 0;
                flight(i).trajectory(TRAJ_num).highalt = 100000;
                flight(i).trajectory(TRAJ_num).lowspd = 0;
                flight(i).trajectory(TRAJ_num).highspd = 9999;
                
                % P3 -> Destination
                TRAJ_num = TRAJ_num + 1;
                flight(i).trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                flight(i).trajectory(TRAJ_num).id = flight(i).command.destination{j};
                flight(i).trajectory(TRAJ_num).type = flight(i).command.type{j};
                flight(i).trajectory(TRAJ_num).traj_name = 'vectoring';
                flight(i).trajectory(TRAJ_num).wp_name = Airspace.Waypoint([Airspace.Waypoint.id] == flight(i).command.destination{j}).Name;
                flight(i).trajectory(TRAJ_num).lat = Airspace.Waypoint([Airspace.Waypoint.id] == flight(i).command.destination{j}).Lat;
                flight(i).trajectory(TRAJ_num).long = Airspace.Waypoint([Airspace.Waypoint.id] == flight(i).command.destination{j}).Long;
                flight(i).trajectory(TRAJ_num).flyover = false;
                
                if strcmp(flight(i).command.altitude{j}, 'default')
                    flight(i).trajectory(TRAJ_num).alt = flight(i).trajectory(TRAJ_num - 1).alt;
                elseif ~isnan(str2double(flight(i).command.altitude{j}))
                    flight(i).trajectory(TRAJ_num).alt = str2double(flight(i).command.altitude{j});
                else
                    ['cannot read altitude command of flight #' num2str(i) ' Trajectory #' num2str(TRAJ_num) ' check altitude command in ' num2str(j)]
                    flight(i).trajectory(TRAJ_num).alt = flight(i).trajectory(TRAJ_num - 1).alt;
                end
                
                flight(i).trajectory(TRAJ_num).lowalt = 0;
                flight(i).trajectory(TRAJ_num).highalt = 100000;
                flight(i).trajectory(TRAJ_num).lowspd = 0;
                flight(i).trajectory(TRAJ_num).highspd = 9999;
                
                % P1 & P2 는 constraint 정한 후 다시 결정
                % 임시 위치는 일단 1/3 2/3 지점으로...
                flight(i).trajectory(TRAJ_num - 2).lat = 2/3 * flight(i).trajectory(TRAJ_num - 3).lat + 1/3 * flight(i).trajectory(TRAJ_num).lat;
                flight(i).trajectory(TRAJ_num - 2).long = 2/3 * flight(i).trajectory(TRAJ_num - 3).long + 1/3 * flight(i).trajectory(TRAJ_num).long;
                
                flight(i).trajectory(TRAJ_num - 1).lat = 1/3 * flight(i).trajectory(TRAJ_num - 3).lat + 2/3 * flight(i).trajectory(TRAJ_num).lat;
                flight(i).trajectory(TRAJ_num - 1).long = 1/3 * flight(i).trajectory(TRAJ_num - 3).long + 2/3 * flight(i).trajectory(TRAJ_num).long;
                
        end
    end
    
    
    
    
    alt_fix = [];
    spd_fix = [];
    acc_fix = [];
    
    
    
    Assignloop = 1;
    Validateloop = 1;
    AltAssign = true;
    SpdAssign = true;
    AssignProgress = true;
    ValidateProgress = true;
    
    % initial altitude assignment
    while ValidateProgress
        while AssignProgress
            
            
            if Assignloop <= 100
                ['Flight #' num2str(i) ' Trajectory Assignment in progress for ' num2str(Assignloop) ' times.']
                
                while AltAssign
                    
                    for l = 1:length(flight(i).trajectory)
                        if l ~= length(flight(i).trajectory)
                            [dist_deg, flight(i).trajectory(l).heading] = distance(flight(i).trajectory(l).lat, flight(i).trajectory(l).long, flight(i).trajectory(l + 1).lat, flight(i).trajectory(l + 1).long);
                            flight(i).trajectory(l).distance = dist_deg * 60;
                        end
                        if and(~isempty(flight(i).trajectory(l).lowalt), ~isempty(flight(i).trajectory(l).highalt))
                            if flight(i).trajectory(l).highalt - flight(i).trajectory(l).lowalt < 100;
                                flight(i).trajectory(l).alt = flight(i).trajectory(l).lowalt;
                                alt_fix = [alt_fix l];
                            end
                        end
                    end
                    
                    alt_fix = sort(unique(alt_fix));
                    
                    
                    % OPTION: CDO profile / low altitude profile / 이후 fitting 작업하고 해당
                    % profile 적용할 것
                    
                    % SID: 이륙 후 cruising alt에 도달할때까지 linear
                    % STAR, INST: 착륙 때 까지 3도 각도로 쭉 올림
                    % route: 고도 유지
                    
                    
                    % Cruise Altitude 구하기
                    
                    
                    % Cruise Alt
                    if ~isempty(find(strcmp({flight(i).trajectory.wp_name}, 'trajectory_assigned') == 1, 1));
                        switch flight(i).trajectory(strcmp({flight(i).trajectory.wp_name}, 'trajectory_assigned') == 1).type
                            case {'ground' 'SID'}
                                if ~isempty(find(strcmp({flight(i).trajectory(~cellfun(@isempty,{flight(i).trajectory.alt})).type}, 'route')==1, 1));
                                    
                                    if strcmp(flight(i).trajectory(min(find(strcmp({flight(i).trajectory(~cellfun(@isempty,{flight(i).trajectory.alt})).type}, 'route')==1, 1, 'last') + 1, length(flight(i).trajectory)) ).type, 'route')
                                        % From CDO Profile:
                                        % Cr_alt = max(plan(flight(i).id).cruising_alt,flight(i).trajectory(find(~cellfun(@isempty,{flight(i).trajectory.alt}), 1, 'last' )).alt);
                                        
                                        % From CCO Profile:
                                        Cr_alt = max([flight(i).trajectory(strcmp('route', {flight(i).trajectory.type})).alt]);
                                    else
                                        Cr_alt = plan(flight(i).id).cruising_alt;
                                    end
                                    
                                else
                                    Cr_alt = plan(flight(i).id).cruising_alt;
                                end
                            otherwise
                                if ~isempty(find(strcmp({flight(i).trajectory.type}, 'route') == 1, 1));
                                    if ~isempty(find(strcmp({flight(i).trajectory(~cellfun(@isempty,{flight(i).trajectory.alt})).type}, 'route')==1, 1));
                                        if strcmp(flight(i).trajectory(find(strcmp({flight(i).trajectory(~cellfun(@isempty,{flight(i).trajectory.alt})).type}, 'route')==1, 1, 'last') + 1).type, 'route')
                                            % From CDO Profile:
                                            Cr_alt = flight(i).trajectory(find(~cellfun(@isempty,{flight(i).trajectory.alt}), 1, 'last' )).alt;
                                            
                                            % From CCO Profile:
                                            % Cr_alt = flight(i).trajectory(find(~cellfun(@isempty,{flight(i).trajectory.alt}), 1)).alt;
                                        else
                                            Cr_alt = plan(flight(i).id).cruising_alt;
                                        end
                                    else
                                        Cr_alt = plan(flight(i).id).cruising_alt;
                                    end
                                else
                                    Cr_alt = max([flight(i).trajectory.alt]);
                                end
                        end
                    else
                        if ~isempty(find(strcmp({flight(i).trajectory(~cellfun(@isempty,{flight(i).trajectory.alt})).type}, 'route')==1, 1));
                            if strcmp(flight(i).trajectory(find(strcmp({flight(i).trajectory(~cellfun(@isempty,{flight(i).trajectory.alt})).type}, 'route')==1, 1, 'last') + 1).type, 'route')
                                if isempty(flight(i).trajectory(find(strcmp({flight(i).trajectory(~cellfun(@isempty,{flight(i).trajectory.alt})).type}, 'route')==1, 1, 'last') + 1).alt);
                                    Cr_alt = plan(flight(i).id).cruising_alt;
                                else
                                    % From CDO Profile:
                                    Cr_alt = flight(i).trajectory(find(~cellfun(@isempty,{flight(i).trajectory.alt}), 1, 'last' )).alt;
                                    % From CCO Profile:
                                    % Cr_alt = flight(i).trajectory(find(~cellfun(@isempty,{flight(i).trajectory.alt}), 1)).alt;
                                end
                            else
                                Cr_alt = plan(flight(i).id).cruising_alt;
                            end
                        else
                            % From CDO Profile:
                            Cr_alt = max(plan(flight(i).id).cruising_alt, flight(i).trajectory(find(~cellfun(@isempty,{flight(i).trajectory.alt}), 1, 'last' )).alt);
                            
                            % From CCO Profile:
                            %                         Cr_alt = max(plan(flight(i).id).crusing_alt, flight(i).trajectory(find(~cellfun(@isempty,{flight(i).trajectory.alt}), 1)).alt);
                        end
                    end
                    
                    
                    
                    
                    switch plan(flight(i).id).desc_profile
                        case 'CDO_flex'
                            ['Assigning Trajectory.....flight #' num2str(i) ' descending altitude profile: ' plan(flight(i).id).desc_profile]
                            [flight(i), alt_fix] = Desc_Profile_CDO_flex(flight(i), alt_fix, acc_fix, ArrFE, Cr_alt);
                            
                        case 'CDO_strict'
                            
                        case 'lowest_alt'
                            
                        case 'highest_alt'
                            
                        case 'rand_uniform'
                            
                        case 'rand_normal'
                            
                        case 'nomial'
                            
                    end
                    
                    
                    
                    
                    % 여기는 climb profile
                    
                    
                    switch plan(flight(i).id).climb_profile
                        
                        case 'CCO_flex'
                            ['Assigning Trajectory.....flight #' num2str(i) ' climbing altitude profile: ' plan(flight(i).id).desc_profile]
                            [flight(i), alt_fix] = Climb_Profile_CCO_flex(flight(i), alt_fix, acc_fix, DepFE, Cr_alt);
                            
                        case 'CCO_strict'
                            
                        case 'lowest_alt'
                            
                        case 'highest_alt'
                            
                        case 'rand_uniform'
                            
                        case 'rand_normal'
                            
                        case 'nomial'
                            
                    end
                    
                    
                    % route에서는 alt_fix 외 Cr_alt 유지
                    ['Assigning Trajectory.....flight #' num2str(i) ' route altitude profile: default']
                    
                    route_fix = find(strcmp('route', {flight(i).trajectory.type}));
                    if min(route_fix) > 1
                        if isempty(flight(i).trajectory(min(route_fix) - 1).alt)
                            route_fix = sort([route_fix (min(route_fix) - 1)]);
                        end
                    end
                    for RouteSeq = 1:length(route_fix)
                        if isempty(flight(i).trajectory(route_fix(RouteSeq)).alt)
                            flight(i).trajectory(route_fix(RouteSeq)).alt = Cr_alt;
                        end
                    end
                    
                    
                    % initial FS assignment -> 고도를 기준으로
                    % Option: initial
                    
                    flight(i) = AssignFlightStatus(flight(i), DepFE, ArrFE ,'AltOnly');
                    
                    
                    AltAssign = false;
                end
                
                
                % check procedure
                
                for ac = 1:length(flight)
                    for line = 1:length(flight(ac).trajectory)
                        if isempty(flight(ac).trajectory(line).alt)
                            if and(line > 1, line < length(flight(ac).trajectory))
                                flight(ac).trajectory(line).alt = ((flight(ac).trajectory(line - 1).distance * flight(ac).trajectory(line - 1).alt) + (flight(ac).trajectory(line).distance * flight(ac).trajectory(line + 1).alt) ) / (flight(ac).trajectory(line - 1).distance + flight(ac).trajectory(line).distance);
                            elseif line == 1
                                flight(ac).trajectory(line).alt = flight(ac).trajectory(line + 1).alt;
                            elseif line == length(flight(ac).trajectory)
                                flight(ac).trajectory(line).alt = flight(ac).trajectory(line - 1).alt;
                            end
                        end
                        if isempty(flight(ac).trajectory(line).FS)
                            if line > 1
                                flight(ac).trajectory(line).FS =  flight(ac).trajectory(line - 1).FS;
                            elseif line == 1
                                flight(ac).trajectory(line).FS =  flight(ac).trajectory(line + 1).FS;
                            end
                        end
                        
                    end
                end
                
                
                
                
                while SpdAssign
                    
                    flight(i) = AssignFlightStatus(flight(i), DepFE, ArrFE ,'AltOnly');
                    
                    
                    for l = 1:length(flight(i).trajectory) - 1
                        if and(~isempty(flight(i).trajectory(l).lowspd), ~isempty(flight(i).trajectory(l).highspd))
                            if ~isempty(flight(i).trajectory(l).Vcas)
                                if ~isempty(flight(i).trajectory(l).Vmach)
                                    if flight(i).trajectory(l).alt <= Perf.(flight(i).type).Machtrans_cruise
                                        flight(i).trajectory(l).Vcas = max(flight(i).trajectory(l).lowspd, flight(i).trajectory(l).Vcas);
                                        flight(i).trajectory(l).Vmach = '';
                                        spd_fix = [spd_fix l];
                                    else
                                        flight(i).trajectory(l).Vcas = max(flight(i).trajectory(l).lowspd, tas2cas(mach2tas(flight(i).trajectory(l).Vmach, flight(i).trajectory(l).alt), flight(i).trajectory(l).alt));
                                        flight(i).trajectory(l).Vcas = '';
                                        spd_fix = [spd_fix l];
                                    end
                                else
                                    flight(i).trajectory(l).Vcas = max(flight(i).trajectory(l).lowspd, flight(i).trajectory(l).Vcas);
                                    spd_fix = [spd_fix l];
                                end
                            elseif ~isempty(flight(i).trajectory(l).Vmach)
                                if ~isempty(flight(i).trajectory(l).Vcas)
                                    if flight(i).trajectory(l).alt <= Perf.(flight(i).type).Machtrans_cruise
                                        flight(i).trajectory(l).Vcas = max(flight(i).trajectory(l).lowspd, flight(i).trajectory(l).Vcas);
                                        flight(i).trajectory(l).Vmach = '';
                                        spd_fix = [spd_fix l];
                                    else
                                        flight(i).trajectory(l).Vcas = max(flight(i).trajectory(l).lowspd, tas2cas(mach2tas(flight(i).trajectory(l).Vmach, flight(i).trajectory(l).alt), flight(i).trajectory(l).alt));
                                        flight(i).trajectory(l).Vcas = '';
                                        spd_fix = [spd_fix l];
                                    end
                                else
                                    flight(i).trajectory(l).Vcas = max(flight(i).trajectory(l).lowspd, tas2cas(mach2tas(flight(i).trajectory(l).Vmach, flight(i).trajectory(l).alt), flight(i).trajectory(l).alt));
                                    spd_fix = [spd_fix l];
                                end
                            elseif flight(i).trajectory(l).highspd - flight(i).trajectory(l).lowspd < 10;
                                flight(i).trajectory(l).Vcas = flight(i).trajectory(l).lowspd;
                                spd_fix = [spd_fix l];
                            end
                        end
                    end
                    
                    spd_fix = sort(unique(spd_fix));
                    
                    
                    % initial speed assignment -> 지점별 속도를 어떻게 assign 할 것인가
                    % OPTION: 일단 linear, max_accel..
                    % profile 적용할 것
                    switch plan(flight(i).id).speed_control
                        case 'linear'
                            ['Assigning Trajectory.....flight #' num2str(i) ' speed profile: ' plan(flight(i).id).speed_control]
                            [flight(i), spd_fix] = Speed_Profile_BADA_Linear(flight(i), spd_fix, DepFE, ArrFE, acc_fix);
                    end
                    
                    
                    
                    % initial acceleration assignment -> 지점별 배정된 속도로 어떤 형식으로 가속할 것인가
                    % OPTION: 일단 linear
                    % profile 적용할 것
                    
                    % 추후 TBO 모듈 개발시 여기에 프로파일이 다양해질것, acc_fix를 사용하자
                    
                    switch plan(flight(i).id).accel_control
                        case 'linear'
                            ['Assigning Trajectory.....flight #' num2str(i) ' acceleration profile: ' plan(flight(i).id).accel_control]
                            flight(i) = Accl_Profile_Linear(flight(i));
                    end
                    
                    % speed까지 입혀서 다시 FS 배정
                    flight(i) = AssignFlightStatus(flight(i), DepFE, ArrFE ,'AltSpd');
                    
                    
                    SpdAssign = false;
                end
                
                % Acceleration Limit Test
                [flight(i), AssignProgress, AltAssign, SpdAssign, acc_fix] = CheckAcceleration(flight(i), acc_fix);
                
                Assignloop = Assignloop + 1;
            else
                
                AssignProgress = false;
                ['Flight #' num2str(i) ' Trajectory Assignment in progress over limit! Breaking (' num2str(Assignloop) ')']
                
                
            end
            if ~AssignProgress
                ThrustProgress = true;
                % Acceleration Limit Test 통과하면 Thrust 계산 -> Fuel Consumption ->Mass
                
                while ThrustProgress
                    init_mass = flight(i).mass;
                    for TrajLen = 1:length(flight(i).trajectory)
                        flight(i).trajectory(TrajLen).mass = init_mass;
                    end
                    
                    flight(i) = CalculateThrust(flight(i));
                    % Maximum Thrust만족 -> ThrustProgress = false
                    
                    
                    [flight(i), ThrustProgress, AssignProgress, AltAssign, SpdAssign, acc_fix] = CheckThrust(flight(i), alt_fix, spd_fix, acc_fix);
   

                    % Acceleration에 correction 필요
                    %                     flight(i) = Accel_Correction(flight(i), spd_fix, alt_fix);
                    
                    if AssignProgress
                        if AltAssign
                            % CCO, CDO 삭제 -> 이 경우에는 Cr_alt의 문제일 경우도 많다. 아래 mass를
                            % 서서히 증가시키는 방법처럼 Cr_alt를 서서히 변화시켜보자.
                            for DeleteFix = 1:length(flight(i).FalseFix)
                                %                                 flight(i).trajectory(flight(i).FalseFix(DeleteFix)) = [];
                                for TrajDown = find([flight(i).trajectory.TRAJ_num] == flight(i).FalseFix(DeleteFix) + 1, 1):length(flight(i).trajectory)
                                    flight(i).trajectory(TrajDown - 1) = flight(i).trajectory(TrajDown);
                                    flight(i).trajectory(TrajDown - 1).TRAJ_num = TrajDown - 1;
                                end
                                flight(i).trajectory(end) = [];
                            end
                            flight(i).FalseFix = [];
                        end         
                        flight(i).old_trajectory = struct;
                        names = fieldnames(flight(i).trajectory);
                        for CCTraj = 1:length(flight(i).trajectory)
                            for CopyTraj = 1:length(names)
                                ctn = names{CopyTraj};
                                flight(i).old_trajectory(CCTraj).(ctn) = flight(i).trajectory(CCTraj).(ctn);
                            end
                        end
                        flight(i) = InitializeTrajectory(flight(i), alt_fix, spd_fix, acc_fix, AltAssign, SpdAssign);
                    end
                    
                    
                    
                    % 이후 Mass Correction 들어가자 -> 다시 Alt, Spd, Thrust Correction
                    if ~ThrustProgress
                        flight(i) = FuelConsumption(flight(i));
                        flight(i) = MassCorrection(flight(i));
                    end
                    
                    % FE Filter (주로 Thrust)가 여기 들어가고 문제 없으면 AssignComplete를 return 하자.
                    % 문제 있으면 해당 constraint를 잡고 alt_fix, spd_fix 제외 Assign 날리고 FalseFix를 삭제
                    % 다시 profile을 통과시키자.

                    
                end
                


                
            else
                ValidateProgress = true;
                
                
                

                
                
                if AltAssign
                    % CCO, CDO 삭제 -> 이 경우에는 Cr_alt의 문제일 경우도 많다. 아래 mass를
                    % 서서히 증가시키는 방법처럼 Cr_alt를 서서히 변화시켜보자.
                    for DeleteFix = 1:length(flight(i).FalseFix)
                        % flight(i).trajectory(flight(i).FalseFix(DeleteFix)) = [];
                        for TrajDown = find([flight(i).trajectory.TRAJ_num] == flight(i).FalseFix(DeleteFix) + 1, 1):length(flight(i).trajectory)
                            flight(i).trajectory(TrajDown - 1) = flight(i).trajectory(TrajDown);
                            flight(i).trajectory(TrajDown - 1).TRAJ_num = TrajDown - 1;
                        end
                        flight(i).trajectory(end) = [];
                    end
                    flight(i).FalseFix = [];
                end
                
                
                flight(i).old_trajectory = struct;
                names = fieldnames(flight(i).trajectory);
                for CCTraj = 1:length(flight(i).trajectory)
                    for CopyTraj = 1:length(names)
                        ctn = names{CopyTraj};
                        flight(i).old_trajectory(CCTraj).(ctn) = flight(i).trajectory(CCTraj).(ctn);
                    end
                end
                
                
                flight(i) = InitializeTrajectory(flight(i), alt_fix, spd_fix, acc_fix, AltAssign, SpdAssign);
                
                
                
                
            end
            
        end
        
        
        
        % Mass Correction이 들어갔기 때문에 새로 min mass등으로 인해 endurance가 발생 ->
        % 다시 총체적인 validation을 들어가고 mass로 인한 envelope에 걸리면
        % (1) Profile을 변경 -> 더 연료가 덜 드는 걸로
        % (2) Plan을 변경 -> (2.1) 초기 Mass를 증가 or (2.2) Route 변경
        
        if Validateloop <= 100
            ['Flight #' num2str(i) ' Trajectory Validation in progress for ' num2str(Validateloop) ' times.']
            
            [flight(i), ValidateProgress] = TrajectoryValidation(flight(i));
            
            % flatworld heading, distance correction
            for TrajLen = 1:length(flight(i).trajectory) - 1
                %             [dist,azim] = distance('rh', flight(i).trajectory(TrajLen).lat, flight(i).trajectory(TrajLen).long, flight(i).trajectory(TrajLen + 1).lat, flight(i).trajectory(TrajLen + 1).long);
                %             flight(i).trajectory(TrajLen).distance = deg2nm(dist);
                %             flight(i).trajectory(TrajLen).heading = azim;
                FlatHead = rad2deg(atan2(flight(i).trajectory(TrajLen + 1).long - flight(i).trajectory(TrajLen).long, flight(i).trajectory(TrajLen + 1).lat - flight(i).trajectory(TrajLen).lat));
                if FlatHead < 0
                    FlatHead = FlatHead + 360;
                end
                %             FlatDist = sqrt((flight(i).trajectory(TrajLen + 1).long - flight(i).trajectory(TrajLen).long)^2 + (flight(i).trajectory(TrajLen + 1).lat - flight(i).trajectory(TrajLen).lat)^2);
                
                %             flight(i).trajectory(TrajLen).distance = FlatDist;
                flight(i).trajectory(TrajLen).heading = FlatHead;
            end
            
            
            if ValidateProgress
                %         AssignComplete = true;
                
                % 이건 Assignment는 통과했으나... Validate에 실패 (mass 문제)
                % mass를 Perf에서 mass_max가 될때까지 조금씩 올려보자 (즉, 연료를 더 실어보자)
                % 그래도 안되면 plan (profile, origin, dest, route) 문제
                
                
                InitializeTrajectory;
                AssignProgress = true;
                
                
            end
            
            
            Validateloop = Validateloop + 1;
        else
            ['Flight #' num2str(i) ' Trajectory Validation in progress over limit! Breaking (' num2str(Validateloop) ')']
            
            ValidateProgress = false;
        end
        
    end
   
    catch
        flight(i).id = [];
        plan(i).id = [];
    end
end
end
