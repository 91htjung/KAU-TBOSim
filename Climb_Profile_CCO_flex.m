%% CCO_flex Profile

function [flight_profile, alt_fix] = Climb_Profile_CCO_flex(flight_profile, alt_fix, acc_fix, DepFE, Cr_alt)

global atmos plan unit Perf Aerodrome

if ~isempty(find(strcmp({flight_profile.trajectory.type}, 'SID') == 1, 1));
    previous_distdiff = 0;
    previous_turndistance = 0;
    TOC = 0;
    % BADA에서 가져온 기본 최대 고도
    Alt_max = Perf.(flight_profile.type).MaxAlt;
    for m = 1:length(flight_profile.trajectory)
        flight_profile.trajectory(m).highalt = min(flight_profile.trajectory(m).highalt, Alt_max);
        flight_profile.trajectory(m).lowalt = max(flight_profile.trajectory(m).lowalt, 0);
    end
    
    mass_cor=sqrt(flight_profile.mass/Perf.(flight_profile.type).Mass_ref);

    
    % 항로 진입 지점
    RTS = find(strcmp({flight_profile.trajectory.type}, 'SID') ==1, 1 ,'last');
    if ~isempty(find(strcmp({flight_profile.trajectory.type}, 'route') == 1, 1));
        RTE = find(strcmp({flight_profile.trajectory.type}, 'route') ==1, 1 ,'last');
    else
        RTE = find(strcmp({flight_profile.trajectory.type}, 'SID') ==1, 1 ,'last') + 1;
    end
    % Take-OFF
    GND = cellfun(@(x) x==DepFE, {flight_profile.trajectory.alt}, 'UniformOutput', false);
    TOF=[];
    for GND_len = 1:RTS
        if GND{GND_len} == 1;
            TOF = [TOF GND_len];
        end
    end
    TOF = max(TOF);
    if isempty(find([alt_fix] == TOF, 1))
        alt_fix = [alt_fix TOF];
    end
    

%     % RTS 지접을 alt_fix화, alt는 Cr_alt 배정
%     flight_profile.trajectory(RTS).alt = Cr_alt;
%     flight_profile.trajectory(RTS).lowalt = flight_profile.trajectory(RTS).alt;
%     flight_profile.trajectory(RTS).highalt = flight_profile.trajectory(RTS).alt;
    
fix_alt = alt_fix;
fix_acc = acc_fix;

    % TOF 이전 alt_fix 삭제
    fix_alt(fix_alt < TOF) = [];
    
    
    if isempty(find(strcmp({flight_profile.trajectory(~cellfun(@isempty,{flight_profile.trajectory.alt})).type}, 'route')==1, 1))
        fix_alt(fix_alt >= RTE) = [];
        fix_alt = [fix_alt RTE];
    else
        for RouteSeq = 1:length(flight_profile.trajectory)
            if strcmp(flight_profile.trajectory(RouteSeq).type, 'route')
                if ~isempty(flight_profile.trajectory(RouteSeq).alt);
                    if flight_profile.trajectory(RouteSeq).alt < Cr_alt;
                    else
                        Reach_Cr_alt = RouteSeq;
                        break
                    end
                end
            end
        end
        
        if ~isempty(Reach_Cr_alt)
            fix_alt(fix_alt > Reach_Cr_alt) = [];
            fix_alt = [fix_alt Reach_Cr_alt];
        else
            fix_alt(fix_alt > RTE) = [];
            fix_alt = [fix_alt RTE];
        end

    end
    
    
    
