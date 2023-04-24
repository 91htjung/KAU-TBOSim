% 17.05.19 Autopilot_Vectorized

function flight = vecAutopilot(flight, RunTime)

global config unit Perf atmos

% Vectorize on May 20th, 2017
[~, ~, ~, rho] = atmosisa(([flight.alt] * unit.ft2meter));

manual = [flight.manual];

bankangle = zeros(1, length(flight));
minspeed = zeros(1, length(flight));
timeavail = zeros(1, length(flight));


manualbank = [manual.ban];
fixedbank = manualbank(1,:);

bankangle =  bankangle + fixedbank .* manualbank(2,:);
bankangle = bankangle + and(~fixedbank, strcmp({flight.FS}, 'TO')) .* 15 + and(~fixedbank, strcmp({flight.FS}, 'IC')) .* 35 +...
    and(~fixedbank, strcmp({flight.FS}, 'CR')) .* 35 + and(~fixedbank, strcmp({flight.FS}, 'AP')) .* 35 + ...
    and(~fixedbank, strcmp({flight.FS}, 'LD')) .* 15;

paramindex = strcmp({flight.FS}, 'TO') | strcmp({flight.FS}, 'IC') | strcmp({flight.FS}, 'CR') | strcmp({flight.FS}, 'AP') | strcmp({flight.FS}, 'LD');
temFS = {flight.FS};
temFS(~paramindex) = {'TO'};
Cd0 = cell2mat(cellfun(@(x, y) Perf.(x).(strcat('CD0_', y)), {flight.type}, temFS, 'uni', false));
Cd2 = cell2mat(cellfun(@(x, y) Perf.(x).(strcat('CD2_', y)), {flight.type}, temFS, 'uni', false));
Cd0(~paramindex) = 0;
Cd2(~paramindex) = 0;

paramindex = strcmp({flight.FS}, 'LD');
CdLDG = cell2mat(cellfun(@(x) Perf.(x).GearDown_CD0, {flight.type}, 'uni', false));

paramindex = strcmp({flight.FS}, 'TO');
minspeed = minspeed + paramindex .* cell2mat(cellfun(@(x, y) cas2tas(1.2 * Perf.(x).Vstall_TO, y), {flight.type}, {flight.alt},  'uni', false));

paramindex = strcmp({flight.FS}, 'IC') | strcmp({flight.FS}, 'CR') | strcmp({flight.FS}, 'AP') | strcmp({flight.FS}, 'LD');
minspeed = minspeed + paramindex .* cell2mat(cellfun(@(x, y, z) cas2tas(1.3 * Perf.(x).(strcat('Vstall_', z)), y), {flight.type}, {flight.alt}, temFS, 'uni', false));

mtransalt = cell2mat(cellfun(@(x) Perf.(x).Machtrans_cruise, {flight.type}, 'uni', false));

beltransind = [flight.alt] < mtransalt;
maxspeed = beltransind .* cell2mat(cellfun(@(x, y) cas2tas(1.15 * Perf.(x).VMO, y), {flight.type}, {flight.alt},  'uni', false)) ...
    + ~beltransind .* cell2mat(cellfun(@(x, y) mach2tas(1.15 * Perf.(x).MMO, y), {flight.type}, {flight.alt},  'uni', false));


hdgdiff = mod([flight.hdg_sc] - [flight.hdg], 360); % deg
hdgdiff(hdgdiff > 180) = hdgdiff(hdgdiff > 180) - 360;

spddiff = ([flight.Vtas_sc] - [flight.Vtas]) / 3600; % nm/sec
altdiff = [flight.alt_sc] - [flight.alt]; % ft

latdiff = deg2nm([flight.lat_sc] - [flight.lat]); % nm
longdiff = deg2nm([flight.long_sc] - [flight.long]); % nm
distdiff = sqrt(latdiff.^2 + longdiff.^2); % nm

