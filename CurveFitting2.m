function CurveFiting2
clear all
close all



%%% Parameters %%%
% Population
pool = 200;
% Number of Curves in Spline (4 >=)
curvenumber = 6;
% Maximum Generation
maxgen = 200;
% Cross-over & Mutation Param (higher -> frequent mutation)
CR = 0.2;
% Evaluation Param (weight on arc length differnece)
F = 0.2;

curvegraph = struct;

%%% Objective Curve

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
p60 = [32.4 124.5   2500    244];
p61 = [33.2 137.7   2800    270];
p62 = [33.2 122.1   2400    234];
p70 = [32.4 128.5   2500    244];


objpoints(:,:,1) = [p10 ; p11 ; p12 ; p20];
objpoints(:,:,2) = [p20 ; p21 ; p22 ; p30];
objpoints(:,:,3) = [p30 ; p31 ; p32 ; p40];
objpoints(:,:,4) = [p40 ; p41 ; p42 ; p50];
objpoints(:,:,5) = [p50 ; p51 ; p52 ; p60];
objpoints(:,:,6) = [p60 ; p61 ; p62 ; p70];

% objpoints = rand(4,4,6);
objcurve = GenBezierCurve(objpoints);

lon = [objcurve(:,1)];
lat = [objcurve(:,2)];

arclen = deg2nm(sum(sqrt(([lon(2:end)] - [lon(1:end - 1)]).^2 + ([lat(2:end)] - [lat(1:end - 1)]).^2)));


fig1 = figure;
ax = subplot(3,2, [1 2 3 4]);
ax.XLim = [-0.5 1.5];
ax.YLim = [-0.5 1.5];
ax.DataAspectRatio = [1 1 1];
hold on
curve = line(objcurve(:,1),objcurve(:,2));

erax = subplot(3,2,5);
arax = subplot(3,2,6);


ncurve = curvenumber * ones(pool,1);
score = zeros(pool,2);
curveset = cell(pool,1);
pointset = cell(pool,1);

gen = 1;
best = 1;
disptext = '';

% Initialize
for j = 1:pool
    randvec = rand(1, ncurve(j));

    for veclen = 1:length(randvec)
        point{j,veclen} = sum(randvec(1:veclen)) / sum(randvec);
    end
    
    for k = 1:ncurve(j)
        randlam = 0 + (rand(1,2) *  (10 / ncurve(j)));
        lambda1{j,k} = randlam(1);
        lambda2{j,k} = randlam(2);
    end
    
    stats = text(0.1, 0.9, disptext, 'Unit', 'normalized', 'Parent', ax);
    curvegraph.curve(j) = line(objcurve(1,1), objcurve(1,2), 'Color', [1 1 0 0.05], 'Parent', ax);
    
    curvegraph.cpts = line(objcurve(1,1), objcurve(1,2), 'Color', [1 0 0], 'Marker', 'o', 'LineStyle', ':', 'Parent', ax);
    curvegraph.curve(best).Color = [1 0 0];

end

