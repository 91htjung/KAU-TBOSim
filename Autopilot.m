%% autopilot: 현재 위치와 다음 reference를 비교, 필요 속도, heading, ROCD 구하기 & control
%   (1) 현재 위치/시간과 Reference Trajectory를 비교

%   (2) 필요할 경우 다음 Reference Trajectory에서 참고할 위/경도, 속도, 고도, 기수를 가져온다.

%   (2-1) CTA control인 경우: 현재 시간과 Reference Trajectory내 시간을 기준으로 판단
%       - Fixed CTA, dynamic spd control
%   (2-2) spd control인 경우: 현재 위치와 Reference Trajectory내 위치를 기준으로 판단
%       - Fixed spd, no CTA control
%   (2-3) 만약 더이상 참고할 Reference Trajetory가 없다면, 항공기는 도착한 것으로 한다.

%   (3) 가져온 참고 위/경도, 속도, 고도, 기수와 현재 값을 비교한다.

%   (4) 해당 참고 값까지 도달할 때까지 걸릴 시간을 결정한다.

%   (5) control 옵션에 따라 참고 값을 만족하기 위한 값을 계산한다.
%       - 요구되는 속도: 남은거리/남은시간 (cta control) or 참고속도 (spd control)
%       - 요구되는 기수: 현재 지점에서 다음 지점까지 bearing (기본) or 지정된 heading (hdg control on)
%       - 요구되는 고도: 참고고도 (기본) or 지정된 altitude (alt control on)

%   (6) 현재 속도/기수/고도와 요구되는 속도/기수/고도를 비교, 남은 시간을 나눈다.
%       - 수평가속도 (ft/s^2)
%       - Rate of Turn (degree/s)
%       - Rate of Climb & Descent (ft/s)
%       - 수직가속도 (ft/s^2)

%   (7) 수평가속도/수직가속도/중량 -> Thrust 계산
%   (8) Thrust -> Fuel Flow (kg/min) 계산

%   (9) UpdateParam 함수에서 실제 항공기 변수 업데이트 (flight Structure)



%% Global 변수 설명

% flight (Struct): 항공기 데이터를 담고 있는 Struct

% flight.lat, flight.long, flight.alt, flight.Vtas, flight.hdg: 각 항공기 현재 위도/경도/고도/속도(TAS)/기수
% flight.FS: 항공기 Flap Setting (이 값에 따라 읽는 BADA Performance Parameter가 다름)
% flight.mass: 항공기 중량

% flight.Reference: 해당 항공기 Reference Trajectory
%   1행: Segment 번호
%   2행: longitude
%   3행: latitude
%   4행: altitude
%   5행: airspeed
%   6행: time
%   7행: Flap Setting

% flight.ReferenceFrom / flight.ReferenceTo : 현재 참고중인 Reference Trajectory의 열 번호
% flight.lat_sc, flight.long_sc, flight.alt_sc, flight.Vtas_sc, flight.hdg_sc: 참고중인 Reference Trajectory를 기준으로 가야 할 위도/경도/고도/속도/기수

% flight.manual: 해당 항공기 manual control 상태 (관제 명령 등)
%   hdg: 기수 control
%   alt: 고도 control
%   spd: 속도 control (CTA와 mutually exclusive)
%   cta: CTA control (spd와 mutually exclusive)

% flight.gentime: 항공기 생성 시간 (초)
% flight.arrived: 항공기 도착 여부 (도착 전: -1, 도착 후: 도착 시간)

% config: 시뮬레이션 내 사용되는 여러가지 설정들
%   config.update: 시뮬레이션 업데이트 시간 폭 (초)
%   config.TrajRes: Reference Trajectory의 Resolution (몇 초 단위로 구성되어 있는지)
%   config.DistDiffThreshold: spd control 시 현재 위치와 참고점 위치 비교할 때 사용하는 상수로 기본값은 1

% unit: 단위 변환용 상수

% Perf: BADA 내 항공기 성능 파라미터

% atmos: 기상 모델 파라미터 (ISA를 가정한 상태)

% RunTime: 시뮬레이션 clock

%% 내부 변수 설명

% 다음 참조점 결정할 때 사용하는 변수

% timeleft: (도착시간 산출), Trajectory를 전부 소모했을 때 마지막 열 소요 시간
% speedcor: (도착시간 산출), 현재 속도와 Trajectory 마지막 속도의 비율로 소요 시간 보정하기 위함
% nexttime: (while 문 통제용 변수) 시간 조건 만족
% cumtime: 참고하는 Reference Trajectory의 시간 길이. 시간이 update 단위에 비해 너무 짧으면 다음 point 것을 받아오도록

