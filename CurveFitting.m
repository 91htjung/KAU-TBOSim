% function flight = CurveFitting(flight)
% clear all
%
% datapoint = flight.RadarTrack(2:5,:); % longitude latitude altitude and speed
%
% p = sets of control points
%
%
%
% n + 1 -> (n+1) degree of the curve
clear all
close all
fig1 = figure;
fig2 = figure;
fig3 = figure;
p10 = [30.0 120.0   5000    200];
p11 = [31.0 121.0   4600    190];
p12 = [32.5 120.9   4200    195];
p20 = [32.0 124.1   2700    197];
p21 = [31.5 127.3   1200    199];
p22 = [30.8 133.2   3800    214];
p30 = [30.4 132.0   3600    218];
p31 = [30.2 130.9   3500    120];
p32 = [30.3 127.1   3800    210];
p40 = [28.4 122.1   2500    227];
p41 = [24.6 117.1   1200    244];
p42 = [25.2 115.1   2400    210];
p50 = [28.4 113.1   2500    220];
p51 = [31.6 111.1   2600    230];
p52 = [32.0 120.1   2400    234];
p60 = [32.4 124.6   2500    247];

psi1 = atan2(p20(1) - p12(1), p20(2) - p12(2));
psi2 = atan2(p30(1) - p22(1), p30(2) - p22(2));
psi3 = atan2(p40(1) - p32(1), p40(2) - p32(2));
psi4 = atan2(p50(1) - p42(1), p50(2) - p42(2));
psi5 = atan2(p60(1) - p52(1), p60(2) - p52(2));

dist1 = deg2nm(sqrt((p20(1) - p12(1))^2 + (p20(2) - p12(2))^2));
dist2 = deg2nm(sqrt((p30(1) - p22(1))^2 + (p30(2) - p22(2))^2));
dist3 = deg2nm(sqrt((p40(1) - p32(1))^2 + (p40(2) - p32(2))^2));
dist4 = deg2nm(sqrt((p50(1) - p42(1))^2 + (p50(2) - p42(2))^2));
dist5 = deg2nm(sqrt((p60(1) - p52(1))^2 + (p60(2) - p52(2))^2));

gamma1 = atan((p20(3) - p12(3))/6076.12 * dist1);
gamma2 = atan((p30(3) - p22(3))/6076.12 * dist2);
gamma3 = atan((p40(3) - p32(3))/6076.12 * dist3);
gamma4 = atan((p50(3) - p42(3))/6076.12 * dist4);
gamma5 = atan((p60(3) - p52(3))/6076.12 * dist5);

points(:,:,1) = [p10 ; p11 ; p12 ; p20];
points(:,:,2) = [p20 ; p21 ; p22 ; p30];
points(:,:,3) = [p30 ; p31 ; p32 ; p40];
points(:,:,4) = [p40 ; p41 ; p42 ; p50];
points(:,:,5) = [p50 ; p51 ; p52 ; p60];

ax = axes('Parent', fig1);
nax = axes('Parent', fig2);
pax = axes('Parent', fig3);
hold on

ax.XLim = [-0.5 ; 1.5];
ax.YLim = [-0.5 ; 1.5];
curves = 5;
resolution = curves / 2000;
n = length(points(:,:,1)) - 1;
curvepoint = [];

for seg = 1:curves
    sigma = zeros(1,n);
    for    i=0:1:n
        sigma(i+1)=factorial(n) / (factorial(i) * factorial(n - i));  % for calculating (x!/(y!(x-y)!)) values
    end
    beziercurve=[];
    segment = [];
    for tau=0:resolution:(1 - resolution)
        for d = 1:n + 1
            segment(d) = sigma(d) * ((1 - tau)^(n + 1 - d)) * (tau^(d - 1));
        end
        beziercurve=cat(1,beziercurve,segment);                                      %catenation
    end
    
    curvepoint = cat(1, curvepoint, beziercurve * points(:,:,seg));
end


