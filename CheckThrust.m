function [flight_profile, ThrustProgress, AssignProgress, AltAssign, SpdAssign, acc_fix] = CheckThrust(flight_profile, alt_fix, spd_fix, acc_fix)
['Checking flight #' num2str(flight_profile.id) ' Accerleration Limit']

% 현재 Landing 부분이 MAx_Thrust의 2배 가까이 되는 문제 발생 -> Drag가 과하게 배정되는 것으로 판단
% BADA PTD 파일과 비교할 것 or 실제 항적과 비교하자


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
    % 현재 재 Assign Progress는 미구현
%     ['Flight #' num2str(flight_profile.id) ' Thrust Limit Violated.....Re-Assigning Acceleration Profile']
%     AssignProgress = 1;
end
ThrustProgress = 0;
AssignProgress = 0;
AltAssign = 0;
SpdAssign = 0;
end