% LocDiff: 현재 위치와 다음 참고점 위치의 차이
% DegDiff: 현재 기수와 다음 참고점 기수의 차이
% RelLocDiff: 위 LocDiff가 짧은지(다음 참고점을 받아야 할지) 아닌지 결정하는 비교 거리
%   - 현재 속도를 유지하면서 (update 시간 폭 2배 또는 Trajectory Resolution 중 큰 값) 만큼 비행한 것의 (상수) 배, 여기서 (상수)는 1
% nextdist: (while 문 통제용 변수) 거리 조건 만족
% nextang: (while 문 통제용 변수) 기수 조건 만족
% cumloc: 참고하는 Reference Trajectory의 거리 길이. 거리가 너무 짧으면 다음 point 것을 받아오도록
% cumang: 참고하는 Reference Trajectory의 각도. 현재 코드 사용하지 않음



% 참조점과 현재 비교할 때 사용하는 변수

% hdgdiff: 현재 기수와 참조점 기수의 차이 (degree)
% spddiff: 현재 속도와 참조점 속도의 차이 (knot)
% altdiff: 현재 고도와 참조점 고도의 차이 (feet)

% latdiff: 현재 위도와 참조점 위도의 차이 (nm)
% longdiff: 현재 경도와 참조점 경도의 차이 (nm)
% distdiff: 현재 위치와 참조점 사이의 거리 (nm)

% TrajLatDiff : 현재 위도와 Reference Trajectory 위도의 차이 : 위 latdiff와 같으나 hdg control 시에만 사용됨
% TrajLongDiff : 현재 위도와 Reference Trajectory 경도의 차이 : 위 longdiff와 같으나 hdg control 시에만 사용됨
% TrajDistDiff : 현재 위치와 Reference Trajectory의 거리 : 위 distdiff와 같으나 hdg control 시에만 사용됨

% timeavail: 현재에서 다음 참조점까지의 시간 차이

% RequiredROCD: 참조점 도달 위한 Rate of Climb & Descent (ft/sec)

% (hdg control시 flight.lat_sc, flight.long_sc를 다시 입력하는 과정), 
% 다른 control은 위경도가 Reference trajectory를 따라가기 때문에 불필요
% ReqDHdg: 기수 차이를 시간으로 나눈 값
% ReqHdg: 다음 update 시 기수
% ReqDSpd: 속도 차이를 시간으로 나눈 값
% ReqSpd: 다음 update 시 속도 (nm/sec)
% AvgSpd: 현 속도와 다음 update시 속도의 평균

% RequiredHdg: 참조점 도달 위한 Heading (degree)
% RequiredHdgDiff: 현 기수와 RequiredHdg의 차이

% RequiredSpd: 참조점 도달 위한 airspeed



% 구한 변수를 이용하여 추가 parameter 계산

% RequiredLongAccel: RequiredSpd 도달위한 수평가속도
% RequiredVertAccel: RequiredROCD 도달위한 수직가속도

% LongAccel: Performance Filter(BADA)를 통과한 수평가속도 -> 적용
% VertAccel: Performance Filter(BADA)를 통과한 수직가속도 -> 적용


% 추력 계산용 변수

% rho: International Standard Atmosphere 상 현재 항공기 고도에 해당하는 rho 값
% bankangle: Flap Setting에 따른 항공기 bank 각
% CD0: Flap Setting에 따른 Drag Coefficient (1)
% CD2: Flap Setting에 따른 Drag Coefficient (2)
% CDLDG: Landing Gear 다운시 추가되는 Drag Coefficient

% Surf: 항공기 날개 면적
% g: 중력 가속도
% mass: 항공기 무게(kg)
% TAS: 항공기 속도(m/s)
% accl: 수평가속도(m/s^2)
% vert: 수직가속도(m/s^2)

% Lift: 항공기 작용 양력
% qS: 1/2 * rho * v^2 * S (양력과 항력에 사용되는 상수)
% LiftCoeff: 양력 계수
% DragCoeff: 항력 계수
% Drag: 항력

% Required Thrust: 해당 수평/수직 가속도를 내기 위한 필요 추력

% ISA_Max_Thrust: ISA 환경에서 최대 추력
% dTeff: ISA와 현재 적용중인 기상 모델에서 온도 차이를 반영한 상수 -> 현재는 차이 없음
% maxThrust: dTeff를 적용한 최대 추력

