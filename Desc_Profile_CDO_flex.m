%% CDO_flex Profile

function [flight_profile, alt_fix] = Desc_Profile_CDO_flex(flight_profile, alt_fix, acc_fix, ArrFE, Cr_alt)

global plan unit Perf



TOD = 0;
RTS = 0;
TDZ = 0;
% BADA에서 가져온 기본 최대 고도
Alt_max = Perf.(flight_profile.type).MaxAlt;
for m = 1:length(flight_profile.trajectory)
    flight_profile.trajectory(m).highalt = min(flight_profile.trajectory(m).highalt, Alt_max);
    flight_profile.trajectory(m).lowalt = max(flight_profile.trajectory(m).lowalt, 0);
end


if ~isempty(find(strcmp({flight_profile.trajectory.type}, 'INST') == 1, 1));
    % Initial Approach Fix
    IAF = find(strcmp({flight_profile.trajectory.type}, 'INST') ==1, 1 ) - 1;
    % Touch Down Zone
    GND = cellfun(@(x) x==ArrFE, {flight_profile.trajectory.alt}, 'UniformOutput', false);
    TDZ=[];
    for GND_len = IAF:length(GND)
        if GND{GND_len} == 1;
            TDZ = [TDZ GND_len];
        end
    end
    TDZ = min(TDZ);

    if isempty(find([alt_fix] == TDZ, 1))
        alt_fix = [alt_fix TDZ];
    end
    

    
    if isempty(find(strcmp({flight_profile.trajectory.type}, 'STAR') == 1, 1));
        % INST only
        status = 0;

        if ~isempty(find(strcmp({flight_profile.trajectory.type}, 'route') == 1, 1));
            RTS = 0;
            RTE = find(strcmp({flight_profile.trajectory.type}, 'route') ==1, 1 ) - 1;
        elseif ~isempty(find(strcmp({flight_profile.trajectory.type}, 'vector') == 1, 1));
            RTS = 0;
            RTE = find(strcmp({flight_profile.trajectory.type}, 'vector') ==1, 1 ) - 1;
        end
        
    else
        % STAR & INST
        status = 1;
        RTE = find(strcmp({flight_profile.trajectory.type}, 'STAR') ==1, 1 ) - 1;
        % route 있는지 확인
        if ~isempty(find(strcmp({flight_profile.trajectory.type}, 'route') == 1, 1));
            RTS = find(strcmp({flight_profile.trajectory.type}, 'route') ==1, 1 );
        else
            RTS = 0;
        end
    end
else
    % No Landing Trajectory
    status = 2;
end



rate_of_descend = tan(deg2rad(plan(flight_profile.id).desc_angle)) * unit.nm2meter / unit.ft2meter;
fix_alt = alt_fix;
fix_acc = acc_fix;

switch status
    case 0
        fix_alt(fix_alt < IAF) = [];
        fix_alt = sort([fix_alt IAF]);
        
    case 1
        if isempty(flight_profile.trajectory(RTE).alt)
            if RTS >= 1;
                fix_alt(fix_alt < RTS) = [];
                flight_profile.trajectory(RTS).alt = Cr_alt;
                fix_alt = sort([fix_alt RTS]);
            end
        elseif flight_profile.trajectory(RTE).alt < Cr_alt;
            if RTS >= 1;
                fix_alt(fix_alt < RTS) = [];
                flight_profile.trajectory(RTS).alt = Cr_alt;
                fix_alt = sort([fix_alt RTS]);
            end
        else
            alt_fix(alt_fix < RTE) = [];
        end
end

if TDZ == 0
    fix_alt = (length(flight_profile.trajectory) - 1) - fix_alt;
else
    fix_alt = TDZ - fix_alt;
end

% Top of Descend, alt assign
finish = false;
loop = 0;

