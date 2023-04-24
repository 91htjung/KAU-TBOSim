%% Assign Trajectory
function flight=AssignTrajectory_rev(flight, Aerodrome, Airspace, Procedure)
global unit Perf plan config atmos

% for i = 1:length(flight)
%     try
    DepFE = 0;
    ArrFE = 0;
    Cr_alt = 0;
    flight.FalseFix = [];
    flight.old_FalseFix = struct;
    flight.old_trajectory = struct;



    % �ϴ� hard �ڵ����� direct�� ������, ���߿��� current_position�� ������ �����ϴ� �������� ������
    % ������ �ľ��ؼ� direct�� ���� �����ϵ��� �� ��
    if strcmp(flight.FS, 'TX') == 0
        % ground�� �ƴ� ��Ȳ�̸� ���� fix ���� direct�� ����
        TRAJ_num=1;
        flight.trajectory=struct;
        flight.trajectory(TRAJ_num).TRAJ_num = 1;
        flight.trajectory(TRAJ_num).type = 'direct';
        flight.trajectory(TRAJ_num).traj_name = 'direct';
        flight.trajectory(TRAJ_num).wp_name = 'trajectory_assigned';
        flight.trajectory(TRAJ_num).lat = flight.lat;
        flight.trajectory(TRAJ_num).long = flight.long;
        flight.trajectory(TRAJ_num).alt = flight.alt;
        flight.trajectory(TRAJ_num).Vcas = tas2cas(flight.Vtas, flight.alt);
        flight.trajectory(TRAJ_num).Vmach = '';
        flight.trajectory(TRAJ_num).Vtas = flight.Vtas;
        flight.trajectory(TRAJ_num).flyover = false;
        flight.trajectory(TRAJ_num).lowalt = flight.alt;
        flight.trajectory(TRAJ_num).highalt = flight.alt;
        flight.trajectory(TRAJ_num).lowspd = flight.Vtas;
        flight.trajectory(TRAJ_num).highspd = flight.Vtas;
        flight.trajectory(TRAJ_num).mass = flight.mass;
        
    
    else
        % ground ���, TO ���� ��Ȳ����, RWY_THR �̵� -> airbourne ������ ����
        if strcmp(flight.command.type{1}, 'SID') == 1

            DepFE = Aerodrome(strcmp(plan(flight.id).departure, {Aerodrome.ID})).RWY(strcmp(plan(flight.id).departure_RWY, {Aerodrome(strcmp(plan(flight.id).departure, {Aerodrome.ID})).RWY.name})).elevation;
            
            TRAJ_num = 1;
            flight.trajectory=struct;
            
            if TRAJ_num == 1
                % ù��° fix�� �ι�° fix�� �ݰ� 0.3NM �̳���� ���� �Ƚ��� �������
                FirstTrajDiff = distance(flight.lat, flight.long, Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight.id).departure, '_', plan(flight.id).departure_RWY, '_THR'))==1).Lat, Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight.id).departure, '_', plan(flight.id).departure_RWY, '_THR'))==1).Long);
                if deg2nm(FirstTrajDiff) > 0.3
                    flight.trajectory(TRAJ_num).TRAJ_num = 1;
                    flight.trajectory(TRAJ_num).type = 'ground';
                    flight.trajectory(TRAJ_num).traj_name = 'line-up';
                    flight.trajectory(TRAJ_num).wp_name = 'trajectory_assigned';
                    flight.trajectory(TRAJ_num).lat = flight.lat;
                    flight.trajectory(TRAJ_num).long = flight.long;
                    flight.trajectory(TRAJ_num).alt = DepFE;
                    flight.trajectory(TRAJ_num).Vcas = 35;
                    flight.trajectory(TRAJ_num).Vmach = '';
                    flight.trajectory(TRAJ_num).Vtas = 35;
                    flight.trajectory(TRAJ_num).flyover = false;
                    flight.trajectory(TRAJ_num).lowalt = flight.trajectory(TRAJ_num).alt;
                    flight.trajectory(TRAJ_num).highalt = flight.trajectory(TRAJ_num).alt;
                    flight.trajectory(TRAJ_num).lowspd = 0;
                    flight.trajectory(TRAJ_num).highspd = 35;
                    flight.trajectory(TRAJ_num).mass = flight.mass;
                    TRAJ_num = TRAJ_num + 1;
                end
            end
            
            flight.trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
            flight.trajectory(TRAJ_num).id = Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight.id).departure, '_', plan(flight.id).departure_RWY, '_THR'))==1).id;
            flight.trajectory(TRAJ_num).type = 'ground';
            flight.trajectory(TRAJ_num).traj_name = 'rolling';
            % ������ lineup ��ġ�ε�, �ϴ� THR�� ��� ���߿� ��������
            flight.trajectory(TRAJ_num).wp_name = strcat(plan(flight.id).departure, '_', plan(flight.id).departure_RWY, '_THR');
            flight.trajectory(TRAJ_num).lat = Airspace.Waypoint([Airspace.Waypoint.id] == flight.trajectory(TRAJ_num).id).Lat;
            flight.trajectory(TRAJ_num).long = Airspace.Waypoint([Airspace.Waypoint.id] == flight.trajectory(TRAJ_num).id).Long;
            flight.trajectory(TRAJ_num).alt = DepFE;
            flight.trajectory(TRAJ_num).Vcas = 35;
            flight.trajectory(TRAJ_num).Vmach = '';
            flight.trajectory(TRAJ_num).Vtas = 35;
            flight.trajectory(TRAJ_num).flyover = false;
            flight.trajectory(TRAJ_num).lowalt = flight.trajectory(TRAJ_num).alt;
            flight.trajectory(TRAJ_num).highalt = flight.trajectory(TRAJ_num).alt;
            flight.trajectory(TRAJ_num).lowspd = 0;
            flight.trajectory(TRAJ_num).highspd = 35;
            
            %Airbourne ����, �ϴ� rwy 3/5���� �����.
            TRAJ_num = TRAJ_num + 1;
            flight.trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
            flight.trajectory(TRAJ_num).type = 'SID';
            flight.trajectory(TRAJ_num).traj_name = Procedure(flight.command.trajectory{1}).name;
            flight.trajectory(TRAJ_num).wp_name = strcat(plan(flight.id).departure, '_', plan(flight.id).departure_RWY, '_Airbourne');
            flight.trajectory(TRAJ_num).lat = (Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight.id).departure, '_', plan(flight.id).departure_RWY, '_THR'))==1).Lat * 2 + Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight.id).departure, '_', plan(flight.id).departure_RWY, '_END'))==1).Lat * 3) / 5;
            flight.trajectory(TRAJ_num).long = (Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight.id).departure, '_', plan(flight.id).departure_RWY, '_THR'))==1).Long * 2 + Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight.id).departure, '_', plan(flight.id).departure_RWY, '_END'))==1).Long * 3) / 5;
            flight.trajectory(TRAJ_num).alt = DepFE;
            if strcmp(Perf.(flight.type).Engtype,'Jet')==1
                flight.trajectory(TRAJ_num).Vcas = 1.2*sqrt(flight.mass/Perf.(flight.type).Mass_ref)*Perf.(flight.type).Vstall_TO + 15;
                flight.trajectory(TRAJ_num).Vtas = cas2tas(1.2*sqrt(flight.mass/Perf.(flight.type).Mass_ref)*Perf.(flight.type).Vstall_TO+5,flight.trajectory(TRAJ_num).alt);
            else
                flight.trajectory(TRAJ_num).Vcas = 1.2*sqrt(flight.mass/Perf.(flight.type).Mass_ref)*Perf.(flight.type).Vstall_TO + 30;
                flight.trajectory(TRAJ_num).Vtas = cas2tas(1.2*sqrt(flight.mass/Perf.(flight.type).Mass_ref)*Perf.(flight.type).Vstall_TO+20,flight.trajectory(TRAJ_num).alt);
            end
            flight.trajectory(TRAJ_num).Vmach = '';
            flight.trajectory(TRAJ_num).flyover = false;
            flight.trajectory(TRAJ_num).lowalt = flight.trajectory(TRAJ_num).alt;
            flight.trajectory(TRAJ_num).highalt = flight.trajectory(TRAJ_num).alt;
            flight.trajectory(TRAJ_num).lowspd = 1.2*sqrt(flight.mass/Perf.(flight.type).Mass_ref)*Perf.(flight.type).Vstall_TO;
            flight.trajectory(TRAJ_num).highspd = 9999;
            
        else
            % ground movement
            ['warning! flight #' num2str(flight.id) ' has trajectory other than SID']
        end
    end
    
    for j = 1:length(flight.command.status)
        
        switch flight.command.status{j}
            case {'procedure' 'route'}
                origin = Procedure(flight.command.trajectory{j}).trajectory([Procedure(flight.command.trajectory{j}).trajectory.WP_id] == flight.command.origination{j}).WP_num;
                dest = Procedure(flight.command.trajectory{j}).trajectory([Procedure(flight.command.trajectory{j}).trajectory.WP_id] == flight.command.destination{j}).WP_num;
                TRAJ_num=length(flight.trajectory);
                
                if (j > 1) + (TRAJ_num > 1) == 2
                    if flight.command.destination{j-1} == flight.command.origination{j}
                        IMP_TRAJ_num = 0;
                    else
                        ['warning! flight #' num2str(flight.id) ' has different origin(' Procedure(flight.command.trajectory{j}).trajectory(origin).WP_name ') & destiation (' Procedure(flight.command.trajectory{j-1}).trajectory(dest).WP_name ') in connecting trajectory waypoint # ' num2str(TRAJ_num)]
                        IMP_TRAJ_num = 1;
                    end
                else
                    IMP_TRAJ_num = 1;
                end
                
                if strcmp(flight.command.status{j}, 'route')
                    if origin <= dest
                        kstep = 1;
                    else
                        kstep = -1;
                    end
                else
                    kstep = 1;
                end


                for k = origin:kstep:dest
                    if IMP_TRAJ_num == 0
                        if flight.trajectory(TRAJ_num).TRAJ_num ~= TRAJ_num
                            ['error! flight #' num2str(flight.id) ' has error in TRAJ_num (' num2str(TRAJ_num) ') trajectory waypoint # ' num2str(TRAJ_num)]
                        end
                        if flight.trajectory(TRAJ_num).id ~= Procedure(flight.command.trajectory{j}).trajectory(k).WP_id;
                            ['error! flight #' num2str(flight.id) ' has error in WP_id (' flight.trajectory(TRAJ_num).id ') trajectory waypoint # ' num2str(TRAJ_num)]
                        end
                        if strcmp(flight.trajectory(TRAJ_num).wp_name, Procedure(flight.command.trajectory{j}).trajectory(k).WP_name) == 0;
                            ['error! flight #' num2str(flight.id) ' has error in WP_name (' flight.trajectory(TRAJ_num).wp_name ') trajectory waypoint # ' num2str(TRAJ_num)]
                        end
                        if flight.trajectory(TRAJ_num).lat ~= Procedure(flight.command.trajectory{j}).trajectory(k).WP_lat;
                            ['error! flight #' num2str(flight.id) ' has error in WP_lat (' num2str(flight.trajectory(TRAJ_num).lat) ') trajectory waypoint # ' num2str(TRAJ_num)]
                        end
                        if flight.trajectory(TRAJ_num).long ~= Procedure(flight.command.trajectory{j}).trajectory(k).WP_long;
                            ['error! flight #' num2str(flight.id) ' has error in WP_long (' num2str(flight.trajectory(TRAJ_num).long) ') trajectory waypoint # ' num2str(TRAJ_num)]
                        end
                        
                        flight.trajectory(TRAJ_num).lowalt = max(flight.trajectory(TRAJ_num).lowalt, Procedure(flight.command.trajectory{j}).trajectory(k).lowalt);
                        flight.trajectory(TRAJ_num).highalt = min(flight.trajectory(TRAJ_num).highalt, Procedure(flight.command.trajectory{j}).trajectory(k).highalt);
                        
                        if strcmp(flight.command.status{j}, 'procedure') == 1
                            flight.trajectory(TRAJ_num).lowspd = max(flight.trajectory(TRAJ_num).lowspd, Procedure(flight.command.trajectory{j}).trajectory(k).lowspd);
                            flight.trajectory(TRAJ_num).highspd = min(flight.trajectory(TRAJ_num).highspd, Procedure(flight.command.trajectory{j}).trajectory(k).highspd);
                        end
                        
                        
                    else
                        
                        if TRAJ_num == 1
                            % ù��° fix�� �ι�° fix�� �ݰ� 0.3NM �̳���� ���� �Ƚ��� �������
                            FirstTrajDiff = distance(flight.trajectory(1).lat, flight.trajectory(1).long, Procedure(flight.command.trajectory{j}).trajectory(k).WP_lat, Procedure(flight.command.trajectory{j}).trajectory(k).WP_long);
                            if deg2nm(FirstTrajDiff) <= 0.3
                                flight.trajectory(TRAJ_num).id = Procedure(flight.command.trajectory{j}).trajectory(k).WP_id;
                                flight.trajectory(TRAJ_num).type = flight.command.type{j};
                                flight.trajectory(TRAJ_num).traj_name = Procedure(flight.command.trajectory{j}).name;
                                flight.trajectory(TRAJ_num).wp_name = Procedure(flight.command.trajectory{j}).trajectory(k).WP_name;
                                flight.trajectory(TRAJ_num).lat = Procedure(flight.command.trajectory{j}).trajectory(k).WP_lat;
                                flight.trajectory(TRAJ_num).long = Procedure(flight.command.trajectory{j}).trajectory(k).WP_long;
                                flight.trajectory(TRAJ_num).lowalt = Procedure(flight.command.trajectory{j}).trajectory(k).lowalt;
                                flight.trajectory(TRAJ_num).highalt = Procedure(flight.command.trajectory{j}).trajectory(k).highalt;
                                
                                if strcmp(flight.command.status{j}, 'procedure') == 1
                                    flight.trajectory(TRAJ_num).flyover = Procedure(flight.command.trajectory{j}).trajectory(k).flyover;
                                    flight.trajectory(TRAJ_num).lowspd = Procedure(flight.command.trajectory{j}).trajectory(k).lowspd;
                                    flight.trajectory(TRAJ_num).highspd = Procedure(flight.command.trajectory{j}).trajectory(k).highspd;
                                    
                                elseif strcmp(flight.command.status{j}, 'route') == 1
                                    flight.trajectory(TRAJ_num).flyover = false;
                                    flight.trajectory(TRAJ_num).lowspd = 0;
                                    flight.trajectory(TRAJ_num).highspd = 9999;
                                end
                            else
                                TRAJ_num = TRAJ_num + 1;
                                flight.trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                                flight.trajectory(TRAJ_num).id = Procedure(flight.command.trajectory{j}).trajectory(k).WP_id;
                                flight.trajectory(TRAJ_num).type = flight.command.type{j};
                                flight.trajectory(TRAJ_num).traj_name = Procedure(flight.command.trajectory{j}).name;
                                flight.trajectory(TRAJ_num).wp_name = Procedure(flight.command.trajectory{j}).trajectory(k).WP_name;
                                flight.trajectory(TRAJ_num).lat = Procedure(flight.command.trajectory{j}).trajectory(k).WP_lat;
                                flight.trajectory(TRAJ_num).long = Procedure(flight.command.trajectory{j}).trajectory(k).WP_long;
                                flight.trajectory(TRAJ_num).lowalt = Procedure(flight.command.trajectory{j}).trajectory(k).lowalt;
                                flight.trajectory(TRAJ_num).highalt = Procedure(flight.command.trajectory{j}).trajectory(k).highalt;
                                
                                if strcmp(flight.command.status{j}, 'procedure') == 1
                                    flight.trajectory(TRAJ_num).flyover = Procedure(flight.command.trajectory{j}).trajectory(k).flyover;
                                    flight.trajectory(TRAJ_num).lowspd = Procedure(flight.command.trajectory{j}).trajectory(k).lowspd;
                                    flight.trajectory(TRAJ_num).highspd = Procedure(flight.command.trajectory{j}).trajectory(k).highspd;
                                    
                                elseif strcmp(flight.command.status{j}, 'route') == 1
                                    flight.trajectory(TRAJ_num).flyover = false;
                                    flight.trajectory(TRAJ_num).lowspd = 0;
                                    flight.trajectory(TRAJ_num).highspd = 9999;
                                end
                                
                            end
                        else
                            TRAJ_num = TRAJ_num + 1;
                            flight.trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                            flight.trajectory(TRAJ_num).id = Procedure(flight.command.trajectory{j}).trajectory(k).WP_id;
                            flight.trajectory(TRAJ_num).type = flight.command.type{j};
                            flight.trajectory(TRAJ_num).traj_name = Procedure(flight.command.trajectory{j}).name;
                            flight.trajectory(TRAJ_num).wp_name = Procedure(flight.command.trajectory{j}).trajectory(k).WP_name;
                            flight.trajectory(TRAJ_num).lat = Procedure(flight.command.trajectory{j}).trajectory(k).WP_lat;
                            flight.trajectory(TRAJ_num).long = Procedure(flight.command.trajectory{j}).trajectory(k).WP_long;
                            flight.trajectory(TRAJ_num).lowalt = Procedure(flight.command.trajectory{j}).trajectory(k).lowalt;
                            flight.trajectory(TRAJ_num).highalt = Procedure(flight.command.trajectory{j}).trajectory(k).highalt;
                            
                            if strcmp(flight.command.status{j}, 'procedure') == 1
                                flight.trajectory(TRAJ_num).flyover = Procedure(flight.command.trajectory{j}).trajectory(k).flyover;
                                flight.trajectory(TRAJ_num).lowspd = Procedure(flight.command.trajectory{j}).trajectory(k).lowspd;
                                flight.trajectory(TRAJ_num).highspd = Procedure(flight.command.trajectory{j}).trajectory(k).highspd;
                                
                            elseif strcmp(flight.command.status{j}, 'route') == 1
                                flight.trajectory(TRAJ_num).flyover = false;
                                flight.trajectory(TRAJ_num).lowspd = 0;
                                flight.trajectory(TRAJ_num).highspd = 9999;
                            end
                        end
                        
                    end
                    
                    IMP_TRAJ_num = IMP_TRAJ_num + 1;
                    
                    if k == dest
                        switch flight.command.type{j}
                            case 'INST'
                                % INST ���������� RWY�� trajectory�� �־�����

                                if strcmp(flight.trajectory(TRAJ_num).wp_name, strcat(plan(flight.id).arrival, '_', plan(flight.id).arrival_RWY, '_THR')) == 1
                                    ArrFE = Aerodrome(strcmp(plan(flight.id).arrival, {Aerodrome.ID})).RWY(strcmp(plan(flight.id).arrival_RWY, {Aerodrome(strcmp(plan(flight.id).arrival, {Aerodrome.ID})).RWY.name})).elevation;

                                    if Procedure(flight.command.trajectory{j}).trajectory(k).RDH == 0
                                        Procedure(flight.command.trajectory{j}).trajectory(k).RDH = '-3.0';
                                    end
                                        % RWY End ������ �����Ѵ� -> ���� TDZ�� RDH�� ������.
                                        
                                        %Touchdown ����, RDH�� reckon�Լ��� ������
                                        TRAJ_num = TRAJ_num + 1;
                                        flight.trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                                        flight.trajectory(TRAJ_num).type = 'INST';
                                        flight.trajectory(TRAJ_num).traj_name = Procedure(flight.command.trajectory{j}).name;
                                        flight.trajectory(TRAJ_num).wp_name = strcat(plan(flight.id).arrival, '_', plan(flight.id).arrival_RWY, '_TouchDown');
                                        
                                        % Low Alt�� �������� ����.
                                        DescRate_RDH = tan(deg2rad(str2double(Procedure(flight.command.trajectory{j}).trajectory(k).RDH))) * unit.nm2meter / unit.ft2meter;
                                        THR2TDZ = -1 * (flight.trajectory(TRAJ_num - 1).lowalt / DescRate_RDH);
                                        bearing = azimuth(flight.trajectory(TRAJ_num - 2).lat, flight.trajectory(TRAJ_num - 2).long, flight.trajectory(TRAJ_num - 1).lat, flight.trajectory(TRAJ_num - 1).long);
                                        
                                        [flight.trajectory(TRAJ_num).lat, flight.trajectory(TRAJ_num).long] = reckon(flight.trajectory(TRAJ_num - 1).lat, flight.trajectory(TRAJ_num - 1).long, nm2deg(THR2TDZ), bearing);
                                        flight.trajectory(TRAJ_num).alt = ArrFE;
                                        flight.trajectory(TRAJ_num).Vcas = 1.3*sqrt(flight.mass/Perf.(flight.type).Mass_ref)*Perf.(flight.type).Vstall_LD + 5;
                                        flight.trajectory(TRAJ_num).Vtas = cas2tas(1.3*sqrt(flight.mass/Perf.(flight.type).Mass_ref)*Perf.(flight.type).Vstall_LD + 5,flight.trajectory(TRAJ_num).alt);
                                        flight.trajectory(TRAJ_num).flyover = false;
                                        
                                        flight.trajectory(TRAJ_num).lowalt = flight.trajectory(TRAJ_num).alt;
                                        flight.trajectory(TRAJ_num).highalt = flight.trajectory(TRAJ_num).alt;
                                        flight.trajectory(TRAJ_num).lowspd = flight.trajectory(TRAJ_num).Vtas;
                                        flight.trajectory(TRAJ_num).highspd = 9999;
                                        
                                        
                                        %Taxi Segment -> brake�� ��
                                        %0.5NM(3000ft)�� ����
                                        TRAJ_num = TRAJ_num + 1;
                                        flight.trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                                        flight.trajectory(TRAJ_num).type = 'ground';
                                        flight.trajectory(TRAJ_num).traj_name = 'brake';
                                        flight.trajectory(TRAJ_num).wp_name = strcat(plan(flight.id).arrival, '_', plan(flight.id).arrival_RWY, '_Brake');
                                        
                                        [flight.trajectory(TRAJ_num).lat, flight.trajectory(TRAJ_num).long] = reckon(flight.trajectory(TRAJ_num - 1).lat, flight.trajectory(TRAJ_num - 1).long, nm2deg(0.5), bearing);
                                        flight.trajectory(TRAJ_num).alt = ArrFE;
                                        flight.trajectory(TRAJ_num).Vcas = '';
                                        flight.trajectory(TRAJ_num).Vtas = '';
                                        flight.trajectory(TRAJ_num).flyover = false;
                                        
                                        flight.trajectory(TRAJ_num).lowalt = flight.trajectory(TRAJ_num).alt;
                                        flight.trajectory(TRAJ_num).highalt = flight.trajectory(TRAJ_num).alt;
                                        flight.trajectory(TRAJ_num).lowspd = 0;
                                        flight.trajectory(TRAJ_num).highspd = 9999;
                                        
                                        

                                    
                                    
                                else
                                    TRAJ_num = TRAJ_num + 1;
                                    flight.trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                                    flight.trajectory(TRAJ_num).id = Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight.id).arrival, '_', plan(flight.id).arrival_RWY, '_THR'))==1).id;
                                    flight.trajectory(TRAJ_num).type = 'INST';
                                    flight.trajectory(TRAJ_num).traj_name = Procedure(flight.command.trajectory{j}).name;
                                    flight.trajectory(TRAJ_num).wp_name = strcat(plan(flight.id).arrival, '_', plan(flight.id).arrival_RWY, '_THR');
                                    flight.trajectory(TRAJ_num).lat = Airspace.Waypoint([Airspace.Waypoint.id] == flight.trajectory(TRAJ_num).id).Lat;
                                    flight.trajectory(TRAJ_num).long = Airspace.Waypoint([Airspace.Waypoint.id] == flight.trajectory(TRAJ_num).id).Long;
                                    flight.trajectory(TRAJ_num).alt = '';
                                    flight.trajectory(TRAJ_num).Vcas = 1.3 * sqrt(flight.mass/Perf.(flight.type).Mass_ref) * Perf.(flight.type).Vstall_LD + 5;
                                    flight.trajectory(TRAJ_num).Vmach = '';
                                    flight.trajectory(TRAJ_num).Vtas = cas2tas(1.3 * sqrt(flight.mass/Perf.(flight.type).Mass_ref) * Perf.(flight.type).Vstall_LD + 5, 0);
                                    flight.trajectory(TRAJ_num).flyover = false;
                                    flight.trajectory(TRAJ_num).lowalt = 0;
                                    flight.trajectory(TRAJ_num).highalt = 100000;
                                    flight.trajectory(TRAJ_num).lowspd = flight.trajectory(TRAJ_num).Vtas;
                                    flight.trajectory(TRAJ_num).highspd = 9999;
                                    
                                    %Touchdown ����, �ϴ� rwy 1/4 �������� �����.
                                    TRAJ_num = TRAJ_num + 1;
                                    flight.trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                                    flight.trajectory(TRAJ_num).type = 'INST';
                                    flight.trajectory(TRAJ_num).traj_name = Procedure(flight.command.trajectory{j}).name;
                                    flight.trajectory(TRAJ_num).wp_name = strcat(plan(flight.id).arrival, '_', plan(flight.id).arrival_RWY, '_TouchDown');
                                    flight.trajectory(TRAJ_num).lat = (Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight.id).arrival, '_', plan(flight.id).arrival_RWY, '_THR'))==1).Lat * 3 + Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight.id).arrival, '_', plan(flight.id).arrival_RWY, '_END'))==1).Lat) / 4;
                                    flight.trajectory(TRAJ_num).long = (Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight.id).arrival, '_', plan(flight.id).arrival_RWY, '_THR'))==1).Long * 3 + Airspace.Waypoint(strcmp({Airspace.Waypoint.Name}, strcat(plan(flight.id).arrival, '_', plan(flight.id).arrival_RWY, '_END'))==1).Long) / 4;
                                    flight.trajectory(TRAJ_num).alt = ArrFE;
                                    flight.trajectory(TRAJ_num).Vcas = 1.3*sqrt(flight.mass/Perf.(flight.type).Mass_ref)*Perf.(flight.type).Vstall_LD + 5;
                                    flight.trajectory(TRAJ_num).Vmach = '';
                                    flight.trajectory(TRAJ_num).Vtas = cas2tas(1.3*sqrt(flight.mass/Perf.(flight.type).Mass_ref)*Perf.(flight.type).Vstall_LD + 5,flight.trajectory(TRAJ_num).alt);
                                    flight.trajectory(TRAJ_num).flyover = false;
                                    
                                    flight.trajectory(TRAJ_num).lowalt = flight.trajectory(TRAJ_num).alt;
                                    flight.trajectory(TRAJ_num).highalt = flight.trajectory(TRAJ_num).alt;
                                    flight.trajectory(TRAJ_num).lowspd = 1.3*sqrt(flight.mass/Perf.(flight.type).Mass_ref)*Perf.(flight.type).Vstall_LD;
                                    flight.trajectory(TRAJ_num).highspd = 9999;
                                    
                                    
                                    %Taxi Segment -> brake�� ��
                                    %0.5NM(3000ft)�� ����
                                    TRAJ_num = TRAJ_num + 1;
                                    flight.trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                                    flight.trajectory(TRAJ_num).type = 'ground';
                                    flight.trajectory(TRAJ_num).traj_name = 'Brake';
                                    flight.trajectory(TRAJ_num).wp_name = strcat(plan(flight.id).arrival, '_', plan(flight.id).arrival_RWY, '_Brake');
                                    bearing = azimuth(flight.trajectory(TRAJ_num - 2).lat, flight.trajectory(TRAJ_num - 2).long, flight.trajectory(TRAJ_num - 1).lat, flight.trajectory(TRAJ_num - 1).long);
                                    [flight.trajectory(TRAJ_num).lat, flight.trajectory(TRAJ_num).long] = reckon(flight.trajectory(TRAJ_num - 1).lat, flight.trajectory(TRAJ_num - 1).long, nm2deg(0.5), bearing);
                                    
                                    flight.trajectory(TRAJ_num).alt = ArrFE;
                                    flight.trajectory(TRAJ_num).Vcas = '';
                                    flight.trajectory(TRAJ_num).Vmach = '';
                                    flight.trajectory(TRAJ_num).Vtas = '';
                                    flight.trajectory(TRAJ_num).flyover = false;
                                    
                                    flight.trajectory(TRAJ_num).lowalt = flight.trajectory(TRAJ_num).alt;
                                    flight.trajectory(TRAJ_num).highalt = flight.trajectory(TRAJ_num).alt;
                                    flight.trajectory(TRAJ_num).lowspd = 0;
                                    flight.trajectory(TRAJ_num).highspd = 9999;
                                    
                                    
                                end
                                
                                
                        end
                    end
                end
                
            case'direct'
                % �װ��� ���� ����� direct WP���� bearing�� ��, �ʿ��� ��� ��ȸ segment
                % �����ʿ�.
                
                
                TRAJ_num = length(flight.trajectory);
                if strcmp(flight.trajectory(TRAJ_num).wp_name, Airspace.Waypoint([Airspace.Waypoint.id] == flight.command.destination{j}).Name) == 1
                    ['warning! flight #' num2str(flight.id) ' has same direct waypoint(' flight.trajectory(TRAJ_num).name ') in connecting trajectory waypoint # ' num2str(TRAJ_num)]
                else
                    
                    % Direct ��� �ߺν� ��ȸ �ڽ� ����
                
                    wplat = Airspace.Waypoint([Airspace.Waypoint.id] == flight.command.destination{j}).Lat;
                    wplong = Airspace.Waypoint([Airspace.Waypoint.id] == flight.command.destination{j}).Long;
                    curlat = flight.lat;
                    curlong = flight.long;
                    curspd = flight.Vtas;
                    curhdg = flight.hdg;

                    dst = sqrt((wplong - curlong) ^2 + (wplat - curlat)^2) * 60;
                    brg = rad2deg(atan2(wplong - curlong, wplat - curlat));
                    if brg < 0
                        brg = brg + 360;
                    end
