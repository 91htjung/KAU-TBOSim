function flight = UpdateParam(RunTime, flight)

global config Weather

winddir = 0;
windspd = 0;

if config.WindOpt
    
%     Get wind data
    for SecLen = 1:length(Weather.Sector)
        in = inpolygon(flight.long, flight.lat, [Weather.Sector(SecLen).Layer.Long]', [Weather.Sector(SecLen).Layer.Lat]');
        if in
            if and(flight.alt >= Weather.Sector(SecLen).Layer(1).LowAlt, flight.alt <= Weather.Sector(SecLen).Layer(1).HighAlt)
                if RunTime >= Weather.Sector(SecLen).WX(end).ActiveTime
                    winddir = Weather.Sector(SecLen).WX(end).WindDirection;
                    windspd = Weather.Sector(SecLen).WX(end).WindSpeed;
                else
                    for TimeLayer = 1:length(Weather.Sector(SecLen).WX) - 1
                        if and(RunTime >= Weather.Sector(SecLen).WX(TimeLayer).ActiveTime, RunTime < Weather.Sector(SecLen).WX(TimeLayer + 1).ActiveTime)
                            winddir = Weather.Sector(SecLen).WX(TimeLayer).WindDirection;
                            windspd = Weather.Sector(SecLen).WX(TimeLayer).WindSpeed;
                        end
                    end
                end
            end
        end
    end
    
    if config.WindNoise
        winddir = winddir + rad2deg(normrnd(config.WindMu(1), config.WindSigma(1)));
        windspd = windspd + normrnd(config.WindMu(2), config.WindSigma(2));
        
    end
    Weather.Wind(flight.id).dir = winddir;
    Weather.Wind(flight.id).spd = windspd;
    
end
    

if or(flight.id == 11, flight.id == 13)
    winddir = 360;
    windspd = 10;
else
    winddir = 0;
    windspd = 0;
end

OldVtas = flight.Vtas;
Oldhdg = flight.hdg;
OldROCD = flight.ROCD;

flight.Vtas = flight.Vtas + (config.update * flight.LongAccel) * 3600;

flight.hdg = mod(flight.hdg + (config.update * flight.RateOfTurn), 360);
flight.ROCD = flight.ROCD + (config.update * flight.VertAccel);

% flight.id
% flight.ROCD
% config.update
% flight.VertAccel


flight.long = flight.long + config.update * nm2deg((sin(deg2rad((flight.hdg + Oldhdg) / 2)) * ((flight.Vtas + OldVtas) / 2 / 3600)) - (sin(deg2rad(winddir) - pi) * (windspd / 3600)));
flight.lat = flight.lat + config.update * nm2deg((cos(deg2rad((flight.hdg + Oldhdg) / 2)) * ((flight.Vtas + OldVtas) / 2 / 3600)) - (cos(deg2rad(winddir) - pi) * (windspd / 3600)));
flight.alt = flight.alt + config.update * (flight.ROCD);


flight.FuelConsumption = flight.FuelConsumption + (flight.FuelFlow * config.update);
flight.mass = flight.mass - ((flight.FuelFlow * config.update) / 1000);


end