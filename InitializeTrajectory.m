function flight_profile = InitializeTrajectory(flight_profile, alt_fix, spd_fix, acc_fix, AltAssign, SpdAssign)



for TrajLen = 1:length(flight_profile.trajectory)
    
    if AltAssign
        if isempty(find(alt_fix == TrajLen, 1))
            flight_profile.trajectory(TrajLen).alt = [];
            flight_profile.trajectory(TrajLen).FS = [];
        end
    end
    
    if SpdAssign
        if isempty(find(spd_fix == TrajLen, 1))
            flight_profile.trajectory(TrajLen).Vtas = [];
            flight_profile.trajectory(TrajLen).SegmentTAS = [];
            flight_profile.trajectory(TrajLen).Vcas = [];
            flight_profile.trajectory(TrajLen).Vmach = [];
            flight_profile.trajectory(TrajLen).FS = [];
        end
    end
    
    % 여기는 나중에 TBO 모듈 구현시 TimeAssign으로 판단하자
    flight_profile.trajectory(TrajLen).vs = [];
    flight_profile.trajectory(TrajLen).max_vs = [];
    flight_profile.trajectory(TrajLen).EET = [];
    flight_profile.trajectory(TrajLen).distance = flight_profile.trajectory(TrajLen).InterFix_distance;
    flight_profile.trajectory(TrajLen).accel_time = [];
    flight_profile.trajectory(TrajLen).turn_time = [];
    flight_profile.trajectory(TrajLen).p_turn_time = [];
    flight_profile.trajectory(TrajLen).turn_distance = [];
    flight_profile.trajectory(TrajLen).p_turn_distance = [];
    flight_profile.trajectory(TrajLen).accel_distance = [];
    flight_profile.trajectory(TrajLen).ground_distance = [];
    flight_profile.trajectory(TrajLen).turn_rate = [];
    flight_profile.trajectory(TrajLen).turn_radius = [];
    flight_profile.trajectory(TrajLen).accel_long = [];
    flight_profile.trajectory(TrajLen).accel_vert = [];
    flight_profile.trajectory(TrajLen).accel_normal = [];
    flight_profile.trajectory(TrajLen).max_accel_long = [];
    flight_profile.trajectory(TrajLen).max_accel_vert = [];
    flight_profile.trajectory(TrajLen).max_accel_normal = [];
    
    
    
    
    flight_profile.trajectory(TrajLen).mass = [];
end



    flight_profile.trajectory(1).mass = flight_profile.mass;


end