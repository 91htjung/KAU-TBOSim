%% TrajectoryValidation
function [flight_profile, ValidateProgress] = TrajectoryValidation(flight_profile)

global atmos Perf

for TrajLen = 1:length(flight_profile.trajectory) - 1
    % A. Flight Envelope
    [T,a,p,rho]=atmosisa(flight_profile.trajectory(TrajLen).alt);
    
    % 1. MASS
    Mass_min=Perf.(flight_profile.type).Mass_min;
    Mass_max=Perf.(flight_profile.type).Mass_max;
    mass_cor=sqrt(flight_profile.trajectory(TrajLen).mass/Perf.(flight_profile.type).Mass_ref);
    
    % 2. ALTITUDE
    Alt_max = (Perf.(flight_profile.type).Hmax == 0) * Perf.(flight_profile.type).MaxAlt + (Perf.(flight_profile.type).Hmax ~= 0) * min(Perf.(flight_profile.type).Hmax, Perf.(flight_profile.type).MaxAlt + (Perf.(flight_profile.type).TempGrad * max((atmos.Td - Perf.(flight_profile.type).MaxClimbThrust_4),0))+(Perf.(flight_profile.type).Mass_massGrad * ((Perf.(flight_profile.type).Mass_max*1000)-(flight_profile.trajectory(TrajLen).mass*1000))));
    
    % 3. AIRSPEED
    % minimum speed
    
    % 아래는 Low Speed Buffet Limit에 관한 식. 추후 확인해보고 수정할 것.
    
    % a1 = -1 * Perf.(flight(i).type).Clbo / Perf.(flight(i).type).k;
    % a2 = 0;
    % a3 = (flight(i).mass * atmos.g_0 * 1000) / (Perf.(flight(i).type).Surf * Perf.(flight(i).type).k * p * 0.5830);
    %
    % Q = ((3 * a2) - (a1^2)) / 9;
    % R = ((9 * a1 * a2) - (27 * a3) - (2 * (a1^3))) / 54;
    % theta = acos(R / ((-1 * Q)^(1/3)));
    %
    % X1 = 2 * sqrt(-1 * Q) * cos(theta / 3) - (a1 / 3);
    % X2 = 2 * sqrt(-1 * Q) * cos((theta / 3) + deg2rad(120)) - (a1 / 3);
    % X3 = 2 * sqrt(-1 * Q) * cos((theta / 3) + deg2rad(240)) - (a1 / 3);
    % X=[X1 X2 X3];
    % TAS_min_jet = (geoalt(flight(i).alt) < 15000) * (((strcmp(flight(i).FS, 'TO') == 1) * (cas2tas(1.2*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS ]),flight(i).alt))) + ((strcmp(flight(i).FS, 'TO') == 0) * (cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS ]),flight(i).alt)))) + (geoalt(flight(i).alt) >= 15000) * max(cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS]),flight(i).alt),mach2tas(min(X(X>0)),flight(i).alt));
    % TAS_min_fly = (strcmp(Perf.(flight(i).type).Engtype,'Jet')) * (TAS_min_jet) + (strcmp(Perf.(flight(i).type).Engtype,'Jet') == 0) * cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS]),flight(i).alt);
    % TAS_min = (strcmp(flight(i).FS,'TX') == 0) * ((strcmp(Perf.(flight(i).type).Engtype,'Jet') == 1) * TAS_min_fly);
    if strcmp(flight_profile.trajectory(TrajLen).FS, 'TX') == 1
        TAS_min = 0;
    else
        TAS_min_jet = (geoalt(flight_profile.trajectory(TrajLen).alt) < 15000) * (((strcmp(flight_profile.trajectory(TrajLen).FS, 'TO') == 1) * (cas2tas(1.2*mass_cor*Perf.(flight_profile.type).(['Vstall_' flight_profile.trajectory(TrajLen).FS ]),flight_profile.trajectory(TrajLen).alt))) + ((strcmp(flight_profile.trajectory(TrajLen).FS, 'TO') == 0) * (cas2tas(1.3*mass_cor*Perf.(flight_profile.type).(['Vstall_' flight_profile.trajectory(TrajLen).FS ]),flight_profile.trajectory(TrajLen).alt)))) + (geoalt(flight_profile.trajectory(TrajLen).alt) >= 15000) * max(cas2tas(1.3*mass_cor*Perf.(flight_profile.type).(['Vstall_' flight_profile.trajectory(TrajLen).FS]),flight_profile.trajectory(TrajLen).alt),0);
        TAS_min_fly = (strcmp(Perf.(flight_profile.type).Engtype,'Jet')) * (TAS_min_jet) + (strcmp(Perf.(flight_profile.type).Engtype,'Jet') == 0) * cas2tas(1.3*mass_cor*Perf.(flight_profile.type).(['Vstall_' flight_profile.trajectory(TrajLen).FS]),flight_profile.trajectory(TrajLen).alt);
        TAS_min = (strcmp(flight_profile.trajectory(TrajLen).FS,'TX') == 0) * ((strcmp(Perf.(flight_profile.type).Engtype,'Jet') == 1) * TAS_min_fly);
    end
    % maximum speed check
    if flight_profile.trajectory(TrajLen).alt < Perf.(flight_profile.type).Machtrans_cruise; % CAS 운항(Machtrans alt 이하) maximum spd(VMO) 이상
        TAS_max = cas2tas(Perf.(flight_profile.type).VMO,flight_profile.trajectory(TrajLen).alt);
    else % Mach 운항(Machtrans alt 이상) maximum spd(MMO) 이상
        TAS_max = mach2tas(Perf.(flight_profile.type).MMO,flight_profile.trajectory(TrajLen).alt);
    end
    
    % 4. ENGINE THRUST & Reduced Climb Power (nomial ROCD)
    
    switch Perf.(flight_profile.type).Engtype
        case 'Jet'
            THR_max_ISA = Perf.(flight_profile.type).MaxClimbThrust_1 * (1 - ((geoalt(flight_profile.trajectory(TrajLen).alt))/(Perf.(flight_profile.type).MaxClimbThrust_2)) + (Perf.(flight_profile.type).MaxClimbThrust_3 * ((geoalt(flight_profile.trajectory(TrajLen).alt))^2)));
        case 'Turboprop'
            THR_max_ISA = ((Perf.(flight_profile.type).MaxClimbThrust_1)/(flight_profile.trajectory(TrajLen).Vtas)) * (1 - ((geoalt(flight_profile.trajectory(TrajLen).alt))/(Perf.(flight_profile.type).MaxClimbThrust_2))) + Perf.(flight_profile.type).MaxClimbThrust_3;
        case 'Piston'
            THR_max_ISA = Perf.(flight_profile.type).MaxClimbThrust_1 * (1 - ((geoalt(flight_profile.trajectory(TrajLen).alt))/(Perf.(flight_profile.type).MaxClimbThrust_2))) + ((Perf.(flight_profile.type).MaxClimbThrust_3)/(flight_profile.trajectory(TrajLen).Vtas));
    end
    
    dTeff = atmos.Td - Perf.(flight_profile.type).MaxClimbThrust_4;
    if dTeff < 0
        dTeff = 0;
    elseif dTeff > 0.4
        dTeff = 0.4;
    end
    
    THR_max=THR_max_ISA * (1 - (Perf.(flight_profile.type).MaxClimbThrust_5)*(dTeff));

    %expedite climb/descent가 아닌 경우 ROCD에 C_pow_red 적용 -> BADA 3.8.2 pp24
    
    % 5. Maximum acceleration
    
    al_max = 2.0;
    an_max = 5.0;
    


    if flight_profile.trajectory(TrajLen).mass < Mass_min
        ['warning! flight #' num2str(flight_profile.id) ' trajectory #' num2str(TrajLen) ' has mass(' num2str(flight_profile.trajectory(TrajLen).mass) ') lower than minimum mass(' num2str(Mass_min) ')']
    elseif flight_profile.trajectory(TrajLen).mass > Mass_max
        ['warning! flight #' num2str(flight_profile.id) ' trajectory #' num2str(TrajLen) ' has mass(' num2str(flight_profile.trajectory(TrajLen).mass) ') higher than maximum mass(' num2str(Mass_max) ')']
    end
    
    if flight_profile.trajectory(TrajLen).alt > Alt_max
        ['warning! flight #' num2str(flight_profile.id) ' trajectory #' num2str(TrajLen) ' has altitude(' num2str(flight_profile.trajectory(TrajLen).alt) ') higher than maximum altitude(' num2str(Alt_max) ')']
    end
    
    if flight_profile.trajectory(TrajLen).Vtas < TAS_min
        ['warning! flight #' num2str(flight_profile.id) ' trajectory #' num2str(TrajLen) ' has TAS(' num2str(flight_profile.trajectory(TrajLen).Vtas) ') lower than minimum TAS(' num2str(TAS_min) ')']
    elseif flight_profile.trajectory(TrajLen).Vtas > TAS_max
        ['warning! flight #' num2str(flight_profile.id) ' trajectory #' num2str(TrajLen) ' has TAS(' num2str(flight_profile.trajectory(TrajLen).Vtas) ') higher than maximum TAS(' num2str(TAS_max) ')']
    end
    
    if abs(flight_profile.trajectory(TrajLen).max_accel_long) > al_max
        ['warning! flight #' num2str(flight_profile.id) ' trajectory #' num2str(TrajLen) ' has longitudinal acceleration(' num2str(flight_profile.trajectory(TrajLen).max_accel_long) ') greater than 2)']
    end
    
    if abs(flight_profile.trajectory(TrajLen).max_accel_normal) > an_max
        ['warning! flight #' num2str(flight_profile.id) ' trajectory #' num2str(TrajLen) ' has normal acceleration(' num2str(flight_profile.trajectory(TrajLen).max_accel_long) ') greater than 5)']
    end
    
    
    if flight_profile.trajectory(TrajLen).Thrust > THR_max
        ['warning! flight #' num2str(flight_profile.id) ' trajectory #' num2str(TrajLen) 'has Thrust(' num2str(flight_profile.trajectory(TrajLen).Thrust) ') higher than maximum Thrust(' num2str(THR_max) ')']
    end
        
end

ValidateProgress = false;

end