TrajLatDiff = deg2nm(cell2mat(cellfun(@(x, y) x(3, y), {flight.Reference}, {flight.ReferenceTo}, 'uni', false)) - [flight.lat]);
TrajLongDiff = deg2nm(cell2mat(cellfun(@(x, y) x(2, y), {flight.Reference}, {flight.ReferenceTo}, 'uni', false)) - [flight.long]);
TrajDistDiff = sqrt(TrajLatDiff.^2 + TrajLongDiff.^2);


manualcta = [manual.cta];
manualhdg = [manual.hdg];
manualalt = [manual.alt];

dyindex = manualcta(1,:);
stindex = and(~dyindex, ~manualhdg(1,:));
maindex = and(~dyindex, manualhdg(1,:));

% cell2mat(cellfun(@(x, y) x(6, y), {flight.Reference}, {flight.ReferenceTo}, 'uni', false))

timeavail = timeavail + dyindex .* ...
    ((cell2mat(cellfun(@(x, y) x(6, y), {flight.Reference}, {flight.ReferenceTo}, 'uni', false)) + [flight.gentime]) - (RunTime - [flight.delay]) + config.update);

timeavail = timeavail + stindex .* ...
    TrajDistDiff ./ (((cell2mat(cellfun(@(x, y) x(5, y), {flight.Reference}, {flight.ReferenceTo}, 'uni', false)) + [flight.Vtas]) / (2 *3600)) .* cos(deg2rad(hdgdiff)));

timeavail = timeavail + maindex * max(2 * config.update, config.TrajRes);


%% Heading
fixedhdg = manualhdg(1,:);
RequiredHdg = zeros(1, length(flight));
RequiredHdgDiff = zeros(1, length(flight));

if ~all(fixedhdg == 0)
    
    ReqDSpd = spddiff ./ timeavail; %nm/sec
    ReqSpd = ([flight.Vtas] / 3600) + ReqDSpd; %nm/sec
    AvgSpd = (([flight.Vtas] / 3600) + ReqSpd) / 2; %nm/sec

    newlong_sc = ~fixedhdg .* [flight.long_sc] + fixedhdg .* ...
        ([flight.long] + nm2deg((sin(deg2rad([flight.hdg])) .* AvgSpd) * config.update));
    newlat_sc = ~fixedhdg .* [flight.lat_sc] + fixedhdg .* ...
        ([flight.lat] + nm2deg((cos(deg2rad([flight.hdg])) .* AvgSpd) * config.update));
    
    newlong_sc = num2cell(newlong_sc);
    newlat_sc = num2cell(newlat_sc);
    [flight.long_sc] = newlong_sc{:};
    [flight.lat_sc] = newlat_sc{:};
    
    RequiredHdg = RequiredHdg + fixedhdg .* [flight.hdg_sc];
    
end

if ~all(fixedhdg == 1)
    RequiredHdg = RequiredHdg + ~fixedhdg .* mod(rad2deg(atan2([flight.long_sc] - [flight.long], [flight.lat_sc] - [flight.lat])), 360);
end

RequiredHdgDiff = mod(RequiredHdg - [flight.hdg], 360);
RequiredHdgDiff(RequiredHdgDiff > 180) = RequiredHdgDiff(RequiredHdgDiff > 180) - 360;

tdir = zeros(1, length(flight));
temary = manualhdg(3,:);
if ~all(temary == 0)
    posdirind = and(fixedhdg, manualhdg(3,:) > 0);
    posdircond = and(posdirind, and(RequiredHdgDiff >= (-360 + 360 * manualhdg(3,:)), RequiredHdgDiff < -180 + (360 * manualhdg(3,:))));
    tdir = tdir + posdircond .* max(0, temary - 1);
    
    negdirind = and(fixedhdg, manualhdg(3,:) < 0);
    negdircond = and(negdirind, and(RequiredHdgDiff > 180 + (360 * manualhdg(3,:)), RequiredHdgDiff <= 360 + (360 * manualhdg(3,:))));
    tdir = tdir + negdircond .* min(0, temary - 1);
    
    if ~all(or(posdircond, negdircond) == 0)
        % unable to vectorize: no direct access to 2nd deep struct data
        for i = 1:length(tdir)
            flight(i).manual.hdg(3) = tdir(i);
        end
    end
    RequiredHdgDiff = RequiredHdgDiff + fixedhdg .* (360 * tdir);