while finish == false;

    do_again = false;
    if ~isempty(find(strcmp({flight_profile.trajectory.type}, 'INST') == 1, 1));
        
        if length(fix_alt) >= 3;
            for seg = 1:length(fix_alt) - 2
                seg_st = fix_alt(length(fix_alt)- seg + 1) + 1;
                seg_en = fix_alt(length(fix_alt)- seg) - 1;
                tot_dist = 0;
                for m = seg_st:seg_en + 1
                    tot_dist = tot_dist + flight_profile.trajectory(TDZ - m).distance;
                end

                seg_rate = (flight_profile.trajectory(TDZ - seg_en - 1).alt - flight_profile.trajectory(TDZ - seg_st + 1).alt) / tot_dist;

                for m = seg_st:seg_en
                    if do_again == false
                        
                        if ~isempty(fix_acc)
                            if ~isempty(find(fix_acc(1) == (TDZ - m), 1))
                                % 여기서 acc_fix가 들어가자
                                LOC = find(fix_acc(1) == (TDZ - m), 1);
                                % acc_fix(1)은 해당 fix 위치, acc_fix(2)는 사유: 0-long, 1-normal, 2-long&normal
                                switch  fix_acc(2,LOC)
                                    case 0
                                        % Longitudinal acceleration이 걸린 경우: max값은 2 ft/s^2
                                        % Alt Assign에는 해당 없음 pass.
                                    case {1, 2}
                                        old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory((TDZ - m)).wp_name));

                                        if flight_profile.old_trajectory(old_ref).max_accel_vert >= 0
                                            limit = 0.9 * sqrt(21);
                                            direction = 1;
                                        elseif flight_profile.old_trajectory(old_ref).max_accel_vert < 0
                                            limit = -0.9 * sqrt(21);
                                            direction = -1;
                                        end
                                        
                                        % Normal acceleration이 걸린 경우: max값은 5 ft/s^2
                                        if isempty(find(fix_alt == (TDZ - m), 1));
                                            % 이건 acc_fix에 해당하는 alt_fix 잡히지 않은 경우
                                            % 우선 accel 여유분을 배정할 수 있는segment를 찾아보자
                                            forward_break = true;
                                            backward_break = true;
                                            
                                            forward = 0;
                                            backward = 0;
                                            while or(forward_break, backward_break)
                                                if forward_break
                                                    if ((TDZ - m) - (forward + 1)) < 1
                                                        forward_break = false;
                                                    else
                                                        if isempty(find(fix_alt == ((TDZ - m) - (forward + 1)), 1))
                                                            forward = forward + 1;
                                                        else
                                                            forward_break = false;
                                                        end
                                                    end
                                                end
                                                if backward_break
                                                    if ((TDZ - m) + (backward + 1)) > length(flight_profile.trajectory)
                                                        backward_break = false;
                                                    else
                                                        if isempty(find(fix_alt == ((TDZ - m) + (backward + 1)), 1))
                                                            backward = backward + 1;
                                                        else
                                                            backward_break = false;
                                                        end
                                                    end
                                                end
                                            end
                                            Decision = 0;
                                            
                                            for forward_accel = 1:forward
                                                old_ref = strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory((TDZ - m) - forward_accel).wp_name);
                                                Decision = Decision + (direction * (limit - flight_profile.old_trajectory(old_ref).max_accel_vert));
                                            end
                                            for  backward_accel = 1:backward
                                                old_ref = strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory((TDZ - m) + backward_accel).wp_name);
                                                Decision = Decision + (direction * (limit - flight_profile.old_trajectory(old_ref).max_accel_vert));
                                            end
                                        else
                                            backward_break = true;
                                            backward = 0;
                                            % 이건 acc_fix에 해당하는 spd_fix 잡힌 경우 ->뒤만 가능
                                            while backward_break
                                                if backward_break
                                                    if ((TDZ - m) + (backward + 1)) > length(flight_profile.trajectory)
                                                        backward_break = false;
                                                    else
                                                        if isempty(find(fix_alt == ((TDZ - m) + (backward + 1)), 1))
                                                            backward = backward + 1;
                                                        else
                                                            backward_break = false;
                                                        end
                                                    end
                                                end
                                            end
                                            for  backward_accel = 1:backward
                                                old_ref = strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory((TDZ - m) + backward_accel).wp_name);
                                                Decision = Decision + (direction * (limit - flight_profile.old_trajectory(old_ref).max_accel_vert));
                                            end
                                        end
                                        if Decision > 0
                                            step_dir = 1;
                                        else
                                            step_dir = -1;
                                        end
                                        
                                        notenough = true;
                                        step_for = 0;
                                        step_bac = 0;
                                        old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory((TDZ - m)).wp_name));
                                        exceeded = flight_profile.old_trajectory(old_ref).max_accel_vert * flight_profile.old_trajectory(old_ref).accel_time;
                                        time = flight_profile.old_trajectory(old_ref).accel_time;
                                        capacity = limit * time;
                                        new_accel_vert = flight_profile.old_trajectory(old_ref).max_accel_vert;
                                        
                                        while notenough
                                            if step_dir == 1
                                                if abs(exceeded) > abs(capacity)
                                                    if step_for == forward
                                                        step_dir = -1;
                                                    else
                                                        step_for = step_for + 1;
                                                        old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory((TDZ - m) - step_for).wp_name));
                                                        exceeded = exceeded + flight_profile.old_trajectory(old_ref).max_accel_vert * flight_profile.old_trajectory(old_ref).accel_time;
                                                        time = time + flight_profile.old_trajectory(old_ref).accel_time;
                                                        new_accel_vert = exceeded / time;
                                                        capacity = limit * time;
                                                        step_dir = -1;
                                                    end
                                                else notenough = false;
                                                end
                                            else
                                                if abs(exceeded) > abs(capacity)
                                                    if step_bac == backward
                                                        step_dir = 1;
                                                    else
                                                        step_bac = step_bac + 1;
                                                        old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory((TDZ - m) + step_bac).wp_name));
                                                        exceeded = exceeded + flight_profile.old_trajectory(old_ref).max_accel_vert * flight_profile.old_trajectory(old_ref).accel_time;
                                                        time = time + flight_profile.old_trajectory(old_ref).accel_time;
                                                        new_accel_vert = exceeded / time;
                                                        capacity = limit * time;
                                                        step_dir = 1;
                                                    end
                                                else notenough = false;
                                                end
                                            end
                                            if and(step_for == forward, step_bac == backward)
                                                if abs(exceeded) > abs(capacity)
                                                    ['warning! flight #' num2str(flight_profile.id) 'cannot satisfy acceleration condition, required:' num2str(exceeded) ' capacity:' num2str(capacity)]
                                                    notenough = false;
                                                else
                                                    notenough = false;
                                                end
                                            end
                                        end
                                        old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory((TDZ - m) - step_for).wp_name));
                                        StartAlt = flight_profile.old_trajectory(old_ref).alt;
                                        
                                        
                                        for acc_Traj = (TDZ - m) - step_for : (TDZ - m) + step_bac
                                            if acc_Traj == (TDZ - m) - step_for
                                                old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(acc_Traj).wp_name));
                                                if round(StartAlt + (flight_profile.old_trajectory(old_ref).accel_time * new_accel_vert)) <= Cr_alt
                                                    flight_profile.trajectory(acc_Traj + 1).alt = round(StartAlt + (flight_profile.old_trajectory(old_ref).accel_time * new_accel_vert));
                                                    TOD = TDZ - m;
                                                else
                                                    % TOD를 새로 만들어야 하는 경우
                                                    TRAJ_LEN = length(flight_profile.trajectory);
                                                    if TOD == 0
                                                        TOD = TDZ - m + 1;
                                                    end
                                                    for afterTOD = 0:TRAJ_LEN - TOD
                                                        flight_profile.trajectory(TRAJ_LEN - afterTOD + 1) = flight_profile.trajectory(TRAJ_LEN - afterTOD);
                                                        flight_profile.trajectory(TRAJ_LEN - afterTOD + 1).TRAJ_num = TRAJ_LEN - afterTOD + 1;
                                                    end
                                                    
                                                    flight_profile.trajectory(TOD).wp_name = 'TOD';
                                                    flight_profile.trajectory(TOD).alt = Cr_alt;
                                                    flight_profile.trajectory(TOD).id = '';
                                                    
                                                    flight_profile.trajectory(TOD).lowalt = flight_profile.trajectory(TOD).alt;
                                                    flight_profile.trajectory(TOD).highalt = flight_profile.trajectory(TOD).alt;
                                                    
                                                    TOD_relative = (Cr_alt - flight_profile.trajectory(TOD + 1).alt) / (rate_of_descend * flight_profile.trajectory(TOD - 1).distance);
                                                    TOD_distance = flight_profile.trajectory(TOD - 1).distance - (TOD_relative * flight_profile.trajectory(TOD - 1).distance);
                                                    
                                                    [flight_profile.trajectory(TOD).lat, flight_profile.trajectory(TOD).long] = reckon(flight_profile.trajectory(TOD - 1).lat, flight_profile.trajectory(TOD - 1).long, nm2deg(TOD_distance), flight_profile.trajectory(TOD - 1).heading);
                                                    
                                                    [dist_rec, head_rec] = distance(flight_profile.trajectory(TOD - 1).lat, flight_profile.trajectory(TOD - 1).long, flight_profile.trajectory(TOD).lat, flight_profile.trajectory(TOD).long);
                                                    flight_profile.trajectory(TOD - 1).distance = deg2nm(dist_rec);
                                                    flight_profile.trajectory(TOD - 1).heading = head_rec;
                                                    
                                                    [dist_rec, head_rec] = distance(flight_profile.trajectory(TOD).lat, flight_profile.trajectory(TOD).long, flight_profile.trajectory(TOD + 1).lat, flight_profile.trajectory(TOD + 1).long);
                                                    flight_profile.trajectory(TOD).distance = deg2nm(dist_rec);
                                                    flight_profile.trajectory(TOD).heading = head_rec;
                                                    
                                                    
                                                    if ~isempty(flight_profile.FalseFix)
                                                        for FF = 1:length(flight_profile.FalseFix)
                                                            if flight_profile.FalseFix(FF) >= TOD
                                                                flight_profile.FalseFix(FF) =  flight_profile.FalseFix(FF) + 1;
                                                            end
                                                        end
                                                    end
                                                    flight_profile.FalseFix = [TOD flight_profile.FalseFix];
                                                    
                                                    % alt_fix 한칸씩 뒤로 밀기
                                                    for fixLen = 1:length(alt_fix)
                                                        if alt_fix(fixLen) >= TOD
                                                            alt_fix(fixLen) =  alt_fix(fixLen) + 1;
                                                        end
                                                    end
                                                    %                         flight_profile.trajectory(TOD).alt = Cr_alt;
                                                    if RTS ~= 0
                                                        if TOD > RTS
                                                            flight_profile.trajectory(RTS).alt = [];
                                                        end
                                                    end
                                                end
                                            else
                                                old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(acc_Traj).wp_name));
                                                if round(flight_profile.trajectory(acc_Traj).alt + (flight_profile.old_trajectory(old_ref).accel_time * new_accel_vert)) <= Cr_alt
                                                    
                                                    flight_profile.trajectory(acc_Traj + 1).alt = round(flight_profile.trajectory(acc_Traj).alt + (flight_profile.old_trajectory(old_ref).accel_time * new_accel_vert));
                                                    TOD = TDZ - m;
                                                else
                                                    % TOD를 새로 만들어야 하는 경우
                                                    TRAJ_LEN = length(flight_profile.trajectory);
                                                    if TOD == 0
                                                        TOD = TDZ - m + 1;
                                                    end
                                                    for afterTOD = 0:TRAJ_LEN - TOD
                                                        flight_profile.trajectory(TRAJ_LEN - afterTOD + 1) = flight_profile.trajectory(TRAJ_LEN - afterTOD);
                                                        flight_profile.trajectory(TRAJ_LEN - afterTOD + 1).TRAJ_num = TRAJ_LEN - afterTOD + 1;
                                                    end
                                                    
                                                    flight_profile.trajectory(TOD).wp_name = 'TOD';
                                                    flight_profile.trajectory(TOD).alt = Cr_alt;
                                                    flight_profile.trajectory(TOD).id = '';
                                                    
                                                    flight_profile.trajectory(TOD).lowalt = flight_profile.trajectory(TOD).alt;
                                                    flight_profile.trajectory(TOD).highalt = flight_profile.trajectory(TOD).alt;
                                                    
                                                    TOD_relative = (Cr_alt - flight_profile.trajectory(TOD + 1).alt) / (rate_of_descend * flight_profile.trajectory(TOD - 1).distance);
                                                    TOD_distance = flight_profile.trajectory(TOD - 1).distance - (TOD_relative * flight_profile.trajectory(TOD - 1).distance);
                                                    
                                                    [flight_profile.trajectory(TOD).lat, flight_profile.trajectory(TOD).long] = reckon(flight_profile.trajectory(TOD - 1).lat, flight_profile.trajectory(TOD - 1).long, nm2deg(TOD_distance), flight_profile.trajectory(TOD - 1).heading);
                                                    
                                                    [dist_rec, head_rec] = distance(flight_profile.trajectory(TOD - 1).lat, flight_profile.trajectory(TOD - 1).long, flight_profile.trajectory(TOD).lat, flight_profile.trajectory(TOD).long);
                                                    flight_profile.trajectory(TOD - 1).distance = deg2nm(dist_rec);
                                                    flight_profile.trajectory(TOD - 1).heading = head_rec;
                                                    
                                                    [dist_rec, head_rec] = distance(flight_profile.trajectory(TOD).lat, flight_profile.trajectory(TOD).long, flight_profile.trajectory(TOD + 1).lat, flight_profile.trajectory(TOD + 1).long);
                                                    flight_profile.trajectory(TOD).distance = deg2nm(dist_rec);
                                                    flight_profile.trajectory(TOD).heading = head_rec;
                                                    
                                                    
                                                    if ~isempty(flight_profile.FalseFix)
                                                        for FF = 1:length(flight_profile.FalseFix)
                                                            if flight_profile.FalseFix(FF) >= TOD
                                                                flight_profile.FalseFix(FF) =  flight_profile.FalseFix(FF) + 1;
                                                            end
                                                        end
                                                    end
                                                    flight_profile.FalseFix = [TOD flight_profile.FalseFix];
                                                    
                                                    % alt_fix 한칸씩 뒤로 밀기
                                                    for fixLen = 1:length(alt_fix)
                                                        if alt_fix(fixLen) >= TOD
                                                            alt_fix(fixLen) =  alt_fix(fixLen) + 1;
                                                        end
                                                    end
                                                    %                         flight_profile.trajectory(TOD).alt = Cr_alt;
                                                    if RTS ~= 0
                                                        if TOD > RTS
                                                            flight_profile.trajectory(RTS).alt = [];
                                                        end
                                                    end
                                                end
                                            end
                                            fix_alt = sort([fix_alt (acc_Traj + 1)]);
                                            do_again = true;
                                        end
                                        
                                end
                            end
                        end
                        
                        flight_profile.trajectory(TDZ - m).alt = round(flight_profile.trajectory(TDZ - m + 1).alt + (seg_rate * flight_profile.trajectory(TDZ - m).distance));
                        if seg_rate == 0
                            fix_alt = sort([fix_alt m],'descend');
                            do_again = true;
                        end
                        

                        % constraint 침범 시
                        if flight_profile.trajectory(TDZ - m).alt < flight_profile.trajectory(TDZ - m).lowalt
                            ['flight #' num2str(flight_profile.id) ' trajectory #' num2str(TDZ - m) ' initial assigned alt(' num2str(flight_profile.trajectory(TDZ - m).alt) ') has violated low altitude constraint (' num2str(flight_profile.trajectory(TDZ - m).lowalt) ') adding constraint & calculating again...']
                            
                            flight_profile.trajectory(TDZ - m).alt = flight_profile.trajectory(TDZ - m).lowalt;
