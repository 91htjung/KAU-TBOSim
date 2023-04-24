function [config, unit, atmos]=Configuration
msg='Loading Configuration......';
config=struct;

config.EXPTEST = 1; % 실험용 스위치
config.TGTAD = [126.439166666667, 37.4625000000000]; % RKSI
config.SWITCHRANGE = 100; % NM

config.VisibleFilter = 0; % Make Track Visible with certain Condition, invisible elsewise.
config.VisibleCenter = [126.439166666667, 37.4625000000000];
config.VisibleRange = 200;


config.Vid = 0;
config.VidTime = 3600;

config.Temp = false; %온도 변화 반영 (True: 실제 기온 / False: ISA 기준 - MSL에서 15 Celcius)
config.Pres = false; %기압 변화 반영 (True: 실제 기압 / False: ISA 기준 - MSL에서 1013.25hPa)

config.Map={'Japan';'Korea'}; % Data 처리 순서로 Japan 먼저
% config.Map = {'Korea'};

config.AC_List={'A306';'A319';'A320';'A321';'A332';'A333';'A343';'A346';'A388'; ...
    'B732';'B733';'B734';'B735';'B737';'B738';'B739';'B744';'B748';'B752';'B762';'B763';'B772';'B773';'B77W';'B77L';'B788'; ...
    'C130';'C172';'C560';'CRJ2';'DH8C';'DH8D';'E170';'E190';'MD11';'SF34';}; %사용할 항공기 목록

config.AD_List={...
    'RKSI';'RKPC';'RKSS';'RKPK';'RKTN';'RKTU';'RKJB';'RKJJ';'RKJK';'RKJY';'RKNY';'RKNW';'RKPS';'RKPU';'RKTH';... % Korea (15)
    
    'RJAA';'RJBB';'RJCC';'RJTT';'RJFF';'ROAH';'RJOO';'RJGG';'RJFK';'RJFT';'RJSS';'RJFU';'RJFM';'RJOM';'RJOA';...
    'RJBE';'ROIG';'RJFO';'RJNK';'RJOT';'RJCH';'RJOB';'RJOK';'ROMY';'RJFR';'RJSK';'RJEC';'RJOS';'RJSA';'RJSN';... % Japan (30)
    
    'ZBAA';'ZSPD';'ZGGG';'ZUUU';'ZGSZ';'ZSSS';'ZPPP';'ZLXY';'ZUCK';'ZSHC';'ZSAM';'ZSNJ';'ZHHH';'ZGHA';'ZWWW';...
    'ZSQD';'ZHCC';'ZJSY';'ZJHK';'ZBTJ';'ZYTL';'ZYHB';'ZUGY';'ZYTX';'ZSFZ';'ZGNN';'ZSJN';'ZBYN';'ZYCC';'ZLLL';...
    'ZSCN';'ZBHH';'ZSWZ';'ZSNB';'ZSOF';'ZGKL';'ZBSJ';'ZPLJ';'ZLIC';'ZBNY';'ZGSD';'ZSWX';'ZSYT';'ZPJH';'ZLXN';...
    'ZSQZ';'ZGOW';'ZULS';'ZBOW';'ZBLA'... % China (50)
    
    'ZMUB';'VHHH';'WIII';'WARR';'WADD';'WAAA';'WIMM';'WICC';'VMMC';'WMKJ';'WBKK';'WBGG';'WMMK';'WBGR';'WMKP';'RPLC';...
    'RPLL';'RPVI';'RPVK';'RPVM';'RPMD';'WSSS';'RCTP';'RCKH';'RCMQ';'VTBS';'VTBD';'VTCC';'VTSP';'VTSM';'VVNB';'VVTS';... % SE Asia (32)
    
    'VVTS';'OMDB';'VABB';'VIDP';'OEJN';'OPKC';'OTBD';'OIII';... % Other Asian
    
    'KATL';'KORD';'EGLL';'KLAX';'LFPG';'KDFW';'LTBA';'EDDF';'EHAM';'KJFK';'KDEN';'KSFO';'LEMD';'KLAS';'KCLT';'KMIA';...
    'KPHX';'KIAH';'KSEA';'CYYZ';'EDDM';'LIRF';'EGKK';'YSSY';'LEBL';'SBGR';'KMCO';'MMMX';'KEWR';'KMSP';'UUDD';'UUEE';...
    'LFPO';'LTAI';'EKCH';'LSZH';'ENGM';'LTFJ';'LEPA';'LOWW';'ESSA';'EGCC';'EBBR';'EDDL';'EIDW';'EDDT';'KBOS';'KDTW';...
    'KPHL';'KLGA';'KFLL';'KBWI';'KDCA';'KMDW';'KSLC';'KIAD';'CYVR';'KSAN';'SKBO';'YMML';'YBBN';'FAOR';% Other Large Airports
    };