%     if ~isempty(acc_fix)
%         if and(~isempty(acc_fix(1) <= fix_alt(end), 1), ~isempty(find(acc_fix(2) == 2, 1)))
%             
%             
%         end
%     end
    
    
    
    
    % CCO_flex는 CDO와 달리, rate_of_climb이 필요 없으며, TOF에서 RTE까지 전부 segment 화
    
    % Top of Climb, alt assign
    finish = false;
    loop = 0;
    
    while finish == false;
        
        do_again = false;
        if ~isempty(find(strcmp({flight_profile.trajectory.type}, 'SID') == 1, 1));
            
            if length(fix_alt) >= 2;
                for seg = 1:length(fix_alt) - 2
                    seg_st = fix_alt(seg) + 1;
                    seg_en = fix_alt(seg + 1) - 1;
                    tot_dist = 0;
                    
                    for m = seg_st - 1:seg_en
                        tot_dist = tot_dist + flight_profile.trajectory(m).distance;
                    end
                    seg_rate = (flight_profile.trajectory(seg_en + 1).alt - flight_profile.trajectory(seg_st - 1).alt) / tot_dist;
                    for m = seg_st:seg_en
                        if do_again == false
                            
                            
                            if ~isempty(fix_acc)
                                if ~isempty(find(fix_acc(1) == m, 1))
                                    % 여기서 acc_fix가 들어가자
                                    LOC = find(fix_acc(1) == m, 1);
                                    % acc_fix(1)은 해당 fix 위치, acc_fix(2)는 사유: 0-long, 1-normal, 2-long&normal
                                    old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(m).wp_name));
                                    switch  fix_acc(2,LOC)
                                        case 0
                                            % Longitudinal acceleration이 걸린 경우: max값은 2 ft/s^2
                                            % Alt Assign에는 해당 없음 pass.
                                        case {1, 2}
                                            % Normal acceleration이 걸린 경우: max값은 5 ft/s^2

                                            if flight_profile.old_trajectory(old_ref).max_accel_normal >= 0
                                                limit = 0.9 * sqrt(21);
                                                direction = 1;
                                            elseif flight_profile.old_trajectory(old_ref).max_accel_long < 0
                                                limit = -0.9 * sqrt(21);
                                                direction = -1;
                                            end

                                            if isempty(find(fix_alt == m, 1));
                                                % 이건 acc_fix에 해당하는 alt_fix 잡히지 않은 경우
                                                
                                                % 우선 accel 여유분을 배정할 수 있는segment를 찾아보자
                                                forward_break = true;
                                                backward_break = true;
                                                
                                                forward = 0;
                                                backward = 0;
                                                
                                                while or(forward_break, backward_break)
                                                    if forward_break
                                                        if (m - (forward + 1)) < 1
                                                            forward_break = false;
                                                        else
                                                            if isempty(find(fix_alt == (m - (forward + 1)), 1))
                                                                forward = forward + 1;
                                                            else
                                                                forward_break = false;
                                                            end
                                                        end
                                                    end
                                                    if backward_break
                                                        if (m + (backward + 1)) > length(flight_profile.trajectory)
                                                            backward_break = false;
                                                        else
                                                            if isempty(find(fix_alt == (m + (backward + 1)), 1))
                                                                backward = backward + 1;
                                                            else
                                                                backward_break = false;
                                                            end
                                                        end
                                                    end
                                                end
                                                Decision = 0;
                                                for forward_accel = 1:forward
                                                    old_ref = strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(m - forward_accel).wp_name);
                                                    Decision = Decision + (direction * (limit - flight_profile.old_trajectory(old_ref).max_accel_vert));
                                                end
                                                for  backward_accel = 1:backward
                                                    old_ref = strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(m + backward_accel).wp_name);
                                                    Decision = Decision + (direction * (limit - flight_profile.old_trajectory(old_ref).max_accel_vert));
                                                end
                                                
                                            else
                                                % 이건 acc_fix에 해당하는 alt_fix 잡힌 경우 -> 앞뒤 체크하자
                                                backward_break = true;
                                                backward = 0;
                                                while backward_break
                                                    if backward_break
                                                        if (m + (backward + 1)) > length(flight_profile.trajectory)
                                                            backward_break = false;
                                                        else
                                                            if isempty(find(fix_alt == (m + (backward + 1)), 1))
                                                                backward = backward + 1;
                                                            else
                                                                backward_break = false;
                                                            end
                                                        end
                                                    end
                                                end
                                                for  backward_accel = 1:backward
                                                    old_ref = strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(m + backward_accel).wp_name);
                                                    Decision = Decision + (direction * (limit - flight_profile.old_trajectory(old_ref).max_accel_vert));
                                                end
                                            end
                                            if Decision > 0
                                                step_dir = 1;
                                            else
                                                step_dir = -1;
                                            end
                                            old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(m).wp_name));
                                            notenough = true;
                                            step_for = 0;
                                            step_bac = 0;
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
                                                            old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(m - step_for).wp_name));
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
                                                            old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(m + step_bac).wp_name));
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
                                            
                                            old_ref = strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(m - step_for).wp_name);
                                            StartAlt = flight_profile.old_trajectory(old_ref).alt;
                                            
                                            
                                            for acc_Traj = m - step_for : m + step_bac
                                                if acc_Traj == m - step_for
                                                    old_ref = strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(acc_Traj).wp_name);
                                                    flight_profile.trajectory(acc_Traj).alt = round(StartAlt);
                                                    flight_profile.trajectory(acc_Traj + 1).alt = round(StartAlt + ((flight_profile.old_trajectory(old_ref).accel_time * new_accel_vert) * flight_profile.old_trajectory(old_ref).accel_time));
                                                else
                                                    old_ref = strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(acc_Traj).wp_name);
                                                    flight_profile.trajectory(acc_Traj + 1).alt = round(flight_profile.trajectory(acc_Traj).alt + ((flight_profile.old_trajectory(old_ref).accel_time * new_accel_vert) * flight_profile.old_trajectory(old_ref).accel_time));
                                                end
                                                fix_alt = sort([fix_alt (acc_Traj + 1)]);
                                                
                                            end
                                            
                                    end
                                end
                            end
                            
                            if do_again == 0
                                flight_profile.trajectory(m).alt = round(flight_profile.trajectory(m - 1).alt + (seg_rate * flight_profile.trajectory(m - 1).distance));
                            end
                            % constraint 침범 시
                            if flight_profile.trajectory(m).alt < flight_profile.trajectory(m).lowalt
                                ['flight #' num2str(flight_profile.id) ' trajectory #' num2str(m) ' initial assigned alt(' num2str(flight_profile.trajectory(m).alt) ') has violated low altitude constraint (' num2str(flight_profile.trajectory(m).lowalt) ') adding constraint & calculating again...']
                                flight_profile.trajectory(m).alt = flight_profile.trajectory(m).lowalt;
                                % flight_profile.trajectory(m).highalt = flight_profile.trajectory(m).alt;
                                fix_alt = sort([fix_alt m]);
                                do_again = true;
                            end
                            if flight_profile.trajectory(m).alt > flight_profile.trajectory(m).highalt
                                ['flight #' num2str(flight_profile.id) ' trajectory #' num2str(m) ' initial assigned alt(' num2str(flight_profile.trajectory(m).alt) ') has violated high altitude constraint (' num2str(flight_profile.trajectory(m).highalt) ') adding constraint & calculating again...']
                                
                                flight_profile.trajectory(m).alt = flight_profile.trajectory(m).highalt;