%                             flight_profile.trajectory(TDZ - m).highalt = flight_profile.trajectory(TDZ - m).alt;
                            fix_alt = sort([fix_alt m],'descend');
                            do_again = true;
                        end
                        if flight_profile.trajectory(TDZ - m).alt > flight_profile.trajectory(TDZ - m).highalt
                            ['flight #' num2str(flight_profile.id) ' trajectory #' num2str(TDZ - m) ' initial assigned alt(' num2str(flight_profile.trajectory(TDZ - m).alt) ') has violated high altitude constraint (' num2str(flight_profile.trajectory(TDZ - m).highalt) ') adding constraint & calculating again...']
                            
                            flight_profile.trajectory(TDZ - m).alt = flight_profile.trajectory(TDZ - m).highalt;
%                             flight_profile.trajectory(TDZ - m).lowalt = flight_profile.trajectory(TDZ - m).alt;
                            fix_alt = sort([fix_alt m],'descend');
                            do_again = true;
                        end
                    end
                end
            end
        end
        
        % 여기서부턴 3도로 올리자
        seg = length(fix_alt) - 1;
        seg_st = fix_alt(length(fix_alt)- seg + 1) + 1;
        seg_en = fix_alt(length(fix_alt)- seg) - 1;
        
        for m = seg_st:seg_en
            if do_again == false;
                if status == 1;
                    
                    
                    if ~isempty(fix_acc)
                        if ~isempty(find(fix_acc(1) == (TDZ - m), 1))
                            % 여기서 acc_fix가 들어가자
                            LOC = find(fix_acc(1) == (TDZ - m), 1);
                            % acc_fix(1)은 해당 fix 위치, acc_fix(2)는 사유: 0-long, 1-normal, 2-long&normal
                            
                            switch  fix_acc(2,LOC)
                                case 0
                                    % Longitudinal acceleration이 걸린 경우: max값은 2 ft/s^2
                                    % Alt Assign에는 해당 없음 pass.
                                case {1, 2}
                                    % Normal acceleration이 걸린 경우: max값은 5 ft/s^2
                                    old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory((TDZ - m)).wp_name));
                  
                                        if flight_profile.old_trajectory(old_ref).max_accel_vert >= 0
                                            limit = 0.9 * sqrt(21);
                                            direction = 1;
                                        elseif flight_profile.old_trajectory(old_ref).max_accel_vert < 0
                                            limit = -0.9 * sqrt(21);
                                            direction = -1;
                                        end
                                        
                                        % Normal acceleration이 걸린 경우: max값은 5 ft/s^2
                                        if isempty(find(fix_alt == (TDZ - m), 1));
                                            % 이건 acc_fix에 해당하는 alt_fix 잡히지 않은 경우
                                            % 우선 accel 여유분을 배정할 수 있는segment를 찾아보자
                                            forward_break = true;
                                            backward_break = true;
                                            
                                            forward = 0;
                                            backward = 0;
                                            while or(forward_break, backward_break)
                                                if forward_break
                                                    if ((TDZ - m) - (forward + 1)) < 1
                                                        forward_break = false;
                                                    else
                                                        if isempty(find(fix_alt == ((TDZ - m) - (forward + 1)), 1))
                                                            forward = forward + 1;
                                                        else
                                                            forward_break = false;
                                                        end
                                                    end
                                                end
                                                if backward_break
                                                    if ((TDZ - m) + (backward + 1)) > length(flight_profile.trajectory)
                                                        backward_break = false;
                                                    else
                                                        if isempty(find(fix_alt == ((TDZ - m) + (backward + 1)), 1))
                                                            backward = backward + 1;
                                                        else
                                                            backward_break = false;
                                                        end
                                                    end
                                                end
                                            end
                                            Decision = 0;
                                            
                                            for forward_accel = 1:forward
                                                old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory((TDZ - m) - forward_accel).wp_name));
                                                Decision = Decision + (direction * (limit - flight_profile.old_trajectory(old_ref).max_accel_vert));
                                            end
                                            for  backward_accel = 1:backward
                                                old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory((TDZ - m) + backward_accel).wp_name));
                                                Decision = Decision + (direction * (limit - flight_profile.old_trajectory(old_ref).max_accel_vert));
                                            end
                                        else
                                            backward_break = true;
                                            backward = 0;
                                            % 이건 acc_fix에 해당하는 spd_fix 잡힌 경우 ->뒤만 가능
                                            while backward_break
                                                if backward_break
                                                    if ((TDZ - m) + (backward + 1)) > length(flight_profile.trajectory)
                                                        backward_break = false;
                                                    else
                                                        if isempty(find(fix_alt == ((TDZ - m) + (backward + 1)), 1))
                                                            backward = backward + 1;
                                                        else
                                                            backward_break = false;
                                                        end
                                                    end
                                                end
                                            end
                                            for  backward_accel = 1:backward
                                                old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory((TDZ - m) + backward_accel).wp_name));
                                                Decision = Decision + (direction * (limit - flight_profile.old_trajectory(old_ref).max_accel_vert));
                                            end
                                        end
                                        if Decision > 0
                                            step_dir = 1;
                                        else
                                            step_dir = -1;
                                        end
                                        
                                        notenough = true;
                                        step_for = 0;
                                        step_bac = 0;
                                        old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory((TDZ - m)).wp_name));
                                        exceeded = flight_profile.old_trajectory(old_ref).max_accel_vert * flight_profile.old_trajectory(old_ref).accel_time;
                                        time = flight_profile.old_trajectory(old_ref).accel_time;
                                        capacity = limit * time;
                                        new_accel_vert = flight_profile.old_trajectory(old_ref).max_accel_vert;
                                        
                                        while notenough
                                            if step_dir == 1
                                                if abs(exceeded) > abs(capacity)
                                                    if step_for == forward
                                                        step_dir = -1;
                                                    else
                                                        step_for = step_for + 1;
                                                        old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory((TDZ - m) - step_for).wp_name));
                                                        exceeded = exceeded + flight_profile.old_trajectory(old_ref).max_accel_vert * flight_profile.old_trajectory(old_ref).accel_time;
                                                        time = time + flight_profile.old_trajectory(old_ref).accel_time;
                                                        new_accel_vert = exceeded / time;
                                                        capacity = limit * time;
                                                        step_dir = -1;
                                                    end
                                                else notenough = false;
                                                end
                                            else
                                                if abs(exceeded) > abs(capacity)
                                                    if step_bac == backward
                                                        step_dir = 1;
                                                    else
                                                        step_bac = step_bac + 1;
                                                        old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory((TDZ - m) + step_bac).wp_name));
                                                        exceeded = exceeded + flight_profile.old_trajectory(old_ref).max_accel_vert * flight_profile.old_trajectory(old_ref).accel_time;
                                                        time = time + flight_profile.old_trajectory(old_ref).accel_time;
                                                        new_accel_vert = exceeded / time;
                                                        capacity = limit * time;
                                                        step_dir = 1;
                                                    end
                                                else notenough = false;
                                                end
                                            end
                                            if and(step_for == forward, step_bac == backward)
                                                if abs(exceeded) > abs(capacity)
                                                    ['warning! flight #' num2str(flight_profile.id) 'cannot satisfy acceleration condition, required:' num2str(exceeded) ' capacity:' num2str(capacity)]
                                                    notenough = false;
                                                else
                                                    notenough = false;
                                                end
                                            end
                                        end
                                        old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory((TDZ - m) - step_for).wp_name));

                                        StartAlt = flight_profile.old_trajectory(old_ref).alt;
                                        
                                        
                                        for acc_Traj = (TDZ - m) - step_for : (TDZ - m) + step_bac
                                            if acc_Traj == (TDZ - m) - step_for
                                                old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(acc_Traj).wp_name));
                                                if round(StartAlt + (flight_profile.old_trajectory(old_ref).accel_time * new_accel_vert)) <= Cr_alt
                                                    flight_profile.trajectory(acc_Traj + 1).alt = round(StartAlt + (flight_profile.old_trajectory(old_ref).accel_time * new_accel_vert));
                                                    TOD = TDZ - m;
                                                else
                                                    % TOD를 새로 만들어야 하는 경우
                                                    TRAJ_LEN = length(flight_profile.trajectory);
                                                    if TOD == 0
                                                        TOD = TDZ - m + 1;
                                                    end
                                                    for afterTOD = 0:TRAJ_LEN - TOD
                                                        flight_profile.trajectory(TRAJ_LEN - afterTOD + 1) = flight_profile.trajectory(TRAJ_LEN - afterTOD);
                                                        flight_profile.trajectory(TRAJ_LEN - afterTOD + 1).TRAJ_num = TRAJ_LEN - afterTOD + 1;
                                                    end
                                                    
                                                    flight_profile.trajectory(TOD).wp_name = 'TOD';
                                                    flight_profile.trajectory(TOD).alt = Cr_alt;
                                                    flight_profile.trajectory(TOD).id = '';
                                                    
                                                    flight_profile.trajectory(TOD).lowalt = flight_profile.trajectory(TOD).alt;
                                                    flight_profile.trajectory(TOD).highalt = flight_profile.trajectory(TOD).alt;
                                                    
                                                    TOD_relative = (Cr_alt - flight_profile.trajectory(TOD + 1).alt) / (rate_of_descend * flight_profile.trajectory(TOD - 1).distance);
                                                    TOD_distance = flight_profile.trajectory(TOD - 1).distance - (TOD_relative * flight_profile.trajectory(TOD - 1).distance);
                                                    
                                                    [flight_profile.trajectory(TOD).lat, flight_profile.trajectory(TOD).long] = reckon(flight_profile.trajectory(TOD - 1).lat, flight_profile.trajectory(TOD - 1).long, nm2deg(TOD_distance), flight_profile.trajectory(TOD - 1).heading);
                                                    
                                                    [dist_rec, head_rec] = distance(flight_profile.trajectory(TOD - 1).lat, flight_profile.trajectory(TOD - 1).long, flight_profile.trajectory(TOD).lat, flight_profile.trajectory(TOD).long);
                                                    flight_profile.trajectory(TOD - 1).distance = deg2nm(dist_rec);
                                                    flight_profile.trajectory(TOD - 1).heading = head_rec;
                                                    
                                                    [dist_rec, head_rec] = distance(flight_profile.trajectory(TOD).lat, flight_profile.trajectory(TOD).long, flight_profile.trajectory(TOD + 1).lat, flight_profile.trajectory(TOD + 1).long);
                                                    flight_profile.trajectory(TOD).distance = deg2nm(dist_rec);
                                                    flight_profile.trajectory(TOD).heading = head_rec;
                                                    
                                                    
                                                    if ~isempty(flight_profile.FalseFix)
                                                        for FF = 1:length(flight_profile.FalseFix)
                                                            if flight_profile.FalseFix(FF) >= TOD
                                                                flight_profile.FalseFix(FF) =  flight_profile.FalseFix(FF) + 1;
                                                            end
                                                        end
                                                    end
                                                    flight_profile.FalseFix = [TOD flight_profile.FalseFix];
                                                    
                                                    % alt_fix 한칸씩 뒤로 밀기
                                                    for fixLen = 1:length(alt_fix)
                                                        if alt_fix(fixLen) >= TOD
                                                            alt_fix(fixLen) =  alt_fix(fixLen) + 1;
                                                        end
                                                    end
                                                    %                         flight_profile.trajectory(TOD).alt = Cr_alt;
                                                    if RTS ~= 0
                                                        if TOD > RTS
                                                            flight_profile.trajectory(RTS).alt = [];
                                                        end
                                                    end
                                                end
                                            else
                                                old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(acc_Traj).wp_name));
                                                if round(flight_profile.trajectory(acc_Traj).alt + (flight_profile.old_trajectory(old_ref).accel_time * new_accel_vert)) <= Cr_alt
                                                    flight_profile.trajectory(acc_Traj + 1).alt = round(flight_profile.trajectory(acc_Traj).alt + (flight_profile.old_trajectory(old_ref).accel_time * new_accel_vert));
                                                    TOD = TDZ - m;
                                                else
                                                    TRAJ_LEN = length(flight_profile.trajectory);
                                                    if TOD == 0
                                                        TOD = TDZ - m + 1;
                                                    end
                                                    for afterTOD = 0:TRAJ_LEN - TOD
                                                        flight_profile.trajectory(TRAJ_LEN - afterTOD + 1) = flight_profile.trajectory(TRAJ_LEN - afterTOD);
                                                        flight_profile.trajectory(TRAJ_LEN - afterTOD + 1).TRAJ_num = TRAJ_LEN - afterTOD + 1;
                                                    end
                                                    
                                                    flight_profile.trajectory(TOD).wp_name = 'TOD';
                                                    flight_profile.trajectory(TOD).alt = Cr_alt;
                                                    flight_profile.trajectory(TOD).id = '';
                                                    
                                                    flight_profile.trajectory(TOD).lowalt = flight_profile.trajectory(TOD).alt;
                                                    flight_profile.trajectory(TOD).highalt = flight_profile.trajectory(TOD).alt;
                                                    
                                                    TOD_relative = (Cr_alt - flight_profile.trajectory(TOD + 1).alt) / (rate_of_descend * flight_profile.trajectory(TOD - 1).distance);
                                                    TOD_distance = flight_profile.trajectory(TOD - 1).distance - (TOD_relative * flight_profile.trajectory(TOD - 1).distance);
                                                    
                                                    [flight_profile.trajectory(TOD).lat, flight_profile.trajectory(TOD).long] = reckon(flight_profile.trajectory(TOD - 1).lat, flight_profile.trajectory(TOD - 1).long, nm2deg(TOD_distance), flight_profile.trajectory(TOD - 1).heading);
                                                    
                                                    [dist_rec, head_rec] = distance(flight_profile.trajectory(TOD - 1).lat, flight_profile.trajectory(TOD - 1).long, flight_profile.trajectory(TOD).lat, flight_profile.trajectory(TOD).long);
                                                    flight_profile.trajectory(TOD - 1).distance = deg2nm(dist_rec);
                                                    flight_profile.trajectory(TOD - 1).heading = head_rec;
                                                    
                                                    [dist_rec, head_rec] = distance(flight_profile.trajectory(TOD).lat, flight_profile.trajectory(TOD).long, flight_profile.trajectory(TOD + 1).lat, flight_profile.trajectory(TOD + 1).long);
                                                    flight_profile.trajectory(TOD).distance = deg2nm(dist_rec);
                                                    flight_profile.trajectory(TOD).heading = head_rec;
                                                    
                                                    
                                                    if ~isempty(flight_profile.FalseFix)
                                                        for FF = 1:length(flight_profile.FalseFix)
                                                            if flight_profile.FalseFix(FF) >= TOD
                                                                flight_profile.FalseFix(FF) =  flight_profile.FalseFix(FF) + 1;
                                                            end
                                                        end
                                                    end
                                                    flight_profile.FalseFix = [TOD flight_profile.FalseFix];
                                                    
                                                    % alt_fix 한칸씩 뒤로 밀기
                                                    for fixLen = 1:length(alt_fix)
                                                        if alt_fix(fixLen) >= TOD
                                                            alt_fix(fixLen) =  alt_fix(fixLen) + 1;
                                                        end
                                                    end
                                                    %                         flight_profile.trajectory(TOD).alt = Cr_alt;
                                                    if RTS ~= 0
                                                        if TOD > RTS
                                                            flight_profile.trajectory(RTS).alt = [];
                                                        end
                                                    end
                                                end
                                            end
                                            fix_alt = sort([fix_alt (acc_Traj + 1)]);
                                            do_again = true;
                                        end
                                        
                            end
                        end
                    end
                    
                    
                    
                    if flight_profile.trajectory(TDZ - m + 1).alt + round((rate_of_descend * flight_profile.trajectory(TDZ - m).distance)) <= Cr_alt
                        
                        flight_profile.trajectory(TDZ - m).alt = round(flight_profile.trajectory(TDZ - m + 1).alt + (rate_of_descend * flight_profile.trajectory(TDZ - m).distance));
                        
                        TOD = TDZ - m;
                        % constraint 침범 시
                        if flight_profile.trajectory(TDZ - m).alt < flight_profile.trajectory(TDZ - m).lowalt
                            ['flight #' num2str(flight_profile.id) ' trajectory #' num2str(TDZ - m) ' initial assigned alt(' num2str(flight_profile.trajectory(TDZ - m).alt) ') has violated low altitude constraint (' num2str(flight_profile.trajectory(TDZ - m).lowalt) ') adding constraint & calculating again...']
                            
                            flight_profile.trajectory(TDZ - m).alt = flight_profile.trajectory(TDZ - m).lowalt;
