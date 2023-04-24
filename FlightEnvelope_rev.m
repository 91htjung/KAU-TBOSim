% AssignConstraints
function flight = FlightEnvelope_rev(flight)
global atmos Perf unit


    % Reference Row Lookup List (A/C Performance Param)
    % 1: Segment Number
    % 2: Logitude (deg)
    % 3: Latitude (deg)
    % 4: Altitude (ft)
    % 5: Airspeed(TAS) (kt)
    % 6: Time (sec) - TrajectoryResolution defined in Configuration
    % 7: FlightStatus - 1)Taxi 2)TakeOff 3)InitialClimb 4)Cruise 5)Appraoach 6)Landing
    % 8: Longitudinal Acceleration (ft/sec^2)
    % 9: VerticalSpeed (ft/sec)
    % 10: Vertical Acceleration (ft/sec^2)
    % 11: RateOfClimbDescent (ft/min)
    % 12: Mass (kg)
    % 13: Thrust (kN)
    % 14: FuelFlow (kg/min)
    % 15: FuelperTime (kg/TrajResolution(sec))
    % 16: FuelUsed (kg)
    
    % Reference Row Lookup List (A/C Flight Envelope)
    % 17: Maximum Mass (t)
    % 18: Minimum Mass (t)
    % 19: Maximum Altitude (ft)
    % 20: Maximum Airspeed (kt)
    % 21: Minimum Airspeed (kt)
    % 22: Maximum Thrust (N)
    % 23: Maximum Longitudinal Acceleration (ft/sec^2)
    % 24: Maximum Normal Acceleration (ft/sec^2)
    
    % Reference Row Lookup List (Trajectory Data)
    % 25: Heading
    % 26: Curvature
    % 27: Bankangle
    % 28: Distance
    
    

% for i = 1:length(flight)
    msg = ['Validating & Simulating flight #' num2str(flight.id) ' Reference Trajectory'];
    [msg '.....initialize']
    flight.Reference(12,1) = flight.trajectory(1).mass * 1000; % mass kg
    flight.Reference(16,1) = 0; % Fuel Used kg
    
    for RefLen = 1:length(flight.Reference(1,:)) - 1
        flight.Reference(9,RefLen) = (flight.Reference(4,RefLen + 1) - flight.Reference(4,RefLen)) / (flight.Reference(6,RefLen + 1) - flight.Reference(6,RefLen)); % Vertical Speed ft/sec
        flight.Reference(10,RefLen) = (flight.Reference(9,RefLen + 1) - flight.Reference(9,RefLen)) / (flight.Reference(6,RefLen + 1) - flight.Reference(6,RefLen)); % Vertical Accel ft/sec^2
        flight.Reference(11,RefLen) = flight.Reference(9,RefLen) * 60; %ROCD ft/min
    end
   
    
    for RefLen = 1:length(flight.Reference(1,:)) - 1
        [msg '.....(' num2str(RefLen) '/' num2str(length(flight.Reference(1,:))) ')']
        
            
%         flight.Reference(7,RefLen) = (flight.Reference(4,RefLen + 1) - flight.Reference(4,RefLen)) * unit.nm2ft / 3600 / (flight.Reference(5,RefLen + 1) - flight.Reference(5,RefLen)); % accel_long ft/s^2
%         flight.Reference(9,RefLen) = (flight.Reference(8,RefLen + 1) - flight.Reference(8,RefLen)) / (flight.Reference(5,RefLen + 1) - flight.Reference(5,RefLen)); % Accel_Vert ft/sec^2
        
        
        [T, a, P, rho] = atmosisa((flight.Reference(4,RefLen) * unit.ft2meter));
        switch flight.Reference(7,RefLen)
            case 1
                bankangle = 0;
                Cd0 = 0;
                Cd2 = 0;
                CdLDG = 0;
                SFS = 'TX';
            case 2
                bankangle = 15;
                Cd0 = Perf.(flight.type).CD0_TO;
                Cd2 = Perf.(flight.type).CD2_TO;
                CdLDG = 0;
                SFS = 'TO';
            case 3
                bankangle = 35;
                Cd0 = Perf.(flight.type).CD0_IC;
                Cd2 = Perf.(flight.type).CD2_IC;
                CdLDG = 0;
                SFS = 'IC';
            case 4
                bankangle = 35;
                Cd0 = Perf.(flight.type).CD0_CR;
                Cd2 = Perf.(flight.type).CD2_CR;
                CdLDG = 0;
                SFS = 'CR';
            case 5
                bankangle = 35;
                Cd0 = Perf.(flight.type).CD0_AP;
                Cd2 = Perf.(flight.type).CD2_AP;
                CdLDG = 0;
                SFS = 'AP';
            case 6
                bankangle = 15;
                Cd0 = Perf.(flight.type).CD0_LD;
                Cd2 = Perf.(flight.type).CD2_LD;
                CdLDG = Perf.(flight.type).GearDown_CD0;
                SFS = 'LD';
            otherwise
                Cd0 = Perf.(flight.type).CD0_CR;
                Cd2 = Perf.(flight.type).CD2_CR;
                CdLDG = 0;
                bankangle = 35;
                SFS = 'CR';
        end
        
        
        mass =  flight.Reference(12,RefLen); % kilogram
        
        vs = flight.Reference(9,RefLen) * unit.ft2meter; % ft/s -> m/s
        TAS = flight.Reference(5,RefLen) * unit.nm2meter / 3600; % kt -> m/s
        
        accel_long = flight.Reference(8,RefLen) * unit.ft2meter; % ft/s^2 -> m/s^2
        accel_vert = flight.Reference(10,RefLen) * unit.ft2meter; % ft/s^2 -> m/s^2
        
        Surf = Perf.(flight.type).Surf;
        g = atmos.g_0; % m/s^2

        Lift = mass * (g + accel_vert);
        qS = rho * (TAS ^ 2) * Surf / 2;
        
        LiftCoeff = Lift / qS;
        DragCoeff = (Cd0 + CdLDG) + (Cd2 * (LiftCoeff^2));
        Drag = DragCoeff * qS;