% normalize
curvepoint = (curvepoint - min(curvepoint)) ./ (max(curvepoint) - min(curvepoint));
% points(:,1,:) = (points(:,1,:) - min(points(:,1,:))) ./ (max(points(:,1,:)) - min(points(:,1,:)));
% points(:,2,:) = (points(:,2,:) - min(points(:,2,:))) ./ (max(points(:,2,:)) - min(points(:,2,:)));

objcurve = line(curvepoint(:,1),curvepoint(:,2), 'Parent', ax);
% objpoint = line(reshape([points(:,1,:)], 1, curves * (n + 1)), reshape([points(:,2,:)], 1, curves * (n + 1)), 'LineStyle', ':', 'Color', 'b', 'Marker', 'o', 'Parent', ax);

lon = [curvepoint(:,1)];
lat = [curvepoint(:,2)];

arclen = deg2nm(sum(sqrt(([lon(2:end)] - [lon(1:end - 1)]).^2 + ([lat(2:end)] - [lat(1:end - 1)]).^2)));


% data point generalization
% for i = 1:length(datapoint)
%     gendatapt(i) = datapoint(1)
% end

% objfunction = sum(datapoint - curvepoint);

pool = 100;
% ncurve = 2 + round(rand(pool,1) * 5);
ncurve = ones(pool,1) * 5;
score = zeros(pool,1);
curvegraph = struct;
curvepool = cell(pool,1);
pointpool = cell(pool,1);
maxgen = 100;
CR = 0.1;
F = 0.2;
beta = 0.2; % can be changed

gen = 1;
bestind = 1;

% Initialize
for j = 1:pool
    randvec = rand(1, ncurve(j));
    %     stenpoint{j,1} = 0;
    for veclen = 1:length(randvec)
        stenpoint{j,veclen} = sum(randvec(1:veclen)) / sum(randvec);
    end
    for k = 1:ncurve(j)
        randlam = 0 + (rand(1,2) * 1);
        lambda{j,k} = randlam;
    end
    
    curvegraph.curve(j) = line(curvepoint(1,1), curvepoint(1,2), 'Color', [1 0 1 0.1], 'Parent', ax);
    curvegraph.curve(bestind).Color = [1 0 0];
%     curvegraph.point(j) = line(curvepoint(1,1), curvepoint(1,2), 'LineStyle', ':', 'Color', [0 1 1 0.5], 'Marker', 'o', 'Parent', ax);

    
end