%                             flight_profile.trajectory(TDZ - m).highalt = flight_profile.trajectory(TDZ - m).alt;
                            fix_alt = sort([fix_alt m],'descend');
                            do_again = true;
                        end
                        if flight_profile.trajectory(TDZ - m).alt > flight_profile.trajectory(TDZ - m).highalt
                            ['flight #' num2str(flight_profile.id) ' trajectory #' num2str(TDZ - m) ' initial assigned alt(' num2str(flight_profile.trajectory(TDZ - m).alt) ') has violated high altitude constraint (' num2str(flight_profile.trajectory(TDZ - m).highalt) ') adding constraint & calculating again...']
                            
                            flight_profile.trajectory(TDZ - m).alt = flight_profile.trajectory(TDZ - m).highalt;
%                             flight_profile.trajectory(TDZ - m).lowalt = flight_profile.trajectory(TDZ - m).alt;
                            fix_alt = sort([fix_alt m],'descend');
                            do_again = true;
                        end
                        
                    else
                        % TOD를 새로 만들어야 하는 경우
                        
                        TRAJ_LEN = length(flight_profile.trajectory);
                        if TOD == 0
                           TOD = TDZ - m + 1; 
                        end
                        for afterTOD = 0:TRAJ_LEN - TOD
                            flight_profile.trajectory(TRAJ_LEN - afterTOD + 1) = flight_profile.trajectory(TRAJ_LEN - afterTOD);
                            flight_profile.trajectory(TRAJ_LEN - afterTOD + 1).TRAJ_num = TRAJ_LEN - afterTOD + 1;
                        end

                        flight_profile.trajectory(TOD).wp_name = 'TOD';
                        flight_profile.trajectory(TOD).alt = Cr_alt;
                        flight_profile.trajectory(TOD).id = '';
                        
                        flight_profile.trajectory(TOD).lowalt = flight_profile.trajectory(TOD).alt;
                        flight_profile.trajectory(TOD).highalt = flight_profile.trajectory(TOD).alt;

                        TOD_relative = (Cr_alt - flight_profile.trajectory(TOD + 1).alt) / (rate_of_descend * flight_profile.trajectory(TOD - 1).distance);
                        TOD_distance = flight_profile.trajectory(TOD - 1).distance - (TOD_relative * flight_profile.trajectory(TOD - 1).distance);

                        [flight_profile.trajectory(TOD).lat, flight_profile.trajectory(TOD).long] = reckon(flight_profile.trajectory(TOD - 1).lat, flight_profile.trajectory(TOD - 1).long, nm2deg(TOD_distance), flight_profile.trajectory(TOD - 1).heading);
                        
                        [dist_rec, head_rec] = distance(flight_profile.trajectory(TOD - 1).lat, flight_profile.trajectory(TOD - 1).long, flight_profile.trajectory(TOD).lat, flight_profile.trajectory(TOD).long);
                        flight_profile.trajectory(TOD - 1).distance = deg2nm(dist_rec);
                        flight_profile.trajectory(TOD - 1).heading = head_rec;
                        
                        [dist_rec, head_rec] = distance(flight_profile.trajectory(TOD).lat, flight_profile.trajectory(TOD).long, flight_profile.trajectory(TOD + 1).lat, flight_profile.trajectory(TOD + 1).long);
                        flight_profile.trajectory(TOD).distance = deg2nm(dist_rec);
                        flight_profile.trajectory(TOD).heading = head_rec;   
                        
                        
                        if ~isempty(flight_profile.FalseFix)
                            for FF = 1:length(flight_profile.FalseFix)
                                if flight_profile.FalseFix(FF) >= TOD
                                    flight_profile.FalseFix(FF) =  flight_profile.FalseFix(FF) + 1;
                                end
                            end
                        end
                        flight_profile.FalseFix = [TOD flight_profile.FalseFix];
                        
                        % alt_fix 한칸씩 뒤로 밀기
                        for fixLen = 1:length(alt_fix)
                            if alt_fix(fixLen) >= TOD
                                alt_fix(fixLen) =  alt_fix(fixLen) + 1;
                            end
                        end
                        