%         Thrust = Drag + (mass * (accel_vert)) + (mass * accel_long);
        
        Thrust = max(0, Drag + (mass * atmos.g_0 * vs / TAS) + (mass * accel_long));
        
        flight.Reference(13,RefLen) = Thrust / 1000;
        
        
        CF1 = Perf.(flight.type).Thrust_Fuel1; % Jet:kg/(min*kN)  Turboprop:kg/(min*kN*kt)  Piston:kg/min
        CF2 = Perf.(flight.type).Thrust_Fuel2; % kt
        CF3 = Perf.(flight.type).Descent_Fuel3; % kg/min
        CF4 = Perf.(flight.type).Descent_Fuel4; % ft
        CFCR = Perf.(flight.type).Cruise_Fuel; % dimensionless
        
        switch Perf.(flight.type).Engtype
            case 'Jet'
                mu = CF1 * (1 + (flight.Reference(5,RefLen) / CF2));
                FuelNom = mu * Thrust / 1000;
                FuelMin = CF3 * (1 - (geoalt(flight.Reference(4,RefLen)) / CF4));
                FuelAPLD = max(FuelNom, FuelMin);
                FuelCR = mu * Thrust / 1000 * CFCR;
            case 'Turboprop'
                mu = CF1 * (1 - (flight.Reference(5,RefLen) / CF2)) * (flight.Reference(5,RefLen) / 1000);
                FuelNom = mu * Thrust / 1000;
                FuelMin = CF3 * (1 - (geoalt(flight.Reference(4,RefLen)) / CF4));
                FuelAPLD = max(FuelNom, FuelMin);
                FuelCR = mu * Thrust / 1000 * CFCR;
            case 'Piston'
                FuelNom = CF1;
                FuelMin = CF3;
                FuelAPLD = FuelNom;
                FuelCR = CF1 * CFCR;
        end
            
            
            %     flight.trajectory(TrajLen).FuelMin = FuelMin;
            
            switch flight.Reference(7,RefLen)
                case 1
                    flight.Reference(14,RefLen) = FuelNom;
                    
                case 4
                    flight.Reference(14,RefLen) = FuelCR;
                    
                case {5 6}
                    flight.Reference(14,RefLen) = FuelAPLD;
                    
                otherwise
                    flight.Reference(14,RefLen) = FuelNom;
            end
            
            flight.Reference(15,RefLen) = flight.Reference(14,RefLen) * ((flight.Reference(6,RefLen + 1) - flight.Reference(6,RefLen)) / 60); % Fuel Used
            flight.Reference(16,RefLen + 1) = flight.Reference(16,RefLen) + flight.Reference(15,RefLen); % cumulative Fuel consumption
            flight.Reference(12,RefLen + 1) = flight.Reference(12,RefLen) - flight.Reference(15,RefLen);  %mass
            
            
            %     % 1. MASS
            Mass_min=Perf.(flight.type).Mass_min;
            Mass_max=Perf.(flight.type).Mass_max;
            mass_cor=sqrt((flight.Reference(12,RefLen) / 1000)/Perf.(flight.type).Mass_ref);
            
%             flight.Reference(17,RefLen) = Mass_min;
%             flight.Reference(18,RefLen) = Mass_max;
            
            %     % 2. ALTITUDE
            Alt_max = (Perf.(flight.type).Hmax == 0) * Perf.(flight.type).MaxAlt + (Perf.(flight.type).Hmax ~= 0) * min(Perf.(flight.type).Hmax, Perf.(flight.type).MaxAlt + (Perf.(flight.type).TempGrad * max((atmos.Td - Perf.(flight.type).MaxClimbThrust_4),0))+(Perf.(flight.type).Mass_massGrad * ((Perf.(flight.type).Mass_max*1000)-((flight.Reference(12,RefLen) / 1000)*1000))));
            
