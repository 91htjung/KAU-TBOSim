function [long, lat, alt, tas, hdg, FS] = GetNextReference(flight, pointTo)

global config unit Perf

if flight.manual.alt(1)
    
%     if flight.exp

    input_alt = round(flight.manual.alt(2) / config.AltRes(1)) * config.AltRes(1);
    if flight.alt < input_alt
        alt = min(input_alt, flight.alt + (sin(deg2rad(30)) * (flight.Vtas / 3600 * unit.nm2ft) * config.update));
    else
        alt = max(input_alt, flight.alt + (sin(deg2rad(-30)) * (flight.Vtas / 3600 * unit.nm2ft) * config.update));
    end
    
    
else
    alt = round(flight.Reference(4,pointTo), config.AltRes(2));
end

if flight.manual.spd(1)
    tas = round(flight.manual.spd(2) / config.SpdRes(1)) * config.SpdRes(1);
else
    tas = round(flight.Reference(5,pointTo), config.SpdRes(2));
end

if flight.manual.hdg(1)
    hdg = round(flight.manual.hdg(2) / config.HdgRes(1)) * config.HdgRes(1);
    
    long = flight.long;
    lat = flight.lat;

    
else
    if pointTo == 1
        hdg = mod(rad2deg(atan2(flight.Reference(2,pointTo + 1) - flight.Reference(2,pointTo), flight.Reference(3,pointTo + 1) - flight.Reference(3,pointTo))),360);
    else
        hdg = mod(rad2deg(atan2(flight.Reference(2,pointTo) - flight.Reference(2,pointTo - 1), flight.Reference(3,pointTo) - flight.Reference(3,pointTo - 1))),360);
    end
    
    if hdg < 0
        hdg = hdg + 360;
    end
    
    hdg = round(hdg, config.HdgRes(2));
    
    long = flight.Reference(2,pointTo);
    lat = flight.Reference(3,pointTo);
end


% If Manual: FS Decision Algorithm
if flight.manual.hdg(1) == 1
    if alt > flight.alt %climb
        if and(flight.alt >= 0, flight.alt < 400)
            FS = 'TO';
        elseif and(flight.alt >= 400, flight.alt < 2000)
            FS = 'IC';
        else
            FS = 'CR';
        end
    else % descent
        if and(flight.alt >= 0, flight.alt < 3000)
            if flight.Vtas < (1.3 * Perf.(flight.type).Vstall_AP) + 10
                FS = 'LD';
            else
                FS = 'AP';
            end
        elseif and(flight.alt >= 3000, flight.alt < 8000)
            if flight.Vtas < 1.3 * Perf.(flight.type).Vstall_CR + 10
                FS = 'AP';
            else
                FS = 'CR';
            end
        else
            FS = 'CR';
        end
    end
    
else
    if isempty(flight.FixFlap)
        switch flight.Reference(7,pointTo)
            case 1
                FS = 'TX';
            case 2
                FS = 'TO';
            case 3
                FS = 'IC';
            case 4
                FS = 'CR';
            case 5
                FS = 'AP';
            case 6
                FS = 'LD';
        end
    else
        FS = flight.FixFlap;
    end
end