
function flight_profile = Accl_Profile_Linear(flight_profile)

global atmos plan unit Perf config

% BADA �޴��󿡼� 2���� acceleration constraint�� �ְ� ����. pp.31 5.2


previous_distdiff = 0;
previous_turndistance = 0;
previous_turntime = 0;
for TrajLen = 1:length(flight_profile.trajectory) - 1
    
    % TAS ����
    if isempty(flight_profile.trajectory(TrajLen).Vtas)
        ['warning!  flight #' num2str(flight_profile.trajectory.id) ', trajectory #' num2str(TrajLen) ' has no TAS in Acceleration Profile.']
        if ~isempty(flight_profile.trajecotry(TrajLen).Vcas)
            flight_profile.trajecotry(TrajLen).Vtas = cas2tas(flight_profile.trajecotry(TrajLen).Vcas, flight_profile.trajecotry(TrajLen).alt);
        elseif ~isempty(flight_profile.trajecotry(TrajLen).Vmach)
            flight_profile.trajecotry(TrajLen).Vtas = mach2tas(flight_profile.trajecotry(TrajLen).Vmach, flight_profile.trajecotry(TrajLen).alt);
        end
    end
    
    % Distance Bearing ���
    [arclen, az] = distance(flight_profile.trajectory(TrajLen).lat, flight_profile.trajectory(TrajLen).long, flight_profile.trajectory(TrajLen + 1).lat, flight_profile.trajectory(TrajLen + 1).long);
    
    flight_profile.trajectory(TrajLen).distance = deg2nm(arclen);
    flight_profile.trajectory(TrajLen).heading = az;
    if TrajLen == length(flight_profile.trajectory) - 1
        flight_profile.trajectory(TrajLen + 1).heading = az;
    end
    seg_spd = (flight_profile.trajectory(TrajLen).Vtas + flight_profile.trajectory(TrajLen + 1).Vtas) / 2;

    
    % �Ʒ� �ڵ�� ���� fix�� ���� ��ȸ������ ���� ������ segment
%     
%     % Acceleration ���� �� turning segment �������
% 
%     hdg_diff = abs(flight_profile.trajectory(TrajLen + 1).heading - flight_profile.trajectory(TrajLen).heading);
%     
%     if hdg_diff > 180
%         hdg_diff = 360 - hdg_diff;
%     end
%     
%     switch flight_profile.trajectory(TrajLen).FS
%         case {'TO' 'LD'}
%             bankangle = 15;
%         otherwise
%             bankangle = 35;
%     end
%     
%     if abs(hdg_diff) < 1
%         hdg_diff = 0;
%     end
%     
%     hdg_diff = 180 - hdg_diff;
% 
%     turn_rate = 1091 * tan(deg2rad(bankangle)) / flight_profile.trajectory(TrajLen + 1).Vtas;
%     turn_radius= (flight_profile.trajectory(TrajLen + 1).Vtas ^ 2)/(11.26 * tan(deg2rad(bankangle))) * unit.ft2meter / unit.nm2meter;
%     
%     distdiff =  turn_radius/abs(tan(deg2rad(hdg_diff / 2)));
%     
%     accel_distance = flight_profile.trajectory(TrajLen).distance - distdiff - previous_distdiff;
%     turn_distance = deg2rad(180 - hdg_diff) * turn_radius;
%     ground_distance = accel_distance + previous_turndistance;
%     
%     accel_time = accel_distance / seg_spd;
%     turn_time = previous_turndistance / flight_profile.trajectory(TrajLen).Vtas;
%     real_time = accel_time + turn_time;
% 
%       % segment �� ���� �ҿ� �ð� (second)
%     flight_profile.trajectory(TrajLen).EET = real_time * 3600;
%     flight_profile.trajectory(TrajLen).accel_time = accel_time * 3600;
%     flight_profile.trajectory(TrajLen).turn_time = turn_time * 3600;
%     
%     % vertical speed ��� (ft / sec)
%     flight_profile.trajectory(TrajLen).vs = (flight_profile.trajectory(TrajLen + 1).alt - flight_profile.trajectory(TrajLen).alt) / (flight_profile.trajectory(TrajLen).EET);
%     flight_profile.trajectory(TrajLen).max_vs = (flight_profile.trajectory(TrajLen + 1).alt - flight_profile.trajectory(TrajLen).alt) / (flight_profile.trajectory(TrajLen).accel_time);
%     
%     % distance�� ��ȸ segment �и�����
%     flight_profile.trajectory(TrajLen).InterFix_distance = flight_profile.trajectory(TrajLen).distance;
%     flight_profile.trajectory(TrajLen).ground_distance = ground_distance;
%     flight_profile.trajectory(TrajLen).accel_distance = accel_distance;
%     flight_profile.trajectory(TrajLen).turn_distance = turn_distance;
% 
% 
%     previous_turndistance = turn_distance;
%     previous_distdiff = distdiff;
%     previous_turntime = turn_time;

    
    