%                                 flight_profile.trajectory(m).lowalt = flight_profile.trajectory(m).alt;
                                fix_alt = sort([fix_alt m]);
                                do_again = true;
                            end
                        end
                    end
                end
            end
            
            % 여기서는 2200ft/min으로 올리자
            
            seg = length(fix_alt) - 1;
            seg_st = fix_alt(seg) + 1;
            seg_en = fix_alt(seg + 1) - 1;

            for m = seg_st:seg_en
                if do_again == false
                    
                    % CCO flex는 Vertical speed를 사용하기 때문에, speed constraint 이전의 ground spd를 유추해서
                    % 배정이 되어야 하는 어려움이 있다. -> 일단 전 fix의 alt를 보고 판단하는 거로
                    % 하자... 더 좋은 방법이 떠오르지 않는다.
                    
                    if ~isempty(fix_acc)
                        if ~isempty(find(fix_acc(1) == m, 1))
                            % 여기서 acc_fix가 들어가자
                            LOC = find(fix_acc(1) == m, 1);
                            % acc_fix(1)은 해당 fix 위치, acc_fix(2)는 사유: 0-long, 1-normal, 2-long&normal
                            switch  fix_acc(2,LOC)
                                case 0
                                    % Longitudinal acceleration이 걸린 경우: max값은 2 ft/s^2
                                    % Alt Assign에는 해당 없음 pass.
                                case {1, 2}
                                    % Normal acceleration이 걸린 경우: max값은 5 ft/s^2
                                    old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(m).wp_name));

                                    if flight_profile.old_trajectory(old_ref).max_accel_vert >= 0
                                        limit = 0.9 * sqrt(21);
                                        direction = 1;
                                    elseif flight_profile.old_trajectory(old_ref).max_accel_vert < 0
                                        limit = -0.9 * sqrt(21);
                                        direction = -1;
                                    end
                                    
                                    if isempty(find(fix_alt == m, 1));
                                        % 이건 acc_fix에 해당하는 alt_fix 잡히지 않은 경우

                                        % 우선 accel 여유분을 배정할 수 있는segment를 찾아보자
                                        forward_break = true;
                                        backward_break = true;
                                        
                                        forward = 0;
                                        backward = 0;
                                        
                                        while or(forward_break, backward_break)
                                            if forward_break
                                                if (m - (forward + 1)) < 1
                                                    forward_break = false;
                                                else
                                                    if isempty(find(fix_alt == (m - (forward + 1)), 1))
                                                        forward = forward + 1;
                                                    else
                                                        forward_break = false;
                                                    end
                                                end
                                            end
                                            if backward_break
                                                if (m + (backward + 1)) > length(flight_profile.trajectory)
                                                    backward_break = false;
                                                else
                                                    if isempty(find(fix_alt == (m + (backward + 1)), 1))
                                                        backward = backward + 1;
                                                    else
                                                        backward_break = false;
                                                    end
                                                end
                                            end
                                        end
                                        Decision = 0;
                                        for forward_accel = 1:forward
                                            old_ref = strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(m - forward_accel).wp_name);
                                            Decision = Decision + (direction * (limit - flight_profile.old_trajectory(old_ref).max_accel_vert));
                                        end
                                        for  backward_accel = 1:backward
                                            old_ref = strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(m + backward_accel).wp_name);
                                            Decision = Decision + (direction * (limit - flight_profile.old_trajectory(old_ref).max_accel_vert));
                                        end
                                        
                                    else
                                        % 이건 acc_fix에 해당하는 alt_fix 잡힌 경우 -> 앞뒤 체크하자
                                        backward_break = true;
                                        backward = 0;
                                        while backward_break
                                            if backward_break
                                                if (m + (backward + 1)) > length(flight_profile.trajectory)
                                                    backward_break = false;
                                                else
                                                    if isempty(find(fix_alt == (m + (backward + 1)), 1))
                                                        backward = backward + 1;
                                                    else
                                                        backward_break = false;
                                                    end
                                                end
                                            end
                                        end
                                        for  backward_accel = 1:backward
                                            old_ref = strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(m + backward_accel).wp_name);
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
                                    old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(m).wp_name));
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
                                                    old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(m - step_for).wp_name));
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
                                                    old_ref = find(strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(m + step_bac).wp_name));
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
                                    old_ref = strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(m - step_for).wp_name);
                                    StartAlt = flight_profile.old_trajectory(old_ref).alt;
                                    
                                    
                                    for acc_Traj = m - step_for : m + step_bac
                                        if acc_Traj == m - step_for
                                            old_ref = strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(acc_Traj).wp_name);
                                            if round(StartAlt + ((flight_profile.old_trajectory(old_ref).accel_time * new_accel_vert) * flight_profile.old_trajectory(old_ref).accel_time)) < Cr_alt
                                                flight_profile.trajectory(acc_Traj).alt = round(StartAlt);
                                                flight_profile.trajectory(acc_Traj + 1).alt = round(StartAlt + ((flight_profile.old_trajectory(old_ref).accel_time * new_accel_vert) * flight_profile.old_trajectory(old_ref).accel_time));
                                                TOC = acc_Traj + 1;
                                            else
                                                flight_profile.trajectory(acc_Traj).alt = round(StartAlt);
                                                flight_profile.trajectory(acc_Traj + 1).alt = Cr_alt;
                                                TOC = acc_Traj + 1;
                                                
                                                TRAJ_LEN = length(flight_profile.trajectory);
                                                
                                                for afterTOC = 1:TRAJ_LEN - TOC
                                                    flight_profile.trajectory(TRAJ_LEN - afterTOC + 2) = flight_profile.trajectory(TRAJ_LEN - afterTOC + 1);
                                                    flight_profile.trajectory(TRAJ_LEN - afterTOC + 2).TRAJ_num = TRAJ_LEN - afterTOC + 2;
                                                end
                                                flight_profile.trajectory(TOC + 1).wp_name = 'TOC';
                                                flight_profile.trajectory(TOC + 1).alt = Cr_alt;
                                                flight_profile.trajectory(TOC + 1).id = '';
                                                flight_profile.trajectory(TOC + 1).lowalt = flight_profile.trajectory(TOC + 1).alt;
                                                flight_profile.trajectory(TOC + 1).highalt = flight_profile.trajectory(TOC + 1).alt;
                                                
                                                
                                                % FalseFix 도 한칸씩 뒤로 밀기
                                                if ~isempty(flight_profile.FalseFix)
                                                    for FF = 1:length(flight_profile.FalseFix)
                                                        if flight_profile.FalseFix(FF) >= TOC + 1
                                                            flight_profile.FalseFix(FF) =  flight_profile.FalseFix(FF) + 1;
                                                        end
                                                    end
                                                end
                                                flight_profile.FalseFix = [TOC + 1 flight_profile.FalseFix];
                                                
                                                % alt_fix 한칸씩 뒤로 밀기
                                                for fixLen = 1:length(alt_fix)
                                                    if alt_fix(fixLen) >= TOC + 1
                                                        alt_fix(fixLen) =  alt_fix(fixLen) + 1;
                                                    end
                                                end
                                                
                                                TOC_relative = (Cr_alt - flight_profile.trajectory(TOC).alt) / (rate_of_climb * flight_profile.trajectory(TOC).distance);
                                                TOC_distance = flight_profile.trajectory(TOC).distance - (TOC_relative * flight_profile.trajectory(TOC).distance);
                                                
                                                [flight_profile.trajectory(TOC + 1).lat, flight_profile.trajectory(TOC + 1).long] = reckon(flight_profile.trajectory(TOC).lat, flight_profile.trajectory(TOC).long, nm2deg(TOC_distance), flight_profile.trajectory(TOC).heading);
                                                
                                                [dist_rec, head_rec] = distance(flight_profile.trajectory(TOC).lat, flight_profile.trajectory(TOC).long, flight_profile.trajectory(TOC + 1).lat, flight_profile.trajectory(TOC + 1).long);
                                                flight_profile.trajectory(TOC).distance = deg2nm(dist_rec);
                                                flight_profile.trajectory(TOC).heading = head_rec;
                                                
                                                [dist_rec, head_rec] = distance(flight_profile.trajectory(TOC + 1).lat, flight_profile.trajectory(TOC + 1).long, flight_profile.trajectory(TOC + 2).lat, flight_profile.trajectory(TOC + 2).long);
                                                flight_profile.trajectory(TOC + 1).distance = deg2nm(dist_rec);
                                                flight_profile.trajectory(TOC + 1).heading = head_rec;
                                                break
                                            end
                                        else
                                            old_ref = strcmp({flight_profile.old_trajectory.wp_name}, flight_profile.trajectory(acc_Traj).wp_name);
                                            flight_profile.trajectory(acc_Traj).alt = round(StartAlt);
                                            if round(flight_profile.trajectory(acc_Traj).alt + ((flight_profile.old_trajectory(old_ref).accel_time * new_accel_vert) * flight_profile.old_trajectory(old_ref).accel_time)) < Cr_alt
                                                flight_profile.trajectory(acc_Traj + 1).alt = round(flight_profile.trajectory(acc_Traj).alt + ((flight_profile.old_trajectory(old_ref).accel_time * new_accel_vert) * flight_profile.old_trajectory(old_ref).accel_time));
                                                TOC = acc_Traj + 1;
                                            else
                                                flight_profile.trajectory(acc_Traj + 1).alt = Cr_alt;
                                                TOC = acc_Traj + 1;
                                                
                                                TRAJ_LEN = length(flight_profile.trajectory);
                                                
                                                for afterTOC = 1:TRAJ_LEN - TOC
                                                    flight_profile.trajectory(TRAJ_LEN - afterTOC + 2) = flight_profile.trajectory(TRAJ_LEN - afterTOC + 1);
                                                    flight_profile.trajectory(TRAJ_LEN - afterTOC + 2).TRAJ_num = TRAJ_LEN - afterTOC + 2;
                                                end
                                                flight_profile.trajectory(TOC + 1).wp_name = 'TOC';
                                                flight_profile.trajectory(TOC + 1).alt = Cr_alt;
                                                flight_profile.trajectory(TOC + 1).id = '';
                                                flight_profile.trajectory(TOC + 1).lowalt = flight_profile.trajectory(TOC + 1).alt;
                                                flight_profile.trajectory(TOC + 1).highalt = flight_profile.trajectory(TOC + 1).alt;
                                                
                                                
                                                % FalseFix 도 한칸씩 뒤로 밀기
                                                if ~isempty(flight_profile.FalseFix)
                                                    for FF = 1:length(flight_profile.FalseFix)
                                                        if flight_profile.FalseFix(FF) >= TOC + 1
                                                            flight_profile.FalseFix(FF) =  flight_profile.FalseFix(FF) + 1;
                                                        end
                                                    end
                                                end
                                                flight_profile.FalseFix = [TOC + 1 flight_profile.FalseFix];
                                                
                                                % alt_fix 한칸씩 뒤로 밀기
                                                for fixLen = 1:length(alt_fix)
                                                    if alt_fix(fixLen) >= TOC + 1
                                                        alt_fix(fixLen) =  alt_fix(fixLen) + 1;
                                                    end
                                                end
                                                
                                                TOC_relative = (Cr_alt - flight_profile.trajectory(TOC).alt) / (rate_of_climb * flight_profile.trajectory(TOC).distance);
                                                TOC_distance = flight_profile.trajectory(TOC).distance - (TOC_relative * flight_profile.trajectory(TOC).distance);
                                                
                                                [flight_profile.trajectory(TOC + 1).lat, flight_profile.trajectory(TOC + 1).long] = reckon(flight_profile.trajectory(TOC).lat, flight_profile.trajectory(TOC).long, nm2deg(TOC_distance), flight_profile.trajectory(TOC).heading);
                                                
                                                [dist_rec, head_rec] = distance(flight_profile.trajectory(TOC).lat, flight_profile.trajectory(TOC).long, flight_profile.trajectory(TOC + 1).lat, flight_profile.trajectory(TOC + 1).long);
                                                flight_profile.trajectory(TOC).distance = deg2nm(dist_rec);
                                                flight_profile.trajectory(TOC).heading = head_rec;
                                                
                                                [dist_rec, head_rec] = distance(flight_profile.trajectory(TOC + 1).lat, flight_profile.trajectory(TOC + 1).long, flight_profile.trajectory(TOC + 2).lat, flight_profile.trajectory(TOC + 2).long);
                                                flight_profile.trajectory(TOC + 1).distance = deg2nm(dist_rec);
                                                flight_profile.trajectory(TOC + 1).heading = head_rec;
                                                break
                                            end
                                            
                                            
                                        end
                                        
                                        
                                        
                                        
                                        fix_alt = sort([fix_alt (acc_Traj + 1)]);
                                        do_again = true;
                                        
                                    end
                            end
                        end
                    end
                    
                    
                    
                    rate_of_climb = plan(flight_profile.id).climb_rate;
                    
                    %                     if flight_profile.trajectory(m).heading - flight_profile.trajectory(m - 1).heading > 180;
                    %                         hdg_diff = 360 - flight_profile.trajectory(m).heading - flight_profile.trajectory(m - 1).heading;
                    %                     elseif flight_profile.trajectory(m).heading - flight_profile.trajectory(m - 1).heading < -180;
                    %                         hdg_diff = 360 + flight_profile.trajectory(m).heading - flight_profile.trajectory(m - 1).heading;
                    %                     else
                    %                         hdg_diff = abs(flight_profile.trajectory(m).heading - flight_profile.trajectory(m - 1).heading);
                    %                     end
                    %                     hdg_diff = 180 - hdg_diff;
                    
                    hdg_diff = abs(flight_profile.trajectory(m).heading - flight_profile.trajectory(m - 1).heading);
                    
                    if hdg_diff > 180
                        hdg_diff = 360 - hdg_diff;
                    end
                    
                    if abs(hdg_diff) < 1
                        hdg_diff = 0;
                    end
                    
                    hdg_diff = 180 - hdg_diff;
                    
                    if hdg_diff > 1
                        % 1 도 이상의 bearing 차이에는 turn을 고려하자
                        if strcmp(Perf.(flight_profile.type).Engtype,'Jet')==1 %Jet일 경우
                            
                            if flight_profile.trajectory(m - 1).alt < 100
                                pseudo_spd = cas2tas(1.2*mass_cor*Perf.(flight_profile.type).Vstall_TO + 5, flight_profile.trajectory(m - 1).alt);
                            elseif and(flight_profile.trajectory(m - 1).alt >= 100, flight_profile.trajectory(m - 1).alt < 3000)
                                pseudo_spd = cas2tas(1.3*mass_cor*Perf.(flight_profile.type).Vstall_TO + 5, flight_profile.trajectory(m - 1).alt);
                            elseif and(flight_profile.trajectory(m - 1).alt >= 3000, flight_profile.trajectory(m - 1).alt < 4000)
                                pseudo_spd = cas2tas(mass_cor*Perf.(flight_profile.type).Vstall_TO + 30,flight_profile.trajectory(m - 1).alt);
                            elseif and(flight_profile.trajectory(m - 1).alt >= 4000, flight_profile.trajectory(m - 1).alt < 5000)
                                pseudo_spd = cas2tas(mass_cor*Perf.(flight_profile.type).Vstall_TO + 60,flight_profile.trajectory(m - 1).alt);
                            elseif and(flight_profile.trajectory(m - 1).alt >= 5000, flight_profile.trajectory(m - 1).alt < 6000)
                                pseudo_spd = cas2tas(mass_cor*Perf.(flight_profile.type).Vstall_TO + 80,flight_profile.trajectory(m - 1).alt);
                            elseif and(flight_profile.trajectory(m - 1).alt >= 6000, flight_profile.trajectory(m - 1).alt < 10000)
                                pseudo_spd = cas2tas(min(mass_cor*Perf.(flight_profile.type).Vclimb_low,mass_cor*250),flight_profile.trajectory(m - 1).alt);
                            elseif and(flight_profile.trajectory(m - 1).alt >= 10000, flight_profile.trajectory(m - 1).alt < Perf.(flight_profile.type).Machtrans_climb);
                                pseudo_spd = cas2tas(mass_cor*Perf.(flight_profile.type).Vclimb_high,flight_profile.trajectory(m - 1).alt);
                            elseif flight_profile.trajectory(m - 1).alt >= Perf.(flight_profile.type).Machtrans_climb;
                                pseudo_spd = mach2tas(mass_cor*Perf.(flight_profile.type).Mclimb,flight_profile.trajectory(m - 1).alt);
                            end
                        else %Jet가 아니면
                            if flight_profile.trajectory(m - 1).alt < 100
                                pseudo_spd = cas2tas(1.2*mass_cor*Perf.(flight_profile.type).Vstall_TO + 20,flight_profile.trajectory(m - 1));
                            elseif and(flight_profile.trajectory(m - 1).alt >= 100, flight_profile.trajectory(m - 1).alt < 1000)
                                pseudo_spd = cas2tas(1.3*mass_cor*Perf.(flight_profile.type).Vstall_TO + 20,flight_profile.trajectory(m - 1));
                            elseif and(flight_profile.trajectory(m - 1).alt >= 1000, flight_profile.trajectory(m - 1).alt < 1500)
                                pseudo_spd = cas2tas(1.3*mass_cor*Perf.(flight_profile.type).Vstall_TO + 30,flight_profile.trajectory(m - 1));
                            elseif and(flight_profile.trajectory(m - 1).alt >= 1500, flight_profile.trajectory(m - 1).alt < 10000)
                                pseudo_spd = cas2tas(1.3*mass_cor*Perf.(flight_profile.type).Vstall_TO + 35,flight_profile.trajectory(m - 1));
                            elseif and(flight_profile.trajectory(m - 1).alt >= 10000, flight_profile.trajectory(m - 1).alt < Perf.(flight_profile.type).Machtrans_climb);
                                pseudo_spd = cas2tas(mass_cor*Perf.(flight_profile.type).Vclimb_high,flight_profile.trajectory(m - 1));
                            elseif flight_profile.trajectory(m - 1).alt >= Perf.(flight_profile.type).Machtrans_climb;
                                pseudo_spd = mach2tas(mass_cor*Perf.(flight_profile.type).Mclimb,flight_profile.trajectory(m - 1));
                            end
                        end
                        
                        % 원래는 FS로 찾아야 함. Alt로 구분하자 (400 이하 TO)
                        if flight_profile.trajectory(m - 1).alt <= 400
                            bankangle = 15;
                        else
                            bankangle = 35;
                        end
                        
                        turn_rate = 1091 * tan(deg2rad(bankangle)) / pseudo_spd;
                        turn_radius= (pseudo_spd^2)/(11.26 * tan(deg2rad(bankangle))) * unit.ft2meter / unit.nm2meter;
                        
                        distdiff =  turn_radius/abs(tan(deg2rad(hdg_diff / 2)));
                        
                        accel_distance = flight_profile.trajectory(m - 1).distance - previous_distdiff - distdiff;
                        turn_distance = deg2rad(180 - hdg_diff) * turn_radius / 2;
                        
                        real_distance = accel_distance + turn_distance + previous_turndistance;
                        accel_min = accel_distance / pseudo_spd * 60;
                        turn_min = turn_distance / pseudo_spd * 60;
                        
                        previous_turndistance = turn_distance;
                        previous_distdiff = distdiff;
                        previous_pseudo_spd = pseudo_spd;
                        accel_min = max(accel_min, 0);
                        if do_again == 0
                            if round(flight_profile.trajectory(m - 1).alt + (rate_of_climb * accel_min)) < Cr_alt
                                flight_profile.trajectory(m).alt = round(flight_profile.trajectory(m - 1).alt + (rate_of_climb * accel_min));
                                TOC = m;
                                
                            else
                                
                                if m <= TOC + 1
                                    
                                    TRAJ_LEN = length(flight_profile.trajectory);
                                    
                                    for afterTOC = 1:TRAJ_LEN - TOC
                                        flight_profile.trajectory(TRAJ_LEN - afterTOC + 2) = flight_profile.trajectory(TRAJ_LEN - afterTOC + 1);
                                        flight_profile.trajectory(TRAJ_LEN - afterTOC + 2).TRAJ_num = TRAJ_LEN - afterTOC + 2;
                                    end
                                    flight_profile.trajectory(TOC + 1).wp_name = 'TOC';
                                    flight_profile.trajectory(TOC + 1).alt = Cr_alt;
                                    flight_profile.trajectory(TOC + 1).id = '';
                                    flight_profile.trajectory(TOC + 1).lowalt = flight_profile.trajectory(TOC + 1).alt;
                                    flight_profile.trajectory(TOC + 1).highalt = flight_profile.trajectory(TOC + 1).alt;
                                    
                                    
                                    % FalseFix 도 한칸씩 뒤로 밀기
                                    if ~isempty(flight_profile.FalseFix)
                                        for FF = 1:length(flight_profile.FalseFix)
                                            if flight_profile.FalseFix(FF) >= TOC + 1
                                                flight_profile.FalseFix(FF) =  flight_profile.FalseFix(FF) + 1;
                                            end
                                        end
                                    end
                                    flight_profile.FalseFix = [TOC + 1 flight_profile.FalseFix];
                                    
                                    % alt_fix 한칸씩 뒤로 밀기
                                    for fixLen = 1:length(alt_fix)
                                        if alt_fix(fixLen) >= TOC + 1
                                            alt_fix(fixLen) =  alt_fix(fixLen) + 1;
                                        end
                                    end
                                    
                                    TOC_relative = (Cr_alt - flight_profile.trajectory(TOC).alt) / (rate_of_climb * flight_profile.trajectory(TOC).distance);
                                    TOC_distance = flight_profile.trajectory(TOC).distance - (TOC_relative * flight_profile.trajectory(TOC).distance);
                                    
                                    [flight_profile.trajectory(TOC + 1).lat, flight_profile.trajectory(TOC + 1).long] = reckon(flight_profile.trajectory(TOC).lat, flight_profile.trajectory(TOC).long, nm2deg(TOC_distance), flight_profile.trajectory(TOC).heading);
                                    
                                    [dist_rec, head_rec] = distance(flight_profile.trajectory(TOC).lat, flight_profile.trajectory(TOC).long, flight_profile.trajectory(TOC + 1).lat, flight_profile.trajectory(TOC + 1).long);
                                    flight_profile.trajectory(TOC).distance = deg2nm(dist_rec);
                                    flight_profile.trajectory(TOC).heading = head_rec;
                                    
                                    [dist_rec, head_rec] = distance(flight_profile.trajectory(TOC + 1).lat, flight_profile.trajectory(TOC + 1).long, flight_profile.trajectory(TOC + 2).lat, flight_profile.trajectory(TOC + 2).long);
                                    flight_profile.trajectory(TOC + 1).distance = deg2nm(dist_rec);
                                    flight_profile.trajectory(TOC + 1).heading = head_rec;
                                    
                                    break
                                else
                                    flight_profile.trajectory(TOC + 1).alt = Cr_alt;
                                end
                            end
                        else
                            distdiff = 0;
                            accel_distance = flight_profile.trajectory(m - 1).distance - (previous_distdiff / 2) - (distdiff / 2);
                            accel_min = flight_profile.trajectory(m - 1).distance / pseudo_spd * 60;
                            flight_profile.trajectory(m).alt = round(flight_profile.trajectory(m - 1).alt + (rate_of_climb * accel_min));
                            previous_distdiff = distdiff;
                            previous_pseudo_spd = pseudo_spd;
                            
                        end
                        
                    end
                    
                    
                    
                    
                    
                    % constraint 침범 시
                    if flight_profile.trajectory(m).alt < flight_profile.trajectory(m).lowalt
                        ['flight #' num2str(flight_profile.id) ' trajectory #' num2str(m) ' initial assigned alt(' num2str(flight_profile.trajectory(m).alt) ') has violated low altitude constraint (' num2str(flight_profile.trajectory(m).lowalt) ') adding constraint & calculating again...']
                        flight_profile.trajectory(m).alt = flight_profile.trajectory(m).lowalt;