config.AClookup = {'A330', 'A333' ; 'B747' , 'B744' ; 'B767' , 'B763' ; 'B787' , 'B788' ; 'B777' , 'B772'};
config.defaultAC = 'A333';

config.update = 5; % simulation update time (sec)
config.starttime = (18 * 86400) + (9 * 3600); % simulation start time (sec)
config.simtime = 4000; % maximum simulation time (sec)
config.timer = 0; % Update Timer, 0:Off, Else: time(sec)

config.AutoRadarUpdate = 1; % Auto radar update setting (20 FPS);
config.ManualRadarUpdate = 3; % Manual Radar Update Interval (with RunTime)
config.RadarPause = 0; % Additional Radar Pause (sec)

config.Filter = 0; % Filter Displayed AC
config.RadarColorLabel = 1; % Radar Highlighted Color Based on Label (true) / Default (false)


config.LogSwitch = 0; % Switch : Save Log into txt file
config.InternalLogSwitch = 0; % Switch: Save Log into local variable (lower performance)

config.ReadSwitch = 0; % Switch : Import data;
config.PlanSwitch = 0; % Switch : Flight Plan Reading Reserved
config.WeatherSwitch = 0; % Switch : Weather Reading
config.GenerateSwitch = 0; % Switch : Generate Trajectory;
config.ValidateSwitch = 0; % Switch : Validate Trajectory;
config.SimulateSwitch = 0; % Switch : Simulation
config.MappingSwitch = 0; % Switch : Mapping

config.RadarDataSwitch = [1 ; 1 ; 0 ; 0 ; 0]; % Switch : Import RadarData / ARTS+FPLAN
% config.RadarData = {'Cleaned_Radar_Data_2012_0801' ; '20160509'} ; % RadarData (Korea) ; Date: ARTS/Flight Plan (Japan)
config.RadarData = {'radarData150118' ; 'trk7_rdp_facc_20150118' ; 'trk7_rdp_tacc_20150118' ; 'trk7_rdp_sacc_20150118' ; 'trk7_rdp_nacc_20150118'} ; % RadarData (Korea) ; Date: ARTS/Flight Plan (Japan)
config.PlanData = {'150118_plan.csv'; '' ; '' ; '' ; ''}; % FlightPlanData (Korea, Japan)

config.Scenario = 'Test'; % Import Scenario

config.Curve = 'strict'; %'free', 'semifree', 'strict'
config.CurveOpt = 0; % Curve Optimization
config.CurveThr = 1; % Straight-segment / Curve-segment Heading difference Threshold  (deg)

config.DistDiffThreshold = 1.0; % Autopilot Module: Distance Difference Threshold -> 여기에 update와 속도(nm/sec)가 곱해짐
config.AngleDiffThreshold = 5.0; % Autopilot Module: Angle Difference Threshold (deg/sec)

config.SecDerivCoeff = 0.5; % Coefficient for Second Derivates (accel, hdg rate...) in Control

config.ThrustCorr = 0; % Correction of Thrust if thrust is below min or above max -> unstable
config.FlapBreakFlag = 0; % Flap Brake -> unstable
config.FlapBreakTime = 0; % Time(sec) threshold for activating & deactivating Flap Break -> autopilot module

config.TrajRes = 5; % Trajectory Resolution(sec)
config.AltRes = [1000 ; 0]; % Altitude Round Resolution [ManualInput - 1000ft 단위 등.. ; Autopilot - 소수점 자리]
config.SpdRes = [10 ; 2]; % Airspeed Round Resolution
config.HdgRes = [1 ; 2]; % Heading Round Resolution