end

RequiredROT = RequiredHdgDiff ./ (timeavail * config.SecDerivCoeff); % deg/sec^2
absmaxROT = rad2deg(tan(deg2rad(bankangle)) * atmos.g_0 ./ ([flight.Vtas] * unit.nm2meter / 3600)); % deg/sec

posReqROT = RequiredROT > 0;
TurnRate = posReqROT .* min(RequiredROT, absmaxROT) + ~posReqROT .* max(RequiredROT, - 1 * absmaxROT);

%% Get Distance

RequiredSpd = dyindex .* ((distdiff .* abs(cos(deg2rad(RequiredHdgDiff)))) ./ timeavail) + ...
    ~dyindex .* ([flight.Vtas_sc] / 3600);

RequiredSpd = min(max((minspeed / 3600), RequiredSpd), (maxspeed / 3600));

max_pitch = 30 * ones(1, length(flight));
fixedROCDind = manualalt(2,:);

RequiredROCD = (fixedROCDind == 0) .* (altdiff ./ timeavail) + ((fixedROCDind ~= 0) .* (fixedROCDind / 60));
posreqROCD = RequiredROCD >= 0;

RequiredROCD = posreqROCD .* (min(RequiredROCD, ((RequiredSpd * unit.nm2ft) .* sin(deg2rad(max_pitch))))) ...
    + ~posreqROCD .* (max(RequiredROCD, - 1 * ((RequiredSpd * unit.nm2ft) .* sin(deg2rad(max_pitch)))));

%% 수평/수직가속도
% Get Performance Parameter
RequiredLongAccel = (RequiredSpd - ([flight.Vtas] / 3600))  .* abs(cos(deg2rad(RequiredHdgDiff))) ./ (timeavail); % nm/sec^2
RequiredVertAccel = (RequiredROCD - [flight.ROCD]) ./ (timeavail * config.SecDerivCoeff); % ft/sec^2

%% Thrust

Surf = cell2mat(cellfun(@(x) Perf.(x).Surf, {flight.type}, 'uni', false));
g = atmos.g_0; % m/s^2

mass = [flight.mass] * 1000;
TAS = [flight.Vtas] * unit.nm2meter / 3600;
TAS(TAS == 0) = 0.000001;
VS = [flight.ROCD] * unit.ft2meter; % ft/s -> m/s

accl = RequiredLongAccel * unit.nm2meter; % nm/s^2 -> m/s^2
accv = RequiredVertAccel * unit.ft2meter; % ft/s^2 -> m/s^2
acc = sqrt(accl.^2 + accv.^2);

Lift = mass .* (g + accv);
qS = rho .* (TAS .^ 2) .* Surf / 2;

LiftCoeff = Lift ./ qS;
DragCoeff = (Cd0 + CdLDG) + (Cd2 .* (LiftCoeff.^2));
Drag = DragCoeff .* qS;

% Total Energy Model
RequiredThrust = Drag + (mass .* atmos.g_0 .* VS ./ TAS) + (mass .* accl);

% Maximum Thrust
jetind = cell2mat(cellfun(@(x) strcmp({Perf.(x).Engtype}, 'Jet'), {flight.type}, 'uni', false));
propind = cell2mat(cellfun(@(x) strcmp({Perf.(x).Engtype}, 'Turboprop'), {flight.type}, 'uni', false));
pistind = cell2mat(cellfun(@(x) strcmp({Perf.(x).Engtype}, 'Piston'), {flight.type}, 'uni', false));

