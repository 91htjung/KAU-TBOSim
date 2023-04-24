function flight=autopilot2(flight)
global atmos Perf unit
% 이 단계는 Flight에 BADA 입히는 과정
msg ='Initiating Autopilot Module.....';
% 초기값 배정은 어짜피 auto=true 일테니, update마다 돌리면 될거 같은데

H_maxTO=400;    
H_maxIC=2000;
H_maxAP=8000;
H_maxLD=3000;

for i=1:length(flight)
[msg flight(i).callsign '.....(' num2str(i) '/' num2str(length(flight)) ')' ]

    LSBL=0;
    alt_max=0;
    
    
    % min / max mass check
    if flight(i).mass < Perf.(flight(i).type).Mass_min;
        ['Warning. aircraft ID #' num2str(i) ' has low mass (' num2str(flight(i).mass) 't), switch to minimum mass: ' num2str(Perf.(flight(i).type).Mass_min) 't']
        flight(i).mass = Perf.(flight(i).type).Mass_min;
    elseif flight(i).mass > Perf.(flight(i).type).Mass_max
        ['Warning. aircraft ID #' num2str(i) ' has high mass (' num2str(flight(i).mass) 't), switch to maximum mass: ' num2str(Perf.(flight(i).type).Mass_max) 't']
        flight(i).mass = Perf.(flight(i).type).Mass_max;
    end
    % mass correction: 속도 보정계수
    mass_cor=sqrt(flight(i).mass/Perf.(flight(i).type).Mass_ref);
    
    % max altitude check
    if Perf.(flight(i).type).Hmax ~= 0
        alt_max=min(Perf.(flight(i).type).Hmax, Perf.(flight(i).type).MaxAlt + (Perf.(flight(i).type).TempGrad * max((atmos.Td - Perf.(flight(i).type).MaxClimbThrust_4),0))+(Perf.(flight(i).type).Mass_massGrad * ((Perf.(flight(i).type).Mass_max*1000)-(flight(i).mass*1000))));
    else
        alt_max=Perf.(flight(i).type).MaxAlt;
    end
    % 현재 고도(alt)에 오류가 있다면, 수정 0~max_alt
    if flight(i).alt < 0
        ['Error. aircraft ID #' num2str(i) ' has negative altitude (' num2str(flight(i).alt) 'ft), switching to altitude: 0 ft']
        flight(i).alt = 0;
    elseif flight(i).alt > alt_max
        ['Error. aircraft ID #' num2str(i) ' has too high altitude (' num2str(flight(i).alt) 'ft), switching to maximum altitude: ' num2str(alt_max) 'ft']
        flight(i).alt = alt_max;
    end
    % 배정 고도(alt_sc)에 오류가 있다면, 수정 0~max_alt
    if flight(i).alt_sc < 0
        ['Error. aircraft ID #' num2str(i) ' has negative scheduled altitude (' num2str(flight(i).alt_sc) 'ft), switching to altitude: 0 ft']
        flight(i).alt_sc = 0;
    elseif flight(i).alt_sc > alt_max
        ['Error. aircraft ID #' num2str(i) ' has too high scheduled altitude (' num2str(flight(i).alt_sc) 'ft), switching to maximum altitude: ' num2str(alt_max) 'ft']
        flight(i).alt_sc = alt_max;
    end
    
    % FS Update
    if strcmp(flight(i).FS,'TX')==0 && flight(i).alt~=0
        if flight(i).alt_sc - flight(i).alt > 50 % 10ft 오차 허용? -> 상승 요구됨을 파악
            if flight(i).alt <= H_maxTO
                flight(i).FS='TO';
            elseif flight(i).alt > H_maxTO && flight(i).alt <= H_maxIC;
                flight(i).FS='IC';
            elseif flight(i).alt > H_maxIC
                flight(i).FS='CR';
            end
        elseif flight(i).alt_sc - flight(i).alt < -50 % 10ft 오차 허용-> 하강
            if flight(i).alt <= H_maxLD
                if flight(i).Vtas < 1.3*(mass_cor*Perf.(flight(i).type).Vstall_AP) + 10
                    flight(i).FS='LD';
                elseif flight(i).Vtas >= 1.3*(mass_cor*Perf.(flight(i).type).Vstall_AP) +10 && flight(i).Vtas < 1.3*(mass_cor*Perf.(flight(i).type).Vstall_CR) + 10
                    flight(i).FS='AP';
                else
                    ['Warning. aircraft ID #' num2str(i) ' is too fast! TAS must be below: ' num2tsr(1.3*(mass_cor*Perf.(flight(i).type).Vstall_CR) + 10) ', consider go-around']
                end
            elseif flight(i).alt > H_maxLD && flight(i).alt <= H_maxAP
                if flight(i).Vtas < 1.3*(mass_cor*Perf.(flight(i).type).Vstall_CR) + 10
                    flight(i).FS='AP';
                else
                    flight(i).FS='CR';
                end
            elseif flight(i).alt > H_maxAP
                flight(i).FS='CR';
            end
        else
            flight(i).FS='CR';
        end
    elseif strcmp(flight(i).FS,'LD')==1 && flight(i).alt==0
        flight(i).FS='TX';
    elseif strcmp(flight(i).FS,'TX')==1
        if flight(i).alt_sc==0
            flight(i).FS='TX';
        else
            flight(i).FS='TO';
        end
    else
        if flight(i).alt==0
            ['Warning. aircraft ID #' num2str(i) ' cannot have proper flight status, switching FS to Taxi']
        else
            ['Warning. aircraft ID #' num2str(i) ' cannot have proper flight status, switching FS to Cruise']
        end
    end
    
    
    % Speed 조절 부분
    % spdcontrol이 true면 관제사 지시를 따르며 (그래도 최소속도, 최대속도 범위로 맞춘다.) false면 BADA에서
    % 지정한 procedure에 따라 속도 조절
     
    % Vtas_sc가 빈 경우, 즉 BADA로 assign(auto=true) 및 관제사 지시(auto=false) 둘다 되지
    % 않은 경우
    
    if isempty(flight(i).Vtas_sc);
        ['Warning. aircraft ID #' num2str(i) ' has no scheduled speed, switching to autopilot']
        flight(i).manual.spd=false;
    end
      
    % FS 배정
    if isempty(flight(i).FS);
        if flight(i).alt == 0
            if flight(i).alt_sc > 0
                flight(i).FS='TO';
                ['Warning. aircraft ID #' num2str(i) ' has no flight status, switching to TakeOff, altitude: ' num2str(flight(i).alt_sc) 'ft']
            else
                flight(i).FS='TX';
                ['Warning. aircraft ID #' num2str(i) ' has no flight status, switching to Taxi, altitude: ' num2str(flight(i).alt_sc) 'ft']
            end
        else
            flight(i).FS='CR';
            flight(i).alt_sc = round(flight(i).alt/1000)*1000;
            ['Warning. aircraft ID #' num2str(i) ' has no flight status, switching to Cruise, altitude: ' num2str(flight(i).alt_sc) 'ft']
        end
    end
    
    if flight(i).manual.spd==false;
        switch flight(i).FS
            case 'CR' % cruise
                if strcmp(Perf.(flight(i).type).Engtype,'Jet')==1 %Jet일 경우
                    %CAS altitude에 따라 구하기
                    if flight(i).alt >= 0 && flight(i).alt < 3000
                        flight(i).Vtas_sc = cas2tas(min(mass_cor*Perf.(flight(i).type).Vcruise_low,mass_cor*170),flight(i).alt);
                    elseif flight(i).alt >= 3000 && flight(i).alt < 6000
                        flight(i).Vtas_sc = cas2tas(min(mass_cor*Perf.(flight(i).type).Vcruise_low,mass_cor*220),flight(i).alt);
                    elseif flight(i).alt >= 6000 && flight(i).alt < 14000
                        flight(i).Vtas_sc = cas2tas(min(mass_cor*Perf.(flight(i).type).Vcruise_low,mass_cor*250),flight(i).alt);
                    elseif flight(i).alt >= 14000 && flight(i).alt < Perf.(flight(i).type).Machtrans_cruise;
                        flight(i).Vtas_sc = cas2tas(mass_cor*Perf.(flight(i).type).Vcruise_high,flight(i).alt);
                    elseif flight(i).alt >= Perf.(flight(i).type).Machtrans_cruise && flight(i).alt < Perf.(flight(i).type).MaxAlt;
                        flight(i).Vtas_sc = mach2tas(mass_cor*Perf.(flight(i).type).Mcruise,flight(i).alt);
                    elseif flight(i).alt < 0
                        ['error! aircraft ID #' num2str(i) ' has negative altitude in Flight Status #' flight(i).FS]
                    else
                        ['error! aircraft ID #' num2str(i) ' higher than maximum altitude in Flight Status #' flight(i).FS]
                    end
                else %Jet이 아닌 turboprop 또는 Piston인 경우,
                    if flight(i).alt >= 0 && flight(i).alt < 3000
                        flight(i).Vtas_sc = cas2tas(min(mass_cor*Perf.(flight(i).type).Vcruise_low,mass_cor*150),flight(i).alt);
                    elseif flight(i).alt >= 3000 && flight(i).alt < 6000
                        flight(i).Vtas_sc = cas2tas(min(mass_cor*Perf.(flight(i).type).Vcruise_low,mass_cor*180),flight(i).alt);
                    elseif flight(i).alt >= 6000 && flight(i).alt < 10000
                        flight(i).Vtas_sc = cas2tas(min(mass_cor*Perf.(flight(i).type).Vcruise_low,mass_cor*250),flight(i).alt);
                    elseif flight(i).alt >= 10000 && flight(i).alt < Perf.(flight(i).type).Machtrans_cruise;
                        flight(i).Vtas_sc = cas2tas(mass_cor*Perf.(flight(i).type).Vcruise_high,flight(i).alt);
                    elseif flight(i).alt >= Perf.(flight(i).type).Machtrans_cruise && flight(i).alt < Perf.(flight(i).type).MaxAlt;
                        flight(i).Vtas_sc = mach2tas(mass_cor*Perf.(flight(i).type).Mcruise,flight(i).alt);
                    elseif flight(i).alt < 0
                        ['error! aircraft ID #' num2str(i) ' has negative altitude in Flight Status #' flight(i).FS]
                    else
                        ['error! aircraft ID #' num2str(i) ' higher than maximum altitude in Flight Status #' flight(i).FS]
                    end
                end
            case {'TO', 'IC'} % Climb
                if strcmp(Perf.(flight(i).type).Engtype,'Jet')==1 %Jet일 경우
                    if flight(i).alt >= 0 && flight(i).alt < 100 %TO 직후로 Vstall에 곱하는 계수가 1.2 고도
                        flight(i).Vtas_sc = cas2tas(1.2*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])+5,flight(i).alt);
                    elseif flight(i).alt >= 100 && flight(i).alt < 1500 %이 이후로는 계수는 1.3
                        flight(i).Vtas_sc = cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])+5,flight(i).alt);
                    elseif flight(i).alt >= 1500 && flight(i).alt < 3000
                        flight(i).Vtas_sc = cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])+10,flight(i).alt);
                    elseif flight(i).alt >= 3000 && flight(i).alt < 4000
                        flight(i).Vtas_sc = cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])+30,flight(i).alt);
                    elseif flight(i).alt >= 4000 && flight(i).alt < 5000
                        flight(i).Vtas_sc = cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])+60,flight(i).alt);
                    elseif flight(i).alt >= 5000 && flight(i).alt < 6000
                        flight(i).Vtas_sc = cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])+80,flight(i).alt);
                    elseif flight(i).alt >= 6000 && flight(i).alt < 10000
                        flight(i).Vtas_sc = cas2tas(min(mass_cor*Perf.(flight(i).type).Vclimb_low,mass_cor*250),flight(i).alt);
                    elseif flight(i).alt >= 10000 && flight(i).alt < Perf.(flight(i).type).Machtrans_climb;
                        flight(i).Vtas_sc = cas2tas(mass_cor*Perf.(flight(i).type).Vclimb_high,flight(i).alt);
                    elseif flight(i).alt >= Perf.(flight(i).type).Machtrans_climb && flight(i).alt < Perf.(flight(i).type).MaxAlt;
                        flight(i).Vtas_sc = mach2tas(mass_cor*Perf.(flight(i).type).Mclimb,flight(i).alt);
                    elseif flight(i).alt < 0
                        ['error! aircraft ID #' num2str(i) ' has negative altitude in Flight Status #' flight(i).FS]
                    else
                        ['error! aircraft ID #' num2str(i) ' higher than maximum altitude in Flight Status #' flight(i).FS]
                    end
                else %Jet가 아니면
                    if flight(i).alt >= 0 && flight(i).alt < 100 %TO 직후로 Vstall에 곱하는 계수가 1.2
                        flight(i).Vtas_sc = cas2tas(1.2*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])+20,flight(i).alt);
                    elseif flight(i).alt >= 100 && flight(i).alt < 1000 %이 이후로는 계수는 1.3
                        flight(i).Vtas_sc = cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])+20,flight(i).alt);
                    elseif flight(i).alt >= 1000 && flight(i).alt < 1500
                        flight(i).Vtas_sc = cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])+30,flight(i).alt);
                    elseif flight(i).alt >= 1500 && flight(i).alt < 10000
                        flight(i).Vtas_sc = cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])+35,flight(i).alt);
                    elseif flight(i).alt >= 10000 && flight(i).alt < Perf.(flight(i).type).Machtrans_climb;
                        flight(i).Vtas_sc = cas2tas(mass_cor*Perf.(flight(i).type).Vclimb_high,flight(i).alt);
                    elseif flight(i).alt >= Perf.(flight(i).type).Machtrans_climb && flight(i).alt < Perf.(flight(i).type).MaxAlt;
                        flight(i).Vtas_sc = mach2tas(mass_cor*Perf.(flight(i).type).Mclimb,flight(i).alt);
                    elseif flight(i).alt < 0
                        ['error! aircraft ID #' num2str(i) ' has negative altitude in Flight Status #' flight(i).FS]
                    else
                        ['error! aircraft ID #' num2str(i) ' higher than maximum altitude in Flight Status #' flight(i).FS]
                    end
                end
            case {'AP', 'LD'} % Descent, Approach, Landing
                % Descent에는 특이하게 Piston과 그 외의 경우로 나뉜다.
                if strcmp(Perf.(flight(i).type).Engtype,'Piston')==1 %Piston일 경우
                    if flight(i).alt >= 0 && flight(i).alt < 500
                        flight(i).Vtas_sc = cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])+5,flight(i).alt);
                    elseif flight(i).alt >= 500 && flight(i).alt < 1000
                        flight(i).Vtas_sc = cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])+10,flight(i).alt);
                    elseif flight(i).alt >= 1000 && flight(i).alt < 1500
                        flight(i).Vtas_sc = cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])+20,flight(i).alt);
                    elseif flight(i).alt >= 1500 && flight(i).alt < 10000
                        flight(i).Vtas_sc = cas2tas(mass_cor*Perf.(flight(i).type).Vdescent_low,flight(i).alt);
                    elseif flight(i).alt >= 10000 && flight(i).alt < Perf.(flight(i).type).Machtrans_descent;
                        flight(i).Vtas_sc = cas2tas(mass_cor*Perf.(flight(i).type).Vdescent_high,flight(i).alt);
                    elseif flight(i).alt >= Perf.(flight(i).type).Machtrans_climb && flight(i).alt < Perf.(flight(i).type).MaxAlt;
                        flight(i).Vtas_sc = mach2tas(mass_cor*Perf.(flight(i).type).Mdescent,flight(i).alt);
                    elseif flight(i).alt < 0
                        ['error! aircraft ID #' num2str(i) ' has negative altitude in Flight Status #' flight(i).FS]
                    else
                        ['error! aircraft ID #' num2str(i) ' higher than maximum altitude in Flight Status #' flight(i).FS]
                    end
                else %Piston이 아니면
                    if flight(i).alt >= 0 && flight(i).alt < 1000
                        flight(i).Vtas_sc = cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])+5,flight(i).alt);
                    elseif flight(i).alt >= 1000 && flight(i).alt < 1500
                        flight(i).Vtas_sc = cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])+10,flight(i).alt);
                    elseif flight(i).alt >= 1500 && flight(i).alt < 2000
                        flight(i).Vtas_sc = cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])+20,flight(i).alt);
                    elseif flight(i).alt >= 2000 && flight(i).alt < 3000
                        flight(i).Vtas_sc = cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])+50,flight(i).alt);
                    elseif flight(i).alt >= 3000 && flight(i).alt < 6000
                        flight(i).Vtas_sc = cas2tas(min(mass_cor*Perf.(flight(i).type).Vdescent_low,mass_cor*220),flight(i).alt);
                    elseif flight(i).alt >= 6000 && flight(i).alt < 10000
                        flight(i).Vtas_sc = cas2tas(min(mass_cor*Perf.(flight(i).type).Vdescent_low,mass_cor*250),flight(i).alt);
                    elseif flight(i).alt >= 10000 && flight(i).alt < Perf.(flight(i).type).Machtrans_descent;
                        flight(i).Vtas_sc = cas2tas(mass_cor*Perf.(flight(i).type).Vdescent_high,flight(i).alt);
                    elseif flight(i).alt >= Perf.(flight(i).type).Machtrans_climb && flight(i).alt < Perf.(flight(i).type).MaxAlt;
                        flight(i).Vtas_sc = mach2tas(mass_cor*Perf.(flight(i).type).Mdescent,flight(i).alt);
                    elseif flight(i).alt < 0
                        ['error! aircraft ID #' num2str(i) ' has negative altitude in Flight Status #' flight(i).FS]
                    else
                        ['error! aircraft ID #' num2str(i) ' higher than maximum altitude in Flight Status #' flight(i).FS]
                    end
                end
            case 'HL' % holding
                if flight(i).alt >= 0 && flight(i).alt < 14000;
                    flight(i).Vtas_sc = cas2tas(mass_cor*230,flight(i).alt);
                elseif flight(i).alt >= 14000 && flight(i).alt < 20000;
                    flight(i).Vtas_sc = cas2tas(mass_cor*240,flight(i).alt);
                elseif flight(i).alt >= 20000 && flight(i).alt < 34000;
                    flight(i).Vtas_sc = cas2tas(mass_cor*265,flight(i).alt);
                elseif flight(i).alt >= 34000 && flight(i).alt < Perf.(flight(i).type).MaxAlt;
                    flight(i).Vtas_sc = mach2tas(mass_cor*0.83,flight(i).alt);
                elseif flight(i).alt < 0
                    ['error! aircraft ID #' num2str(i) ' has negative altitude in Flight Status #' flight(i).FS]
                else
                    ['error! aircraft ID #' num2str(i) ' higher than maximum altitude in Flight Status #' flight(i).FS]
                end
            case 'TX' % taxi
                flight(i).Vtas_sc = mass_cor*15;
            otherwise
                ['error! aircraft ID #' num2str(i) ' has no matching Flight Status #' flight(i).FS]
        end
    else
        flight(i).Vtas_sc=flight(i).Vtas_sc;
        %Auto.spd가 false면 Vtas_sc의 변화 없다
    end
    
    % minimum speed check
    if strcmp(flight(i).FS,'TX')==0
        % Jet low buffer (3.6.2)
        if strcmp(Perf.(flight(i).type).Engtype,'Jet')==1
            
            %일단 ISA를 가정했기 때문에 atmosisa를 사용하는 중.
            % ISA 외부 모델로 받고 싶다면, 기상 데이터 모듈을 넣어서 해당 pressure, temp, rho를 받도록
            [T,a,p,rho]=atmosisa(flight(i).alt);
            syms M
            LSBL=double(real(vpa(solve((double(Perf.(flight(i).type).k)*(M^3)) - (double(Perf.(flight(i).type).Clbo)*(M^2)) + double(((flight(i).mass*1000*atmos.g_0)/(Perf.(flight(i).type).Surf*p*0.5830))) ==0,M,'Real',true),4)));
            LSBL(LSBL<=0)=[];
            LSBL=min(LSBL);
            if isempty(LSBL)
                LSBL=0;
            end
            if geoalt(flight(i).alt) < 15000
                if strcmp(flight(i).FS, 'TO')==1
                    if tas2cas(flight(i).Vtas_sc,flight(i).alt) <  1.2*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS ]); %minimum spd 이하
                        ['Warning aircraft ID #' num2str(i) ' Sceduled CAS (' num2str(tas2cas(flight(i).Vtas_sc,flight(i).alt)) ') lower than minimum speed, corrected to minimum CAS (' num2str(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])) ') (TAS: ' num2str(cas2tas(1.2*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS]),flight(i).alt)) ')']
                        flight(i).Vtas_sc=cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS]),flight(i).alt);
                    end
                else
                    if tas2cas(flight(i).Vtas_sc,flight(i).alt) <  1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS ]); %minimum spd 이하
                        ['Warning aircraft ID #' num2str(i) ' Sceduled CAS (' num2str(tas2cas(flight(i).Vtas_sc,flight(i).alt)) ') lower than minimum speed, corrected to minimum CAS (' num2str(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])) ') (TAS: ' num2str(cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS]),flight(i).alt)) ')']
                        flight(i).Vtas_sc=cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS]),flight(i).alt);
                    end
                end
            else
                if tas2cas(flight(i).Vtas_sc,flight(i).alt) <  max(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS ]),tas2cas(mach2tas(LSBL,flight(i).alt),flight(i).alt)); %minimum spd 이하
                    if cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS]),flight(i).alt) > mach2tas(LSBL,flight(i).alt)
                        ['Warning aircraft ID #' num2str(i) ' Sceduled CAS (' num2str(tas2cas(flight(i).Vtas_sc,flight(i).alt)) ') lower than minimum speed, corrected to minimum CAS (' num2str(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])) ') (TAS: ' num2str(cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS]),flight(i).alt)) ')']
                    else
                        ['Warning aircraft ID #' num2str(i) ' Sceduled Mach (' num2str(tas2mach(flight(i).Vtas_sc,flight(i).alt)) ') lower than minimum speed, corrected to minimum Mach (' num2str(LSBL) ') (TAS: ' num2str(mach2tas(LSBL,flight(i).alt)) ')']
                    end
                    flight(i).Vtas_sc=max(cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS]),flight(i).alt),mach2tas(LSBL,flight(i).alt));
                end
            end
        else
            if tas2cas(flight(i).Vtas_sc,flight(i).alt) <  1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS ]); %minimum spd 이하
                ['Warning aircraft ID #' num2str(i) ' Sceduled CAS (' num2str(tas2cas(flight(i).Vtas_sc,flight(i).alt)) ') lower than minimum speed, corrected to minimum CAS (' num2str(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS])) ') (TAS: ' num2str(cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS]),flight(i).alt)) ')']
                flight(i).Vtas_sc=cas2tas(1.3*mass_cor*Perf.(flight(i).type).(['Vstall_' flight(i).FS]),flight(i).alt);
            end
        end
    end

    
    if flight(i).alt < Perf.(flight(i).type).Machtrans_cruise; % CAS 운항(Machtrans alt 이하) maximum spd(VMO) 이상
        if tas2cas(flight(i).Vtas_sc,flight(i).alt) >  Perf.(flight(i).type).VMO;
            ['Warning aircraft ID #' num2str(i) ' Sceduled CAS (' num2str(tas2cas(flight(i).Vtas_sc,flight(i).alt)) ') higher than maximum CAS, corrected to maximum CAS (' num2str(Perf.(flight(i).type).VMO) ') (TAS: ' num2str(cas2tas(Perf.(flight(i).type).VMO,flight(i).alt)) ')']
            flight(i).Vtas_sc=cas2tas(Perf.(flight(i).type).VMO,flight(i).alt);
        end
    else % Mach 운항(Machtrans alt 이상) maximum spd(MMO) 이상
        if tas2cas(flight(i).Vtas_sc,flight(i).alt) >  Perf.(flight(i).type).VMO;
            ['Warning aircraft ID #' num2str(i) ' Sceduled Mach (' num2str(tas2mach(flight(i).Vtas_sc,flight(i).alt)) ') higher than maximum Mach, corrected to maximum Mach (' num2str(Perf.(flight(i).type).MMO) ') (TAS: ' num2str(mach2tas(Perf.(flight(i).type).VMO,flight(i).alt)) ')']
            flight(i).Vtas_sc=mach2tas(Perf.(flight(i).type).MMO,flight(i).alt);
        end
    end
    
    % rate of turn 계산 -> 추후 실제 업데이트 시 ror으로 계산하자
    switch flight(i).FS
        case {'TO', 'LD'}
            if flight(i).manual.exp==false;
                flight(i).rot=(atmos.g_0/flight(i).Vtas)*rad2deg(tan(deg2rad(15)));
            else
                flight(i).rot=(atmos.g_0/flight(i).Vtas)*rad2deg(tan(deg2rad(25)));
            end
        case 'HL'
            if flight(i).manual.exp==false;
                flight(i).rot=(atmos.g_0/flight(i).Vtas)*rad2deg(tan(deg2rad(35)));
            else
                flight(i).rot=(atmos.g_0/flight(i).Vtas)*rad2deg(tan(deg2rad(35)));
            end
        otherwise
            if flight(i).manual.exp==false;
                flight(i).rot=(atmos.g_0/flight(i).Vtas)*rad2deg(tan(deg2rad(35)));
            else
                flight(i).rot=(atmos.g_0/flight(i).Vtas)*rad2deg(tan(deg2rad(45)));
            end
    end
    
    % radius of turn 계산
    flight(i).radot=flight(i).Vtas/(flight(i).rot*20*pi);
    
    
    % heading 배정
    % 현 위도(lat)과 다음 지점의 위도(lat_sc) & 현 경도(long)과 다음 지점의 경도(long_sc)으로
    % hdg_sc 계산
    

    if isempty(flight(i).hdg_sc);
        ['Warning. aircraft ID #' num2str(i) ' has no scheduled heading, switch to current heading: ' num2str(flight(i).hdg)]
        flight(i).hdg_sc=flight(i).hdg;
    end
    if flight(i).manual.hdg==false
        % 사전에 지정된 procedure를 불러와서 radius of turn을 계산, fly-by point에서는 미리 선회할 수
        % 있도록
        
        
        flight(i).hdg_sc= rad2deg(atan((flight(i).long_sc-(flight(i).long))/(flight(i).lat_sc-(flight(i).lat))));
    
        
    else
        flight(i).hdg_sc=flight(i).hdg_sc;
    end
    
        

    
end