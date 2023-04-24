function flight_profile = FuelConsumption(flight_profile)

global Perf

CF1 = Perf.(flight_profile.type).Thrust_Fuel1; % Jet:kg/(min*kN)  Turboprop:kg/(min*kN*kt)  Piston:kg/min
CF2 = Perf.(flight_profile.type).Thrust_Fuel2; % kt
CF3 = Perf.(flight_profile.type).Descent_Fuel3; % kg/min
CF4 = Perf.(flight_profile.type).Descent_Fuel4; % ft
CFCR = Perf.(flight_profile.type).Cruise_Fuel; % dimensionless


for TrajLen = 1:length(flight_profile.trajectory) - 1
    
    switch Perf.(flight_profile.type).Engtype
        case 'Jet'
            mu = CF1 * (1 + (flight_profile.trajectory(TrajLen).Vtas / CF2));
            FuelNom = mu * flight_profile.trajectory(TrajLen).Thrust / 1000;
            FuelMin = CF3 * (1 - (geoalt(flight_profile.trajectory(TrajLen).alt) / CF4));
            FuelAPLD = max(FuelNom, FuelMin);
            FuelCR = mu * flight_profile.trajectory(TrajLen).Thrust / 1000 * CFCR;
        case 'Turboprop'
            mu = CF1 * (1 - (flight_profile.trajectory(TrajLen).Vtas / CF2)) * (flight_profile.trajectory(TrajLen).Vtas / 1000);
            FuelNom = mu * flight_profile.trajectory(TrajLen).Thrust / 1000;
            FuelMin = CF3 * (1 - (geoalt(flight_profile.trajectory(TrajLen).alt) / CF4));
            FuelAPLD = max(FuelNom, FuelMin);
            FuelCR = mu * flight_profile.trajectory(TrajLen).Thrust / 1000 * CFCR;
        case 'Piston'
            FuelNom = CF1;
            FuelMin = CF3;
            FuelAPLD = FuelNom;
            FuelCR = CF1 * CFCR;
    end


%     flight_profile.trajectory(TrajLen).FuelMin = FuelMin;
    
    switch flight_profile.trajectory(TrajLen).FS
        case 'TX'
            flight_profile.trajectory(TrajLen).FuelFlow = FuelNom;

        case 'CR'
            flight_profile.trajectory(TrajLen).FuelFlow = FuelCR;

        case {'AP' 'LD'}
            flight_profile.trajectory(TrajLen).FuelFlow = FuelAPLD;

        otherwise
            flight_profile.trajectory(TrajLen).FuelFlow = FuelNom;
    end
    
    flight_profile.trajectory(TrajLen).FuelUsed = flight_profile.trajectory(TrajLen).FuelFlow * (flight_profile.trajectory(TrajLen).EET / 60);
end