%                     [dst, brg] = distance(curlat, curlong, wplat, wplong);
                    
                    hdg_brg = mod(brg - curhdg, 360);
                    if hdg_brg > 180
                        hdg_brg = hdg_brg - 360;
                    end
                    if abs(hdg_brg) < 1
                        hdg_brg = 0;
                    end
%                     hdg_brg = 180 - hdg_brg;
                    
                    ba_direct = 35;
                    
                    turn_rate = rad2deg(tan(deg2rad(ba_direct * config.BankAngleBuffer)) * atmos.g_0 / (curspd * unit.nm2meter / 3600));
%                     turn_rate = rad2deg(tan(deg2rad(ba_direct)) * atmos.g_0 / (curspd * unit.nm2meter / 3600));

                    turn_radius = curspd / (turn_rate * 20 * pi);
                    turn_distance = abs(deg2rad(180 - hdg_brg) * turn_radius);
                    
                    newdist = dst - turn_distance;
                    nlong = wplong + (sin(deg2rad(brg + 180)) * newdist / 60);
                    nlat = wplat + (cos(deg2rad(brg + 180)) * newdist / 60);
                    
                    slong = curlong + (sin(deg2rad(curhdg)) * (turn_distance / 2) / 60);
                    slat = curlat + (cos(deg2rad(curhdg)) * (turn_distance / 2) / 60);
                    
                    TRAJ_num = TRAJ_num + 1;
                    flight.trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                    flight.trajectory(TRAJ_num).id = '';
                    flight.trajectory(TRAJ_num).type = flight.command.type{j};
                    flight.trajectory(TRAJ_num).traj_name = 'Turning WP';
                    flight.trajectory(TRAJ_num).wp_name = '';
                    flight.trajectory(TRAJ_num).lat = slat;
                    flight.trajectory(TRAJ_num).long = slong;
                    flight.trajectory(TRAJ_num).flyover = false;
                    
                    if strcmp(flight.command.altitude{j}, 'default')
                        flight.trajectory(TRAJ_num).alt = flight.trajectory(TRAJ_num - 1).alt;
                    elseif ~isnan(str2double(flight.command.altitude{j}))
                        flight.trajectory(TRAJ_num).alt = str2double(flight.command.altitude{j});
                    else
                        ['cannot read altitude command of flight #' num2str(flight.id) ' Trajectory #' num2str(TRAJ_num) ' check altitude command in ' num2str(j)]
                        flight.trajectory(TRAJ_num).alt = flight.trajectory(TRAJ_num - 1).alt;
                    end
                    flight.trajectory(TRAJ_num).lowalt = 0;
                    flight.trajectory(TRAJ_num).highalt = 100000;
                    flight.trajectory(TRAJ_num).lowspd = 0;
                    flight.trajectory(TRAJ_num).highspd = 9999;
                    