% Thrust: 실제 추력



% 연료 소모 계산용 변수

% CF1 ~ CF4 & CFCR: BADA 내 연료 소모율 계산 파라미터
% mu: 해당 파라미터로 구한 상수
% FuelNom: nomial Fuel Flow
% FuelMin: minimal Fuel Flow
% FuelAPLD: Fuel Flow in Approach/Landing Segment
% FuelCR: Fuel Flow in Cruise Segment

% FuelFlow: Flap Setting에 따른 연료 소모 계수


% 기수 계산용 변수

% RequiredROT: RequiredHdgDiff를 만족하기 위한 시간에 따른 기수 변화율 (deg/sec)
% absmaxROT: 항공기 속도와 bankangle에 따른 최대 선회율 (deg/sec)
% TurnRate: 실제 선회율

function flight = Autopilot(RunTime, flight)

global config unit Perf atmos

% Get next Reference Point


% Test Code: 필터 안에 들어오면 Mode를 Manual로 변경
if config.EXPTEST
    if and(flight.label == 1, flight.manual.cta == [1 ; 0 ; 0])
        dist = 60 * ((config.TGTAD(1) - flight.long)^2 + (config.TGTAD(2) - flight.lat)^2);
        if and(dist > config.SWITCHRANGE - 2, dist < config.SWITCHRANGE)
            flight.manual.spd = [1 ; flight.Vtas_sc ; 0]; % 속도 수동 배정(관제사 지시) - boolean ; 배정된 속도 - double
            flight.manual.alt = [1 ; flight.alt_sc ; 0]; % 고도 수동 배정(관제사 지시), 3rd arg: ROCD limit (ft/min) -> 0: auto, -1: maximum, other: inputed ROCD
            flight.manual.hdg = [1 ; flight.hdg_sc ; 0]; % 기수 수동 배정(관제사 지시), 3rd arg: direction (0: auto, 1: one loop clockwise, -2: two loop counter clockwise)
            flight.manual.cta = [0 ; 0 ; 0];
            flight.alt_sc = flight.alt;
            flight.Vtas_sc = flight.Vtas;
            flight.hdg_sc = flight.hdg;

        end
    end
end




if and(~flight.manual.hdg(1), flight.manual.cta(1)) % Refernece Trajectory를 시간을 기준으로 갱신하자
    
    %   (1) CTA: 현재 시간과 Reference Trajectory를 비교
    if RunTime - flight.delay >= flight.Reference(6, flight.ReferenceTo) + flight.gentime - (max(config.update * 2, config.TrajRes))

        flight.ReferenceFrom = flight.ReferenceTo;
        [len, wid] = size(flight.Reference);
        
        
        if flight.ReferenceFrom >= wid - 1
            %   Trajectory 끝 -> 완전히 도착
            timeleft = (flight.Reference(6, end) - flight.Reference(6, flight.ReferenceFrom));
            speedcor = ((flight.Vtas / flight.Reference(5, flight.ReferenceFrom)) - 1) / 2;
            if or(isinf(speedcor), isnan(speedcor))
                speedcor = 0;
            end
            flight.arrived = round(RunTime + (timeleft * (1 + speedcor))) + config.update;
        else
            %   Trajectory 남아있음
            nexttime = 1;
            cumtime = 0;
            flight.ReferenceTo = flight.ReferenceTo + 1;
            
            %   참고할 Reference Trajectory 내 항공기 위치를 몇초 앞 데이터로 가져올건지
            while nexttime
                cumtime = cumtime + flight.Reference(6, flight.ReferenceTo) - flight.Reference(6, flight.ReferenceFrom);
                if cumtime >= (max(config.update * 3, config.TrajRes)) + (RunTime - (flight.Reference(6, flight.ReferenceFrom) + flight.gentime))
                    nexttime = 0;
                else
                    if flight.ReferenceTo == wid
                        nexttime = 0;
                    else
                        flight.ReferenceTo = flight.ReferenceTo + 1;
                    end
                end
            end
            
            %   Reference Trajectory 에서 ReferenceTo에 해당하는 열 데이터 받아오기
            [flight.long_sc, flight.lat_sc, flight.alt_sc, flight.Vtas_sc, flight.hdg_sc, flight.FS] = GetNextReference(flight, flight.ReferenceTo);
        end
        
        
    end
