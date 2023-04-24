function flight = autopilot3(flight, Active)

global atmos config unit

for AClen = 1:length(Active)
    AC = Active(AClen);
    POS = [];
    CurveFix = [];
    ControlFix = [];
    % modify trajectory into Bezier Curve
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
            altn = 0;
            update = config.update;
            
    
            
            if From == 1
                Vtas0 = flight(AC).trajectory(From).Vtas / 3600; %nm/sec
                alt0 = flight(AC).trajectory(From).alt; %ft
                hdg0 = deg2rad(flight(AC).trajectory(From).heading); %rad
                P0 = deg2nm([flight(AC).trajectory(From).long ; flight(AC).trajectory(From).lat]);
                h0 = flight(AC).trajectory(From).alt;
                dalt = unit.ft2nm * (flight(AC).trajectory(To).alt - flight(AC).trajectory(From).alt); %degree
                d = flight(AC).trajectory(From).distance;
                dangle = atan(dalt / d); %rad
            else
                P0 = P3;
                h0 = h3;
                Vtas0 = v3; %nm/sec
                alt0 = h3; %ft
                hdg0 = deg2rad(flight(AC).trajectory(From).heading); %rad
            end

            if ~turn_flag
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
                    
                    Vtas1 = flight(AC).trajectory(To).Vtas / 3600; % nm/sec
                    alt1 = flight(AC).trajectory(To).alt - altdiff; %ft
                    hdg1 = deg2rad(flight(AC).trajectory(From).heading); %rad
                    P3 = deg2nm([flight(AC).trajectory(To).long ; flight(AC).trajectory(To).lat]) - distdiff * [sin(hdg0) ; cos(hdg0)];
                    h3 = flight(AC).trajectory(To).alt - altdiff;
                end

                turn_flag = 1;
            else
                if isempty(flight(AC).trajectory(From).distdiff)
                    distdiff = 0;
                else
                    distdiff = flight(AC).trajectory(From).distdiff;
                end
                altdiff = distdiff / flight(AC).trajectory(From).distance * (flight(AC).trajectory(To).alt - flight(AC).trajectory(From).alt);

                Vtas1 = flight(AC).trajectory(To).Vtas / 3600; % nm/sec
                alt1 = flight(AC).trajectory(To).alt + altdiff; %ft
                hdg1 = deg2rad(flight(AC).trajectory(To).heading); %rad
                
                P3 = deg2nm([flight(AC).trajectory(To).long ; flight(AC).trajectory(To).lat]) + distdiff * [sin(hdg1) ; cos(hdg1)];
                h3 = flight(AC).trajectory(To).alt + altdiff;
                turn_flag = 0;
                From = From + 1;
            end
            
            
            dalt = unit.ft2nm * (alt1 - alt0); % nm
            
            %                 d = sqrt((P3 - P0)' * (P3 - P0)) + flight(AC).trajectory(From).turn_distance; % nm
            d = sqrt((P3 - P0)' * (P3 - P0));
            dangle = atan(dalt / d); %rad
            
            L = sqrt(d^2 + dalt^2);
            
            EET = 2*L / (Vtas0 + Vtas1); % sec
            
            
            CurveFix = [CurveFix [P0 ; P3]];
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
            
            
            hold on
            plot3(P0(1), P0(2), h0, 'o')
            plot3(P3(1), P3(2), h3, 'x')
            PP1=plot3(P1(1), P1(2), h1, '^');
            PP2=plot3(P2(1), P2(2), h2, '*');

            lambda0 = 0.1;
            lambda1 = 0.1;
            
            for time = 0:update:EET
                Vtasn = Vtas0 + (Vtas1 - Vtas0) * (time/EET);
                altn = alt0 + unit.nm2ft * (dalt * (time/EET));
                % flight(AC).long = flight(AC).Vtas  * cos(ROD) * cos(wind)

                P1 = P0 + (lambda0 * tau + 1/3) * L * [sin(hdg0) ; cos(hdg0)];
                P2 = P3 + (lambda1 * (tau - 1) - 1/3) * L * [sin(hdg1) ; cos(hdg1)];
                PP1.XData = P1(1);
                PP1.YData = P1(2);
                
                PP2.XData = P2(1);
                PP2.YData = P2(2);
                
                Curve = (1-tau)^3*P0 + 3*tau*(1-tau)^2*P1 + 3*tau^2*(1-tau)*P2 + tau^3*P3;
                POS = [POS [nm2deg(Curve) ; altn ; 3600 * Vtasn]];
                
                
                plot3(POS(1,:), POS(2,:), POS(3,:),'r','linewidth',1.0)
                
                tau = tau + (Vtasn / L) * update;
                
                
            end
            ControlFix = [ControlFix [P1 ; P2]];
            h3 = altn;
            v3 = Vtasn;
            
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
    flight(AC).POS = POS;
    flight(AC).CurveFix = nm2deg(CurveFix);
    flight(AC).ControlFix = nm2deg(ControlFix);
    
end

end