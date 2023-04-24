function flight_profile = CalculateThrust(flight_profile)

global atmos Perf unit
Surf = Perf.(flight_profile.type).Surf;
g = atmos.g_0; % m/s^2

for TrajLen = 1:length(flight_profile.trajectory) - 1
    [T, a, P, rho] = atmosisa((flight_profile.trajectory(TrajLen).alt*unit.ft2meter));

    
    % 여기서, trajectory 내 turning segement를 제외한 accel_segment에서 ACC적용 그 외 T=D
    switch flight_profile.trajectory(TrajLen).FS
        case 'TX'
            bankangle = 0;
            Cd0 = 0;
            Cd2 = 0;
            CdLDG = 0;
        case 'TO'
            bankangle = 15;
            Cd0 = Perf.(flight_profile.type).CD0_TO;
            Cd2 = Perf.(flight_profile.type).CD2_TO;
            CdLDG = 0;
        case 'IC'
            bankangle = 35;
            Cd0 = Perf.(flight_profile.type).CD0_IC;
            Cd2 = Perf.(flight_profile.type).CD2_IC;
            CdLDG = 0;
        case 'CR'
            bankangle = 35;
            Cd0 = Perf.(flight_profile.type).CD0_CR;
            Cd2 = Perf.(flight_profile.type).CD2_CR;
            CdLDG = 0;
        case 'AP'
            bankangle = 35;
            Cd0 = Perf.(flight_profile.type).CD0_AP;
            Cd2 = Perf.(flight_profile.type).CD2_AP;
            CdLDG = 0;
        case 'LD'
            bankangle = 15;
            Cd0 = Perf.(flight_profile.type).CD0_LD;
            Cd2 = Perf.(flight_profile.type).CD2_LD;
            CdLDG = Perf.(flight_profile.type).GearDown_CD0;
        otherwise
            Cd0 = Perf.(flight_profile.type).CD0_CR;
            Cd2 = Perf.(flight_profile.type).CD2_CR;
            CdLDG = 0;
            bankangle = 35;
    end
    % accelerating segment는 bankangle = 0;
    
%     (Thr - D) * Vtas = mass * g * vs + mass * Vtas * accel_long
    
    mass = flight_profile.trajectory(TrajLen).mass * 1000; % ton -> kilogram
    
    vs = flight_profile.trajectory(TrajLen).vs * unit.ft2meter; % ft/s -> m/s
    TAS = flight_profile.trajectory(TrajLen).SegmentTAS * unit.nm2meter / 3600; % kt -> m/s
%     if TrajLen < length(flight_profile.trajectory)
%         TAS = flight_profile.trajectory(TrajLen + 1).Vtas * unit.nm2meter / 3600;
%     else
%         TAS = 0;
%     end
    
    accel_long = flight_profile.trajectory(TrajLen).accel_long * unit.ft2meter; % ft/s^2 -> m/s^2
    accel_vert = flight_profile.trajectory(TrajLen).accel_vert * unit.ft2meter; % ft/s^2 -> m/s^2
    
    Lift = mass * (g + accel_vert);
    qS = rho * (TAS ^ 2) * Surf / 2;

    Accel_LiftCoeff = Lift / qS;
    Accel_DragCoeff = (Cd0 + CdLDG) + (Cd2 * (Accel_LiftCoeff^2));
    Accel_Drag = Accel_DragCoeff * qS;
%     Accel_Thrust = Accel_Drag + (mass * (accel_vert)) + (mass * accel_long);
  
    % New TEM Equation
    Accel_Thrust = max(0, Accel_Drag + (mass * atmos.g_0 * vs / TAS) + (mass *accel_long));


    % turning segment

    Turn_LiftCoeff = (mass * g) / (qS * cos(deg2rad(bankangle)));
    Turn_DragCoeff = (Cd0 + CdLDG) + (Cd2 * (Turn_LiftCoeff ^ 2));
    Turn_Drag = Turn_DragCoeff * qS;
    Turn_Thrust = Turn_Drag;
        
    flight_profile.trajectory(TrajLen).Lift = Lift;
    
%     flight_profile.trajectory(TrajLen).Accel_Drag = Accel_Drag;
%     flight_profile.trajectory(TrajLen).Turn_Drag = Turn_Drag;

%     flight_profile.trajectory(TrajLen).Accel_Thrust = Accel_Thrust;
%     flight_profile.trajectory(TrajLen).Turn_Thrust = Turn_Thrust;

%     accel_time_rate = flight_profile.trajectory(TrajLen).accel_time / flight_profile.trajectory(TrajLen).EET;
    
%     flight_profile.trajectory(TrajLen).Thrust = accel_time_rate * Accel_Thrust + (1 - accel_time_rate) * Turn_Thrust;
    flight_profile.trajectory(TrajLen).Thrust = max(0, Accel_Thrust);