elseif and(~flight.manual.hdg(1), ~flight.manual.cta(1))
    %   (1) spd: 현재 위치과 Reference Trajectory를 비교
    
    % Reference Trajectory를 지점 통과 기준으로 갱신하자
    % 현재 받은 Reference 지점까지 bearing과 현재 heading 비교, 둘이 많이 다르면 1차 조건
    % 현재 fix와 다음 fix와의 거리가 매우 짧다 -> 다음 reference Trajecoty 값을 받자
    
%     DegDiff = mod(rad2deg(atan2(flight.long_sc - flight.long, flight.lat_sc - flight.lat)) - flight.hdg_sc,360);
%     AbsDegDiff = abs(min(360 - DegDiff, DegDiff)) / config.update;
    
    LocDiff = deg2nm(sqrt((flight.long_sc - flight.long)^2 + (flight.lat_sc - flight.lat)^2));
    DegDiff = mod(rad2deg(atan2(flight.long_sc - flight.long, flight.lat_sc - flight.lat)) - flight.hdg, 360);
    
    RelLocDiff = config.DistDiffThreshold * (max(2 * config.update, config.TrajRes)) * (flight.Vtas / 3600);
    
%     if or(AbsDegDiff > config.AngleDiffThreshold, LocDiff < RelLocDiff)
    if LocDiff * abs(cos(deg2rad(DegDiff))) < RelLocDiff
%     if AbsDegDiff > config.AngleDiffThreshold
        flight.ReferenceFrom = flight.ReferenceTo;

        [len, wid] = size(flight.Reference);
        if flight.ReferenceFrom >= wid - 1
            timeleft = (flight.Reference(6, end) - flight.Reference(6, flight.ReferenceFrom));
            speedcor = ((flight.Vtas / flight.Reference(5, flight.ReferenceFrom)) - 1) / 2;
            if or(isinf(speedcor), isnan(speedcor))
                speedcor = 0;
            end
            flight.arrived = round(RunTime + (timeleft * (1 + speedcor)));
        else
            nextdist = 1;
            nextang = 1;
            cumloc = 0;
            flight.ReferenceTo = flight.ReferenceTo + 1;
            while and(nextdist, nextang)
                
%                 cumtime = flight.Reference(6, flight.ReferenceTo) - flight.Reference(6, flight.ReferenceFrom) + config.update;
%                 cumloc = cumloc + deg2nm(sqrt((flight.Reference(2, flight.ReferenceTo) - flight.Reference(2, flight.ReferenceFrom)) ^ 2 + (flight.Reference(3, flight.ReferenceTo) - flight.Reference(3, flight.ReferenceFrom)) ^ 2));
                
                cumloc = deg2nm(sqrt((flight.Reference(2, flight.ReferenceTo) - flight.long) ^ 2 + (flight.Reference(3, flight.ReferenceTo) - flight.lat) ^ 2));
                cumdeg = mod(rad2deg(atan2(flight.Reference(2, flight.ReferenceTo) - flight.long, flight.Reference(3, flight.ReferenceTo) - flight.lat)) - flight.hdg, 360);
                
                if cumdeg > 180
                   cumdeg = cumdeg - 360; 
                end
                
%                 cumang = abs(mod(rad2deg(atan2(flight.Reference(2, flight.ReferenceTo) - flight.long, flight.Reference(3, flight.ReferenceTo) - flight.lat)), 360)) / cumtime;
%                 if and(config.DistDiffThreshold * cumloc > RelLocDiff, cumang <= config.AngleDiffThreshold)
                if cumloc * abs(cos(deg2rad(cumdeg))) > RelLocDiff
                    nextdist = 0;
                else
                    if flight.ReferenceTo == wid
                        nextdist = 0;
                    else
                        flight.ReferenceTo = flight.ReferenceTo + 1;
                    end
                end
            end
            [flight.long_sc, flight.lat_sc, flight.alt_sc, flight.Vtas_sc, flight.hdg_sc, flight.FS] = GetNextReference(flight, flight.ReferenceTo);
        end

        
    else
        
    end

else 
    [flight.long_sc, flight.lat_sc, flight.alt_sc, flight.Vtas_sc, flight.hdg_sc, flight.FS] = GetNextReference(flight, flight.ReferenceTo);
end

[T, a, P, rho] = atmosisa((flight.alt * unit.ft2meter));