jetMaxThr = cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_1, {flight.type}, 'uni', false)) .* (1 - (geoalt([flight.alt]) ./ cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_2, {flight.type}, 'uni', false))) + ((cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_3, {flight.type}, 'uni', false))) .* ((geoalt([flight.alt]) .^ 2))));
propMaxThr = (((cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_1, {flight.type}, 'uni', false))) ./ ([flight.Vtas])) .* (1 - ((geoalt([flight.alt]) / (cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_2, {flight.type}, 'uni', false))))))) + (cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_3, {flight.type}, 'uni', false)));
pistMaxThr = (cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_1, {flight.type}, 'uni', false)) .* (1 - ((geoalt([flight.alt]) ./ (cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_2, {flight.type}, 'uni', false))))))) + ((cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_3, {flight.type}, 'uni', false))) ./ ([flight.Vtas]));

jetMaxThr(isnan(jetMaxThr)) = 0;
propMaxThr(isnan(propMaxThr)) = 0;
pistMaxThr(isnan(pistMaxThr)) = 0;

jetMaxThr(isinf(jetMaxThr)) = 0;
propMaxThr(isinf(propMaxThr)) = 0;
pistMaxThr(isinf(pistMaxThr)) = 0;

ISA_Max_Thrust = jetind .* jetMaxThr + propind .* propMaxThr + pistind .* pistMaxThr;

% ISA_Max_Thrust = jetind .* cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_1, {flight.type}, 'uni', false)) .* (1 - (geoalt([flight.alt]) ./ cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_2, {flight.type}, 'uni', false))) + ((cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_3, {flight.type}, 'uni', false))) .* ((geoalt([flight.alt]) .^ 2)))) ...
%     + propind .* (((cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_1, {flight.type}, 'uni', false))) ./ ([flight.Vtas])) .* (1 - ((geoalt([flight.alt]) / (cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_2, {flight.type}, 'uni', false))))))) + (cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_3, {flight.type}, 'uni', false))) ...
%     + pistind .* (cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_1, {flight.type}, 'uni', false)) .* (1 - ((geoalt([flight.alt]) ./ (cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_2, {flight.type}, 'uni', false))))))) + ((cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_3, {flight.type}, 'uni', false))) ./ ([flight.Vtas]));

dTeff = atmos.Td - cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_4, {flight.type}, 'uni', false));
dTeff = min(max(0, dTeff), (0.4 ./ cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_5, {flight.type}, 'uni', false))));

maxThrust =ISA_Max_Thrust .* (1 - ((cell2mat(cellfun(@(x) Perf.(x).MaxClimbThrust_5, {flight.type}, 'uni', false))) .* (dTeff)));


negreqThr = RequiredThrust < 0;
ovrmaxThr = RequiredThrust > maxThrust;
norminThr = and(RequiredThrust >= 0, RequiredThrust <= maxThrust);

Thrust = negreqThr .* 0 + ovrmaxThr .* maxThrust + norminThr .* RequiredThrust;

if config.ThrustCorr
    targetThr = or(negreqThr, ovrmaxThr);
    ForceDev = RequiredThrust - Thrust;
    k = sqrt(((acc - (ForceDev ./ mass)).^2) ./ (acc.^2));
    
    RequiredLongAccel = ~targetThr .* RequiredLongAccel + targetThr .* (k .* accl * unit.meter2nm);
    RequiredVertAccel = ~targetThr .* RequiredVertAccel + targetThr .* (k .* accv * unit.meter2ft);
    
end

if config.FlapBreakFlag

    newFixFlapcnt = [flight.FixFlapCount];
    
    curFSary = strcmp({flight.FS}, 'TX') * 1 + strcmp({flight.FS}, 'TO') * 2 + strcmp({flight.FS}, 'IC') * 3 + ...
        strcmp({flight.FS}, 'CR') * 4 + strcmp({flight.FS}, 'AP') * 5 + strcmp({flight.FS}, 'LD') * 6;
    
    FixFlapary = strcmp({flight.FixFlap}, 'TX') * 1 + strcmp({flight.FixFlap}, 'TO') * 2 + strcmp({flight.FixFlap}, 'IC') * 3 + ...
        strcmp({flight.FixFlap}, 'CR') * 4 + strcmp({flight.FixFlap}, 'AP') * 5 + strcmp({flight.FixFlap}, 'LD') * 6;  
    
