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
        % Acceleration Envelope ħ�� ���� Ȯ���ϱ�
        if and(abs(flight_profile.trajectory(TrajLen).accel_long) > 2 * 1.35, ~strcmp(flight_profile.trajectory(TrajLen).FS, 'TX'))
            ['warning! flight #' num2str(flight_profile.id) ' Trajectory #' num2str(TrajLen) ' has accel_long(' num2str(flight_profile.trajectory(TrajLen).accel_long) ') and violated longitudinal acceleration limit (2 ft/s^2) ']
            % Acceleration �� ���� spd �缳���ؾ� �ϴµ�, �̰� constraint ���� �� �ٽ� Spd
            % Profile�� �ҷ��;� ��. ���� ����
            
            % �̰Ŵ� speed�� ��ȸ�� ������� ���ϰ� �ΰ��� ���
            
        elseif and(abs(flight_profile.trajectory(TrajLen).max_accel_long) > 2 * 1.35, ~strcmp(flight_profile.trajectory(TrajLen).FS, 'TX'))
            ['warning! flight #' num2str(flight_profile.id) ' Trajectory #' num2str(TrajLen) ' has max_accel_long(' num2str(flight_profile.trajectory(TrajLen).max_accel_long) ') and violated longitudinal acceleration limit (2 ft/s^2) ']
            % ����� ��ȸ�� ����� �� �ӵ��� ���ϰ� ���� ���
            
        else
            accel_long_test = true;
        end
        
        if and(abs(flight_profile.trajectory(TrajLen).accel_vert) > sqrt(21) * 1.35, ~strcmp(flight_profile.trajectory(TrajLen).FS, 'TX'))
            ['warning! flight #' num2str(flight_profile.id) ' Trajectory #' num2str(TrajLen) ' has accel_normal(' num2str(flight_profile.trajectory(TrajLen).accel_normal) ') and violated normal acceleration limit (5 ft/s^2) ']
            % �̰Ŵ� speed / alt�� ��ȸ�� ������� ���ϰ� �ΰ��� ���
        elseif and(abs(flight_profile.trajectory(TrajLen).max_accel_vert) > sqrt(21) * 1.35, ~strcmp(flight_profile.trajectory(TrajLen).FS, 'TX'))
            ['warning! flight #' num2str(flight_profile.id) ' Trajectory #' num2str(TrajLen) ' has max_accel_normal(' num2str(flight_profile.trajectory(TrajLen).max_accel_normal) ') and violated normal acceleration limit (5 ft/s^2) ']
            % ����� ��ȸ�� ����� �� �ӵ�/���� ���ϰ� ���� ���
        else
            accel_normal_test = true;
        end
        
        AddFix = [];
        % AddFix�� 1��: Acceleration limit�� �ɸ� Trajectory ��ġ
        % AddFix�� 2��: �ش� limit�� ����- 0:long, 1:normal, 2:�� ��
        
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
            % ���⼭ ������ �ѹ� ���������� üũ�غ���.
            case 1
                ['Flight #' num2str(flight_profile.id) ' Accerleration Limit(long) Violated.....Re-Assigning Speed Profile']
                AssignProgress = true;
                % ����� altitude ���� ���ٴ� speed�� ���ϰ� ������ ���
                % �յڸ� ���� spd ��������
                AltAssign = false;
                SpdAssign = true;
                
            case 2
                ['Flight #' num2str(flight_profile.id) ' Accerleration Limit(normal) Violated.....Re-Assigning Altitude & Speed Profile']
                AssignProgress = true;
                % ����� altitude�� ���ϰ� �����Ǿ� Vertical Acceleration���� ������ ���� ����̴�.
                % Altitude Assignment���� acc_fix�� ���, �ش� accel_vert = sqrt(accel_normal^2 - accel_long^2)
                % ���� ���������� VS�� ���� ���ϰ�, �ش� VS�� ������ ���� altitude�� ����.
                AltAssign = true;
                
                % spd assign �κ��� ���� �ǵ� �ʿ� ����.
                SpdAssign = true;
                
            case 3
                ['Flight #' num2str(flight_profile.id) ' Accerleration Limit(long & normal) Violated.....Re-Assigning Speed & Altitude Profile']
                AssignProgress = true;
                % ������ �� ������ ���, long_accel�� ���� max�� ��� ���� vert_accel�� alt�� ����.
                % �ѹ� loop�� ���Ƽ� ������ �ذ� �� �ɼ��� �ִµ�, �� �� �Ƹ� �ٸ� case�� ������ �ذ� ���ɼ�
                % ���⼭ loop check�� �־ ���� loop�� ����.
                
                AltAssign = true;
                SpdAssign = true;
                
        end
    end
end

end