switch flight.FS
    case 'TX'
        if flight.manual.ban(1)
            bankangle = flight.manual.ban(2);
        else
            bankangle = 0;
        end
        Cd0 = 0;
        Cd2 = 0;
        CdLDG = 0;
        MinSpeed = 0;
    case 'TO'
        if flight.manual.ban(1)
            bankangle = flight.manual.ban(2);
        else
            bankangle = 15;
        end
        Cd0 = Perf.(flight.type).CD0_TO;
        Cd2 = Perf.(flight.type).CD2_TO;
        CdLDG = 0;
        MinSpeed = cas2tas(1.2 * Perf.(flight.type).Vstall_TO, flight.alt);
    case 'IC'
        if flight.manual.ban(1)
            bankangle = flight.manual.ban(2);
        else
            bankangle = 35;
        end
        Cd0 = Perf.(flight.type).CD0_IC;
        Cd2 = Perf.(flight.type).CD2_IC;
        CdLDG = 0;
        MinSpeed = cas2tas(1.3 * Perf.(flight.type).Vstall_IC, flight.alt);
    case 'CR'
        if flight.manual.ban(1)
            bankangle = flight.manual.ban(2);
        else
            bankangle = 35;
        end
        Cd0 = Perf.(flight.type).CD0_CR;
        Cd2 = Perf.(flight.type).CD2_CR;
        CdLDG = 0;
        MinSpeed = cas2tas(1.3 * Perf.(flight.type).Vstall_CR, flight.alt);
    case 'AP'
        if flight.manual.ban(1)
            bankangle = flight.manual.ban(2);
        else
            bankangle = 35;
        end
        Cd0 = Perf.(flight.type).CD0_AP;
        Cd2 = Perf.(flight.type).CD2_AP;
        CdLDG = 0;
        MinSpeed = cas2tas(1.3 * Perf.(flight.type).Vstall_AP, flight.alt);
    case 'LD'
        if flight.manual.ban(1)
            bankangle = flight.manual.ban(2);
        else
            bankangle = 15;
        end
        Cd0 = Perf.(flight.type).CD0_LD;
        Cd2 = Perf.(flight.type).CD2_LD;
        CdLDG = Perf.(flight.type).GearDown_CD0;
        MinSpeed = cas2tas(1.3 * Perf.(flight.type).Vstall_LD, flight.alt);
    otherwise
        if flight.manual.ban(1)
            bankangle = flight.manual.ban(2);
        else
            bankangle = 35;
        end
        Cd0 = Perf.(flight.type).CD0_CR;
        Cd2 = Perf.(flight.type).CD2_CR;
        CdLDG = 0;
        MinSpeed = cas2tas(1.3 * Perf.(flight.type).Vstall_CR, flight.alt);
end

if flight.alt < Perf.(flight.type).Machtrans_cruise
    MaxSpeed = cas2tas(Perf.(flight.type).VMO, flight.alt) * 1.15;
else
    MaxSpeed = mach2tas(Perf.(flight.type).MMO, flight.alt) * 1.15;
end

if and(~strcmp(flight.FS, 'TX'), or(Cd0 == 0, Cd2 == 0))
    Cd0 = Perf.(flight.type).CD0_CR;
    Cd2 = Perf.(flight.type).CD2_CR;
end


hdgdiff = mod(flight.hdg_sc - flight.hdg, 360); % deg
if hdgdiff > 180
    hdgdiff = hdgdiff - 360;
end

spddiff = (flight.Vtas_sc - flight.Vtas) / 3600; % nm/sec
altdiff = flight.alt_sc - flight.alt; % ft

latdiff = deg2nm(flight.lat_sc - flight.lat); % nm
longdiff = deg2nm(flight.long_sc - flight.long); % nm
distdiff = sqrt(latdiff^2 + longdiff^2); % nm

TrajLatDiff = deg2nm(flight.Reference(3, flight.ReferenceTo) - flight.lat);
TrajLongDiff = deg2nm(flight.Reference(2, flight.ReferenceTo) - flight.long);

TrajDistDiff = sqrt(TrajLatDiff^2 + TrajLongDiff^2);

% 현재위치와 다음 Reference와 비교 요구되는 SPD, ACCL, HDG, ROCD 구하기
% Reference에서 받아온 spd를 사용하지 않고 여기서는 다음 위치까지의 남은 거리로 spd를 재계산.

if flight.manual.cta(1)
    timeavail = (flight.Reference(6, flight.ReferenceTo) + flight.gentime) - (RunTime - flight.delay) + config.update; % sec
else
    if ~flight.manual.hdg(1)