while gen < maxgen
    
    nxcurveset = cell(pool,1);
    nxpoint = cell(pool, max(ncurve));
    nxlambda1 = cell(pool, max(ncurve));
    nxlambda2 = cell(pool, max(ncurve));
    
    nxscore = zeros(pool,2);
    
    
    % mutation & cross-over in each pop
    
    mutind = randi([1,ncurve(j)]);
    mutl1ind = randi([1,ncurve(j)]);
    mutl2ind = randi([1,ncurve(j)]);
    for j = 1:pool
        
        for i = 1:ncurve(j)
            % point mutation
            
            if i == ncurve(j)
                
                nxpoint{j,ncurve(j)} = 1;
            else
                if or(rand(1) <= CR, j == mutind)
                    parind = randperm(pool - 1, 3);
                    parind = parind + (parind >= j);
                    
                    parpt1 = [point{parind(1),:}];
                    parpt2 = [point{parind(2),:}];
                    parpt3 = [point{parind(3),:}];
                    
                    nxpoint{j,i} = parpt1(i) + F * (parpt2(i) - parpt3(i)) + (randn(1) * gen/maxgen);

                    while nxpoint{j,i} >= 1
                        nxpoint{j,i} = point{j,i} + ((nxpoint{j,i} - point{j,i}) / 2);
                    end
                    
                    while nxpoint{j,i} <= 0
                        nxpoint{j,i} = point{j,i} - ((nxpoint{j,i} + point{j,i}) / 2);
                    end
                    
                else
                    nxpoint{j,i} = point{j,i};
                end
                
            end
            
            
            
            
            % lambda mutation
            if or(rand(1) <= CR, j == mutl1ind)
                nxlambda1{j,i} = (5 / ncurve(j)) * rand(1);
            else
                nxlambda1{j,i} = lambda1{j,i};
            end
            if or(rand(1) <= CR, j == mutl2ind)
                nxlambda2{j,i} = (5 / ncurve(j)) * rand(1);
            else
                nxlambda2{j,i} = lambda2{j,i};
            end
                
       
        end
        
        tempar = sort(cell2mat(nxpoint(j,:)));
        for i = 1:ncurve(j)
            nxpoint{j,i} = tempar(i);
        end
        
        % Evaluation
        
        % parse param into curve
        cpt = ceil([point{j,:}] * length(objcurve));
        chapt = ceil([nxpoint{j,:}] * length(objcurve));
        
        cpt(cpt == 1) = 2;
        chapt(chapt == 1) = 2;
                
        cpt = [1 cpt];
        chapt = [1 chapt];
        
        defptset = ParsePointSet(objcurve, cpt, cell2mat(lambda1(j,:)), cell2mat(lambda2(j,:)));
        chaptset = ParsePointSet(objcurve, chapt, cell2mat(nxlambda1(j,:)), cell2mat(nxlambda2(j,:)));
        
        defcurve = GenBezierCurve(defptset);
        chacurve = GenBezierCurve(chaptset);
        
        [deferr, defarc] = Evaluation(defcurve, objcurve);
        [chaerr, chaarc] = Evaluation(chacurve, objcurve);
        
        score(j,1) = deferr;
        score(j,2) = defarc;
        nxscore(j,1) = chaerr;
        nxscore(j,2) = chaarc;
        
        
        curveset{j} = defcurve;
        nxcurveset{j} = chacurve;
        
        if and(chaerr < deferr, chaarc < defarc)
            score(j) = nxscore(j);
            curveset{j} = nxcurveset{j};
            for i = 1:ncurve(j)
                point{j,i} = nxpoint{j,i};
                lambda1{j,i} = nxlambda1{j,i};
                lambda2{j,i} = nxlambda2{j,i};
            end
        end    
    end
    
    %pop growth
    m = 0;
    for l = 1:length(nxscore)
        if or(nxscore(j,1) > score(j,1), nxscore(j,2) > score(j,2))
            m = m + 1;
            score(pool + m,:) = nxscore(l,:);
            curveset{pool + m} = nxcurveset{l};
            for i = 1:ncurve(l)
                point{pool + m,i} = nxpoint{l,i};
                lambda1{pool + m,i} = nxlambda1{l,i};
                lambda2{pool + m,i} = nxlambda2{l,i};
            end
        end
        
    end
    
    
    % pruning
    while m > 0
        
        [val, ind] = max(score(:,1) .* (1 + score(:,2)));

        point(ind,:) = [];
        lambda1(ind,:) = [];
        lambda2(ind,:) = [];
        score(ind,:) = [];
        curveset(ind,:) = [];
        m = m - 1;
    end
    
    
    [val, ind] = min(score(:,1) .* (1 + score(:,2)));
    %     [val, ind] = min(score(:,1));
    best = ind;
    
    for j = 1:pool
        curvegraph.curve(j).XData = curveset{j}(:,1);
        curvegraph.curve(j).YData = curveset{j}(:,2);
        
        if j == best
            curvegraph.curve(j).Color = [1 0 0];
            
            
            cpt = ceil([point{j,:}] * length(objcurve));
            cpt(cpt == 1) = 2;
            cpt = [1 cpt];
            
            cptset = ParsePointSet(objcurve, cpt, cell2mat(lambda1(j,:)), cell2mat(lambda2(j,:)));
            
            
            curvegraph.cpts.XData = reshape([cptset(:,1,:)], 1, ncurve(j) * (length(cptset(:,:,1))));
            curvegraph.cpts.YData = reshape([cptset(:,2,:)], 1, ncurve(j) * (length(cptset(:,:,1))));

            disptext = {['Generation : ' num2str(gen)], ['Curves : ' num2str(ncurve(ind))], ['Error : ' num2str(score(ind,1))] , ['Arc Length Scale : ' num2str(score(ind,2))]};
            if gen == 1
                errgraph = plot([gen],[score(ind,1)], 'k', 'Parent', erax);
                arcgraph = plot([gen],[score(ind,2)], 'g', 'Parent', arax);
                erax.XLim = [0 maxgen];
                arax.XLim = [0 maxgen];
                
            else
                errgraph.XData = [errgraph.XData gen];
                errgraph.YData = [errgraph.YData score(ind,1)];
                arcgraph.XData = [arcgraph.XData gen];
                arcgraph.YData = [arcgraph.YData score(ind,2)];
                erax.XLim = [0 maxgen];
                arax.XLim = [0 maxgen];

            end

        else
            curvegraph.curve(j).Color = [1 1 0 0.05];
        end
    end
    stats.String = disptext;
    drawnow
    
    ['Iteration ' num2str(gen) ' error: ' num2str(score(ind,1)) ' arc: ' num2str(score(ind,2))]
    gen = gen + 1;