%                         flight_profile.trajectory(m).highalt = flight_profile.trajectory(m).alt;
                        fix_alt = sort([fix_alt m]);
                        do_again = true;
                    end
                    if flight_profile.trajectory(m).alt > flight_profile.trajectory(m).highalt
                        ['flight #' num2str(flight_profile.id) ' trajectory #' num2str(m) ' initial assigned alt(' num2str(flight_profile.trajectory(m).alt) ') has violated high altitude constraint (' num2str(flight_profile.trajectory(m).highalt) ') adding constraint & calculating again...']
                        
                        flight_profile.trajectory(m).alt = flight_profile.trajectory(m).highalt;
%                         flight_profile.trajectory(m).lowalt = flight_profile.trajectory(m).alt;
                        fix_alt = sort([fix_alt m]);
                        do_again = true;
                    end
                end
            end
            
%             if flight_profile.trajectory(m).alt + 
% 
%             end
                
            
        else
            % SID나 route가 포함 안 됬다면, 넘어가자
            finish = true;
            break
            
        end
        
        % altitude constraint가 fix의 숫자와 같을 때
        if length(fix_alt) == RTS - TOF + 1
            ['warning! flight #' num2str(flight_profile.id) ' cannot be assigned Climb Profile (CCO_flex) due to altitude constraints']
            ['Breaking Altitude Assignment Procedure... Try Again with different profile']
            finish = true;
        end
        
        % 배정된 altitude와 constraint의 비교
        alt_check = 0;
        if do_again == false;
            for n = TOF:RTS
                if ~isempty(flight_profile.trajectory(n).distance)
                    flight_profile.trajectory(n).vs = (flight_profile.trajectory(n + 1).alt - flight_profile.trajectory(n).alt) / flight_profile.trajectory(n).distance;
                end
                
                if and(flight_profile.trajectory(n).alt <= flight_profile.trajectory(n).highalt, flight_profile.trajectory(n).alt >= flight_profile.trajectory(n).lowalt);
                    alt_check = alt_check + 1;
                end
            end
            
            % 모든 altitude가 okay 이면
            if alt_check == RTS - TOF + 1
                finish = true;
            end
            
        end
        
        loop = loop+1;
    end
    
    
%     if ~isempty(find(strcmp({flight_profile.trajectory.type}, 'vectoring') == 1, 1));
%         for m = find(strcmp({flight_profile.trajectory.type}, 'vectoring') == 1, 1 ) : find(strcmp({flight_profile.trajectory.type}, 'vectoring') == 1, 1, 'last' ) - 1
%             flight_profile.trajectory(m).alt =[];
%         end
%     end
end

end