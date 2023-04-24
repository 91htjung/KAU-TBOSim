%% AssignFlightStatus

function flight_profile = AssignFlightStatus(flight_profile, DepFE, ArrFE, option)

global Perf

H_maxTO=400;
H_maxIC=2000;
H_maxAP=8000;
H_maxLD=3000;

switch option
    case 'AltOnly'
        
        for i=1:length(flight_profile.trajectory)
            
            if i == 1
                if and(strcmp(flight_profile.trajectory(i).type, 'ground'), flight_profile.trajectory(i).alt == DepFE)
                    flight_profile.trajectory(i).FS = 'TX';
                elseif and(strcmp(flight_profile.trajectory(i).type, 'SID'), flight_profile.trajectory(i).alt == DepFE)
                    flight_profile.trajectory(i).FS = 'TO';
                else
                    if strcmp(flight_profile.trajectory(i).wp_name, 'trajectory_assigned') == 1
                        init_status = flight_profile.trajectory(i + 1).type;
                    else
                        init_status = flight_profile.trajectory(i).type;
                    end
                    switch init_status
                        case 'ground'
                            flight_profile.trajectory(i).FS='TX';
                        case 'route'
                            flight_profile.trajectory(i).FS='CR';
                        case {'SID' 'MISS'}
                            if flight_profile.trajectory(i).alt <= H_maxTO
                                flight_profile.trajectory(i).FS='TO';
                            elseif and(flight_profile.trajectory(i).alt > H_maxTO, flight_profile.trajectory(i).alt <= H_maxIC);
                                flight_profile.trajectory(i).FS='IC';
                            elseif flight_profile.trajectory(i).alt > H_maxIC
                                flight_profile.trajectory(i).FS='CR';
                            end
                        case {'STAR' 'INST' 'HOLD'}
                            if flight_profile.trajectory(i).alt <= H_maxLD
                                flight_profile.trajectory(i).FS='LD';
                            elseif and(flight_profile.trajectory(i).alt > H_maxLD, flight_profile.trajectory(i).alt <= H_maxAP)
                                flight_profile.trajectory(i).FS='AP';
                            elseif flight_profile.trajectory(i).alt > H_maxAP
                                flight_profile.trajectory(i).FS='CR';
                            end
                        otherwise
                            if length(flight_profile.trajectory) == 1
                                AltDiffNow = flight_profile.alt - flight_profile.trajectory(1).alt;
                            else
                                AltDiffNow = flight_profile.trajectory(i + 1).alt - flight_profile.trajectory(i + 1).alt;
                            end
                            if or(flight_profile.trajectory(i).alt == DepFE, flight_profile.trajectory(i).alt == ArrFE)
                                flight_profile.trajectory(1).FS = 'TX';
                            elseif AltDiffNow < - 50
                                if flight_profile.trajectory(i).alt <= H_maxLD
                                    flight_profile.trajectory(i).FS='LD';
                                elseif and(flight_profile.trajectory(i).alt > H_maxLD, flight_profile.trajectory(i).alt <= H_maxAP)
                                    flight_profile.trajectory(i).FS='AP';
                                elseif flight_profile.trajectory(i).alt > H_maxAP
                                    flight_profile.trajectory(i).FS='CR';
                                end
                            elseif AltDiffNow > 50
                                if flight_profile.trajectory(i).alt <= H_maxTO
                                    flight_profile.trajectory(i).FS='TO';
                                elseif and(flight_profile.trajectory(i).alt > H_maxTO, flight_profile.trajectory(i).alt <= H_maxIC);
                                    flight_profile.trajectory(i).FS='IC';
                                elseif flight_profile.trajectory(i).alt > H_maxIC
                                    flight_profile.trajectory(i).FS='CR';
                                end
                            else
                                flight_profile.trajectory(i).FS='CR';
                            end
                            
                            
                            
                    end
                end
            else
                if and(strcmp(flight_profile.trajectory(i).type, 'ground'), flight_profile.trajectory(i).alt == DepFE)
                    flight_profile.trajectory(i).FS = 'TX';
                elseif and(strcmp(flight_profile.trajectory(i).type, 'SID'), flight_profile.trajectory(i).alt == DepFE)
                    flight_profile.trajectory(i).FS = 'TO';
                else
                    if flight_profile.trajectory(i).alt - flight_profile.trajectory(i - 1).alt > 50
                        if flight_profile.trajectory(i).alt <= H_maxTO
                            flight_profile.trajectory(i).FS='TO';
                        elseif and(flight_profile.trajectory(i).alt > H_maxTO, flight_profile.trajectory(i).alt <= H_maxIC);
                            flight_profile.trajectory(i).FS='IC';
                        elseif flight_profile.trajectory(i).alt > H_maxIC
                            flight_profile.trajectory(i).FS='CR';
                        end
                    elseif flight_profile.trajectory(i).alt - flight_profile.trajectory(i - 1).alt < -50
                        if and(flight_profile.trajectory(i).alt == ArrFE, i ~= length(flight_profile.trajectory))
                            if and(strcmp(flight_profile.trajectory(i).type, 'INST'), strcmp(flight_profile.trajectory(i + 1).type, 'ground'))
                                flight_profile.trajectory(i).FS='TX';
                            else
                                flight_profile.trajectory(i).FS='LD';
                            end
                        elseif flight_profile.trajectory(i).alt <= H_maxLD
                            flight_profile.trajectory(i).FS='LD';
                        elseif and(flight_profile.trajectory(i).alt > H_maxLD, flight_profile.trajectory(i).alt <= H_maxAP)
                            flight_profile.trajectory(i).FS='AP';
                        elseif flight_profile.trajectory(i).alt > H_maxAP
                            flight_profile.trajectory(i).FS='CR';
                        end
                    else
                        
                        
                        switch flight_profile.trajectory(i).type
                            case 'ground'
                                flight_profile.trajectory(i).FS='TX';
                            case 'route'
                                flight_profile.trajectory(i).FS='CR';
                            case {'SID' 'MISS'}
                                if flight_profile.trajectory(i).alt <= H_maxTO
                                    flight_profile.trajectory(i).FS='TO';
                                elseif and(flight_profile.trajectory(i).alt > H_maxTO, flight_profile.trajectory(i).alt <= H_maxIC);
                                    flight_profile.trajectory(i).FS='IC';
                                elseif flight_profile.trajectory(i).alt > H_maxIC
                                    flight_profile.trajectory(i).FS='CR';
                                end
                            case {'STAR' 'HOLD'}
                                if flight_profile.trajectory(i).alt <= H_maxLD
                                    flight_profile.trajectory(i).FS='LD';
                                elseif and(flight_profile.trajectory(i).alt > H_maxLD, flight_profile.trajectory(i).alt <= H_maxAP)
                                    flight_profile.trajectory(i).FS='AP';
                                elseif flight_profile.trajectory(i).alt > H_maxAP
                                    flight_profile.trajectory(i).FS='CR';
                                end
                            case {'INST'}
                                if and(flight_profile.trajectory(i).alt == ArrFE, i == length(flight_profile.trajectory))
                                    flight_profile.trajectory(i).FS='TX';
                                elseif flight_profile.trajectory(i).alt <= H_maxLD
                                    flight_profile.trajectory(i).FS='LD';
                                elseif and(flight_profile.trajectory(i).alt > H_maxLD, flight_profile.trajectory(i).alt <= H_maxAP)
                                    flight_profile.trajectory(i).FS='AP';
                                elseif flight_profile.trajectory(i).alt > H_maxAP
                                    flight_profile.trajectory(i).FS='CR';
                                end
                            otherwise
                                flight_profile.trajectory(i).FS='CR';
                                
                        end
                        
                    end
                    
                end
            end
            
        end
    case 'AltSpd'
        for i=1:length(flight_profile.trajectory)
            
            if i == 1
                if and(strcmp(flight_profile.trajectory(i).type, 'ground'), flight_profile.trajectory(i).alt == DepFE)
                    flight_profile.trajectory(i).FS = 'TX';
                elseif and(strcmp(flight_profile.trajectory(i).type, 'SID'), flight_profile.trajectory(i).alt == DepFE)
                    flight_profile.trajectory(i).FS = 'TO';
                else
                    if strcmp(flight_profile.trajectory(i).wp_name, 'trajectory_assigned') == 1
                        init_status = flight_profile.trajectory(i + 1).type;
                    else
                        init_status = flight_profile.trajectory(i).type;
                    end
                    switch init_status
                        case 'ground'
                            flight_profile.trajectory(i).FS='TX';
                        case 'route'
                            flight_profile.trajectory(i).FS='CR';
                        case {'SID' 'MISS'}
                            if flight_profile.trajectory(i).alt <= H_maxTO
                                flight_profile.trajectory(i).FS='TO';
                            elseif and(flight_profile.trajectory(i).alt > H_maxTO, flight_profile.trajectory(i).alt <= H_maxIC);
                                flight_profile.trajectory(i).FS='IC';
                            elseif flight_profile.trajectory(i).alt > H_maxIC
                                flight_profile.trajectory(i).FS='CR';
                            end
                        case {'STAR' 'INST' 'HOLD'}
                            if flight_profile.trajectory(i).alt <= H_maxLD
                                if flight_profile.trajectory(i).Vtas < 1.3 * Perf.(flight_profile.type).Vstall_AP + 10
                                    flight_profile.trajectory(i).FS='LD';
                                else and(flight_profile.trajectory(i).Vtas >= 1.3 * Perf.(flight_profile.type).Vstall_AP + 10, flight_profile.trajectory(i).Vtas < 1.3 * Perf.(flight_profile.type).Vstall_CR + 10)
                                    flight_profile.trajectory(i).FS='AP';
                                end
                            elseif and(flight_profile.trajectory(i).alt > H_maxLD, flight_profile.trajectory(i).alt <= H_maxAP)
                                if flight_profile.trajectory(i).Vtas < 1.3 * Perf.(flight_profile.type).Vstall_CR + 10
                                    flight_profile.trajectory(i).FS='AP';
                                elseif flight_profile.trajectory(i).Vtas >= 1.3 * Perf.(flight_profile.type).Vstall_CR + 10
                                    flight_profile.trajectory(i).FS='CR';
                                end
                            elseif flight_profile.trajectory(i).alt > H_maxAP
                                flight_profile.trajectory(i).FS='CR';
                            end
                        otherwise
                            if length(flight_profile.trajectory) == 1
                                AltDiffNow = flight_profile.alt - flight_profile.trajectory(1).alt;
                            else
                                AltDiffNow = flight_profile.trajectory(i + 1).alt - flight_profile.trajectory(i + 1).alt;
                            end
                            if or(flight_profile.trajectory(i).alt == DepFE, flight_profile.trajectory(i).alt == ArrFE)
                                flight_profile.trajectory(1).FS = 'TX';
                            elseif AltDiffNow < - 50
                                if flight_profile.trajectory(i).alt <= H_maxLD
                                    if flight_profile.trajectory(i).Vtas < 1.3 * Perf.(flight_profile.type).Vstall_AP + 10
                                        flight_profile.trajectory(i).FS='LD';
                                    else and(flight_profile.trajectory(i).Vtas >= 1.3 * Perf.(flight_profile.type).Vstall_AP + 10, flight_profile.trajectory(i).Vtas < 1.3 * Perf.(flight_profile.type).Vstall_CR + 10)
                                        flight_profile.trajectory(i).FS='AP';
                                    end
                                elseif and(flight_profile.trajectory(i).alt > H_maxLD, flight_profile.trajectory(i).alt <= H_maxAP)
                                    if flight_profile.trajectory(i).Vtas < 1.3 * Perf.(flight_profile.type).Vstall_CR + 10
                                        flight_profile.trajectory(i).FS='AP';
                                    elseif flight_profile.trajectory(i).Vtas >= 1.3 * Perf.(flight_profile.type).Vstall_CR + 10
                                        flight_profile.trajectory(i).FS='CR';
                                    end
                                elseif flight_profile.trajectory(i).alt > H_maxAP
                                    flight_profile.trajectory(i).FS='CR';
                                end
                            elseif AltDiffNow > 50
                                if flight_profile.trajectory(i).alt <= H_maxTO
                                    flight_profile.trajectory(i).FS='TO';
                                elseif and(flight_profile.trajectory(i).alt > H_maxTO, flight_profile.trajectory(i).alt <= H_maxIC);
                                    flight_profile.trajectory(i).FS='IC';
                                elseif flight_profile.trajectory(i).alt > H_maxIC
                                    flight_profile.trajectory(i).FS='CR';
                                end
                            else
                                flight_profile.trajectory(i).FS='CR';
                            end
                            
                            
                            
                    end
                end
            else
                if and(strcmp(flight_profile.trajectory(i).type, 'ground'), flight_profile.trajectory(i).alt == DepFE)
                    flight_profile.trajectory(i).FS = 'TX';
                elseif and(strcmp(flight_profile.trajectory(i).type, 'SID'), flight_profile.trajectory(i).alt == DepFE)
                    flight_profile.trajectory(i).FS = 'TO';
                else
                    if flight_profile.trajectory(i).alt - flight_profile.trajectory(i - 1).alt > 50
                        if flight_profile.trajectory(i).alt <= H_maxTO
                            flight_profile.trajectory(i).FS='TO';
                        elseif and(flight_profile.trajectory(i).alt > H_maxTO, flight_profile.trajectory(i).alt <= H_maxIC);
                            flight_profile.trajectory(i).FS='IC';
                        elseif flight_profile.trajectory(i).alt > H_maxIC
                            flight_profile.trajectory(i).FS='CR';
                        end
                    elseif flight_profile.trajectory(i).alt - flight_profile.trajectory(i - 1).alt < -50
                        if and(flight_profile.trajectory(i).alt == ArrFE, i ~= length(flight_profile.trajectory))
                            if and(strcmp(flight_profile.trajectory(i).type, 'INST'), strcmp(flight_profile.trajectory(i + 1).type, 'ground'))
                                flight_profile.trajectory(i).FS='TX';
                            else
                                flight_profile.trajectory(i).FS='LD';
                            end
                        elseif flight_profile.trajectory(i).alt <= H_maxLD
                            if flight_profile.trajectory(i).Vtas < 1.3 * Perf.(flight_profile.type).Vstall_AP + 10
                                flight_profile.trajectory(i).FS='LD';
                            else and(flight_profile.trajectory(i).Vtas >= 1.3 * Perf.(flight_profile.type).Vstall_AP + 10, flight_profile.trajectory(i).Vtas < 1.3 * Perf.(flight_profile.type).Vstall_CR + 10)
                                flight_profile.trajectory(i).FS='AP';
                            end
                        elseif and(flight_profile.trajectory(i).alt > H_maxLD, flight_profile.trajectory(i).alt <= H_maxAP)
                            if flight_profile.trajectory(i).Vtas < 1.3 * Perf.(flight_profile.type).Vstall_CR + 10
                                flight_profile.trajectory(i).FS='AP';
                            elseif flight_profile.trajectory(i).Vtas >= 1.3 * Perf.(flight_profile.type).Vstall_CR + 10
                                flight_profile.trajectory(i).FS='CR';
                            end
                        elseif flight_profile.trajectory(i).alt > H_maxAP
                            flight_profile.trajectory(i).FS='CR';
                        end
                    else
                        switch flight_profile.trajectory(i).type
                            case 'ground'
                                flight_profile.trajectory(i).FS='TX';
                            case 'route'
                                flight_profile.trajectory(i).FS='CR';
                            case {'SID' 'MISS'}
                                if flight_profile.trajectory(i).alt <= H_maxTO
                                    flight_profile.trajectory(i).FS='TO';
                                elseif and(flight_profile.trajectory(i).alt > H_maxTO, flight_profile.trajectory(i).alt <= H_maxIC);
                                    flight_profile.trajectory(i).FS='IC';
                                elseif flight_profile.trajectory(i).alt > H_maxIC
                                    flight_profile.trajectory(i).FS='CR';
                                end
                            case {'STAR' 'HOLD'}
                                if flight_profile.trajectory(i).alt <= H_maxLD
                                    if flight_profile.trajectory(i).Vtas < 1.3 * Perf.(flight_profile.type).Vstall_AP + 10
                                        flight_profile.trajectory(i).FS='LD';
                                    else and(flight_profile.trajectory(i).Vtas >= 1.3 * Perf.(flight_profile.type).Vstall_AP + 10, flight_profile.trajectory(i).Vtas < 1.3 * Perf.(flight_profile.type).Vstall_CR + 10)
                                        flight_profile.trajectory(i).FS='AP';
                                    end
                                elseif and(flight_profile.trajectory(i).alt > H_maxLD, flight_profile.trajectory(i).alt <= H_maxAP)
                                    if flight_profile.trajectory(i).Vtas < 1.3 * Perf.(flight_profile.type).Vstall_CR + 10
                                        flight_profile.trajectory(i).FS='AP';
                                    elseif flight_profile.trajectory(i).Vtas >= 1.3 * Perf.(flight_profile.type).Vstall_CR + 10
                                        flight_profile.trajectory(i).FS='CR';
                                    end
                                elseif flight_profile.trajectory(i).alt > H_maxAP
                                    flight_profile.trajectory(i).FS='CR';
                                end
                            case {'INST'}
                                if and(flight_profile.trajectory(i).alt == ArrFE, i == length(flight_profile.trajectory))
                                    flight_profile.trajectory(i).FS='TX';
                                elseif flight_profile.trajectory(i).alt <= H_maxLD
                                    if flight_profile.trajectory(i).Vtas < 1.3 * Perf.(flight_profile.type).Vstall_AP + 10
                                        flight_profile.trajectory(i).FS='LD';
                                    else and(flight_profile.trajectory(i).Vtas >= 1.3 * Perf.(flight_profile.type).Vstall_AP + 10, flight_profile.trajectory(i).Vtas < 1.3 * Perf.(flight_profile.type).Vstall_CR + 10)
                                        flight_profile.trajectory(i).FS='AP';
                                    end
                                elseif and(flight_profile.trajectory(i).alt > H_maxLD, flight_profile.trajectory(i).alt <= H_maxAP)
                                    if flight_profile.trajectory(i).Vtas < 1.3 * Perf.(flight_profile.type).Vstall_CR + 10
                                        flight_profile.trajectory(i).FS='AP';
                                    elseif flight_profile.trajectory(i).Vtas >= 1.3 * Perf.(flight_profile.type).Vstall_CR + 10
                                        flight_profile.trajectory(i).FS='CR';
                                    end
                                elseif flight_profile.trajectory(i).alt > H_maxAP
                                    flight_profile.trajectory(i).FS='CR';
                                end
                            otherwise
                                flight_profile.trajectory(i).FS='CR';
                                
                        end
                        
                    end
                    
                end
            end
        end
        
        
        
        
        
end

end