%     timeavail = (flight.Reference(6, flight.ReferenceTo) -  flight.Reference(6, flight.ReferenceFrom)) * (distdiff * cos(deg2rad(hdgdiff)) / TrajDistDiff);
        timeavail = TrajDistDiff / (((flight.Reference(5, flight.ReferenceTo) + flight.Vtas) / (2 * 3600)) * cos(deg2rad(hdgdiff)));
    else
        timeavail = max(3 * config.update, config.TrajRes);

    end
end

% hdg controlled: contolled hdg -> lat/long estimation
% hdg not controlled: lat_sc/long_sc -> get RequiredHdg


%% Heading
if flight.manual.hdg(1) 
%     ReqDHdg = hdgdiff / timeavail; % deg/sec
%     ReqHdg = flight.hdg + ReqDHdg; % deg
    
    ReqDSpd = spddiff / timeavail; % nm/sec^2
    ReqSpd = (flight.Vtas / 3600) + ReqDSpd; % nm/sec
    AvgSpd = ((flight.Vtas / 3600) + ReqSpd) / 2; %nm/sec
    
    flight.long_sc = flight.long + nm2deg((sin(deg2rad(flight.hdg)) * AvgSpd) * config.update); % deg
    flight.lat_sc = flight.lat + nm2deg((cos(deg2rad(flight.hdg)) * AvgSpd) * config.update); % deg
    RequiredHdg = flight.hdg_sc;
    
    
    RequiredHdgDiff = mod(RequiredHdg - flight.hdg, 360);
    
    if RequiredHdgDiff > 180
        RequiredHdgDiff = RequiredHdgDiff - 360;
    end
    
    
    if flight.manual.hdg(3) > 0
        if and(RequiredHdgDiff >= (-360 + 360 * flight.manual.hdg(3)), RequiredHdgDiff < -180 + (360 * flight.manual.hdg(3)))
            flight.manual.hdg(3) = max(0, flight.manual.hdg(3) - 1);
        end
    elseif flight.manual.hdg(3) < 0
        if and(RequiredHdgDiff > 180 + (360 * flight.manual.hdg(3)), RequiredHdgDiff <= 360 + (360 * flight.manual.hdg(3)))
            flight.manual.hdg(3) = min(0, flight.manual.hdg(3) + 1);
        end
    end
    
    RequiredHdgDiff = RequiredHdgDiff + (360 * flight.manual.hdg(3));
    
else
    RequiredHdg = mod(rad2deg(atan2(flight.long_sc - flight.long, flight.lat_sc - flight.lat)), 360); % deg
    
    RequiredHdgDiff = mod(RequiredHdg - flight.hdg, 360);
    
    if RequiredHdgDiff > 180
        RequiredHdgDiff = RequiredHdgDiff - 360;
    end
    
end



RequiredROT = RequiredHdgDiff / (timeavail * config.SecDerivCoeff); % deg/sec^2

absmaxROT = rad2deg(tan(deg2rad(bankangle)) * atmos.g_0 / (flight.Vtas * unit.nm2meter / 3600)); % deg/sec
% absmaxROT = 1091 * tan(deg2rad(bankangle)) / flight.Vtas; % deg/sec

if RequiredROT > 0
    TurnRate = min(RequiredROT, absmaxROT);
else
    TurnRate = max(RequiredROT, - 1 * absmaxROT);
end

% TurnRadius = flight.Vtas / (TurnRate * 20 * pi);


%% Get Distance
if flight.manual.cta(1) % Time Controlled -> 가급적 도착시간에 맞도록 속도 조절

    RequiredSpd = (distdiff * abs(cos(deg2rad(RequiredHdgDiff)))) / timeavail; % Required speed in Reference Segment nm/sec
else
    
    RequiredSpd = flight.Vtas_sc / 3600;    
end



% Min/Max Speed Validation
RequiredSpd = min(max((MinSpeed / 3600), RequiredSpd), (MaxSpeed / 3600));


% Altitude
if flight.manual.alt(2) == 0
    RequiredROCD = altdiff / (timeavail); % ft/sec
    max_pitch = 30;
else
    RequiredROCD = altdiff / 60; % ft/sec
    max_pitch = 30;
end

% Maximum pitch angle -> set to 35 degree
if RequiredROCD >= 0
    RequiredROCD = min(RequiredROCD, ((RequiredSpd * unit.nm2ft) * sin(deg2rad(max_pitch))));
else
    RequiredROCD = max(RequiredROCD, - 1 * ((RequiredSpd * unit.nm2ft) * sin(deg2rad(max_pitch))));
end