%     FixFlapcel = {flight.FixFlap};
    
    empflaptgt = strcmp({flight.FixFlap}, '');
    newflaptgt = and(empflaptgt, [flight.FixFlapCount] > config.FlapBreakTime);
    
    highertgt = and(newflaptgt, negreqThr);
    if ~all(highertgt == 0)
        FixFlapary(and(highertgt, curFSary == 3)) = 2;
        FixFlapary(and(highertgt, curFSary == 4)) = 5;
        FixFlapary(and(highertgt, curFSary == 5)) = 6;
        newFixFlapcnt(highertgt) = 0;
    end
    
    lowertgt = and(newflaptgt, ovrmaxThr);
    if ~all(lowertgt == 0)
        FixFlapary(and(lowertgt, curFSary == 2)) = 3;
        FixFlapary(and(lowertgt, curFSary == 3)) = 4;
        FixFlapary(and(lowertgt, curFSary == 5)) = 4;
        FixFlapary(and(lowertgt, curFSary == 6)) = 5;
        newFixFlapcnt(lowertgt) = 0;
    end
    
    recflaptgt = and(~empflaptgt, norminThr);
    resettgt = and(recflaptgt, [flight.FixFlapCount] > config.FlapBreakTime);
    if ~all(resettgt == 0)
        curFSary(resettgt) = FixFlapary(resettgt);
        newFixFlapcnt(resettgt) = 0;
        FixFlapary(resettgt) = - 1;
    end
    
    addtimetgt = or(and(or(highertgt, lowertgt), [flight.FixFlapCount] <= config.FlapBreakTime), and(recflaptgt, [flight.FixFlapCount] <= config.FlapBreakTime));
    
    if ~all(addtimetgt == 0)
        newFixFlapcnt(addtimetgt) = newFixFlapcnt(addtimetgt) + config.update;
    end
    
    cortimetgt = and(empflaptgt, norminThr);
    if ~all(cortimetgt == 0)
        newFixFlapcnt(cortimetgt) = max(0, newFixFlapcnt(cortimetgt) - (config.update / 2));
    end
    
    fscell = {flight.FS};
    
    fscell(curFSary == 1) = {'TX'};
    fscell(curFSary == 2) = {'TO'};
    fscell(curFSary == 3) = {'IC'};
    fscell(curFSary == 4) = {'CR'};
    fscell(curFSary == 5) = {'AP'};
    fscell(curFSary == 6) = {'LD'};
    ffcell = {FixFlapary};
    
    ffcell(FixFlapary == - 1) = {''};
    ffcell(FixFlapary == 0) = {''};
    ffcell(FixFlapary == 1) = {'TX'};
    ffcell(FixFlapary == 2) = {'TO'};
    ffcell(FixFlapary == 3) = {'IC'};
    ffcell(FixFlapary == 4) = {'CR'};
    ffcell(FixFlapary == 5) = {'AP'};
    ffcell(FixFlapary == 6) = {'LD'};
    newFixFlapcnt = num2cell(newFixFlapcnt);
    
    [flight.FS] = fscell{:};
    [flight.FixFlapCount] = newFixFlapcnt{:};
    [flight.FixFlap] = ffcell{:}; 
end

nonTXind = ~strcmp({flight.FS}, 'TX');
posReqLong = and(nonTXind, RequiredLongAccel >= 0);
negReqLong = and(nonTXind, RequiredLongAccel < 0);
posReqVert = and(nonTXind, RequiredVertAccel >= 0);
negReqVert = and(nonTXind, RequiredVertAccel < 0);

