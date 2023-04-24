function [flight_profile, AssignProgress, AltAssign, SpdAssign, acc_fix] = CheckAcceleration(flight_profile, acc_fix)
['Checking flight #' num2str(flight_profile.id) ' Accerleration Limit']
Target = 0;
Checked = 0;
Status = 0;
for TrajLen = 1:length(flight_profile.trajectory) - 1
    if ~strcmp(flight_profile.trajectory(TrajLen + 1).type, 'ground')
        Target = Target + 1;
        accel_long_test = false;
        accel_normal_test = false;
        % Acceleration Envelope 침범 여부 확인하기
        if and(abs(flight_profile.trajectory(TrajLen).accel_long) > 2 * 1.35, ~strcmp(flight_profile.trajectory(TrajLen).FS, 'TX'))
            ['warning! flight #' num2str(flight_profile.id) ' Trajectory #' num2str(TrajLen) ' has accel_long(' num2str(flight_profile.trajectory(TrajLen).accel_long) ') and violated longitudinal acceleration limit (2 ft/s^2) ']
            % Acceleration 에 맞춰 spd 재설정해야 하는데, 이건 constraint 설정 후 다시 Spd
            % Profile을 불러와야 함. 추후 개발
            
            % 이거는 speed가 선회와 상관없이 과하게 부과된 경우
            
        elseif and(abs(flight_profile.trajectory(TrajLen).max_accel_long) > 2 * 1.35, ~strcmp(flight_profile.trajectory(TrajLen).FS, 'TX'))
            ['warning! flight #' num2str(flight_profile.id) ' Trajectory #' num2str(TrajLen) ' has max_accel_long(' num2str(flight_profile.trajectory(TrajLen).max_accel_long) ') and violated longitudinal acceleration limit (2 ft/s^2) ']
            % 여기는 선회를 고려할 때 속도가 과하게 잡힌 경우
            
        else
            accel_long_test = true;
        end
        
        if and(abs(flight_profile.trajectory(TrajLen).accel_vert) > sqrt(21) * 1.35, ~strcmp(flight_profile.trajectory(TrajLen).FS, 'TX'))
            ['warning! flight #' num2str(flight_profile.id) ' Trajectory #' num2str(TrajLen) ' has accel_normal(' num2str(flight_profile.trajectory(TrajLen).accel_normal) ') and violated normal acceleration limit (5 ft/s^2) ']
            % 이거는 speed / alt가 선회와 상관없이 과하게 부과된 경우
        elseif and(abs(flight_profile.trajectory(TrajLen).max_accel_vert) > sqrt(21) * 1.35, ~strcmp(flight_profile.trajectory(TrajLen).FS, 'TX'))
            ['warning! flight #' num2str(flight_profile.id) ' Trajectory #' num2str(TrajLen) ' has max_accel_normal(' num2str(flight_profile.trajectory(TrajLen).max_accel_normal) ') and violated normal acceleration limit (5 ft/s^2) ']
            % 여기는 선회를 고려할 때 속도/고도가 과하게 잡힌 경우
        else
            accel_normal_test = true;
        end
        
        AddFix = [];
        % AddFix의 1행: Acceleration limit이 걸린 Trajectory 위치
        % AddFix의 2행: 해당 limit의 종류- 0:long, 1:normal, 2:둘 다
        
        if and(accel_long_test, accel_normal_test)
            Checked = Checked + 1;
        elseif and(~accel_long_test, accel_normal_test)
            Status = 1;
            AddFix = [TrajLen ; 0];
            acc_fix = [acc_fix AddFix];
        elseif and(~accel_long_test, accel_normal_test)
            Status = 2;
            AddFix = [TrajLen ; 1];
            acc_fix = [acc_fix AddFix];
        else
            Status = 3;
            AddFix = [TrajLen ; 2];
            acc_fix = [acc_fix AddFix];
        end
    end
    
    if and(Checked == Target, Status == 0)
        ['Flight #' num2str(flight_profile.id) ' Accerleration Limit(long & normal) OK']
        AssignProgress = false;
        AltAssign = false;
        SpdAssign = false;
    else
        switch Status
            % 여기서 사유를 한번 세부적으로 체크해보자.
            case 1
                ['Flight #' num2str(flight_profile.id) ' Accerleration Limit(long) Violated.....Re-Assigning Speed Profile']
                AssignProgress = true;
                % 여기는 altitude 문제 보다는 speed가 과하게 배정된 경우
                % 앞뒤를 보고 spd 조절하자
                AltAssign = false;
                SpdAssign = true;
                
            case 2
                ['Flight #' num2str(flight_profile.id) ' Accerleration Limit(normal) Violated.....Re-Assigning Altitude & Speed Profile']
                AssignProgress = true;
                % 여기는 altitude가 과하게 배정되어 Vertical Acceleration에서 문제가 생긴 경우이다.
                % Altitude Assignment에서 acc_fix를 잡고, 해당 accel_vert = sqrt(accel_normal^2 - accel_long^2)
                % 여기 여유분으로 VS를 먼저 구하고, 해당 VS를 가졌을 때의 altitude로 가자.
                AltAssign = true;
                
                % spd assign 부분은 따로 건들 필요 없다.
                SpdAssign = true;
                
            case 3
                ['Flight #' num2str(flight_profile.id) ' Accerleration Limit(long & normal) Violated.....Re-Assigning Speed & Altitude Profile']
                AssignProgress = true;
                % 문제가 좀 복잡한 경우, long_accel을 먼저 max로 잡고 남은 vert_accel로 alt를 잡자.
                % 한번 loop가 돌아서 문제가 해결 안 될수도 있는데, 그 때 아마 다른 case로 잡히면 해결 가능성
                % 여기서 loop check를 넣어서 무한 loop를 막자.
                
                AltAssign = true;
                SpdAssign = true;
                
        end
    end
end

end