%% 수평/수직가속도
% Get Performance Parameter
RequiredLongAccel = (RequiredSpd - (flight.Vtas / 3600))  * abs(cos(deg2rad(RequiredHdgDiff))) / (timeavail); % nm/sec^2
RequiredVertAccel = (RequiredROCD - flight.ROCD) / (timeavail * config.SecDerivCoeff); % ft/sec^2



%% Thrust

% if flight.id == 2
%     'a'
% end

Surf = Perf.(flight.type).Surf;
g = atmos.g_0; % m/s^2

mass = flight.mass * 1000; % ton -> kilogram
TAS = flight.Vtas * unit.nm2meter / 3600; % kt -> m/s
% if and(~strcmp(flight.FS, 'TX') , TAS == 0)
if TAS == 0
    TAS = 0.00001;
end
VS = flight.ROCD * unit.ft2meter; % ft/s -> m/s

accl = RequiredLongAccel * unit.nm2meter; % nm/s^2 -> m/s^2
accv = RequiredVertAccel * unit.ft2meter; % ft/s^2 -> m/s^2
acc = sqrt(accl^2 + accv^2);

Lift = mass * (g + accv);
qS = rho * (TAS ^ 2) * Surf / 2;

LiftCoeff = Lift / qS;
DragCoeff = (Cd0 + CdLDG) + (Cd2 * (LiftCoeff^2));
Drag = DragCoeff * qS;

% RequiredThrust = max(Drag + (mass * (accv)) + (mass * accl), 0);
% RequiredThrust = max(Drag + (mass * accl), 0);

% Total Energy Model

RequiredThrust = Drag + (mass * atmos.g_0 * VS / TAS) + (mass *accl);



% Maximum Thrust
switch Perf.(flight.type).Engtype
    case 'Jet'
        ISA_Max_Thrust = Perf.(flight.type).MaxClimbThrust_1 * (1 - (geoalt(flight.alt) / Perf.(flight.type).MaxClimbThrust_2) + ((Perf.(flight.type).MaxClimbThrust_3) * ((geoalt(flight.alt) ^ 2))));
    case 'Turboprop'
        ISA_Max_Thrust = (((Perf.(flight.type).MaxClimbThrust_1) / (flight.Vtas)) * (1 - ((geoalt(flight.alt) / (Perf.(flight.type).MaxClimbThrust_2))))) + (Perf.(flight.type).MaxClimbThrust_3);
    case 'Piston'
        ISA_Max_Thrust = (Perf.(flight.type).MaxClimbThrust_1 * (1 - ((geoalt(flight.alt) / (Perf.(flight.type).MaxClimbThrust_2))))) + ((Perf.(flight.type).MaxClimbThrust_3) / (flight.Vtas));
end

dTeff = atmos.Td - Perf.(flight.type).MaxClimbThrust_4;
dTeff = min(max(0, dTeff), (0.4 / Perf.(flight.type).MaxClimbThrust_5));

maxThrust =ISA_Max_Thrust * (1 - ((Perf.(flight.type).MaxClimbThrust_5) * (dTeff)));


if RequiredThrust < 0
    Thrust = 0;
    if config. ThrustCorr
        ForceDev = RequiredThrust - Thrust;
        k = sqrt(((acc - (ForceDev / mass))^2) / (acc^2));
        
        
        RequiredLongAccel = k * accl * unit.meter2nm;
        RequiredVertAccel = k * accv * unit.meter2ft;
    end
%     RequiredLongAccel = (accl + (RequiredThrust / mass) * (accl/(accl + accv))) * unit.meter2nm;
%     RequiredVertAccel = (accv + (RequiredThrust / mass) * (accv/(accl + accv))) * unit.meter2ft;

    if config.FlapBreakFlag
        if isempty(flight.FixFlap)
            if flight.FixFlapCount > config.FlapBreakTime
                switch flight.FS
                    case 'IC'
                        flight.FixFlap = 'TO';
                    case 'CR'
                        flight.FixFlap = 'AP';
                    case 'AP'
                        flight.FixFlap = 'LD';
                end
                flight.FixFlapCount = 0;
            else
                flight.FixFlapCount = flight.FixFlapCount + config.update;
            end
        end
    end
    