while gen < maxgen
%     pause(0.1)
    nextstenpt = cell(pool, max(ncurve));
    nextlambda = cell(pool, max(ncurve));
    
    error_curve = zeros(pool,1);
    arcdiff = zeros(pool,1);
    
    
    ['Iteration ' num2str(gen)]
    for target = 1:length(stenpoint)
        
        parind = randperm(pool - 1, 3);
        parind = parind + (parind >= target);
        stenptparent = cell(1,3);
        lambdaparent = cell(1,3);
        
        lambdachild = lambda(target,:);
        stenptchild = stenpoint(target,:);
        
        % select parents
        for rf = 1:length(parind)
            
            if ncurve(parind(rf)) == ncurve(target)
                stenptparent{rf} = [stenpoint{parind(rf),:}];
                lambdaparent{rf} = reshape([lambda{parind(rf),:}], [2,ncurve(parind(rf))]);
            elseif ncurve(parind(rf)) > ncurve(target)
                n = ncurve(target);
                a = zeros(1, ncurve(parind(rf)));
                a(randperm(numel(a), n)) = 1;
                
                mutateindex = a;
                temstenpt = [stenpoint{parind(rf),:}];
                temlambda = reshape([lambda{parind(rf),:}], [2,ncurve(parind(rf))]);
                
                stenptparent{rf} = temstenpt(logical(mutateindex));
                lambdaparent{rf} = temlambda(:,logical(mutateindex));
            else
                n = ncurve(parind(rf));
                a = zeros(1, ncurve(target));
                a(randperm(numel(a), n)) = 1;
                
                mutateindex = a;
                temstenpt = [stenpoint{parind(rf),:}];
                temlambda = reshape([lambda{parind(rf),:}], [2,ncurve(parind(rf))]);
                
                datindex = 1;
                indstenpt = zeros(1, length(mutateindex));
                indlambda = zeros(2, length(mutateindex));
                for m = 1:length(mutateindex)
                    if mutateindex(m) == 1
                        indstenpt(m) = temstenpt(datindex);
                        indlambda(:,m) = [temlambda(:,datindex)];
                        datindex = datindex + 1;
                    end
                end
                
                stenptparent{rf} = indstenpt;
                lambdaparent{rf} = indlambda;
                
            end
            
        end
        
        % make child
        stenpttrial = [stenptparent{1}] + F * ([stenptparent{2}] - [stenptparent{3}]);
        lambdatrial = [lambdaparent{1}] + F * ([lambdaparent{2}] - [lambdaparent{3}]);
        mutationindex = randi([1,length(stenpttrial)],1,1);
        
        
        % cross over
        for j = 1:length(stenpttrial)
            if or(rand(1) <= CR, j == mutationindex)
                
                if stenpttrial(j) < 0
                    while stenpttrial(j) < 0
                        stenpttrial(j) = (stenpttrial(j) + stenptchild{j}) / 2;
                    end
                elseif stenpttrial(j) > 1
                    while stenpttrial(j) > 1
                        stenpttrial(j) = (stenpttrial(j) - stenptchild{j}) / 2;
                    end
                end
                stenptchild{j} = stenpttrial(j);
                lambdachild{j} = lambdatrial(:,j)';
            end
            
            % sort cell array
            %             num2cell(sort(cell2mat(stenptchild)));
            
            
            nextstenpt(target,:) = num2cell(sort(cell2mat(stenptchild)));
            nextlambda(target,:) = lambdachild;
        end
        
        % Draw a curve
        
        defcurvept = ceil([stenpoint{target,:}] * length(curvepoint));
        chacurvept = ceil([nextstenpt{target,:}] * length(curvepoint));
        
        defcurvept(defcurvept == 1) = 2;
        chacurvept(chacurvept == 1) = 2;
        
        defcurvept(defcurvept == length(curvepoint)) = length(curvepoint) - 1;
        chacurvept(chacurvept == length(curvepoint)) = length(curvepoint) - 1;
        
        defcurvept = [1 defcurvept];
        chacurvept = [1 chacurvept];
        
        % Curve #1
        points1 = zeros(4,4,ncurve(target));
        bearing1 = zeros(2,ncurve(target));
        resolution = ncurve(target) / 2000;
        
        for k = 1:ncurve(target)
            lampar = lambda{target};
            
            P0 = curvepoint(defcurvept(k),:);
            P0p1 = curvepoint(defcurvept(k) + 1,:);
            P3 = curvepoint(defcurvept(k + 1),:);
            P3p1 = curvepoint(defcurvept(k + 1) - 1,:);
            psihat1 = atan2(P0p1(1) - P0(1), P0p1(2) - P0(2));
            psihat2 = atan2(P3p1(1) - P3(1), P3p1(2) - P3(2)) - (pi);
            
            
            points1(1,:,k) = P0;
            points1(4,:,k) = P3;
            
            points1(2,:,k) = P0 + (lampar(1) * [sin(psihat1) cos(psihat1) 0 0]);
            points1(3,:,k) = P3 - (lampar(2) * [sin(psihat2) cos(psihat2) 0 0]);
            
        end
        
        
        
        n = length(points1(:,:,1)) - 1;
        curve1 = [];
        curvepoint1 = [];
        
        for seg = 1:ncurve(target)
            sigma = zeros(1,n);
            for    i=0:1:n
                sigma(i+1)=factorial(n) / (factorial(i) * factorial(n - i));  % for calculating (x!/(y!(x-y)!)) values
            end
            beziercurve1=[];
            segment = [];
            for tau=0:resolution:(1 - resolution)
                for d = 1:n + 1
                    segment(d) = sigma(d) * ((1 - tau)^(n + 1 - d)) * (tau^(d - 1));
                end
                beziercurve1=cat(1,beziercurve1,segment);                                      %catenation
            end
            
            curvepoint1 = cat(1, curvepoint1, beziercurve1 * points1(:,:,seg));
        end
        
        
