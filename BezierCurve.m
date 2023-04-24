function flight = BezierCurve(flight)

global atmos config unit plan

for FLen = 1:length(flight)
    
    ['Generating flight #' num2str(FLen) ' Reference Trajectory, curve option: ' config.Curve]
    
    AC = FLen;
    Reference = [];
    CurveFix = [];
    ControlFix = [];
    Totaltime = plan(flight(FLen).id).gentime;
    Segtime = 0;
    InitCount = 0;
    AcclControl = 0;
    segno = 0;
    segRemtime = 0;
    lastsegRemtime = 0;
    ReserveCoord = [0 ; 0];
    ReserveAlt = 0;
    % modify trajectory into Bezier Reference
    if and(~isempty(flight(AC).WaypointFrom), flight(AC).WaypointFrom ~= length(flight(AC).trajectory))
        From = 1;
        turn_flag = 0;
        while From < length(flight(AC).trajectory)
%         for From = flight(AC).WaypointFrom:length(flight(AC).trajectory) - 1
            To = From + 1;
            flight(AC).WaypointTo = To;
            

%             L = sqrt(d^2 + dalt^2); % nm

%             P0 = [flight(AC).trajectory(From).long ; flight(AC).trajectory(From).lat];
%             P3 = [flight(AC).trajectory(To).long ; flight(AC).trajectory(To).lat] - windcor;
            
            % Acceleration
            % optimization ->finding lambda
%             syms lambda0 real
%             syms lambda1 real
%             syms stau real
% %             P = (1-stau)^3 * P0 + 3 * (1-stau)^2 * stau * P1 + 3 * (1-stau)^1 * stau^2 * P2 + stau^3 * P3;
% 
% 
%             P1 = (P0 + (lambda0 * stau + 1/3) * L *[cos(hdg0) ; sin(hdg0)]);
%             P2 = (P3 + (lambda1 * (stau - 1) - 1/3) * L * [cos(hdg1) * cos(dangle) ; sin(hdg1) * cos(dangle)]);
%           
%             P = 3 * stau * (1-stau)^2 * P1 + 3 * stau^2 * (1-stau) * P2 + stau^3 * d * [cos(psi) ; sin(psi)];
%             
%             diffP = 3 * (stau - 1) * (3 * stau - 1) * P1 + 3 * stau * (2 - 3 *stau) * P2 + 3 * stau^2 * d * [cos(psi) ; sin(psi)] ...
%                 + 3 * stau * (1 - stau)^2 * lambda0 * L * [cos(hdg0) ; sin(hdg0)] + 3 * stau^2 * (1 - stau) * lambda1 * L * [cos(hdg1) * cos(dangle) ; sin(hdg1) * cos(dangle)];
%             
%             diff2P = 3 * (6 * stau - 4) * P1 + 3 * (2 - 6 * stau) * P2 + 6 * stau * d * [cos(psi) ; sin(psi)] ...
%                 + 3 * (stau - 1) * (3 * stau - 1) * lambda0 * L * [cos(hdg0) ; sin(hdg0)] + 3 * stau * (2 - 3 * stau) * lambda1 * L * [cos(hdg1) * cos(dangle) ; sin(hdg1) * cos(dangle)];
%             
            
