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



    % �ϴ� hard �ڵ����� direct�� ������, ���߿��� current_position�� ������ �����ϴ� �������� ������
    % ������ �ľ��ؼ� direct�� ���� �����ϵ��� �� ��
    if strcmp(flight(i).FS, 'TX') == 0
        % ground�� �ƴ� ��Ȳ�̸� ���� fix ���� direct�� ����
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
        % ground ���, TO ���� ��Ȳ����, RWY_THR �̵� -> airbourne ������ ����
        if strcmp(flight(i).command.type{1}, 'SID') == 1

            DepFE = Aerodrome(strcmp(plan(flight(i).id).departure, {Aerodrome.ID})).RWY(strcmp(plan(flight(i).id).departure_RWY, {Aerodrome(strcmp(plan(flight(i).id).departure, {Aerodrome.ID})).RWY.name})).elevation;
            
            TRAJ_num = 1;
            flight(i).trajectory=struct;
            
            if TRAJ_num == 1
                % ù��° fix�� �ι�° fix�� �ݰ� 0.3NM �̳���� ���� �Ƚ��� �������
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
            % ������ lineup ��ġ�ε�, �ϴ� THR�� ��� ���߿� ��������
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
            
            %Airbourne ����, �ϴ� rwy 3/5���� �����.
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
                            % ù��° fix�� �ι�° fix�� �ݰ� 0.3NM �̳���� ���� �Ƚ��� �������
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
                                % INST ���������� RWY�� trajectory�� �־�����

                                if strcmp(flight(i).trajectory(TRAJ_num).wp_name, strcat(plan(flight(i).id).arrival, '_', plan(flight(i).id).arrival_RWY, '_THR')) == 1
                                    ArrFE = Aerodrome(strcmp(plan(flight(i).id).arrival, {Aerodrome.ID})).RWY(strcmp(plan(flight(i).id).arrival_RWY, {Aerodrome(strcmp(plan(flight(i).id).arrival, {Aerodrome.ID})).RWY.name})).elevation;

                                    if Procedure(flight(i).command.trajectory{j}).trajectory(k).RDH == 0;
                                        Procedure(flight(i).command.trajectory{j}).trajectory(k).RDH = '-3.0';
                                    end
                                        % RWY End ������ �����Ѵ� -> ���� TDZ�� RDH�� ������.
                                        
                                        %Touchdown ����, RDH�� reckon�Լ��� ������
                                        TRAJ_num = TRAJ_num + 1;
                                        flight(i).trajectory(TRAJ_num).TRAJ_num = TRAJ_num;
                                        flight(i).trajectory(TRAJ_num).type = 'INST';
                                        flight(i).trajectory(TRAJ_num).traj_name = Procedure(flight(i).command.trajectory{j}).name;
                                        flight(i).trajectory(TRAJ_num).wp_name = strcat(plan(flight(i).id).arrival, '_', plan(flight(i).id).arrival_RWY, '_TouchDown');
                                        
                                        % Low Alt�� �������� ����.
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
                                        
                                        
                                        %Taxi Segment -> brake�� ��
                                        %0.5NM(3000ft)�� ����
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
                                    
                                    %Touchdown ����, �ϴ� rwy 1/4 �������� �����.
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
                                    
                                    
                                    %Taxi Segment -> brake�� ��
                                    %0.5NM(3000ft)�� ����
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
                
                % P1 -> ������ ��
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
                
                % P2 -> ������ ��
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
                
                % P1 & P2 �� constraint ���� �� �ٽ� ����
                % �ӽ� ��ġ�� �ϴ� 1/3 2/3 ��������...
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
                    
                    
                    % OPTION: CDO profile / low altitude profile / ���� fitting �۾��ϰ� �ش�
                    % profile ������ ��
                    
                    % SID: �̷� �� cruising alt�� �����Ҷ����� linear
                    % STAR, INST: ���� �� ���� 3�� ������ �� �ø�
                    % route: �� ����
                    
                    
                    % Cruise Altitude ���ϱ�
                    
                    
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
                    
                    
                    
                    
                    % ����� climb profile
                    
                    
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
                    
                    
                    % route������ alt_fix �� Cr_alt ����
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
                    
                    
                    % initial FS assignment -> ���� ��������
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
                    
                    
                    % initial speed assignment -> ������ �ӵ��� ��� assign �� ���ΰ�
                    % OPTION: �ϴ� linear, max_accel..
                    % profile ������ ��
                    switch plan(flight(i).id).speed_control
                        case 'linear'
                            ['Assigning Trajectory.....flight #' num2str(i) ' speed profile: ' plan(flight(i).id).speed_control]
                            [flight(i), spd_fix] = Speed_Profile_BADA_Linear(flight(i), spd_fix, DepFE, ArrFE, acc_fix);
                    end
                    
                    
                    
                    % initial acceleration assignment -> ������ ������ �ӵ��� � �������� ������ ���ΰ�
                    % OPTION: �ϴ� linear
                    % profile ������ ��
                    
                    % ���� TBO ��� ���߽� ���⿡ ���������� �پ�������, acc_fix�� �������
                    
                    switch plan(flight(i).id).accel_control
                        case 'linear'
                            ['Assigning Trajectory.....flight #' num2str(i) ' acceleration profile: ' plan(flight(i).id).accel_control]
                            flight(i) = Accl_Profile_Linear(flight(i));
                    end
                    
                    % speed���� ������ �ٽ� FS ����
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
                % Acceleration Limit Test ����ϸ� Thrust ��� -> Fuel Consumption ->Mass
                
                while ThrustProgress
                    init_mass = flight(i).mass;
                    for TrajLen = 1:length(flight(i).trajectory)
                        flight(i).trajectory(TrajLen).mass = init_mass;
                    end
                    
                    flight(i) = CalculateThrust(flight(i));
                    % Maximum Thrust���� -> ThrustProgress = false
                    
                    
                    [flight(i), ThrustProgress, AssignProgress, AltAssign, SpdAssign, acc_fix] = CheckThrust(flight(i), alt_fix, spd_fix, acc_fix);
   

                    % Acceleration�� correction �ʿ�
                    %                     flight(i) = Accel_Correction(flight(i), spd_fix, alt_fix);
                    
                    if AssignProgress
                        if AltAssign
                            % CCO, CDO ���� -> �� ��쿡�� Cr_alt�� ������ ��쵵 ����. �Ʒ� mass��
                            % ������ ������Ű�� ���ó�� Cr_alt�� ������ ��ȭ���Ѻ���.
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
                    
                    
                    
                    % ���� Mass Correction ���� -> �ٽ� Alt, Spd, Thrust Correction
                    if ~ThrustProgress
                        flight(i) = FuelConsumption(flight(i));
                        flight(i) = MassCorrection(flight(i));
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
        
        
        
        % Mass Correction�� ���� ������ ���� min mass������ ���� endurance�� �߻� ->
        % �ٽ� ��ü���� validation�� ���� mass�� ���� envelope�� �ɸ���
        % (1) Profile�� ���� -> �� ���ᰡ �� ��� �ɷ�
        % (2) Plan�� ���� -> (2.1) �ʱ� Mass�� ���� or (2.2) Route ����
        
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
                
                % �̰� Assignment�� ���������... Validate�� ���� (mass ����)
                % mass�� Perf���� mass_max�� �ɶ����� ���ݾ� �÷����� (��, ���Ḧ �� �Ǿ��)
                % �׷��� �ȵǸ� plan (profile, origin, dest, route) ����
                
                
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