%         curvegraph(gen).curve1(target) = line(curvepoint1(:,1),curvepoint1(:,2), 'LineStyle', '-', 'Color', 'red', 'Parent', ax);
%         curvegraph(gen).point1(target) = line(reshape([points1(:,1,:)], 1, ncurve(target) * (n + 1)), reshape([points1(:,2,:)], 1, ncurve(target) * (n + 1)), 'LineStyle', ':', 'Color', 'r', 'Marker', 'o', 'Parent', ax);
        
        
        lon1 = [curvepoint1(:,1)];
        lat1 = [curvepoint1(:,2)];
        
        arclen1 = deg2nm(sum(sqrt(([lon1(2:end)] - [lon1(1:end - 1)]).^2 + ([lat1(2:end)] - [lat1(1:end - 1)]).^2)));
        
        
        % Curve #2
        points2 = zeros(4,4,ncurve(target));
        bearing2 = zeros(2,ncurve(target));
        
        for k = 1:ncurve(target)
            lampar = lambdachild{1};
            
            P0 = curvepoint(chacurvept(k),:);
            
            P0p1 = curvepoint(chacurvept(k) + 1,:);
            P3 = curvepoint(chacurvept(k + 1),:);
            P3p1 = curvepoint(chacurvept(k + 1) - 1,:);
            
            psihat1 = atan2(P0p1(1) - P0(1), P0p1(2) - P0(2));
            psihat2 = atan2(P3p1(1) - P3(1), P3p1(2) - P3(2)) - (pi);
            
            
            points2(1,:,k) = P0;
            points2(4,:,k) = P3;
            
            points2(2,:,k) = P0 + (lampar(1) * [sin(psihat1) cos(psihat1) 0 0]);
            points2(3,:,k) = P3 - (lampar(2) * [sin(psihat2) cos(psihat2) 0 0]);
            
        end
        
        
        
        n = length(points2(:,:,1)) - 1;
        curve2 = [];
        curvepoint2 = [];
        resolution = ncurve(target) / 2000;
        
        for seg = 1:ncurve(target)
            sigma = zeros(1,n);
            for    i=0:1:n
                sigma(i+1)=factorial(n) / (factorial(i) * factorial(n - i));  % for calculating (x!/(y!(x-y)!)) values
            end
            beziercurve2=[];
            segment = [];
            for tau=0:resolution:(1 - resolution)
                for d = 1:n + 1
                    segment(d) = sigma(d) * ((1 - tau)^(n + 1 - d)) * (tau^(d - 1));
                end
                beziercurve2=cat(1,beziercurve2,segment);                                      %catenation
            end
            
            curvepoint2 = cat(1, curvepoint2, beziercurve2 * points2(:,:,seg));
        end
        
        
%         curvegraph(gen).curve2(target) = line(curvepoint2(:,1),curvepoint2(:,2), 'LineStyle', '-', 'Color', 'magenta', 'Parent', ax);
%         curvegraph(gen).point2(target) = line(reshape([points2(:,1,:)], 1, ncurve(target) * (n + 1)), reshape([points2(:,2,:)], 1, ncurve(target) * (n + 1)), 'LineStyle', ':', 'Color', 'magenta', 'Marker', 'o', 'Parent', ax);

        
        lon2 = [curvepoint2(:,1)];
        lat2 = [curvepoint2(:,2)];
        
        arclen2 = deg2nm(sum(sqrt(([lon2(2:end)] - [lon2(1:end - 1)]).^2 + ([lat2(2:end)] - [lat2(1:end - 1)]).^2)));
        
        
        % Error -> mean square error
        error_curve1 = sum(([lat] - [lat1]).^2 + ([lon] - [lon1]).^2);
        error_curve2 = sum(([lat] - [lat2]).^2 + ([lon] - [lon2]).^2);
        
        arcdiff1 = abs((arclen - arclen1) / arclen);
        arcdiff2 = abs((arclen - arclen2) / arclen);
        
        
        % Selection
        if and(error_curve2 < error_curve1, arcdiff2 < arcdiff1)
            for l = 1:length(lambdachild)
                lambda{target,l} = lambdachild{l};
                stenpoint{target,l} = stenptchild{l};
            end
            error_curve(target) = error_curve2;
            arcdiff(target) =arcdiff2;
            curvepool{target} = curvepoint2;
            pointpool{target} = points2;
        else
            error_curve(target) = error_curve1;
            arcdiff(target) = arcdiff1;
            curvepool{target} = curvepoint1;
            pointpool{target} = points1;
            
        end
        
        
        
        
