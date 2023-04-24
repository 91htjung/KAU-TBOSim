%% autopilot: ���� ��ġ�� ���� reference�� ��, �ʿ� �ӵ�, heading, ROCD ���ϱ� & control
%   (1) ���� ��ġ/�ð��� Reference Trajectory�� ��

%   (2) �ʿ��� ��� ���� Reference Trajectory���� ������ ��/�浵, �ӵ�, ��, ����� �����´�.

%   (2-1) CTA control�� ���: ���� �ð��� Reference Trajectory�� �ð��� �������� �Ǵ�
%       - Fixed CTA, dynamic spd control
%   (2-2) spd control�� ���: ���� ��ġ�� Reference Trajectory�� ��ġ�� �������� �Ǵ�
%       - Fixed spd, no CTA control
%   (2-3) ���� ���̻� ������ Reference Trajetory�� ���ٸ�, �װ���� ������ ������ �Ѵ�.

%   (3) ������ ���� ��/�浵, �ӵ�, ��, ����� ���� ���� ���Ѵ�.

%   (4) �ش� ���� ������ ������ ������ �ɸ� �ð��� �����Ѵ�.

%   (5) control �ɼǿ� ���� ���� ���� �����ϱ� ���� ���� ����Ѵ�.
%       - �䱸�Ǵ� �ӵ�: �����Ÿ�/�����ð� (cta control) or ����ӵ� (spd control)
%       - �䱸�Ǵ� ���: ���� �������� ���� �������� bearing (�⺻) or ������ heading (hdg control on)
%       - �䱸�Ǵ� ��: ����� (�⺻) or ������ altitude (alt control on)

%   (6) ���� �ӵ�/���/���� �䱸�Ǵ� �ӵ�/���/���� ��, ���� �ð��� ������.
%       - ���򰡼ӵ� (ft/s^2)
%       - Rate of Turn (degree/s)
%       - Rate of Climb & Descent (ft/s)
%       - �������ӵ� (ft/s^2)

%   (7) ���򰡼ӵ�/�������ӵ�/�߷� -> Thrust ���
%   (8) Thrust -> Fuel Flow (kg/min) ���

%   (9) UpdateParam �Լ����� ���� �װ��� ���� ������Ʈ (flight Structure)



%% Global ���� ����

% flight (Struct): �װ��� �����͸� ��� �ִ� Struct

% flight.lat, flight.long, flight.alt, flight.Vtas, flight.hdg: �� �װ��� ���� ����/�浵/��/�ӵ�(TAS)/���
% flight.FS: �װ��� Flap Setting (�� ���� ���� �д� BADA Performance Parameter�� �ٸ�)
% flight.mass: �װ��� �߷�

% flight.Reference: �ش� �װ��� Reference Trajectory
%   1��: Segment ��ȣ
%   2��: longitude
%   3��: latitude
%   4��: altitude
%   5��: airspeed
%   6��: time
%   7��: Flap Setting

% flight.ReferenceFrom / flight.ReferenceTo : ���� �������� Reference Trajectory�� �� ��ȣ
% flight.lat_sc, flight.long_sc, flight.alt_sc, flight.Vtas_sc, flight.hdg_sc: �������� Reference Trajectory�� �������� ���� �� ����/�浵/��/�ӵ�/���

% flight.manual: �ش� �װ��� manual control ���� (���� ��� ��)
%   hdg: ��� control
%   alt: �� control
%   spd: �ӵ� control (CTA�� mutually exclusive)
%   cta: CTA control (spd�� mutually exclusive)

% flight.gentime: �װ��� ���� �ð� (��)
% flight.arrived: �װ��� ���� ���� (���� ��: -1, ���� ��: ���� �ð�)

% config: �ùķ��̼� �� ���Ǵ� �������� ������
%   config.update: �ùķ��̼� ������Ʈ �ð� �� (��)
%   config.TrajRes: Reference Trajectory�� Resolution (�� �� ������ �����Ǿ� �ִ���)
%   config.DistDiffThreshold: spd control �� ���� ��ġ�� ������ ��ġ ���� �� ����ϴ� ����� �⺻���� 1

% unit: ���� ��ȯ�� ���

% Perf: BADA �� �װ��� ���� �Ķ����

% atmos: ��� �� �Ķ���� (ISA�� ������ ����)

% RunTime: �ùķ��̼� clock

%% ���� ���� ����

% ���� ������ ������ �� ����ϴ� ����

% timeleft: (�����ð� ����), Trajectory�� ���� �Ҹ����� �� ������ �� �ҿ� �ð�
% speedcor: (�����ð� ����), ���� �ӵ��� Trajectory ������ �ӵ��� ������ �ҿ� �ð� �����ϱ� ����
% nexttime: (while �� ������ ����) �ð� ���� ����
% cumtime: �����ϴ� Reference Trajectory�� �ð� ����. �ð��� update ������ ���� �ʹ� ª���� ���� point ���� �޾ƿ�����

% LocDiff: ���� ��ġ�� ���� ������ ��ġ�� ����
% DegDiff: ���� ����� ���� ������ ����� ����
% RelLocDiff: �� LocDiff�� ª����(���� �������� �޾ƾ� ����) �ƴ��� �����ϴ� �� �Ÿ�
%   - ���� �ӵ��� �����ϸ鼭 (update �ð� �� 2�� �Ǵ� Trajectory Resolution �� ū ��) ��ŭ ������ ���� (���) ��, ���⼭ (���)�� 1
% nextdist: (while �� ������ ����) �Ÿ� ���� ����
% nextang: (while �� ������ ����) ��� ���� ����
% cumloc: �����ϴ� Reference Trajectory�� �Ÿ� ����. �Ÿ��� �ʹ� ª���� ���� point ���� �޾ƿ�����
% cumang: �����ϴ� Reference Trajectory�� ����. ���� �ڵ� ������� ����



% �������� ���� ���� �� ����ϴ� ����

% hdgdiff: ���� ����� ������ ����� ���� (degree)
% spddiff: ���� �ӵ��� ������ �ӵ��� ���� (knot)
% altdiff: ���� ���� ������ ���� ���� (feet)

% latdiff: ���� ������ ������ ������ ���� (nm)
% longdiff: ���� �浵�� ������ �浵�� ���� (nm)
% distdiff: ���� ��ġ�� ������ ������ �Ÿ� (nm)

% TrajLatDiff : ���� ������ Reference Trajectory ������ ���� : �� latdiff�� ������ hdg control �ÿ��� ����
% TrajLongDiff : ���� ������ Reference Trajectory �浵�� ���� : �� longdiff�� ������ hdg control �ÿ��� ����
% TrajDistDiff : ���� ��ġ�� Reference Trajectory�� �Ÿ� : �� distdiff�� ������ hdg control �ÿ��� ����

% timeavail: ���翡�� ���� ������������ �ð� ����

% RequiredROCD: ������ ���� ���� Rate of Climb & Descent (ft/sec)

% (hdg control�� flight.lat_sc, flight.long_sc�� �ٽ� �Է��ϴ� ����), 
% �ٸ� control�� ���浵�� Reference trajectory�� ���󰡱� ������ ���ʿ�
% ReqDHdg: ��� ���̸� �ð����� ���� ��
% ReqHdg: ���� update �� ���
% ReqDSpd: �ӵ� ���̸� �ð����� ���� ��
% ReqSpd: ���� update �� �ӵ� (nm/sec)
% AvgSpd: �� �ӵ��� ���� update�� �ӵ��� ���

% RequiredHdg: ������ ���� ���� Heading (degree)
% RequiredHdgDiff: �� ����� RequiredHdg�� ����

% RequiredSpd: ������ ���� ���� airspeed



% ���� ������ �̿��Ͽ� �߰� parameter ���

% RequiredLongAccel: RequiredSpd �������� ���򰡼ӵ�
% RequiredVertAccel: RequiredROCD �������� �������ӵ�

% LongAccel: Performance Filter(BADA)�� ����� ���򰡼ӵ� -> ����
% VertAccel: Performance Filter(BADA)�� ����� �������ӵ� -> ����


% �߷� ���� ����

% rho: International Standard Atmosphere �� ���� �װ��� ���� �ش��ϴ� rho ��
% bankangle: Flap Setting�� ���� �װ��� bank ��
% CD0: Flap Setting�� ���� Drag Coefficient (1)
% CD2: Flap Setting�� ���� Drag Coefficient (2)
% CDLDG: Landing Gear �ٿ�� �߰��Ǵ� Drag Coefficient

% Surf: �װ��� ���� ����
% g: �߷� ���ӵ�
% mass: �װ��� ����(kg)
% TAS: �װ��� �ӵ�(m/s)
% accl: ���򰡼ӵ�(m/s^2)
% vert: �������ӵ�(m/s^2)

% Lift: �װ��� �ۿ� ���
% qS: 1/2 * rho * v^2 * S (��°� �׷¿� ���Ǵ� ���)
% LiftCoeff: ��� ���
% DragCoeff: �׷� ���
% Drag: �׷�

% Required Thrust: �ش� ����/���� ���ӵ��� ���� ���� �ʿ� �߷�

% ISA_Max_Thrust: ISA ȯ�濡�� �ִ� �߷�
% dTeff: ISA�� ���� �������� ��� �𵨿��� �µ� ���̸� �ݿ��� ��� -> ����� ���� ����
% maxThrust: dTeff�� ������ �ִ� �߷�

% Thrust: ���� �߷�



% ���� �Ҹ� ���� ����

% CF1 ~ CF4 & CFCR: BADA �� ���� �Ҹ��� ��� �Ķ����
% mu: �ش� �Ķ���ͷ� ���� ���
% FuelNom: nomial Fuel Flow
% FuelMin: minimal Fuel Flow
% FuelAPLD: Fuel Flow in Approach/Landing Segment
% FuelCR: Fuel Flow in Cruise Segment

% FuelFlow: Flap Setting�� ���� ���� �Ҹ� ���


% ��� ���� ����

% RequiredROT: RequiredHdgDiff�� �����ϱ� ���� �ð��� ���� ��� ��ȭ�� (deg/sec)
% absmaxROT: �װ��� �ӵ��� bankangle�� ���� �ִ� ��ȸ�� (deg/sec)
% TurnRate: ���� ��ȸ��

function flight = Autopilot(RunTime, flight)

global config unit Perf atmos

% Get next Reference Point


% Test Code: ���� �ȿ� ������ Mode�� Manual�� ����
if config.EXPTEST
    if and(flight.label == 1, flight.manual.cta == [1 ; 0 ; 0])
        dist = 60 * ((config.TGTAD(1) - flight.long)^2 + (config.TGTAD(2) - flight.lat)^2);
        if and(dist > config.SWITCHRANGE - 2, dist < config.SWITCHRANGE)
            flight.manual.spd = [1 ; flight.Vtas_sc ; 0]; % �ӵ� ���� ����(������ ����) - boolean ; ������ �ӵ� - double
            flight.manual.alt = [1 ; flight.alt_sc ; 0]; % �� ���� ����(������ ����), 3rd arg: ROCD limit (ft/min) -> 0: auto, -1: maximum, other: inputed ROCD
            flight.manual.hdg = [1 ; flight.hdg_sc ; 0]; % ��� ���� ����(������ ����), 3rd arg: direction (0: auto, 1: one loop clockwise, -2: two loop counter clockwise)
            flight.manual.cta = [0 ; 0 ; 0];
            flight.alt_sc = flight.alt;
            flight.Vtas_sc = flight.Vtas;
            flight.hdg_sc = flight.hdg;

        end
    end
end




if and(~flight.manual.hdg(1), flight.manual.cta(1)) % Refernece Trajectory�� �ð��� �������� ��������
    
    %   (1) CTA: ���� �ð��� Reference Trajectory�� ��
    if RunTime - flight.delay >= flight.Reference(6, flight.ReferenceTo) + flight.gentime - (max(config.update * 2, config.TrajRes))

        flight.ReferenceFrom = flight.ReferenceTo;
        [len, wid] = size(flight.Reference);
        
        
        if flight.ReferenceFrom >= wid - 1
            %   Trajectory �� -> ������ ����
            timeleft = (flight.Reference(6, end) - flight.Reference(6, flight.ReferenceFrom));
            speedcor = ((flight.Vtas / flight.Reference(5, flight.ReferenceFrom)) - 1) / 2;
            if or(isinf(speedcor), isnan(speedcor))
                speedcor = 0;
            end
            flight.arrived = round(RunTime + (timeleft * (1 + speedcor))) + config.update;
        else
            %   Trajectory ��������
            nexttime = 1;
            cumtime = 0;
            flight.ReferenceTo = flight.ReferenceTo + 1;
            
            %   ������ Reference Trajectory �� �װ��� ��ġ�� ���� �� �����ͷ� �����ð���
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
            
            %   Reference Trajectory ���� ReferenceTo�� �ش��ϴ� �� ������ �޾ƿ���
            [flight.long_sc, flight.lat_sc, flight.alt_sc, flight.Vtas_sc, flight.hdg_sc, flight.FS] = GetNextReference(flight, flight.ReferenceTo);
        end
        
        
    end
elseif and(~flight.manual.hdg(1), ~flight.manual.cta(1))
    %   (1) spd: ���� ��ġ�� Reference Trajectory�� ��
    
    % Reference Trajectory�� ���� ��� �������� ��������
    % ���� ���� Reference �������� bearing�� ���� heading ��, ���� ���� �ٸ��� 1�� ����
    % ���� fix�� ���� fix���� �Ÿ��� �ſ� ª�� -> ���� reference Trajecoty ���� ����
    
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

% ������ġ�� ���� Reference�� �� �䱸�Ǵ� SPD, ACCL, HDG, ROCD ���ϱ�
% Reference���� �޾ƿ� spd�� ������� �ʰ� ���⼭�� ���� ��ġ������ ���� �Ÿ��� spd�� ����.

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
if flight.manual.cta(1) % Time Controlled -> ������ �����ð��� �µ��� �ӵ� ����

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



%% ����/�������ӵ�
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

% % Thrust Limit�� ���� ���ӵ� ����... �� Thrust�� ������ ����
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