%             CurvK = 0;
%             CurvL = 0;
%             for sigtau=0:0.01:1
%                 
%                 sigP1 = (P0 + (lambda0 * sigtau + 1/3) * L *[cos(hdg0) ; sin(hdg0)]);
%                 sigP2 = (P3 + (lambda1 * (sigtau - 1) - 1/3) * L * [cos(hdg1) * cos(dangle) ; sin(hdg1) * cos(dangle)]);
%                 
%                 sigdiffP = 3 * (sigtau - 1) * (3 * sigtau - 1) * sigP1 + 3 * sigtau * (2 - 3 * sigtau) * sigP2 + 3 * sigtau^2 * d * [cos(psi) ; sin(psi)] ...
%                     + 3 * sigtau * (1 - sigtau)^2 * lambda0 * L * [cos(hdg0) ; sin(hdg0)] + 3 * sigtau^2 * (1 - sigtau) * lambda1 * L * [cos(hdg1) * cos(dangle) ; sin(hdg1) * cos(dangle)];
%                 
%                 sigdiff2P = 3 * (6 * sigtau - 4) * sigP1 + 3 * (2 - 6 * sigtau) * sigP2 + 6 * sigtau * d * [cos(psi) ; sin(psi)] ...
%                     + 3 * (sigtau - 1) * (3 * sigtau - 1) * lambda0 * L * [cos(hdg0) ; sin(hdg0)] + 3 * sigtau * (2 - 3 * sigtau) * lambda1 * L * [cos(hdg1) * cos(dangle) ; sin(hdg1) * cos(dangle)];
%                 
%                 V = sqrt(sigdiffP' * sigdiffP);
%                 K = sigdiff2P' * sigdiff2P;
%                 sigtau
%                 CurvL = CurvL + V * 0.01;
%                 CurvK = CurvK + K * 0.01;
%             end
%             CurvL = CurvL - L;
%             CurvK = L^-4 * CurvK;
%             LL = matlabFunction(CurvL)
%             KK = matlabFunction(CurvK)
%             options = optimoptions('fsolve','Display','none','PlotFcns',@optimplotfirstorderopt, 'Algorithm', 'levenberg-marquardt');
%             fsolve(@(x) LL(x(1),x(2)), [0;0], options)
            
            
            
            tau = 0;
%             altn = 0;
            update = config.TrajRes;
    
            
            if InitCount == 0
                Vtas0 = flight(AC).trajectory(From).Vtas / 3600; %nm/sec
                alt0 = flight(AC).trajectory(From).alt; %ft
                hdg0 = deg2rad(flight(AC).trajectory(From).heading); %rad
                P0 = deg2nm([flight(AC).trajectory(From).long ; flight(AC).trajectory(From).lat]);
                h0 = flight(AC).trajectory(From).alt;
                dalt = unit.ft2nm * (flight(AC).trajectory(To).alt - flight(AC).trajectory(From).alt); %degree
                d = flight(AC).trajectory(From).distance;
                dangle = atan(dalt / d); %rad
                vs3 = 0;
            else
                P0 = P3;
                h0 = h3;
                Vtas0 = v3; %nm/sec
                alt0 = h3; %ft
                hdg0 = deg2rad(flight(AC).trajectory(From).heading); %rad
            end
            
            InitCount = 1;
            if ~turn_flag
                switch plan(flight(AC).id).Curve
                    case {'strict' 'semifree'}
                        if flight(AC).trajectory(To).flyover
                            Vtas1 = flight(AC).trajectory(To).Vtas / 3600; % nm/sec
                            alt1 = flight(AC).trajectory(To).alt; %ft
                            %                     hdg1 = deg2rad(flight(AC).trajectory(To).heading); %rad
                            hdg1 = deg2rad(flight(AC).trajectory(From).heading); %rad
                            P3 = deg2nm([flight(AC).trajectory(To).long ; flight(AC).trajectory(To).lat]);
                            h3 = flight(AC).trajectory(To).alt;
                        else
                            if isempty(flight(AC).trajectory(From).distdiff)
                                distdiff = 0;
                            else
                                distdiff = flight(AC).trajectory(From).distdiff;
                            end
                            altdiff = distdiff / flight(AC).trajectory(From).distance * (flight(AC).trajectory(To).alt - flight(AC).trajectory(From).alt);
%                             altdiff = 0;
                            Vtas1 = flight(AC).trajectory(To).Vtas / 3600; % nm/sec
                            alt1 = flight(AC).trajectory(To).alt - altdiff; %ft
                            P3 = deg2nm([flight(AC).trajectory(To).long ; flight(AC).trajectory(To).lat]) - distdiff * [sin(hdg0) ; cos(hdg0)];
                            h3 = flight(AC).trajectory(To).alt - altdiff;
                        end
                    case 'free'
                        Vtas1 = flight(AC).trajectory(To).Vtas / 3600; % nm/sec
                        alt1 = flight(AC).trajectory(To).alt; %ft
                        %                     hdg1 = deg2rad(flight(AC).trajectory(To).heading); %rad
                        hdg1 = deg2rad(flight(AC).trajectory(From).heading); %rad
                        P3 = deg2nm([flight(AC).trajectory(To).long ; flight(AC).trajectory(To).lat]);
                        h3 = flight(AC).trajectory(To).alt;
                end

                AccelControl = 1;
                
                switch plan(flight(AC).id).Curve
                    case 'strict'
                        hdg1 = deg2rad(flight(AC).trajectory(From).heading); %rad
                        turn_flag = 1;
                    case 'free'
                        hdg1 = deg2rad(flight(AC).trajectory(To).heading); %rad
                        From = From + 1;
                        turn_flag = 0;
                    case 'semifree'
                        hdg1 = deg2rad(flight(AC).trajectory(To).heading); %rad
                        From = From + 1;
                        turn_flag = 0;
                end
            else
                if isempty(flight(AC).trajectory(From).distdiff)
                    distdiff = 0;
                else
                    distdiff = flight(AC).trajectory(From).distdiff;
                end
                altdiff = distdiff / flight(AC).trajectory(From).distance * (flight(AC).trajectory(To).alt - flight(AC).trajectory(From).alt);
%                 altdiff = 0;
                
                Vtas1 = flight(AC).trajectory(To).Vtas / 3600; % nm/sec
                alt1 = flight(AC).trajectory(To).alt + altdiff; %ft
                hdg1 = deg2rad(flight(AC).trajectory(To).heading); %rad
                
                P3 = deg2nm([flight(AC).trajectory(To).long ; flight(AC).trajectory(To).lat]) + distdiff * [sin(hdg1) ; cos(hdg1)];
                h3 = flight(AC).trajectory(To).alt + altdiff;
                turn_flag = 0;
                From = From + 1;
                
                AccelControl = 0;
            end
            

            
            
            dalt = unit.ft2nm * (alt1 - alt0); % nm
            
            %                 d = sqrt((P3 - P0)' * (P3 - P0)) + flight(AC).trajectory(From).turn_distance; % nm
            
            
            if isempty(flight(AC).trajectory(From).turn_distance)
                turn_dist = 0;
            else
                turn_dist = flight(AC).trajectory(From).turn_distance;
            end
            if isempty(flight(AC).trajectory(From).p_turn_distance)
                p_turn_dist = 0;
            else
                p_turn_dist = flight(AC).trajectory(From).p_turn_distance;
            end
            
            hdg_diff = abs(hdg1 - hdg0);
            if hdg_diff > 180
                hdg_diff = 360 - hdg_diff;
            end
            

            
            switch plan(flight(AC).id).Curve
                case 'strict'
                    d = sqrt((P3 - P0)' * (P3 - P0));
                case 'semifree'
                    d = sqrt((P3 - P0)' * (P3 - P0)) + turn_dist;
                case 'free'
                    d = sqrt((P3 - P0)' * (P3 - P0)) + turn_dist + p_turn_dist;        
            end
            

            
            dangle = atan(dalt / d); %rad

            L = sqrt(d^2 + dalt^2);
            
            EET = 2*L / (Vtas0 + Vtas1); % sec
            
            if AccelControl
                accel_long = (Vtas1 - Vtas0) / EET; % nm/s^2
                vs = unit.nm2ft *  dalt / EET; %ft/s
            else
                accel_long = al3;
                vs = vs3;
            end
            
         
            
            
            CurveFix = [CurveFix [[nm2deg(P0) ; h0] ; [nm2deg(P3) ; h3]]];
            P1 = P0;
            P2 = P0;
            h1 = h0;
            h2 = h0;
            
            
                 
%             
%             [d,psi] = distance(flight(AC).trajectory(From).lat, flight(AC).trajectory(From).long, flight(AC).trajectory(To).lat, flight(AC).trajectory(To).long);
%             
%             psi = deg2rad(psi);
            
%             d = flight(AC).trajectory(From).distance + flight(AC).trajectory(From).turn_distance;
            

            
            
            windcor = [atmos.wind.spd * EET * cos(deg2rad(atmos.wind.dir) - pi) ; atmos.wind.spd * EET * sin(deg2rad(atmos.wind.dir) - pi)];
            
            
%             hold on
%             plot3(P0(1), P0(2), h0, 'o')
%             plot3(P3(1), P3(2), h3, 'x')
%             PP1=plot3(P1(1), P1(2), h1, '^');
%             PP2=plot3(P2(1), P2(2), h2, '*');

            
            segno = segno + 1;
            forcount = 0;
            segEnd = 0;
            if EET - (update - segRemtime) < 0
                segEnd = 1;
                segRemtime = segRemtime + EET;
            end
            
            
            if hdg_diff < deg2rad(1)
                lambda0 = 0;
                lambda1 = 0;
            else
                lambda0 = config.Lambda(1);
                lambda1 = config.Lambda(2);
            end
            
            % [lambda0, lambda1] = OptimizeLambda(flight, P0, P3, EET, hdg0, hdg1, alt1, alt0)
            
            for time = (0 + (update - segRemtime)):update:EET
%                 segEnd = 0;
                if and(time==0, EET==0)
                    Vtasn = Vtas0 + (Vtas1 - Vtas0);
                    altn = alt0 + unit.nm2ft * dalt;
                else
                    Vtasn = Vtas0 + time * accel_long;
                    altn = alt0 + time * vs;
                    vs3 = vs;
                end
                % flight(AC).long = flight(AC).Vtas  * cos(ROD) * cos(wind)
                
                accel_vert = (vs - vs3) / EET; %ft/s^2
                
                P1 = P0 + (lambda0 * tau + 1/3) * L * [sin(hdg0) ; cos(hdg0)];
                h1 = h0 + (lambda0 * tau + 1/3) * (alt1 - alt0);
                P2 = P3 + (lambda1 * (tau - 1) - 1/3) * L * [sin(hdg1) ; cos(hdg1)];
                h2 = h3 + (lambda0 * (tau - 1) - 1/3) * (alt1 - alt0);
                PP1.XData = P1(1);
                PP1.YData = P1(2);
                
                PP2.XData = P2(1);
                PP2.YData = P2(2);
                
                switch flight(AC).trajectory(From).FS
                    case 'TX'
                        FS = 1;
                    case 'TO'
                        FS = 2;
                    case 'IC'
                        FS = 3;
                    case 'CR'
                        FS = 4;
                    case 'AP'
                        FS = 5;
                        
                    case 'LD'
                        FS = 6;
                        
                end
                
                BezierCurve = (1-tau)^3*P0 + 3*tau*(1-tau)^2*P1 + 3*tau^2*(1-tau)*P2 + tau^3*P3;


                %                 plot3(Reference(1,:), Reference(2,:), Reference(3,:),'r','linewidth',1.0)
                
                
                if segEnd == 0
                    Reference = [Reference [segno ; nm2deg(BezierCurve) ; altn ; 3600 * Vtasn ; Totaltime ; FS ; accel_long * unit.nm2ft ; vs ; accel_vert]];
                else
                end
                
                if (segRemtime + EET - ((forcount + 1) * update)) < update
                    segEnd = 1;
                    segRemtime = rem(segRemtime + EET,update);
%                     ReserveCoord = nm2deg(BezierCurve);
%                     ReserveAlt = altn;
                else
                    segEnd = 0;
%                     segRemtime = 0;
%                     ReserveCoord = [0 ; 0];
%                     ReserveAlt = 0;
                end
                
                Totaltime = Segtime + time;
                tau = tau + (Vtasn / L) * update;
                forcount = forcount + 1;
            end
            Segtime = Segtime + EET;
            
            ControlFix = [ControlFix [[nm2deg(P1) ; h1] ; [nm2deg(P2) ; h2]]];
            h3 = altn;
            v3 = Vtasn;
            al3 = accel_long;
            
%             hold on
%             plot(P0(1), P0(2), 'o')
%             plot(P1(1), P1(2), 'o')
%             plot(P2(1), P2(2), 'o')
%             plot(P3(1), P3(2), 'o')
%             text(P0(1), P0(2), 'P0')
%             text(P1(1), P1(2), 'P1')
%             text(P2(1), P2(2), 'P2')
%             text(P3(1), P3(2), 'P3')
            
        end
        
        
        
        
    end
    
    % Table로 하면 깔끔하긴한데 속도가 너무 떨어짐. 다시 array로 수정함.
%     flight(AC).Reference = array2table(Reference', 'VariableNames', {'SegmentNumber' 'Longitude' 'Latitude' 'Altitude' 'Airspeed' 'Time' 'FlightStatus' 'Acceleration_Long' 'VerticalSpeed' 'Acceleration_Vert'});
    flight(AC).Reference = Reference;
    flight(AC).CurveFix = CurveFix;
    flight(AC).ControlFix = ControlFix;
    
    
    % Reference Row Lookup List
    % 1: Segment Number
    % 2: Logitude (deg)
    % 3: Latitude (deg)
    % 4: Altitude (ft)
    % 5: Airspeed(TAS) (kt)
    % 6: Time (sec)
    % 7: FlightStatus - 1)Taxi 2)TakeOff 3)InitialClimb 4)Cruise 5)Appraoach 6)Landing
    % 8: Acceleration_Long (ft/sec^2)
    % 9: VerticalSpeed (ft/sec)
    % 10: Acceleration_Vert (ft/sec^2)

    % Final correction -> time diff가 매우 작은 경우 제외
    
    Check = 1;
    while Check
        for RefLen = 1:length(flight(AC).Reference(1,:)) - 1
            if flight(AC).Reference(6,RefLen + 1)  - flight(AC).Reference(6,RefLen) < config.TrajRes
                flight(AC).Reference(:,RefLen) = [];
                break;
            end
        end
        if RefLen == length(flight(AC).Reference(1,:)) - 1
            Check = 0;
        end
    end
    
%     RefEnd = height(flight(AC).Reference);
%     
%     flight(AC).Reference(8:16,RefEnd) = 0;
    
end

end