%         drawnow
    end

    
    % Draw Curve
    for target = 1:pool
        cp = curvepool{target};
        ps = pointpool{target};
        curvegraph.curve(target).XData = [cp(:,1)];
        curvegraph.curve(target).YData = [cp(:,2)];
        if target ~= bestind
            curvegraph.curve(target).Color = [1 0 1 0.1];
        end
%         curvegraph.point(target).XData = reshape([ps(:,1,:)], 1, ncurve(target) * (n + 1));
%         curvegraph.point(target).YData = reshape([ps(:,2,:)], 1, ncurve(target) * (n + 1));

        drawnow;
    end
    
    overlambda = lambda;
    overstenpt = stenpoint;
    overerror_curve = error_curve;
    overarcdiff = arcdiff;
    m = 0;
    
    % Population Growth
    [err_min, err_minind] = min(error_curve);
    [FP,PI] = sort(arcdiff,'ascend');
    
    for target = 1:pool
        m = m + 1;
        for l = 1:length([stenpoint{target,:}])
            overlambda{pool + m,l} = lambda{target,l};
            overstenpt{pool + m,l} = stenpoint{target,l};
        end
        overerror_curve(pool + m) = error_curve(target);
        overarcdiff(pool + m) = arcdiff(target);
        
        
    end
    
%     BV = arcdiff(error_curve(PI(:)) <= err_min * (1 + beta));
%     BI = PI(error_curve(PI(:)) <= err_min * (1 + beta));
    
    bestind = err_minind(1);
    
%     bestind = err_minind(1);
    curvegraph.curve(bestind).Color = [1 0 0];
    
    % Pruning
    
    killind = (overarcdiff > beta);
    m = m - length(killind(killind == 1));
    overlambda(killind) = [];
    overstenpt(killind) = [];
    overerror_curve(killind) = [];
    overarcdiff(killind) = [];
    while m > 0
        
        [M, NI] = max(overerror_curve);
        overlambda(NI) = [];
        overstenpt(NI) = [];
        overerror_curve(NI) = [];
        overarcdiff(NI) = [];
        m = m - 1;
    end
    
    if gen == 1
        curvegraph.error = line(gen, err_min, 'Color', [0 1 1], 'Parent', nax);
        curvegraph.arclen = line(gen, arcdiff(bestind), 'Color', [1 0 1], 'Parent', pax);
    else
        curvegraph.error.XData = [curvegraph.error.XData   gen];
        curvegraph.error.YData = [curvegraph.error.YData   err_min];
        curvegraph.arclen.XData = [curvegraph.arclen.XData   gen];
        curvegraph.arclen.YData = [curvegraph.arclen.YData   arcdiff(bestind)];
    end
    
    gen = gen + 1;
end

% Choose Best Result
[err_min, err_minind] = min(error_curve);
[FP,PI] = sort(arcdiff,'ascend');

for target = 1:pool
    if error_curve(PI(target)) <= err_min * (1 + beta)
        m = m + 1;
        for l = 1:length([stenpoint{target,:}])
            overlambda{pool + m,l} = lambda{target,l};
            overstenpt{pool + m,l} = stenpoint{target,l};
        end
        overerror_curve(pool + m) = error_curve(target);
        overarcdiff(pool + m) = arcdiff(target);
    end
    
end

BV = arcdiff(error_curve(PI(:)) <= err_min * (1 + beta));
BI = PI(error_curve(PI(:)) <= err_min * (1 + beta));

[~,ind] = min(BV);
bestind = BI(ind);

%     bestind = err_minind(1);
curvegraph.curve(bestind).Color = [1 0 0];

% end