%                         flight_profile.trajectory(TOD).alt = Cr_alt;
                        if RTS ~= 0
                            if TOD > RTS
                                flight_profile.trajectory(RTS).alt = [];
                            end
                        end
                        
                        break
                        
                    end
                    if seg_rate == 0
                        fix_alt = sort([fix_alt m],'descend');
                        do_again = true;
                    end
                    
                elseif status == 0;
                    TOD = IAF;
                    
                    if flight_profile.trajectory(TDZ - m + 1).alt + round((rate_of_descend * flight_profile.trajectory(TDZ - m).distance)) < Cr_alt
                        flight_profile.trajectory(TDZ - m).alt = round(flight_profile.trajectory(TDZ - m + 1).alt + (rate_of_descend * flight_profile.trajectory(TDZ - m).distance));
                        
                        % constraint 침범 시
                        if flight_profile.trajectory(TDZ - m).alt < flight_profile.trajectory(TDZ - m).lowalt
                            ['flight #' num2str(flight_profile.id) ' trajectory #' num2str(TDZ - m) ' initial assigned alt(' num2str(flight_profile.trajectory(TDZ - m).alt) ') has violated low altitude constraint (' num2str(flight_profile.trajectory(TDZ - m).lowalt) ') adding constraint & calculating again...']
                            
                            flight_profile.trajectory(TDZ - m).alt = flight_profile.trajectory(TDZ - m).lowalt;
