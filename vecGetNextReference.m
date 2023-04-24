function flight = vecGetNextReference(flight, RunTime)

global config unit Perf



% Get next Reference Point
man = [flight.manual];
hdg = [man.hdg];
cta = [man.cta];
alt = [man.alt];
spd = [man.spd];

dyaidx = and([~hdg(1,:)], [cta(1,:)]);
staidx = and([~hdg(1,:)], [~cta(1,:)]);
manidx = [hdg(1,:)];

getidx = zeros(1,length(flight));



temary = cell(1,length(flight));
temary(:) = {2};
lenary = cell2mat(cellfun(@size, {flight.Reference}, temary,'uni',false));

continuearray = zeros(1, length(flight));
arriavedarray = zeros(1, length(flight));

if ~all(dyaidx(:) == 0)
%     idxmat = ([1:length(dyaidx)] .* dyaidx);
%     idxmat(idxmat == 0) = [];
    
    temary = cell2mat(cellfun(@(x,y) x(6,y),{flight.Reference}, {flight.ReferenceTo}, 'uni',false));
    appind = and(dyaidx, RunTime - [flight.delay] >= [temary] + [flight.gentime] - (max(config.update * 2, config.TrajRes)));
    if ~all(appind(:) == 0)
        
        temary = num2cell(~appind .* [flight.ReferenceFrom] + appind .* [flight.ReferenceTo]);
        [flight.ReferenceFrom] = temary{:};
        
        
        finary = and(appind, [flight.ReferenceFrom] >= lenary - 1);
        conary = and(appind, [flight.ReferenceFrom] < lenary - 1);
        
        if ~all(finary(:) == 0)
            timeleft = cell2mat(cellfun(@(x) x(6,end),{flight.Reference}, 'uni',false)) - cell2mat(cellfun(@(x,y) x(6,y),{flight.Reference}, {flight.ReferenceFrom}, 'uni',false));
            speedcor = (([flight.Vtas] ./ cell2mat(cellfun(@(x,y) x(5,y),{flight.Reference}, {flight.ReferenceFrom}, 'uni',false))) - 1) / 2;

            arriavedarray = arriavedarray + finary .* (round(RunTime + timeleft .* (1 + speedcor)) + config.update);
        end
        
        if ~all(conary(:) == 0)
            
            reftime = cellfun(@(x) x(6,:),{flight.Reference}, 'uni',false);
            
            checkary = double(cell2mat(cellfun(@(x,y) ~isempty(find(x >= y, 1)), reftime, num2cell(max(config.update * 3, config.TrajRes) + RunTime - [flight.gentime]), 'uni', false)));
            
            nextind = cell2mat(cellfun(@(x,y) find(x >= y, 1), reftime, num2cell(max(config.update * 3, config.TrajRes) + RunTime - [flight.gentime]), 'uni', false));
            
            checkary(checkary == 1) = nextind;
            checkary(checkary == 0) = lenary(checkary == 0);
            
            continuearray = continuearray + conary .* checkary;
            
            getidx(conary) = 1;
        end
    end

%     % old codes
%     for acind = 1:length(idxmat)
%         ac = idxmat(acind);
%         if RunTime - flight(ac).delay >= flight(ac).Reference(6, flight(ac).ReferenceTo) + flight(ac).gentime - (max(config.update * 2, config.TrajRes))
%             flight(ac).ReferenceFrom = flight(ac).ReferenceTo;
%             [~, wid] = size(flight(ac).Reference);
%             
%             if flight(ac).ReferenceFrom >= wid - 1
%                 %   Trajectory 끝 -> 완전히 도착
%                 timeleft = (flight(ac).Reference(6, end) - flight(ac).Reference(6, flight(ac).ReferenceFrom));
%                 speedcor = ((flight(ac).Vtas / flight(ac).Reference(5, flight(ac).ReferenceFrom)) - 1) / 2;
%                 flight(ac).arrived = round(RunTime + (timeleft * (1 + speedcor))) + config.update;
%             else
%                 %   Trajectory 남아있음
%                 nexttime = 1;
%                 cumtime = 0;
%                 flight.ReferenceTo = flight.ReferenceTo + 1;
%                 
%                 %   참고할 Reference Trajectory 내 항공기 위치를 몇초 앞 데이터로 가져올건지
%                 while nexttime
%                     cumtime = cumtime + flight(ac).Reference(6, flight(ac).ReferenceTo) - flight(ac).Reference(6, flight(ac).ReferenceFrom);
%                     if cumtime >= (max(config.update * 3, config.TrajRes)) + (RunTime - (flight(ac).Reference(6, flight(ac).ReferenceFrom) + flight(ac).gentime))
%                         nexttime = 0;
%                     else
%                         if flight(ac).ReferenceTo == wid
%                             nexttime = 0;
%                         else
%                             flight(ac).ReferenceTo = flight(ac).ReferenceTo + 1;
%                         end
%                     end
%                 end
%                 getidx(ac) = 1;
%             end
%         end
%     end
    