LongAccel = posReqLong .* min(RequiredLongAccel, unit.ft2nm * 2) ...
     + negReqLong .* max(RequiredLongAccel, unit.ft2nm * -2) ...
     + ~nonTXind .* RequiredLongAccel;
 
VertAccel = posReqVert .* min(RequiredVertAccel, sqrt(21)) ...
     + negReqVert .* max(RequiredVertAccel, -sqrt(21)) ...
     + ~nonTXind .* RequiredVertAccel;


%% Fuel Consumption
CF1 = cell2mat(cellfun(@(x) Perf.(x).Thrust_Fuel1, {flight.type}, 'uni', false));
CF2 = cell2mat(cellfun(@(x) Perf.(x).Thrust_Fuel2, {flight.type}, 'uni', false));
CF3 = cell2mat(cellfun(@(x) Perf.(x).Descent_Fuel3, {flight.type}, 'uni', false));
CF4 = cell2mat(cellfun(@(x) Perf.(x).Descent_Fuel4, {flight.type}, 'uni', false));
CFCR = cell2mat(cellfun(@(x) Perf.(x).Cruise_Fuel, {flight.type}, 'uni', false));

jetmu = (CF1 .* (1 + ([flight.Vtas] ./ CF2)));
propmu = (CF1 .* (1 - ([flight.Vtas] ./ CF2)) .* ([flight.Vtas] / 1000));
jetmu(or(isnan(jetmu), isinf(jetmu))) = 0;
propmu(or(isnan(propmu), isinf(propmu))) = 0;

mu = jetind .* jetmu + propind .* propmu;

jetFNom = (mu .* (Thrust ./ 1000));
propFNom = (mu .* (Thrust ./ 1000));
pistFNom = CF1;

jetFNom(or(isnan(jetFNom), isinf(jetFNom))) = 0;
propFNom(or(isnan(propFNom), isinf(propFNom))) = 0;
pistFNom(or(isnan(pistFNom), isinf(pistFNom))) = 0;

FuelNom = jetind .* jetFNom + propind .* propFNom + pistind .* pistFNom;

jetFMin = (CF3 .* (1 - (geoalt([flight.alt]) ./ CF4)));
propFMin= (CF3 .* (1 - (geoalt([flight.alt]) ./ CF4)));
pistFMin = (CF3);

jetFMin(or(isnan(jetFMin), isinf(jetFMin))) = 0;
propFMin(or(isnan(propFMin), isinf(propFMin))) = 0;
pistFMin(or(isnan(pistFMin), isinf(pistFMin))) = 0;

FuelMin = jetind .* jetFMin + propind .* propFMin + pistind .* pistFMin;

FuelAPLD = jetind .* (max(FuelNom, FuelMin)) ...
    + propind .* (max(FuelNom, FuelMin)) ...
    + pistind .* (FuelNom);

FuelCR = FuelNom .* CFCR;


FuelFlow = strcmp({flight.FS}, 'TX') .* FuelNom ...
    + strcmp({flight.FS}, 'CR') .* FuelCR ...
    + or(strcmp({flight.FS}, 'AP'), strcmp({flight.FS}, 'LD')) .* FuelAPLD ...
    + or(strcmp({flight.FS}, 'TO'), strcmp({flight.FS}, 'IC')) .* FuelNom;

FuelFlow = FuelFlow / 60;

LongAccel = num2cell(LongAccel);
VertAccel = num2cell(VertAccel);
TurnRate = num2cell(TurnRate);
Thrust = num2cell(Thrust);
FuelFlow = num2cell(FuelFlow);
Lift = num2cell(Lift);
Drag = num2cell(Drag);

[flight.LongAccel] = LongAccel{:};
[flight.VertAccel] = VertAccel{:};
[flight.RateOfTurn] = TurnRate{:};
[flight.Thrust] = Thrust{:};
[flight.FuelFlow] = FuelFlow{:};
[flight.Lift] = Lift{:};
[flight.Drag] = Drag{:};


end