%             flight.Reference(19,RefLen) = max(Alt_max,0);
            
            %     % 3. AIRSPEED
            %     % minimum speed
            
            if strcmp(SFS, 'TX') == 1
                TAS_min = 0;
            else
                TAS_min_jet = (geoalt(flight.Reference(4,RefLen)) < 15000) * (((strcmp(SFS, 'TO') == 1) * (cas2tas(1.2*mass_cor*Perf.(flight.type).(['Vstall_' SFS ]),flight.Reference(4,RefLen)))) + ((strcmp(SFS, 'TO') == 0) * (cas2tas(1.3*mass_cor*Perf.(flight.type).(['Vstall_' SFS ]),flight.Reference(4,RefLen))))) + (geoalt(flight.Reference(4,RefLen)) >= 15000) * max(cas2tas(1.3*mass_cor*Perf.(flight.type).(['Vstall_' SFS]),flight.Reference(4,RefLen)),0);
                TAS_min_fly = (strcmp(Perf.(flight.type).Engtype,'Jet')) * (TAS_min_jet) + (strcmp(Perf.(flight.type).Engtype,'Jet') == 0) * cas2tas(1.3*mass_cor*Perf.(flight.type).(['Vstall_' SFS]),flight.Reference(4,RefLen));
                TAS_min = (strcmp(SFS,'TX') == 0) * ((strcmp(Perf.(flight.type).Engtype,'Jet') == 1) * TAS_min_fly);
            end
%             flight.Reference(21,RefLen) = max(TAS_min - 10, 0);
            
            % maximum speed check
            if flight.Reference(4,RefLen) < Perf.(flight.type).Machtrans_cruise; % CAS 운항(Machtrans alt 이하) maximum spd(VMO) 이상
                TAS_max = cas2tas(Perf.(flight.type).VMO,flight.Reference(4,RefLen));
            else % Mach 운항(Machtrans alt 이상) maximum spd(MMO) 이상
                TAS_max = mach2tas(Perf.(flight.type).MMO,flight.Reference(4,RefLen));
            end
%             flight.Reference(20,RefLen) = TAS_max;
            
            %     % 4. ENGINE THRUST & Reduced Climb Power (nomial ROCD)
            %
            switch Perf.(flight.type).Engtype
                case 'Jet'
                    ISA_Max_Thrust = Perf.(flight.type).MaxClimbThrust_1 * (1 - (geoalt(flight.Reference(4,RefLen)) / Perf.(flight.type).MaxClimbThrust_2) + ((Perf.(flight.type).MaxClimbThrust_3) * ((geoalt(flight.Reference(4,RefLen)) ^ 2))));
                case 'Turboprop'
                    ISA_Max_Thrust = (((Perf.(flight.type).MaxClimbThrust_1) / (flight.Reference(5,RefLen))) * (1 - ((geoalt(flight.Reference(4,RefLen)) / (Perf.(flight.type).MaxClimbThrust_2))))) + (Perf.(flight.type).MaxClimbThrust_3);
                case 'Piston'
                    ISA_Max_Thrust = (Perf.(flight.type).MaxClimbThrust_1 * (1 - ((geoalt(flight.Reference(4,RefLen)) / (Perf.(flight.type).MaxClimbThrust_2))))) + ((Perf.(flight.type).MaxClimbThrust_3) / (flight.Reference(5,RefLen)));
            end
            
            dTeff = atmos.Td - Perf.(flight.type).MaxClimbThrust_4;
            if dTeff < 0
                dTeff = 0;
            elseif dTeff > 0.4
                dTeff = 0.4;
            end
            
            Max_Thrust =ISA_Max_Thrust * (1 - ((Perf.(flight.type).MaxClimbThrust_5) * (dTeff)));
            
%             flight.Reference(22,RefLen) = Max_Thrust;
            %
            %     %expedite climb/descent가 아닌 경우 ROCD에 C_pow_red 적용 -> BADA 3.8.2 pp24
            %
            %     % 5. Maximum acceleration
            al_max = 2.0;
            an_max = 5.0;
            
%             flight.Reference(23,RefLen) =  al_max;
%             flight.Reference(24,RefLen) = an_max;

            
            
            hdg = rad2deg(atan2(flight.Reference(2,RefLen + 1) - flight.Reference(2,RefLen), flight.Reference(3,RefLen + 1) - flight.Reference(3,RefLen)));
            if hdg < 0
                hdg = hdg + 360;
            end
            
%             flight.Reference(25,RefLen) = hdg;
            
            
%             flight.Reference(26,RefLen) = Lift;
%             flight.Reference(27,RefLen) = Drag;
            
        
    end
    
    
    
%     
%     
%     flight.trajectory(l).lowalt = max([0 (~isempty(flight.trajectory(l).lowalt) * flight.trajectory(l).lowalt) (flight.manual.alt * flight.manual.control_alt)]);
%     flight.trajectory(l).highalt = min([100000 flight.FE.Alt_max flight.trajectory(l).highalt (flight.manual.alt * flight.manual.control_alt)]);
%     
%     if flight.trajectory(l).highalt - flight.trajectory(l).lowalt < 100;
%         flight.trajectory(l).alt = flight.trajectory(l).lowalt;
%     end
%     
%     if strcmp(flight.trajectory(l).type, 'vectoring') == 0
%         fix_alt=find(~cellfun(@isempty,{flight.trajectory(:).alt}));
%         
%     end
%     
    
end
% initial FS Assign
