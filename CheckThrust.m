function [flight_profile, ThrustProgress, AssignProgress, AltAssign, SpdAssign, acc_fix] = CheckThrust(flight_profile, alt_fix, spd_fix, acc_fix)
['Checking flight #' num2str(flight_profile.id) ' Accerleration Limit']

% ���� Landing �κ��� MAx_Thrust�� 2�� ������ �Ǵ� ���� �߻� -> Drag�� ���ϰ� �����Ǵ� ������ �Ǵ�
% BADA PTD ���ϰ� ���� �� or ���� ������ ������


global unit

Checked = 0;
Status = 0;
for TrajLen = 1:length(flight_profile.trajectory) - 1
    AddFix = [];
    if flight_profile.trajectory(TrajLen).Thrust > flight_profile.trajectory(TrajLen).Max_Thrust
        ['warning! flight #' num2str(flight_profile.id) ' trajectory #' num2str(TrajLen) 'has Thrust(' num2str(flight_profile.trajectory(TrajLen).Thrust) ') higher than maximum Thrust(' num2str(flight_profile.trajectory(TrajLen).Max_Thrust) ')']
    else
        Checked = Checked + 1;
    end
    
end

if Checked == length(flight_profile.trajectory) - 1;
    ['Flight #' num2str(flight_profile.id) ' Thrust Limit OK']
    AssignProgress = 0;
    AltAssign = 0;
    SpdAssign = 0;
% else
    % ���� �� Assign Progress�� �̱���
%     ['Flight #' num2str(flight_profile.id) ' Thrust Limit Violated.....Re-Assigning Acceleration Profile']
%     AssignProgress = 1;
end
ThrustProgress = 0;
AssignProgress = 0;
AltAssign = 0;
SpdAssign = 0;
end