%     �Ʒ� �ڵ�� ��ȸ ������ �ݾ� ©�� �� �� segment�� ���ΰ�
        
    % Acceleration ���� �� turning segment �������
    % turn �߿��� ���� x
    
               
    
    
%     hdg_diff = abs(flight_profile.trajectory(TrajLen + 1).heading - flight_profile.trajectory(TrajLen).heading);
%     
%     if hdg_diff > 180
%         hdg_diff = 360 - hdg_diff;
%     end
%     
    
    hdg_diff = mod(flight_profile.trajectory(TrajLen + 1).heading - flight_profile.trajectory(TrajLen).heading, 360); % deg
    if hdg_diff > 180
        hdg_diff = 360 - hdg_diff;
    end
    
    
%     if flight_profile.trajectory(TrajLen + 1).heading - flight_profile.trajectory(TrajLen).heading > 180;
%         hdg_diff = 360 - flight_profile.trajectory(TrajLen + 1).heading - flight_profile.trajectory(TrajLen).heading;
%     elseif flight_profile.trajectory(TrajLen + 1).heading - flight_profile.trajectory(TrajLen).heading < -180;
%         hdg_diff = 360 + flight_profile.trajectory(TrajLen + 1).heading - flight_profile.trajectory(TrajLen).heading;
%     else
%         hdg_diff = abs(flight_profile.trajectory(TrajLen + 1).heading - flight_profile.trajectory(TrajLen).heading);
%     end
%     hdg_diff = 180 - hdg_diff;
    
    switch flight_profile.trajectory(TrajLen).FS
        case {'TO' 'LD'}
            bankangle = 15;
        otherwise
            bankangle = 35;
    end
    
%     if abs(hdg_diff) == 0
%         hdg_diff = 0.0001;
%     end
%     
    hdg_diff = 180 + hdg_diff;
   
%     turn_rate = 1091 * tan(deg2rad(bankangle)) / flight_profile.trajectory(TrajLen + 1).Vtas;
    turn_rate = rad2deg(tan(deg2rad(bankangle * config.BankAngleBuffer)) * atmos.g_0 / (flight_profile.trajectory(TrajLen + 1).Vtas * unit.nm2meter / 3600));
    
%     turn_radius= ((flight_profile.trajectory(TrajLen + 1).Vtas ^ 2)/(11.29 * tan(deg2rad(bankangle)))) * unit.ft2nm;
    turn_radius = flight_profile.trajectory(TrajLen + 1).Vtas / (turn_rate * 20 * pi);
    
%     if abs(turn_radius - (((flight_profile.trajectory(TrajLen + 1).Vtas ^ 2)/(11.29 * tan(deg2rad(bankangle)))) * unit.ft2nm)) > 1
%         'aa'
%     end

%     if hdg_diff == 0
%         distdiff = 0;
%     else
        distdiff =  turn_radius/abs(tan(deg2rad(hdg_diff / 2)));
%     end


    flight_profile.trajectory(TrajLen).distdiff =  distdiff;
    
    accel_distance = flight_profile.trajectory(TrajLen).distance - previous_distdiff - distdiff;
%     accel_distance = flight_profile.trajectory(TrajLen).distance - (previous_distdiff) - (distdiff);

    turn_distance = deg2rad(180 - hdg_diff) * turn_radius / 2;
    ground_distance = accel_distance + turn_distance + previous_turndistance;
    