%     ReducedLift = Lift * (1 - cos(deg2rad(bankangle)));
%     flight_profile.trajectory(TrajLen).ReducedLift = (ReducedLift / mass) / unit.ft2meter;
%     accel_lost = Accel_Thrust - Turn_Thrust;
%     flight_profile.trajectory(TrajLen).accel_lost = (accel_lost / mass) / unit.ft2meter * (flight_profile.trajectory(TrajLen).turn_time * 2);
    
    % Maximum Thrust
    switch Perf.(flight_profile.type).Engtype
        case 'Jet'
            ISA_Max_Thrust = Perf.(flight_profile.type).MaxClimbThrust_1 * (1 - (geoalt(flight_profile.trajectory(TrajLen).alt) / Perf.(flight_profile.type).MaxClimbThrust_2) + ((Perf.(flight_profile.type).MaxClimbThrust_3) * ((geoalt(flight_profile.trajectory(TrajLen).alt) ^ 2))));
            if geoalt(flight_profile.trajectory(TrajLen).alt) < 0.8 * Perf.(flight_profile.type).Hmax
                C_red = 0.15;
            else
                C_red = 0;
            end
        case 'Turboprop'
            ISA_Max_Thrust = (((Perf.(flight_profile.type).MaxClimbThrust_1) / (flight_profile.trajectory(TrajLen).Vtas)) * (1 - ((geoalt(flight_profile.trajectory(TrajLen).alt) / (Perf.(flight_profile.type).MaxClimbThrust_2))))) + (Perf.(flight_profile.type).MaxClimbThrust_3);
            if geoalt(flight_profile.trajectory(TrajLen).alt) < 0.8 * Perf.(flight_profile.type).Hmax
                C_red = 0.25;
            else
                C_red = 0;
            end
        case 'Piston'
            ISA_Max_Thrust = (Perf.(flight_profile.type).MaxClimbThrust_1 * (1 - ((geoalt(flight_profile.trajectory(TrajLen).alt) / (Perf.(flight_profile.type).MaxClimbThrust_2))))) + ((Perf.(flight_profile.type).MaxClimbThrust_3) / (flight_profile.trajectory(TrajLen).Vtas));
            C_red = 0.0;
    end
    
    dTeff = atmos.Td - Perf.(flight_profile.type).MaxClimbThrust_4;
    
    dTeff = min(max(0, dTeff), (0.4 / Perf.(flight_profile.type).MaxClimbThrust_5));
    
    
    Max_Thrust =ISA_Max_Thrust * (1 - ((Perf.(flight_profile.type).MaxClimbThrust_5) * (dTeff)));
    flight_profile.trajectory(TrajLen).Max_Thrust = Max_Thrust;
    
    Red_ClimbPower = 1 - (C_red * ((Perf.(flight_profile.type).Mass_max - flight_profile.trajectory(TrajLen).mass) / (Perf.(flight_profile.type).Mass_max - Perf.(flight_profile.type).Mass_min)));
%     flight_profile.trajectory(TrajLen).Red_CP = Red_ClimbPower;
    
    switch flight_profile.trajectory(TrajLen).FS
        case 'CR'
            flight_profile.trajectory(TrajLen).BADA_Thrust = 0.95 * Max_Thrust;
        case {'AP' 'HD'}
            if geoalt(flight_profile.trajectory(TrajLen).alt) >= Perf.(flight_profile.type).Desc_Level
                flight_profile.trajectory(TrajLen).BADA_Thrust = Perf.(flight_profile.type).ClimbThrust_des_high * Max_Thrust;
            elseif and(geoalt(flight_profile.trajectory(TrajLen).alt) < Perf.(flight_profile.type).Desc_Level, geoalt(flight_profile.trajectory(TrajLen).alt) >= 8000)
                flight_profile.trajectory(TrajLen).BADA_Thrust = Perf.(flight_profile.type).ClimbThrust_des_low * Max_Thrust;
            else
                flight_profile.trajectory(TrajLen).BADA_Thrust = Perf.(flight_profile.type).ClimbThrust_des_app * Max_Thrust;
            end
        case 'LD'
            flight_profile.trajectory(TrajLen).BADA_Thrust = Perf.(flight_profile.type).ClimbThrust_des_ld * Max_Thrust;
        case {'TO', 'IC'}
            flight_profile.trajectory(TrajLen).BADA_Thrust = Red_ClimbPower * Max_Thrust;
        otherwise
            flight_profile.trajectory(TrajLen).BADA_Thrust = 0.95 * Max_Thrust;
    end
    if flight_profile.trajectory(TrajLen).Thrust == 0
        flight_profile.trajectory(TrajLen).BADA_Thrust = 0;
    end
%     flight_profile.trajectory(TrajLen).ROCDfm = round((flight_profile.trajectory(TrajLen).vs * 60) / (flight_profile.trajectory(TrajLen).Vtas / unit.ft2meter / 60), 3);
flight_profile.trajectory(TrajLen).ROCDfm = round((flight_profile.trajectory(TrajLen).vs * 60));

%     flight_profile.trajectory(TrajLen).Max_Thrust;
%     flight_profile.trajectory(TrajLen).Accel_ThrustRate = flight_profile.trajectory(TrajLen).Accel_Thrust / flight_profile.trajectory(TrajLen).Max_Thrust;
%     flight_profile.trajectory(TrajLen).Turn_ThrustRate = flight_profile.trajectory(TrajLen).Turn_Thrust / flight_profile.trajectory(TrajLen).Max_Thrust;

flight_profile.trajectory(TrajLen).ThrustRate = flight_profile.trajectory(TrajLen).Thrust / flight_profile.trajectory(TrajLen).Max_Thrust;

    
end