end

if ~all(staidx(:) == 0)
    
    LocDiff = deg2nm(sqrt(([flight.long_sc] - [flight.long]).^2 + ([flight.lat_sc] - [flight.lat]).^2));
    DegDiff = mod(rad2deg(atan2([flight.long_sc] - [flight.long], [flight.lat_sc] - [flight.lat])) - [flight.hdg], 360);
    
    RelLocDiff = config.DistDiffThreshold * (max(2 * config.update, config.TrajRes)) * ([flight.Vtas] / 3600);
    
    appind = and(staidx, LocDiff .* abs(cos(deg2rad(DegDiff))) < RelLocDiff);
    
    if ~all(appind(:) == 0)

        temary = num2cell(~appind .* [flight.ReferenceFrom] + appind .* [flight.ReferenceTo]);
        [flight.ReferenceFrom] = temary{:};
                
        finary = and(appind, [flight.ReferenceFrom] >= lenary - 1);
        conary = and(appind, [flight.ReferenceFrom] < lenary - 1);
        
        if ~all(finary(:) == 0)
            timeleft = cell2mat(cellfun(@(x) x(6,end),{flight.Reference}, 'uni',false)) - cell2mat(cellfun(@(x,y) x(6,y),{flight.Reference}, {flight.ReferenceFrom}, 'uni',false));
            speedcor = (([flight.Vtas] ./ cell2mat(cellfun(@(x,y) x(5,y),{flight.Reference}, {flight.ReferenceFrom}, 'uni',false))) - 1) / 2;
            arriavedarray = arriavedarray + finary .* (round(RunTime + timeleft .* (1 + speedcor)) + config.update);
        end
        
        if ~all(conary(:) == 0)

            joinrefdist = cellfun(@(x, y, z, w) deg2nm(sqrt((x(2,w) - y).^2 + (x(3,w) - z).^2)), {flight.Reference}, {flight.long}, {flight.lat}, num2cell([flight.ReferenceFrom] + 1 - finary), 'uni',false);

            joinrefhdg = cellfun(@(x, y, z, w, v) mod(rad2deg(atan2(x(2,v) - y, x(3,v) - z)) - w, 360), {flight.Reference}, {flight.long}, {flight.lat}, {flight.hdg}, num2cell([flight.ReferenceFrom] + 1 - finary), 'uni',false);
            
            refdist = cellfun(@(x) deg2nm(sqrt((x(2,3:end) - x(2,2:end - 1)).^2 + (x(3,3:end) - x(3,2:end - 1)).^2)), {flight.Reference}, 'uni', false);
            irefhdg = cellfun(@(x) atan2((x(2,2:end) - x(2,1:end - 1)), (x(3,2:end) - x(3,1:end - 1))), {flight.Reference}, 'uni', false);
            refhdg = cellfun(@(x) (x(2:end) - x(1:end - 1)), irefhdg, 'uni', false);
            
%             refdist = cellfun(@(x, y, z) deg2nm(sqrt((x(2,:) - y).^2 + (x(3,:) - z).^2)), {flight.Reference}, {flight.long}, {flight.lat}, 'uni',false);
%             refhdg = cellfun(@(x, y, z, w) mod(rad2deg(atan2(x(2,:) - y, x(3,:) - z)) - w, 360), {flight.Reference}, {flight.long}, {flight.lat}, {flight.hdg}, 'uni',false);

            joincordist = cell2mat(cellfun(@(x, y) x .* abs(cos(deg2rad(y))), joinrefdist, joinrefhdg, 'uni', false));
            refcordist = cellfun(@(x, y) cumsum(x .* abs(cos(y))), refdist, refhdg, 'uni', false);

            distthres = RelLocDiff - joincordist;
            
