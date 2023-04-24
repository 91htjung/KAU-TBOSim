function flight = vecUpdateParam(flight, RunTime)

global config Weather

winddir = zeros(1, length(flight));
windspd = zeros(1, length(flight));


if config.WindOpt
    
%     Get wind data
    for SecLen = 1:length(Weather.Sector)
        in = inpolygon([flight.long], [flight.lat], [Weather.Sector(SecLen).Layer.Long]', [Weather.Sector(SecLen).Layer.Lat]');
        
        if ~all(in == 0)
            altin = and(in, and([flight.alt] >= Weather.Sector(SecLen).Layer(1).LowAlt, [flight.alt] <= Weather.Sector(SecLen).Layer(1).HighAlt));
            
            timeind = ~isempty(find([Weather.Sector(SecLen).WX.ActiveTime] >= RunTime, 1)) * find([Weather.Sector(SecLen).WX.ActiveTime] >= RunTime, 1) ...
                + isempty(find([Weather.Sector(SecLen).WX.ActiveTime] >= RunTime, 1)) * length([Weather.Sector(SecLen).WX.ActiveTime]);
            
            winddir(altin) = Weather.Sector(SecLen).WX(timeind).WindDirection;
            windspd(altin) = Weather.Sector(SecLen).WX(timeind).WindSpeed;
        end
    end
    
    if config.WindNoise
        winddir = winddir + rad2deg(normrnd(config.WindMu(1), config.WindSigma(1), 1, length(winddir)));
        windspd = windspd + normrnd(config.WindMu(2), config.WindSigma(2), 1, length(windspd));
    end
    
end
    
%  Test Code
% if or(flight.id == 11, flight.id == 13)
%     winddir = 360;
%     windspd = 10;
% else
%     winddir = 0;
%     windspd = 0;
% end

OldVtas = [flight.Vtas];
Oldhdg = [flight.hdg];
OldROCD = [flight.ROCD];

newVtas = [flight.Vtas] + (config.update * [flight.LongAccel]) * 3600;
newhdg = mod([flight.hdg] + (config.update * [flight.RateOfTurn]), 360);
newROCD = [flight.ROCD] + (config.update * [flight.VertAccel]);

newlong = [flight.long] + config.update * nm2deg((sin(deg2rad(([flight.hdg] + Oldhdg) / 2)) .* (([flight.Vtas] + OldVtas) / 2 / 3600)) - (sin(deg2rad([winddir]) - pi) .* ([windspd] / 3600)));
newlat = [flight.lat] + config.update * nm2deg((cos(deg2rad(([flight.hdg] + Oldhdg) / 2)) .* (([flight.Vtas] + OldVtas) / 2 / 3600)) - (cos(deg2rad([winddir]) - pi) .* ([windspd] / 3600)));
newalt = [flight.alt] + config.update * ([flight.ROCD]);

newFuelCon = [flight.FuelConsumption] + ([flight.FuelFlow] * config.update);
newmass = [flight.mass] - (([flight.FuelFlow] * config.update) / 1000);


newVtas = num2cell(newVtas);
newhdg = num2cell(newhdg);
newROCD = num2cell(newROCD);
newlong = num2cell(newlong);
newlat = num2cell(newlat);
newalt = num2cell(newalt);
newFuelCon = num2cell(newFuelCon);
newmass = num2cell(newmass);

[flight.Vtas] = newVtas{:};
[flight.hdg] = newhdg{:};
[flight.ROCD] = newROCD{:};
[flight.long] = newlong{:};
[flight.lat] = newlat{:};
[flight.alt] = newalt{:};
[flight.FuelConsumption] = newFuelCon{:};
[flight.mass] = newmass{:};

end