%                     TRAJ_num = TRAJ_num + 1;
%                     flight.trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
%                     flight.trajectory(TRAJ_num).id = '';
%                     flight.trajectory(TRAJ_num).type = flight.command.type{j};
%                     flight.trajectory(TRAJ_num).traj_name = 'OnCourse WP';
%                     flight.trajectory(TRAJ_num).wp_name = '';
%                     flight.trajectory(TRAJ_num).lat = nlat;
%                     flight.trajectory(TRAJ_num).long = nlong;
%                     flight.trajectory(TRAJ_num).flyover = false;
%                     
%                     if strcmp(flight.command.altitude{j}, 'default')
%                         flight.trajectory(TRAJ_num).alt = flight.trajectory(TRAJ_num - 1).alt;
%                     elseif ~isnan(str2double(flight.command.altitude{j}))
%                         flight.trajectory(TRAJ_num).alt = str2double(flight.command.altitude{j});
%                     else
%                         ['cannot read altitude command of flight #' num2str(flight.id) ' Trajectory #' num2str(TRAJ_num) ' check altitude command in ' num2str(j)]
%                         flight.trajectory(TRAJ_num).alt = flight.trajectory(TRAJ_num - 1).alt;
%                     end
%                     flight.trajectory(TRAJ_num).lowalt = 0;
%                     flight.trajectory(TRAJ_num).highalt = 100000;
%                     flight.trajectory(TRAJ_num).lowspd = 0;
%                     flight.trajectory(TRAJ_num).highspd = 9999;
                    
                    
                    TRAJ_num = TRAJ_num + 1;
                    flight.trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                    flight.trajectory(TRAJ_num).id = flight.command.destination{j};
                    flight.trajectory(TRAJ_num).type = flight.command.type{j};
                    flight.trajectory(TRAJ_num).traj_name = 'direct';
                    flight.trajectory(TRAJ_num).wp_name = Airspace.Waypoint([Airspace.Waypoint.id] == flight.command.destination{j}).Name;
                    flight.trajectory(TRAJ_num).lat = Airspace.Waypoint([Airspace.Waypoint.id] == flight.command.destination{j}).Lat;
                    flight.trajectory(TRAJ_num).long = Airspace.Waypoint([Airspace.Waypoint.id] == flight.command.destination{j}).Long;
                    flight.trajectory(TRAJ_num).flyover = true;
                    
                    if strcmp(flight.command.altitude{j}, 'default')
                        
                        flight.trajectory(TRAJ_num).alt = flight.trajectory(TRAJ_num - 1).alt;
                        
                    elseif ~isnan(str2double(flight.command.altitude{j}))
                        flight.trajectory(TRAJ_num).alt = str2double(flight.command.altitude{j});
                    else
                        ['cannot read altitude command of flight #' num2str(flight.id) ' Trajectory #' num2str(TRAJ_num) ' check altitude command in ' num2str(j)]
                        flight.trajectory(TRAJ_num).alt = flight.trajectory(TRAJ_num - 1).alt;
                    end
                    flight.trajectory(TRAJ_num).lowalt = 0;
                    flight.trajectory(TRAJ_num).highalt = 100000;
                    flight.trajectory(TRAJ_num).lowspd = 0;
                    flight.trajectory(TRAJ_num).highspd = 9999;
                end
                
            case 'vectoring'
                TRAJ_num=length(flight.trajectory) + 1;
                
                % 3rd order Bezier Curve Setting
                
                % P0 -> Origination
                flight.trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                flight.trajectory(TRAJ_num).id = flight.command.origination{j};
                flight.trajectory(TRAJ_num).type = flight.command.type{j};
                flight.trajectory(TRAJ_num).traj_name = 'vectoring';
                flight.trajectory(TRAJ_num).wp_name = Airspace.Waypoint([Airspace.Waypoint.id] == flight.command.origination{j}).Name;
                flight.trajectory(TRAJ_num).lat = Airspace.Waypoint([Airspace.Waypoint.id] == flight.command.origination{j}).Lat;
                flight.trajectory(TRAJ_num).long = Airspace.Waypoint([Airspace.Waypoint.id] == flight.command.origination{j}).Long;
                flight.trajectory(TRAJ_num).flyover = false;
                
                if strcmp(flight.command.altitude{j}, 'default')
                    flight.trajectory(TRAJ_num).alt = flight.trajectory(TRAJ_num - 1).alt;
                elseif ~isnan(str2double(flight.command.altitude{j}))
                    flight.trajectory(TRAJ_num).alt = str2double(flight.command.altitude{j});
                else
                    ['cannot read altitude command of flight #' num2str(flight.id) ' Trajectory #' num2str(TRAJ_num) ' check altitude command in ' num2str(j)]
                    flight.trajectory(TRAJ_num).alt = flight.trajectory(TRAJ_num - 1).alt;
                end
                
                flight.trajectory(TRAJ_num).lowalt = 0;
                flight.trajectory(TRAJ_num).highalt = 100000;
                flight.trajectory(TRAJ_num).lowspd = 0;
                flight.trajectory(TRAJ_num).highspd = 9999;
                
                % P1 -> ������ ��
                TRAJ_num = TRAJ_num + 1;
                flight.trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                flight.trajectory(TRAJ_num).type = flight.command.type{j};
                flight.trajectory(TRAJ_num).traj_name = 'vectoring';
                flight.trajectory(TRAJ_num).wp_name = 'P1';
                flight.trajectory(TRAJ_num).flyover = false;
                
                if strcmp(flight.command.altitude{j}, 'default')
                    flight.trajectory(TRAJ_num).alt = flight.trajectory(TRAJ_num - 1).alt;
                elseif ~isnan(str2double(flight.command.altitude{j}))
                    flight.trajectory(TRAJ_num).alt = str2double(flight.command.altitude{j});
                else
                    ['cannot read altitude command of flight #' num2str(flight.id) ' Trajectory #' num2str(TRAJ_num) ' check altitude command in ' num2str(j)]
                    flight.trajectory(TRAJ_num).alt = flight.trajectory(TRAJ_num - 1).alt;
                end
                
                
                flight.trajectory(TRAJ_num).lowalt = 0;
                flight.trajectory(TRAJ_num).highalt = 100000;
                flight.trajectory(TRAJ_num).lowspd = 0;
                flight.trajectory(TRAJ_num).highspd = 9999;
                
                % P2 -> ������ ��
                TRAJ_num = TRAJ_num + 1;
                flight.trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                flight.trajectory(TRAJ_num).type = flight.command.type{j};
                flight.trajectory(TRAJ_num).traj_name = 'vectoring';
                flight.trajectory(TRAJ_num).wp_name = 'P2';
                flight.trajectory(TRAJ_num).flyover = false;
                
                if strcmp(flight.command.altitude{j}, 'default')
                    flight.trajectory(TRAJ_num).alt = flight.trajectory(TRAJ_num - 1).alt;
                elseif ~isnan(str2double(flight.command.altitude{j}))
                    flight.trajectory(TRAJ_num).alt = str2double(flight.command.altitude{j});
                else
                    ['cannot read altitude command of flight #' num2str(flight.id) ' Trajectory #' num2str(TRAJ_num) ' check altitude command in ' num2str(j)]
                    flight.trajectory(TRAJ_num).alt = flight.trajectory(TRAJ_num - 1).alt;
                end
                
                flight.trajectory(TRAJ_num).lowalt = 0;
                flight.trajectory(TRAJ_num).highalt = 100000;
                flight.trajectory(TRAJ_num).lowspd = 0;
                flight.trajectory(TRAJ_num).highspd = 9999;
                
                % P3 -> Destination
                TRAJ_num = TRAJ_num + 1;
                flight.trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                flight.trajectory(TRAJ_num).id = flight.command.destination{j};
                flight.trajectory(TRAJ_num).type = flight.command.type{j};
                flight.trajectory(TRAJ_num).traj_name = 'vectoring';
                flight.trajectory(TRAJ_num).wp_name = Airspace.Waypoint([Airspace.Waypoint.id] == flight.command.destination{j}).Name;
                flight.trajectory(TRAJ_num).lat = Airspace.Waypoint([Airspace.Waypoint.id] == flight.command.destination{j}).Lat;
                flight.trajectory(TRAJ_num).long = Airspace.Waypoint([Airspace.Waypoint.id] == flight.command.destination{j}).Long;
                flight.trajectory(TRAJ_num).flyover = false;
                
                if strcmp(flight.command.altitude{j}, 'default')
                    flight.trajectory(TRAJ_num).alt = flight.trajectory(TRAJ_num - 1).alt;
                elseif ~isnan(str2double(flight.command.altitude{j}))
                    flight.trajectory(TRAJ_num).alt = str2double(flight.command.altitude{j});
                else
                    ['cannot read altitude command of flight #' num2str(flight.id) ' Trajectory #' num2str(TRAJ_num) ' check altitude command in ' num2str(j)]
                    flight.trajectory(TRAJ_num).alt = flight.trajectory(TRAJ_num - 1).alt;
                end
                
                flight.trajectory(TRAJ_num).lowalt = 0;
                flight.trajectory(TRAJ_num).highalt = 100000;
                flight.trajectory(TRAJ_num).lowspd = 0;
                flight.trajectory(TRAJ_num).highspd = 9999;
                
                % P1 & P2 �� constraint ���� �� �ٽ� ����
                % �ӽ� ��ġ�� �ϴ� 1/3 2/3 ��������...
                flight.trajectory(TRAJ_num - 2).lat = 2/3 * flight.trajectory(TRAJ_num - 3).lat + 1/3 * flight.trajectory(TRAJ_num).lat;
                flight.trajectory(TRAJ_num - 2).long = 2/3 * flight.trajectory(TRAJ_num - 3).long + 1/3 * flight.trajectory(TRAJ_num).long;
                
                flight.trajectory(TRAJ_num - 1).lat = 1/3 * flight.trajectory(TRAJ_num - 3).lat + 2/3 * flight.trajectory(TRAJ_num).lat;
                flight.trajectory(TRAJ_num - 1).long = 1/3 * flight.trajectory(TRAJ_num - 3).long + 2/3 * flight.trajectory(TRAJ_num).long;
                
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
                ['Flight #' num2str(flight.id) ' Trajectory Assignment in progress for ' num2str(Assignloop) ' times.']
                
                while AltAssign
                    
                    for l = 1:length(flight.trajectory)
                        if l ~= length(flight.trajectory)
                            [dist_deg, flight.trajectory(l).heading] = distance(flight.trajectory(l).lat, flight.trajectory(l).long, flight.trajectory(l + 1).lat, flight.trajectory(l + 1).long);
                            flight.trajectory(l).distance = dist_deg * 60;
                        end
                        if and(~isempty(flight.trajectory(l).lowalt), ~isempty(flight.trajectory(l).highalt))
                            if flight.trajectory(l).highalt - flight.trajectory(l).lowalt < 100
                                flight.trajectory(l).alt = flight.trajectory(l).lowalt;
                                alt_fix = [alt_fix l];
                            end
                        end
                    end
                    
                    alt_fix = sort(unique(alt_fix));
                    
                    
                    % OPTION: CDO profile / low altitude profile / ���� fitting �۾��ϰ� �ش�
                    % profile ������ ��
                    
                    % SID: �̷� �� cruising alt�� �����Ҷ����� linear
                    % STAR, INST: ���� �� ���� 3�� ������ �� �ø�
                    % route: �� ����
                    
                    
                    % Cruise Altitude ���ϱ�
                    
                    
                    % Cruise Alt
                    if ~isempty(find(strcmp({flight.trajectory.wp_name}, 'trajectory_assigned') == 1, 1))
                        switch flight.trajectory(strcmp({flight.trajectory.wp_name}, 'trajectory_assigned') == 1).type
                            case {'ground' 'SID'}
                                if ~isempty(find(strcmp({flight.trajectory(~cellfun(@isempty,{flight.trajectory.alt})).type}, 'route')==1, 1));
                                    
                                    if strcmp(flight.trajectory(min(find(strcmp({flight.trajectory(~cellfun(@isempty,{flight.trajectory.alt})).type}, 'route')==1, 1, 'last') + 1, length(flight.trajectory)) ).type, 'route')
                                        % From CDO Profile:
                                        % Cr_alt = max(plan(flight.id).cruising_alt,flight.trajectory(find(~cellfun(@isempty,{flight.trajectory.alt}), 1, 'last' )).alt);
                                        
                                        % From CCO Profile:
                                        Cr_alt = max([flight.trajectory(strcmp('route', {flight.trajectory.type})).alt]);
                                    else
                                        Cr_alt = plan(flight.id).cruising_alt;
                                    end
                                    
                                else
                                    Cr_alt = plan(flight.id).cruising_alt;
                                end
                            otherwise
                                if ~isempty(find(strcmp({flight.trajectory.type}, 'route') == 1, 1));
                                    if ~isempty(find(strcmp({flight.trajectory(~cellfun(@isempty,{flight.trajectory.alt})).type}, 'route')==1, 1));
                                        if strcmp(flight.trajectory(find(strcmp({flight.trajectory(~cellfun(@isempty,{flight.trajectory.alt})).type}, 'route')==1, 1, 'last') + 1).type, 'route')
                                            % From CDO Profile:
                                            Cr_alt = flight.trajectory(find(~cellfun(@isempty,{flight.trajectory.alt}), 1, 'last' )).alt;
                                            
                                            % From CCO Profile:
                                            % Cr_alt = flight.trajectory(find(~cellfun(@isempty,{flight.trajectory.alt}), 1)).alt;
                                        else
                                            Cr_alt = plan(flight.id).cruising_alt;
                                        end
                                    else
                                        Cr_alt = plan(flight.id).cruising_alt;
                                    end
                                else
                                    Cr_alt = max([flight.trajectory.alt]);
                                end
                        end
                    else
                        if ~isempty(find(strcmp({flight.trajectory(~cellfun(@isempty,{flight.trajectory.alt})).type}, 'route')==1, 1));
                            if strcmp(flight.trajectory(find(strcmp({flight.trajectory(~cellfun(@isempty,{flight.trajectory.alt})).type}, 'route')==1, 1, 'last') + 1).type, 'route')
                                if isempty(flight.trajectory(find(strcmp({flight.trajectory(~cellfun(@isempty,{flight.trajectory.alt})).type}, 'route')==1, 1, 'last') + 1).alt);
                                    Cr_alt = plan(flight.id).cruising_alt;
                                else
                                    % From CDO Profile:
                                    Cr_alt = flight.trajectory(find(~cellfun(@isempty,{flight.trajectory.alt}), 1, 'last' )).alt;
                                    % From CCO Profile:
                                    % Cr_alt = flight.trajectory(find(~cellfun(@isempty,{flight.trajectory.alt}), 1)).alt;
                                end
                            else
                                Cr_alt = plan(flight.id).cruising_alt;
                            end
                        else
                            % From CDO Profile:
                            Cr_alt = max(plan(flight.id).cruising_alt, flight.trajectory(find(~cellfun(@isempty,{flight.trajectory.alt}), 1, 'last' )).alt);
                            
                            % From CCO Profile:
                            %                         Cr_alt = max(plan(flight.id).crusing_alt, flight.trajectory(find(~cellfun(@isempty,{flight.trajectory.alt}), 1)).alt);
                        end
                    end
                    
                    
                    
                    if ~isempty(plan(flight.id).desc_profile)
                        switch plan(flight.id).desc_profile
                            case 'CDO_flex'
                                ['Assigning Trajectory.....flight #' num2str(flight.id) ' descending altitude profile: ' plan(flight.id).desc_profile]
                                [flight, alt_fix] = Desc_Profile_CDO_flex(flight, alt_fix, acc_fix, ArrFE, Cr_alt);
                                
                            case 'CDO_strict'
                                
                            case 'lowest_alt'
                                
                            case 'highest_alt'
                                
                            case 'rand_uniform'
                                
                            case 'rand_normal'
                                
                            case 'nomial'
                                
                        end
                    else
                        ['Assigning Trajectory.....flight #' num2str(flight.id) ' descending altitude profile: CDO_flex']
                        [flight, alt_fix] = Desc_Profile_CDO_flex(flight, alt_fix, acc_fix, ArrFE, Cr_alt);
                        
                    end
                    
                    
                    
                    % ����� climb profile
                    
                    
                    if ~isempty(plan(flight.id).climb_profile)
                        switch plan(flight.id).climb_profile
                            
                            case 'CCO_flex'
                                ['Assigning Trajectory.....flight #' num2str(flight.id) ' climbing altitude profile: ' plan(flight.id).desc_profile]
                                [flight, alt_fix] = Climb_Profile_CCO_flex(flight, alt_fix, acc_fix, DepFE, Cr_alt);
                                
                            case 'CCO_strict'
                                
                            case 'lowest_alt'
                                
                            case 'highest_alt'
                                
                            case 'rand_uniform'
                                
                            case 'rand_normal'
                                
                            case 'nomial'
                                
                        end
                    else
                        ['Assigning Trajectory.....flight #' num2str(flight.id) ' climbing altitude profile: CCO_flex']
                        [flight, alt_fix] = Climb_Profile_CCO_flex(flight, alt_fix, acc_fix, DepFE, Cr_alt);
                    end
                    
                    % route������ alt_fix �� Cr_alt ����
                    ['Assigning Trajectory.....flight #' num2str(flight.id) ' route altitude profile: default']
                    
                    route_fix = find(strcmp('route', {flight.trajectory.type}));
                    if min(route_fix) > 1
                        if isempty(flight.trajectory(min(route_fix) - 1).alt)
                            route_fix = sort([route_fix (min(route_fix) - 1)]);
                        end
                    end
                    for RouteSeq = 1:length(route_fix)
                        if isempty(flight.trajectory(route_fix(RouteSeq)).alt)
                            flight.trajectory(route_fix(RouteSeq)).alt = Cr_alt;
                        end
                    end
                    
                    
                    % initial FS assignment -> ���� ��������
                    % Option: initial
                    
                    flight = AssignFlightStatus(flight, DepFE, ArrFE ,'AltOnly');
                    
                    
                    AltAssign = false;
                end
                
                
                % check procedure
                