%                             flight_profile.trajectory(TDZ - m).highalt = flight_profile.trajectory(TDZ - m).alt;
                            fix_alt = sort([fix_alt m],'descend');
                            do_again = true;
                        end
                        if flight_profile.trajectory(TDZ - m).alt > flight_profile.trajectory(TDZ - m).highalt
                            ['flight #' num2str(flight_profile.id) ' trajectory #' num2str(TDZ - m) ' initial assigned alt(' num2str(flight_profile.trajectory(TDZ - m).alt) ') has violated high altitude constraint (' num2str(flight_profile.trajectory(TDZ - m).highalt) ') adding constraint & calculating again...']
                            
                            flight_profile.trajectory(TDZ - m).alt = flight_profile.trajectory(TDZ - m).highalt;
%                             flight_profile.trajectory(TDZ - m).lowalt = flight_profile.trajectory(TDZ - m).alt;
                            fix_alt = sort([fix_alt m],'descend');
                            do_again = true;
                        end
                    else
                        flight_profile.trajectory(TDZ - m).alt = Cr_alt;

                    end
                    
                    flight_profile.trajectory(TOD).alt = min(Cr_alt, round(flight_profile.trajectory(TOD + 1).alt + (rate_of_descend * flight_profile.trajectory(TOD).distance)));
                    
                end
            end
        end
        
       