end

end


function curvepoints = ParsePointSet(objcurve, points, lambda1, lambda2)

for i = 1:length(points) - 1
    lampar1 = lambda1(i);
    lampar2 = lambda2(i);
    
    P0 = objcurve(points(i),:);
    P0p1 = objcurve(min(points(i) + 1, length(objcurve) - 1),:);
    P3 = objcurve(min(points(i + 1), length(objcurve)),:);
    P3p1 = objcurve(min(points(i + 1), length(objcurve)) - 1,:);
    psihat1 = atan2(P0p1(1) - P0(1), P0p1(2) - P0(2));
    psihat2 = atan2(P3p1(1) - P3(1), P3p1(2) - P3(2)) - (pi);
    
    
    curvepoints(1,:,i) = P0;
    curvepoints(4,:,i) = P3;
    
    curvepoints(2,:,i) = P0 + (lampar1 * [sin(psihat1) cos(psihat1) 0 0]);
    curvepoints(3,:,i) = P3 - (lampar2 * [sin(psihat2) cos(psihat2) 0 0]);
    
end
end

function [err, arc] = Evaluation(curve, objcurve)

objlon = [objcurve(:,1)];
objlat = [objcurve(:,2)];

objarclen = deg2nm(sum(sqrt((([objlon(2:end)] - [objlon(1:end - 1)]).^2) + (([objlat(2:end)] - [objlat(1:end - 1)]).^2))));

lon = [curve(:,1)];
lat = [curve(:,2)];

arclen = deg2nm(sum(sqrt((([lon(2:end)] - [lon(1:end - 1)]).^2) + (([lat(2:end)] - [lat(1:end - 1)]).^2))));

arc = abs((arclen - objarclen) / objarclen);

% err = sum(sqrt((([objlon(1:end)] - [lon(1:end)]).^2) + (([objlat(1:end)] - [lat(1:end)]).^2)));
err = sum((([objlon(1:end)] - [lon(1:end)]).^2) + (([objlat(1:end)] - [lat(1:end)]).^2));

end

function curvepoint = GenBezierCurve(points)

curveno = length(points);
numpt = 2000;
resolution = curveno / numpt;
n = length(points(:,:,1)) - 1;
curvepoint = [];

intleft = rem(numpt, curveno);
leftcor = zeros(1, curveno);
lc = intleft;
for il = 1:intleft
    if lc > 0
        leftcor(il) = 1;
        lc = lc - 1;
    end
end

for seg = 1:curveno
    sigma = zeros(1,n);
    for    i=0:1:n
        sigma(i+1)=factorial(n) / (factorial(i) * factorial(n - i));  % for calculating (x!/(y!(x-y)!)) values
    end
    beziercurve=[];
    segment = [];
    for tau=0 : resolution : 1 - (resolution + rem(1, resolution)) + (resolution * leftcor(seg))
        for d = 1:n + 1
            segment(d) = sigma(d) * ((1 - tau)^(n + 1 - d)) * (tau^(d - 1));
        end
        beziercurve=cat(1,beziercurve,segment);                                      %catenation
    end
    
    curvepoint = cat(1, curvepoint, beziercurve * points(:,:,seg));
end

% normalize
curvepoint = (curvepoint - repmat(min(curvepoint),length(curvepoint),1)) ./ repmat((max(curvepoint) - min(curvepoint)), length(curvepoint), 1);

% objpoint = line(reshape([points(:,1,:)], 1, curves * (n + 1)), reshape([points(:,2,:)], 1, curves * (n + 1)), 'LineStyle', ':', 'Color', 'b', 'Marker', 'o', 'Parent', ax);


end