%                 for ac = 1:length(flight)
                    for line = 1:length(flight.trajectory)
                        if isempty(flight.trajectory(line).alt)
                            if and(line > 1, line < length(flight.trajectory))
                                flight.trajectory(line).alt = ((flight.trajectory(line - 1).distance * flight.trajectory(line - 1).alt) + (flight.trajectory(line).distance * flight.trajectory(line + 1).alt) ) / (flight.trajectory(line - 1).distance + flight.trajectory(line).distance);
                            elseif line == 1
                                flight.trajectory(line).alt = flight.trajectory(line + 1).alt;
                            elseif line == length(flight.trajectory)
                                flight.trajectory(line).alt = flight.trajectory(line - 1).alt;
                            end
                        end
                        if isempty(flight.trajectory(line).FS)
                            if line > 1
                                flight.trajectory(line).FS =  flight.trajectory(line - 1).FS;
                            elseif line == 1
                                flight.trajectory(line).FS =  flight.trajectory(line + 1).FS;
                            end
                        end
                        
                    end
%                 end
                
                
                
                
                while SpdAssign
                    
                    flight = AssignFlightStatus(flight, DepFE, ArrFE ,'AltOnly');
                    
                    
                    for l = 1:length(flight.trajectory) - 1
                        if and(~isempty(flight.trajectory(l).lowspd), ~isempty(flight.trajectory(l).highspd))
                            if ~isempty(flight.trajectory(l).Vcas)
                                if ~isempty(flight.trajectory(l).Vmach)
                                    if flight.trajectory(l).alt <= Perf.(flight.type).Machtrans_cruise
                                        flight.trajectory(l).Vcas = max(flight.trajectory(l).lowspd, flight.trajectory(l).Vcas);
                                        flight.trajectory(l).Vmach = '';
                                        spd_fix = [spd_fix l];
                                    else
                                        flight.trajectory(l).Vcas = max(flight.trajectory(l).lowspd, tas2cas(mach2tas(flight.trajectory(l).Vmach, flight.trajectory(l).alt), flight.trajectory(l).alt));
                                        flight.trajectory(l).Vcas = '';
                                        spd_fix = [spd_fix l];
                                    end
                                else
                                    flight.trajectory(l).Vcas = max(flight.trajectory(l).lowspd, flight.trajectory(l).Vcas);
                                    spd_fix = [spd_fix l];
                                end
                            elseif ~isempty(flight.trajectory(l).Vmach)
                                if ~isempty(flight.trajectory(l).Vcas)
                                    if flight.trajectory(l).alt <= Perf.(flight.type).Machtrans_cruise
                                        flight.trajectory(l).Vcas = max(flight.trajectory(l).lowspd, flight.trajectory(l).Vcas);
                                        flight.trajectory(l).Vmach = '';
                                        spd_fix = [spd_fix l];
                                    else
                                        flight.trajectory(l).Vcas = max(flight.trajectory(l).lowspd, tas2cas(mach2tas(flight.trajectory(l).Vmach, flight.trajectory(l).alt), flight.trajectory(l).alt));
                                        flight.trajectory(l).Vcas = '';
                                        spd_fix = [spd_fix l];
                                    end
                                else
                                    flight.trajectory(l).Vcas = max(flight.trajectory(l).lowspd, tas2cas(mach2tas(flight.trajectory(l).Vmach, flight.trajectory(l).alt), flight.trajectory(l).alt));
                                    spd_fix = [spd_fix l];
                                end
                            elseif flight.trajectory(l).highspd - flight.trajectory(l).lowspd < 10;
                                flight.trajectory(l).Vcas = flight.trajectory(l).lowspd;
                                spd_fix = [spd_fix l];
                            end
                        end
                    end
                    
                    spd_fix = sort(unique(spd_fix));
                    
                    
                    % initial speed assignment -> ������ �ӵ��� ��� assign �� ���ΰ�
                    % OPTION: �ϴ� linear, max_accel..
                    % profile ������ ��
                    if ~isempty(plan(flight.id).speed_control)
                        switch plan(flight.id).speed_control
                            case 'linear'
                                ['Assigning Trajectory.....flight #' num2str(flight.id) ' speed profile: ' plan(flight.id).speed_control]
                                [flight, spd_fix] = Speed_Profile_BADA_Linear(flight, spd_fix, DepFE, ArrFE, acc_fix);
                        end
                    else
                        
                        ['Assigning Trajectory.....flight #' num2str(flight.id) ' speed profile: linear']
                        [flight, spd_fix] = Speed_Profile_BADA_Linear(flight, spd_fix, DepFE, ArrFE, acc_fix);
                    end
                    
                    
                    % initial acceleration assignment -> ������ ������ �ӵ��� � �������� ������ ���ΰ�
                    % OPTION: �ϴ� linear
                    % profile ������ ��
                    
                    % ���� TBO ��� ���߽� ���⿡ ���������� �پ�������, acc_fix�� �������
                    
                    if ~isempty(plan(flight.id).accel_control)
                        switch plan(flight.id).accel_control
                            case 'linear'
                                ['Assigning Trajectory.....flight #' num2str(flight.id) ' acceleration profile: ' plan(flight.id).accel_control]
                                flight = Accl_Profile_Linear(flight);
                        end
                        
                    else
                                ['Assigning Trajectory.....flight #' num2str(flight.id) ' acceleration profile: linear']
                                flight = Accl_Profile_Linear(flight);
                        
                        
                    end
                    
                    % speed���� ������ �ٽ� FS ����
                    flight = AssignFlightStatus(flight, DepFE, ArrFE ,'AltSpd');
                    
                    
                    SpdAssign = false;
                end
                
                % Acceleration Limit Test
                [flight, AssignProgress, AltAssign, SpdAssign, acc_fix] = CheckAcceleration(flight, acc_fix);
                
                Assignloop = Assignloop + 1;
            else
                
                AssignProgress = false;
                ['Flight #' num2str(flight.id) ' Trajectory Assignment in progress over limit! Breaking (' num2str(Assignloop) ')']
                
                
            end
            if ~AssignProgress
                ThrustProgress = true;
                % Acceleration Limit Test ����ϸ� Thrust ��� -> Fuel Consumption ->Mass
                
                while ThrustProgress
                    init_mass = flight.mass;
                    for TrajLen = 1:length(flight.trajectory)
                        flight.trajectory(TrajLen).mass = init_mass;
                    end
                    
                    flight = CalculateThrust(flight);
                    % Maximum Thrust���� -> ThrustProgress = false
                    
                    
                    [flight, ThrustProgress, AssignProgress, AltAssign, SpdAssign, acc_fix] = CheckThrust(flight, alt_fix, spd_fix, acc_fix);
   

                    % Acceleration�� correction �ʿ�
                    %                     flight = Accel_Correction(flight, spd_fix, alt_fix);
                    
                    if AssignProgress
                        if AltAssign
                            % CCO, CDO ���� -> �� ��쿡�� Cr_alt�� ������ ��쵵 ����. �Ʒ� mass��
                            % ������ ������Ű�� ���ó�� Cr_alt�� ������ ��ȭ���Ѻ���.
                            for DeleteFix = 1:length(flight.FalseFix)
                                %                                 flight.trajectory(flight.FalseFix(DeleteFix)) = [];
                                for TrajDown = find([flight.trajectory.TRAJ_num] == flight.FalseFix(DeleteFix) + 1, 1):length(flight.trajectory)
                                    flight.trajectory(TrajDown - 1) = flight.trajectory(TrajDown);
                                    flight.trajectory(TrajDown - 1).TRAJ_num = TrajDown - 1;
                                end
                                flight.trajectory(end) = [];
                            end
                            flight.FalseFix = [];
                        end         
                        flight.old_trajectory = struct;
                        names = fieldnames(flight.trajectory);
                        for CCTraj = 1:length(flight.trajectory)
                            for CopyTraj = 1:length(names)
                                ctn = names{CopyTraj};
                                flight.old_trajectory(CCTraj).(ctn) = flight.trajectory(CCTraj).(ctn);
                            end
                        end
                        flight = InitializeTrajectory(flight, alt_fix, spd_fix, acc_fix, AltAssign, SpdAssign);
                    end
                    
                    
                    
                    % ���� Mass Correction ���� -> �ٽ� Alt, Spd, Thrust Correction
                    if ~ThrustProgress
                        flight = FuelConsumption(flight);
                        flight = MassCorrection(flight);
                    end
                    
                    % FE Filter (�ַ� Thrust)�� ���� ���� ���� ������ AssignComplete�� return ����.
                    % ���� ������ �ش� constraint�� ��� alt_fix, spd_fix ���� Assign ������ FalseFix�� ����
                    % �ٽ� profile�� �����Ű��.

                    
                end
                


                
            else
                ValidateProgress = true;
                
                
                

                
                
                if AltAssign
                    % CCO, CDO ���� -> �� ��쿡�� Cr_alt�� ������ ��쵵 ����. �Ʒ� mass��
                    % ������ ������Ű�� ���ó�� Cr_alt�� ������ ��ȭ���Ѻ���.
                    for DeleteFix = 1:length(flight.FalseFix)
                        % flight.trajectory(flight.FalseFix(DeleteFix)) = [];
                        for TrajDown = find([flight.trajectory.TRAJ_num] == flight.FalseFix(DeleteFix) + 1, 1):length(flight.trajectory)
                            flight.trajectory(TrajDown - 1) = flight.trajectory(TrajDown);
                            flight.trajectory(TrajDown - 1).TRAJ_num = TrajDown - 1;
                        end
                        flight.trajectory(end) = [];
                    end
                    flight.FalseFix = [];
                end
                
                
                flight.old_trajectory = struct;
                names = fieldnames(flight.trajectory);
                for CCTraj = 1:length(flight.trajectory)
                    for CopyTraj = 1:length(names)
                        ctn = names{CopyTraj};
                        flight.old_trajectory(CCTraj).(ctn) = flight.trajectory(CCTraj).(ctn);
                    end
                end
                
                
                flight = InitializeTrajectory(flight, alt_fix, spd_fix, acc_fix, AltAssign, SpdAssign);
                
                
                
                
            end
            
        end
        
        
        
        % Mass Correction�� ���� ������ ���� min mass������ ���� endurance�� �߻� ->
        % �ٽ� ��ü���� validation�� ���� mass�� ���� envelope�� �ɸ���
        % (1) Profile�� ���� -> �� ���ᰡ �� ��� �ɷ�
        % (2) Plan�� ���� -> (2.1) �ʱ� Mass�� ���� or (2.2) Route ����
        
        if Validateloop <= 100
            ['Flight #' num2str(flight.id) ' Trajectory Validation in progress for ' num2str(Validateloop) ' times.']
            
            [flight, ValidateProgress] = TrajectoryValidation(flight);
            
            % flatworld heading, distance correction
            for TrajLen = 1:length(flight.trajectory) - 1
                %             [dist,azim] = distance('rh', flight.trajectory(TrajLen).lat, flight.trajectory(TrajLen).long, flight.trajectory(TrajLen + 1).lat, flight.trajectory(TrajLen + 1).long);
                %             flight.trajectory(TrajLen).distance = deg2nm(dist);
                %             flight.trajectory(TrajLen).heading = azim;
                FlatHead = rad2deg(atan2(flight.trajectory(TrajLen + 1).long - flight.trajectory(TrajLen).long, flight.trajectory(TrajLen + 1).lat - flight.trajectory(TrajLen).lat));
                if FlatHead < 0
                    FlatHead = FlatHead + 360;
                end
                %             FlatDist = sqrt((flight.trajectory(TrajLen + 1).long - flight.trajectory(TrajLen).long)^2 + (flight.trajectory(TrajLen + 1).lat - flight.trajectory(TrajLen).lat)^2);
                
                %             flight.trajectory(TrajLen).distance = FlatDist;
                flight.trajectory(TrajLen).heading = FlatHead;
            end
            
            
            if ValidateProgress
                %         AssignComplete = true;
                
                % �̰� Assignment�� ���������... Validate�� ���� (mass ����)
                % mass�� Perf���� mass_max�� �ɶ����� ���ݾ� �÷����� (��, ���Ḧ �� �Ǿ��)
                % �׷��� �ȵǸ� plan (profile, origin, dest, route) ����
                
                
                InitializeTrajectory;
                AssignProgress = true;
                
                
            end
            
            
            Validateloop = Validateloop + 1;
        else
            ['Flight #' num2str(flight.id) ' Trajectory Validation in progress over limit! Breaking (' num2str(Validateloop) ')']
            
            ValidateProgress = false;
        end
        
    end
   
%     catch
%         flight.id = [];
%         plan(flight.id).id = [];
%     end
end
% end