elseif RequiredThrust > maxThrust
    
    Thrust = maxThrust;
    
    if config. ThrustCorr
        ForceDev = RequiredThrust - Thrust;
        k = sqrt(((acc - (ForceDev / mass))^2) / (acc^2));
        RequiredLongAccel = k * accl * unit.meter2nm;
        RequiredVertAccel = k * accv * unit.meter2ft;
    end
    %     RequiredLongAccel = (accl + ((RequiredThrust - maxThrust) / mass) * (accl/(accl + accv))) * unit.meter2nm;
    %     RequiredVertAccel = (accv + ((RequiredThrust - maxThrust) / mass) * (accv/(accl + accv))) * unit.meter2ft;
    
    if config.FlapBreakFlag
        if isempty(flight.FixFlap)
            if flight.FixFlapCount > config.FlapBreakTime
                switch flight.FS
                    case 'TO'
                        flight.FixFlap = 'IC';
                    case 'IC'
                        flight.FixFlap = 'CR';
                    case 'AP'
                        flight.FixFlap = 'CR';
                    case 'LD'
                        flight.FixFlap = 'AP';
                end
                flight.FixFlapCount = 0;
            else
                flight.FixFlapCount = flight.FixFlapCount + config.update;
            end
        end
    end
else
    
    Thrust = RequiredThrust;
    
    if config.FlapBreakFlag
        if ~isempty(flight.FixFlap)
            if flight.FixFlapCount > config.FlapBreakTime
                
                flight.FS = flight.FixFlap;
                flight.FixFlap = '';
                flight.FixFlapCount = 0;
            else
                flight.FixFlapCount = flight.FixFlapCount + config.update;
            end
        else
            flight.FixFlapCount = max(0, flight.FixFlapCount - (config.update / 2));
        end
    end
end


% Performance filter
if ~strcmp(flight.FS, 'TX')
    if RequiredLongAccel > 0
        LongAccel = min(RequiredLongAccel, unit.ft2nm * 2);
    else
        LongAccel = max(RequiredLongAccel, unit.ft2nm * -2);
    end
    if RequiredVertAccel > 0
        VertAccel = min(RequiredVertAccel, sqrt(21));
    else
        VertAccel = max(RequiredVertAccel, -sqrt(21));
    end
else
    LongAccel = RequiredLongAccel;
    VertAccel = RequiredVertAccel;
end

% % Thrust Limit로 인한 가속도 보정... 은 Thrust가 잡히고 하자
% if RequiredThrust > maxThrust;
%     LongAccel = LongAccel * maxThrust / RequiredThrust;
%     VertAccel = VertAccel * maxThrust / RequiredThrust;
% end

%% Fuel Consumption


CF1 = Perf.(flight.type).Thrust_Fuel1; % Jet:kg/(min*kN)  Turboprop:kg/(min*kN*kt)  Piston:kg/min
CF2 = Perf.(flight.type).Thrust_Fuel2; % kt
CF3 = Perf.(flight.type).Descent_Fuel3; % kg/min
CF4 = Perf.(flight.type).Descent_Fuel4; % ft
CFCR = Perf.(flight.type).Cruise_Fuel; % dimensionless


switch Perf.(flight.type).Engtype
    case 'Jet'
        mu = CF1 * (1 + (flight.Vtas / CF2));
        FuelNom = mu * (Thrust / 1000);
        FuelMin = CF3 * (1 - (geoalt(flight.alt) / CF4));
        FuelAPLD = max(FuelNom, FuelMin);
        FuelCR = mu * (Thrust / 1000) * CFCR;
    case 'Turboprop'
        mu = CF1 * (1 - (flight.Vtas / CF2)) * (flight.Vtas / 1000);
        FuelNom = mu * (Thrust / 1000);
        FuelMin = CF3 * (1 - (geoalt(flight.alt) / CF4));
        FuelAPLD = max(FuelNom, FuelMin);
        FuelCR = mu * (Thrust / 1000) * CFCR;
    case 'Piston'
        FuelNom = CF1;
        FuelMin = CF3;
        FuelAPLD = FuelNom;
        FuelCR = CF1 * CFCR;
end

switch flight.FS
    case 'TX'
        FuelFlow = FuelNom;
    case 'CR'
        FuelFlow = FuelCR;
    case {'AP' 'LD'}
        FuelFlow = FuelAPLD;
    otherwise
        FuelFlow = FuelNom;
end
    
FuelFlow = FuelFlow / 60;

%% Return Param
flight.LongAccel = LongAccel;
flight.VertAccel = VertAccel;
flight.RateOfTurn = TurnRate;
flight.Thrust = Thrust;
flight.FuelFlow = FuelFlow;

%% Dynamic Log
flight.Lift = Lift;
flight.Drag = Drag;

end