config.BankAngleBuffer = 0.8; % Accel_Profile-> BankAngle Buffer * Nomial BankAngle
config.Lambda = [0.02 ; 0.02]; % non-optimization manual input: lambda0, lambda1
config.RunSpeed = 50; % 50배속

config.InitialTarget = 1; % Initial Target AC in Radar
config.WindOpt = 1; % Apply Wind data -> lower performance
config.WindNoise = 1; % Apply Normal Noise into Wind data
config.WindMu = [0 ; 0]; % Noise Maen (dir - radian, spd - kt)
config.WindSigma = [0.5 ; 3]; % Noise Std dev. (dir, spd)

config.TrailFlag = 1; % Trail On/Off
config.TrailNo = 3; % Number of Trail displayed in Radar Screen
config.TrailInterval = 3; % Trail Interval (Interval * update)

config.HdgLineFlag = 1; % Heading Line On/Off
config.HdgLineParam = [0.01, 1.001]; % Parameter for line length (multiply, exp_base param)

config.ListWidth = 250; % Width of List shown on right side of Radar

config.RadarCL = 1; % Display CoastLine in Radar Screen
config.RadarAD = 1; % Display Aerodrome in Radar Screen
config.RadarAS = 1; % Display Airspace in Radar Screen
config.RadarAR = 1; % Display AirRoute in Radar Screen
config.RadarWP = 1; % Display Waypoints in Radar Screen

% Save Initialized Radar into PNG and import again
% This would save memory usage but do not support object interactions
config.RadarIMG = 0; % Unstable


config.InitCamPoint = [126 ; 36];
config.InitCamMag = 20;
config.AircraftCam = 0; % Camera Follow Aircraft

config.ViewTraj = 0; % View Target Trajectory
config.ViewCont = 0; % View Target Control Points

config.GraphTarget = 7;
config.GraphRange = 90; % Graph Time Range

config.Zoom = 1.2;
config.Pan = 0;
[msg 'completed']

%% ATMOSPHERE MODEL (pp.7 - pp.12)

unit.ft2meter  = 0.3048; % 1ft = 0.3048m
unit.meter2ft  = 3.2808;
unit.kt2ms = 0.5144; % 1kt = 0.5144m/s
unit.ms2kt = 1.9440;
unit.inch2meter = 0.0254; % 1inch = 0.0254m
unit.nm2meter = 1852; % 1NM = 1852m
unit.meter2nm = (1/1852);
unit.lbs2kg = 0.453592; % 1pound = 2.20462 kg
unit.nm2ft = 6076.12; % 1NM = 6076ft
unit.ft2nm = (1/6076.12);

msg='Loading Atmosphere model......';

%Constants (3.1.2. Expressions)
atmos.kappa = 1.4; %Adiabatic index of air 3.1-25
atmos.kmu = (atmos.kappa-1)/atmos.kappa;
atmos.R = 287.05287; %Real gas constant for air [m^2/(K*s^2)]
atmos.g_0 = 9.80665; % gravitational acceleration [m/s^2]
atmos.beta_Tb = -0.0065; %ISA temperature gradient with altitude below the tropopause [K/m]
atmos.Rad_ear = 6371000; % earth radius (m)

%ISA (3.1.1. Definitions)
atmos.p_0 = 101325; %Standard atmospheric pressure at MLS [Pa]
atmos.rho_0 = 1.225; %Standard atmospheric density at MLS [kg/m^3]
atmos.a_0 = 340.294; %Speed of sound [m/s]a
atmos.T_0 = 288.15 ; %Standard atmospheric temperature [K]
%그 외 고도에 대해서는 [T, a, p, rho] = atmosisa(height) 함수를 사용
atmos.h_trop = 11000;


%Temp / Pres 옵션에 따라 입력
if config.Temp==true
    atmos.T = str2double(input('Enter Temperature(℃) in MSL :','s'));
    atmos.Td=atmos.T-atmos.T_0;
else
    atmos.T = atmos.T_0;
    atmos.Td=0;
end

if config.Pres==true
    atmos.p = str2double(input('Enter Pressure(hPa) in MSL :' ,'s'));
    atmos.pd=atmos.p-atmos.p_0;
else
    atmos.p = atmos.p_0;
    atmos.pd=0;
end

% wind direction in deg;
atmos.wind.dir = 0;
% wind speed in kt
atmos.wind.spd = 0;

[msg 'completed']

end