%             cellfun(@(x,y,w) find(and(x > y, x > w), 1), refcordist, num2cell(distthres), {flight.ReferenceFrom}, 'uni', false)
            
            tcheckary = double(cell2mat(cellfun(@(x,y) ~isempty(find(x > y, 1)), refcordist, num2cell(distthres), 'uni', false)));
            tnextind = cellfun(@(x,y) find(x > y), refcordist, num2cell(distthres), 'uni', false);
            checkary = double(cell2mat(cellfun(@(x,y) ~isempty(find(x > y, 1)), tnextind, {flight.ReferenceFrom}, 'uni', false)));
            nextind = cell2mat(cellfun(@(x,y) find(x > y, 1), tnextind, {flight.ReferenceFrom}, 'ErrorHandler', @length({flight.Reference}), 'uni', false));
            
            checkary = and(tcheckary, checkary);
            assignary = checkary .* nextind + ~checkary .* lenary;
%             checkary(checkary == true) = nextind;
%             checkary(checkary == false) = lenary(checkary == 0);
            
            continuearray = continuearray + conary .* assignary;
            getidx(conary) = 1;
                        
        end
        
    end
    
end
    
if ~all(manidx(:) == 0)
    getidx(logical(manidx)) = 1;
end


getidx(:) = 1;


arriavedarray(arriavedarray == 0) = -1;
contemp = (continuearray == 0);
continuearray = continuearray + contemp .* [flight.ReferenceTo];

arriavedarray = num2cell(arriavedarray);
continuearray = num2cell(continuearray);

[flight.arrived] = arriavedarray{:};
[flight.ReferenceTo] = continuearray{:};    
    
   

autoaltary = ~alt(1,:);
manualalt = and(getidx == 1, autoaltary == 0);
autoalt = and(getidx == 1, autoaltary == 1);
altval = zeros(1, length(flight));

if ~all(manualalt == 0)
    inputalt = manualalt .* round([alt(2,:)] / config.AltRes(1)) * config.AltRes(1);
    manalt = max(min(inputalt, [flight.alt] + (sin(deg2rad(30)) * ([flight.Vtas] / 3600 * unit.nm2ft) * config.update)), ...
        [flight.alt] + (sin(deg2rad(-30)) * ([flight.Vtas] / 3600 * unit.nm2ft) * config.update));
    altval = altval + manualalt .* manalt;
end
if ~all(autoalt == 0)
    refaltary = cell2mat(cellfun(@(x,y) x(4,y), {flight.Reference}, {flight.ReferenceTo}, 'uni',false));
    refaltary = round(refaltary, config.AltRes(2));
    altval = altval + autoalt .* refaltary;
end



autospdary = ~spd(1,:);
manualspd = and(getidx == 1, autospdary == 0);
autospd = and(getidx == 1, autospdary == 1);
spdval = zeros(1, length(flight));

if ~all(manualspd == 0)
    inputspd = manualspd .* round([spd(2,:)] / config.SpdRes(1)) * config.SpdRes(1);
    spdval = spdval + manualspd .* inputspd;
end
if ~all(autospd == 0)
    refspdary = cell2mat(cellfun(@(x,y) x(5,y),{flight.Reference}, {flight.ReferenceTo}, 'uni',false));
    refspdary = round(refspdary, config.SpdRes(2));
    spdval = spdval + autospd .* refspdary;
end


autohdgary = ~hdg(1,:);
manualhdg = and(getidx == 1, autohdgary == 0);
autohdg = and(getidx == 1, autohdgary == 1);
hdgval = zeros(1, length(flight));
latval = zeros(1, length(flight));
longval = zeros(1, length(flight));

if ~all(manualhdg == 0)
    inputhdg = manualhdg .* round([hdg(2,:)] / config.HdgRes(1)) * config.HdgRes(1);
    hdgval = hdgval + manualhdg .* inputhdg;
    longval = longval + manualhdg .* [flight.long];
    latval = latval + manualhdg .* [flight.lat];
end
if ~all(autohdg == 0)
%     sttptary = and(autohdg, ([flight.ReferenceTo] == 1));
    nttptary = and(autohdg, ([flight.ReferenceTo] ~= 1));