%     if ground_distance < 0
%         'aa'
%     end
    accel_time = accel_distance / seg_spd;
    turn_time = turn_distance / flight_profile.trajectory(TrajLen + 1).Vtas;
    real_time = accel_time + turn_time + previous_turntime;
    

      % segment �� ���� �ҿ� �ð� (second)
    flight_profile.trajectory(TrajLen).EET = real_time * 3600;
    flight_profile.trajectory(TrajLen).accel_time = accel_time * 3600;
    flight_profile.trajectory(TrajLen).turn_time = turn_time * 3600;
    flight_profile.trajectory(TrajLen).p_turn_time = previous_turntime * 3600;
    
    % vertical speed ��� (ft / sec)
    flight_profile.trajectory(TrajLen).vs = (flight_profile.trajectory(TrajLen + 1).alt - flight_profile.trajectory(TrajLen).alt) / (flight_profile.trajectory(TrajLen).EET);
    flight_profile.trajectory(TrajLen).max_vs = (flight_profile.trajectory(TrajLen + 1).alt - flight_profile.trajectory(TrajLen).alt) / (flight_profile.trajectory(TrajLen).accel_time);
    
    % distance�� ��ȸ segment �и�����
    flight_profile.trajectory(TrajLen).InterFix_distance = flight_profile.trajectory(TrajLen).distance;
    flight_profile.trajectory(TrajLen).ground_distance = ground_distance;
    flight_profile.trajectory(TrajLen).accel_distance = accel_distance;
    flight_profile.trajectory(TrajLen).turn_distance = turn_distance;
    flight_profile.trajectory(TrajLen).p_turn_distance = previous_turndistance;
    
    previous_turndistance = turn_distance;
    previous_distdiff = distdiff;
    previous_turntime = turn_time;
    
    
    
    
    
    
    % ��ȸ�� ���� ����
    flight_profile.trajectory(TrajLen).turn_rate = turn_time;
    flight_profile.trajectory(TrajLen).turn_radius = turn_radius;
    
    % ���� VS�� TAS�� �ռ��ϰ� GS�� �и�����
    % matlab 3-d coordinate toolbox���� ����������... ���� �� �𸣴ϱ� �ϴ� sqrt�� �ٻ�
    RealDist = sqrt((flight_profile.trajectory(TrajLen).ground_distance)^2 + (((flight_profile.trajectory(TrajLen + 1).alt) - (flight_profile.trajectory(TrajLen).alt))/unit.nm2ft)^2);
    
    flight_profile.trajectory(TrajLen).distance = RealDist;
    
%     SegmentVtas = RealDist / (flight_profile.trajectory(TrajLen).EET / 3600);
%     flight_profile.trajectory(TrajLen + 1).Vtas = round((SegmentVtas * 2) - flight_profile.trajectory(TrajLen).Vtas, 2);
    
    SegmentSpd = flight_profile.trajectory(TrajLen).distance / flight_profile.trajectory(TrajLen).EET * 3600;
    flight_profile.trajectory(TrajLen).SegmentTAS = SegmentSpd;
    if TrajLen == length(flight_profile.trajectory)
        flight_profile.trajectory(TrajLen).SegmentTAS = flight_profile.trajectory(TrajLen).Vtas;
    end

%     if TrajLen == 1
%         flight_profile.trajectory(1).SegmentTAS = flight_profile.trajectory(1).Vtas;
%     end
    
%     flight_profile.trajectory(TrajLen + 1).SegmentTAS = round(((SegmentSpd * 2) - flight_profile.trajectory(TrajLen).SegmentTAS), 2);
    
    
    flight_profile.trajectory(length(flight_profile.trajectory)).vs = 0;
    
end

for TrajLen = 1:length(flight_profile.trajectory) - 1
    
    % ���⼭ speed increment�� linear �ϹǷ� acceleration ���� ����� ���´�.
    flight_profile.trajectory(TrajLen).accel_long = ((flight_profile.trajectory(TrajLen + 1).Vtas - flight_profile.trajectory(TrajLen).Vtas) / 3600 * unit.nm2ft) / flight_profile.trajectory(TrajLen).EET;
    flight_profile.trajectory(TrajLen).max_accel_long = ((flight_profile.trajectory(TrajLen + 1).Vtas - flight_profile.trajectory(TrajLen).Vtas) / 3600 * unit.nm2ft) / flight_profile.trajectory(TrajLen).accel_time;
    flight_profile.trajectory(TrajLen).accel_vert = ((flight_profile.trajectory(TrajLen + 1).vs - flight_profile.trajectory(TrajLen).vs) / flight_profile.trajectory(TrajLen).EET);
    flight_profile.trajectory(TrajLen).max_accel_vert = ((flight_profile.trajectory(TrajLen + 1).vs - flight_profile.trajectory(TrajLen).vs) / flight_profile.trajectory(TrajLen).accel_time);
    
    flight_profile.trajectory(TrajLen).accel_normal = sqrt((flight_profile.trajectory(TrajLen).accel_long)^2 + (flight_profile.trajectory(TrajLen).accel_vert)^2);
    flight_profile.trajectory(TrajLen).max_accel_normal = sqrt((flight_profile.trajectory(TrajLen).max_accel_long)^2 + (flight_profile.trajectory(TrajLen).max_accel_vert)^2);

    
    
end




end