%         if do_again == false;
%             if status == 1;
%                 for m = 1:TOD - 1
%                     if isempty(flight_profile.trajectory(m).alt)
%                         flight_profile.trajectory(m).alt = Cr_alt;
%                     end
%                 end
%             end
%         end
        


    else
        % INST가 포함 안 됬다면, 넘어가자
        finish = true;
        break
        
        
    end
   
    % altitude constraint가 fix의 숫자와 같을 때
    if length(fix_alt) == length(flight_profile.trajectory) - TOD
        ['warning! flight #' num2str(flight_profile.id) ' cannot be assigned Descend Profile (CDO_flex) due to altitude constraints']
        ['Breaking Altitude Assignment Procedure... Try Again with different profile']
        finish = true;
    end
    
    % 배정된 altitude와 constraint의 비교
    alt_check = 0;
    if do_again == false;
        for n = 0:(TDZ - TOD)


            if ~isempty(flight_profile.trajectory(TDZ - n - 1).distance)
                flight_profile.trajectory(TDZ - n - 1).vs = (flight_profile.trajectory(TDZ - n).alt - flight_profile.trajectory(TDZ - n - 1).alt) / flight_profile.trajectory(TDZ - n - 1).distance;
            end

            if and(flight_profile.trajectory(TDZ - n).alt <= flight_profile.trajectory(TDZ - n).highalt, flight_profile.trajectory(TDZ - n).alt >= flight_profile.trajectory(TDZ - n).lowalt);
                alt_check = alt_check + 1;
            end
        end
        
        % 모든 altitude가 okay 이면/
        if alt_check == (TDZ - TOD) + 1
            finish = true;
        end
        
    end

    if loop > 100
        finish = true;
    end
    
    loop = loop+1;
end



% if ~isempty(find(strcmp({flight_profile.trajectory.type}, 'vectoring') == 1, 1));
%     for m = find(strcmp({flight_profile.trajectory.type}, 'vectoring') == 1, 1 ) : find(strcmp({flight_profile.trajectory.type}, 'vectoring') == 1, 1, 'last' ) - 1
%         flight_profile.trajectory(m).alt =[];
%     end
% end

end