%     try
%     strefhdgary = cell2mat(cellfun(@(x,y) mod(rad2deg(atan2(x(2,y + 1) - x(2, y), x(3,y + 1) - x(3, y))), 360) ,{flight.Reference}, {flight.ReferenceTo}, 'uni',false));
%     catch
%         'aa'
%     end
    ntrefhdgary = cell2mat(cellfun(@(x,y) mod(rad2deg(atan2(x(2,max(y, 2)) - x(2,max(y - 1,1)), x(3,max(y, 2)) - x(3, max(y - 1, 1)))), 360) ,{flight.Reference}, {flight.ReferenceTo}, 'uni',false));
%     tmphdgary = sttptary .* strefhdgary + nttptary .* ntrefhdgary;
    tmphdgary = nttptary .* ntrefhdgary;

    tmphdgary(tmphdgary < 0) = tmphdgary(tmphdgary < 0) + 360;
    tmphdgary = round(tmphdgary, config.HdgRes(2));
    
    reflatary = cell2mat(cellfun(@(x,y) x(3,y),{flight.Reference}, {flight.ReferenceTo}, 'uni',false));
    reflongary = cell2mat(cellfun(@(x,y) x(2,y),{flight.Reference}, {flight.ReferenceTo}, 'uni',false));
    
    
    hdgval = hdgval + autohdg .* tmphdgary;
    longval = longval + autohdg .* reflongary;
    latval = latval + autohdg .* reflatary;
end



fsval = zeros(1, length(flight));
fscell = num2cell(fsval);
climbary = and(manualhdg, altval > [flight.alt]);
descentary = and(manualhdg, altval <= [flight.alt]);
fixfary = and(autohdg, ~isempty([flight.FixFlap]));
frefary = and(autohdg, isempty([flight.FixFlap]));

if ~all(climbary == 0)
    fsval = fsval + and(climbary, and([flight.alt] >= 0 , [flight.alt] < 400)) .* 2;
    fsval = fsval + and(climbary, and([flight.alt] >= 400 , [flight.alt] < 2000)) .* 3;
    fsval = fsval + and(climbary, [flight.alt] >= 2000) .* 4;
end

if ~all(descentary == 0)
    VstallAP = cell2mat(cellfun(@(x) Perf.(x).Vstall_AP, {flight.type}, 'uni',false));
    VstallCR = cell2mat(cellfun(@(x) Perf.(x).Vstall_CR, {flight.type}, 'uni',false));
    
    fsval = fsval + and(descentary, and(and([flight.alt] >= 0 , [flight.alt] < 3000), [flight.Vtas] < 1.3 * VstallAP + 10)) .* 6;
    fsval = fsval + and(descentary, and(and([flight.alt] >= 0 , [flight.alt] < 3000), [flight.Vtas] >= 1.3 * VstallAP + 10)) .* 5;
    fsval = fsval + and(descentary, and(and([flight.alt] >= 3000 , [flight.alt] < 8000), [flight.Vtas] < 1.3 * VstallCR + 10)) .* 5;
    fsval = fsval + and(descentary, and(and([flight.alt] >= 3000 , [flight.alt] < 8000), [flight.Vtas] >= 1.3 * VstallCR + 10)) .* 4;
    fsval = fsval + and(descentary, [flight.alt] >= 8000) .* 4;
end

if ~all(frefary == 0)
    reffsary = cell2mat(cellfun(@(x,y) x(7,y),{flight.Reference}, {flight.ReferenceTo}, 'uni',false));
    fsval = fsval + frefary .* reffsary;
end
oriFScell = {flight.FS};
fscell(fsval == 0) = oriFScell(fsval == 0);
fscell(fsval == 1) = {'TX'};
fscell(fsval == 2) = {'TO'};
fscell(fsval == 3) = {'IC'};
fscell(fsval == 4) = {'CR'};
fscell(fsval == 5) = {'AP'};
fscell(fsval == 6) = {'LD'};


if ~all(fixfary == 0)
    fscell(fixfary) = deal(flight.FixFlap);
end

altval = num2cell(altval);
spdval = num2cell(spdval);
hdgval = num2cell(hdgval);
latval = num2cell(latval);
longval = num2cell(longval);


[flight.long_sc] = longval{:};
[flight.lat_sc] = latval{:};    
[flight.alt_sc] = altval{:};
[flight.Vtas_sc] = spdval{:};    
[flight.hdg_sc] = hdgval{:};
[flight.FS] = fscell{:};

end