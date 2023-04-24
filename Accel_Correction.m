function flight_profile = Accel_Correction(flight_profile, alt_fix, spd_fix)
inc  = 0;

for TrajLen = 1:length(flight_profile.trajectory) - 1
    
    inc = flight_profile.trajectory(TrajLen).accel_lost;
    if inc ~= 0
        long = flight_profile.trajectory(TrajLen + 1).max_accel_long * flight_profile.trajectory(TrajLen + 1).accel_time;
        vert = flight_profile.trajectory(TrajLen + 1).max_accel_vert * flight_profile.trajectory(TrajLen + 1).accel_time;
        time = flight_profile.trajectory(TrajLen + 1).accel_time;
        
        long_check = isempty(find(spd_fix == TrajLen + 1, 1));
        vert_check = isempty(find(alt_fix == TrajLen + 1, 1));
        
        avail_long = 0;
        avail_vert = 0;
        
        if inc >= 0
            limit_long = 0.9 * 2;
            limit_vert = 0.9 * sqrt(21);
        else
            limit_long = 0.9 * -2;
            limit_vert = 0.9 * -sqrt(21);
        end

        avail_long = (limit_long * time) - long;
        avail_vert = (limit_vert * time) - vert;
        
        if and(long_check, vert_check)
            switch flight_profile.trajectory(TrajLen).FS
                case {'TO' 'IC'}
                    if abs(avail_vert) - abs(inc) > 0
                        new_vert = vert + inc;
                        new_long = long;
                    else
                        new_vert = avail_vert;
                        new_long = long + (inc - avail_vert);
                    end
                case {'AP' 'LD'}
                    if abs(avail_long) - abs(inc) > 0
                        new_long = long + inc;
                        new_vert = vert;
                    else
                        new_long = avail_long;
                        new_vert = vert + (inc - avail_long);
                    end
                otherwise
                    long_rate = ((limit_long * time) - long) / (((limit_long * time) - long) + ((limit_vert * time) - vert));
                    if and(abs(avail_long) - abs(inc * long_rate) > 0, abs(avail_vert) - abs(inc * (1 - long_rate) > 0))
                        new_long = long + inc * long_rate;
                        new_vert = vert + inc * (1 - long_rate);
                    else
                        if abs(avail_long) - abs(inc) > 0
                            new_long = long + inc;
                            new_vert = vert;
                        else
                            new_long = avail_long;
                            new_vert = vert + (inc - avail_long);
                        end
                    end
            end
            
            flight_profile.trajectory(TrajLen + 1).new_long = new_long / time;
            flight_profile.trajectory(TrajLen + 1).new_vert = new_vert / time;
        elseif and(long_check, ~vert_check)
            
        elseif and(~long_check, ~vert_check)
            % no correction available -> Thrust를 Turn Thrust로 
        else
            
        end
        %     spd_fix
        %     alt_fix 여부 확인 후 해당 없는 곳에 배정 FS에 따라 확인(상승-> 고도에 배정) 하강-> 속도에 배정
        %
        %
        %     if long > 0
        %         limit = 1.8;
        %         direction = 1;
        %     else
        %         limit = -1.8;
        %         direction = -1;
        %     end
        
    end
end

end