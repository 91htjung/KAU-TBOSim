% Generate Aircraft
function [Active, flight, Graphics] = GenerateAircraft(Active, RunTime, flight, Graphics)

global plan config

    

% Vectorized on May 18th.
genidx = and([plan.gentime] <= RunTime, [flight.status] == 1);
arridx = and([flight.status] == 2, [flight.arrived] ~= -1);


if ~all(genidx(:) == 0)
    idxmat = ([1:length(genidx)] .* genidx);
    idxmat(idxmat == 0) = [];
    Active = [Active ; [[plan(idxmat).id]' [flight(idxmat).status]']];
    
    [flight(idxmat).gentime] = deal(RunTime);
    [flight(idxmat).status] = deal(2);
    
    [Graphics.RadarScreen.datablock(idxmat).Visible] = deal('on');
    
    
    [Graphics.RadarScreen.datablock(idxmat).Color] = deal([0.25 0.9 0.55]);
    [Graphics.RadarScreen.radarposition(idxmat).Visible] = deal('on');
    [Graphics.RadarScreen.radarposition(idxmat).MarkerEdgeColor] = deal([0.25 0.9 0.55]);
    
    
    
    [Graphics.RadarScreen.datablock(idxmat).ButtonDownFcn] = deal({@RadarDataBlockCallback, flight, RunTime});
    
    tabidx = [Graphics.RadarScreen.Table.Lookup(idxmat,1)];
%     [Graphics.RadarScreen.Table.Object.Data{tabidx,3}] = deal('<html><body bgcolor="#40E68C">Airborne');
    [Graphics.RadarScreen.Table.Data{tabidx,3}] = deal('<html><table border=0 width=400 bgcolor="#40E68C"><TR><TD>Airborne');


    
    Graphics.RadarScreen.radarposition(Graphics.RadarScreen.Target.OldID).MarkerEdgeColor = [0.9 0.55 0.25];
    Graphics.RadarScreen.datablock(Graphics.RadarScreen.Target.OldID).Color = [0.9 0.55 0.25];
    
end

if ~all(arridx(:) == 0)
    idxmat = ([1:length(arridx)] .* arridx);
    idxmat(idxmat == 0) = [];
    
    [~,delidx] = intersect(Active(:,1),idxmat);
    Active(delidx,:) = [];

    [flight(idxmat).deltime] = deal(RunTime);
    [flight(idxmat).status] = deal(3);
    
       
    [Graphics.RadarScreen.datablock(idxmat).Visible] = deal('off');
    [Graphics.RadarScreen.radarposition(idxmat).Visible] = deal('off');
    [Graphics.RadarScreen.radartrail(idxmat).Visible] = deal('off');
    [Graphics.RadarScreen.hdgline(idxmat).Visible] = deal('off');
    
    [Graphics.RadarScreen.datablock(idxmat).ButtonDownFcn] = deal({@RadarDataBlockCallback, flight, RunTime});
    
    tabidx = [Graphics.RadarScreen.Table.Lookup(idxmat,1)];
%     [Graphics.RadarScreen.Table.Object.Data{tabidx,3}] = deal('<html><table <body bgcolor="#408CE6">Arrived');
    

    [Graphics.RadarScreen.Table.Data{tabidx,3}] = deal('<html><table border=0 width=400 bgcolor="#408CE6"><TR><TD>Arrived');
    

    
    for tidx = 1:length(tabidx)
        Graphics.RadarScreen.Table.Data{tabidx(tidx),6} = flight(idxmat(tidx)).arrived;
        Graphics.RadarScreen.Table.Data{tabidx(tidx),7} = Graphics.RadarScreen.Table.Data{tabidx(tidx),6} - Graphics.RadarScreen.Table.Data{tabidx(tidx),5};
    end
end


if config.RadarColorLabel
    ngenidx = and(genidx, [Graphics.RadarScreen.Table.Lookup(:,3)]');
    narridx = and(arridx, [[Graphics.RadarScreen.Table.Lookup(:,3)] == 0]');
%     ngenidx = and(genidx, [flight.label] == 0);
%     narridx = and(arridx, [flight.label] == 0);
    nmat = [Graphics.RadarScreen.Table.Lookup(:,3)] == 0;
    
    nidxmat = ([1:length(nmat)]' .* nmat);
    ngidxmat = ([1:length(ngenidx)] .* ngenidx);
    naidxmat = ([1:length(narridx)] .* narridx);
    nidxmat(nidxmat == 0) = [];
    ngidxmat(ngidxmat == 0) = [];
    naidxmat(naidxmat == 0) = [];
    
    
    [Graphics.RadarScreen.datablock(nidxmat).Color] = deal([0.6 0.6 0.6]);
    [Graphics.RadarScreen.radarposition(nidxmat).MarkerEdgeColor] = deal([0.6 0.6 0.6]);
    
    ngtabidx = [Graphics.RadarScreen.Table.Lookup(ngidxmat,1)];
%     [Graphics.RadarScreen.Table.Object.Data{ngtabidx,3}] = deal('<html><body bgcolor="#999999">Airborne');

%     [Graphics.RadarScreen.Table.Data{ngtabidx,3}] = deal('<html><font color="#999999">Airborne');
    

    
    natabidx = [Graphics.RadarScreen.Table.Lookup(naidxmat,1)];
%     [Graphics.RadarScreen.Table.Object.Data{natabidx,3}] = deal('<html><body bgcolor="#999999">Arrived');

%     [Graphics.RadarScreen.Table.Data{natabidx,3}] = deal('<html><font color="#999999">Arrived');
    
    for ntidx = 1:length(natabidx)
%         Graphics.RadarScreen.Table.Object.Data{natabidx(ntidx),6} = flight(nidxmat(ntidx)).arrived;
          Graphics.RadarScreen.Table.Data{natabidx(ntidx),6} = flight(naidxmat(ntidx)).arrived;

        
%         Graphics.RadarScreen.Table.Object.Data{natabidx(ntidx),7} = Graphics.RadarScreen.Table.Object.Data{natabidx(ntidx),6} - Graphics.RadarScreen.Table.Object.Data{natabidx(ntidx),5};
          Graphics.RadarScreen.Table.Data{natabidx(ntidx),7} = Graphics.RadarScreen.Table.Data{natabidx(ntidx),6} - Graphics.RadarScreen.Table.Data{natabidx(ntidx),5};

    end

    
    if Graphics.RadarScreen.Table.Lookup(Graphics.RadarScreen.Target.OldID,3) == 1
        Graphics.RadarScreen.radarposition(Graphics.RadarScreen.Target.OldID).MarkerEdgeColor = [0.9 0.55 0.25];
        Graphics.RadarScreen.datablock(Graphics.RadarScreen.Target.OldID).Color = [0.9 0.55 0.25];
    else
        Graphics.RadarScreen.radarposition(Graphics.RadarScreen.Target.OldID).MarkerEdgeColor = [0.6 0.6 0.6];
        Graphics.RadarScreen.datablock(Graphics.RadarScreen.Target.OldID).Color = [0.6 0.6 0.6];
    end
end

set(Graphics.RadarScreen.Table.Object, 'CellSelectionCallback', {@RadarDataBlockCallback, flight, RunTime});
set(Graphics.RadarScreen.Target.Object, 'Callback', {@RadarDataBlockCallback, flight, RunTime});
set(Graphics.RadarScreen.Plan.Strip, 'CellSelectionCallback', {@RadarDataBlockCallback, flight, RunTime});

% set(Graphics.RadarScreen.Table.RefreshButton, 'Callback', {@TableFilterRefreshCallback, flight, RunTime});

end



%     
%     if and(flight(i).status == 2, flight(i).arrived ~= -1)
%         flight(i).status = 3;
%         index = (Active(:,1) == plan(i).id);
% 
%         Active(index,:) = [];
% 
%         flight(i).deltime = RunTime;
% %         Graphics.RadarScreen.radarposition(plan(i).id).MarkerEdgeColor = [0.3 0.3 0.3];
% %         Graphics.RadarScreen.radarposition(plan(i).id).MarkerFaceColor = 'none';
% %         Graphics.RadarScreen.radartrail(plan(i).id).LineStyle = 'none';
% %         Graphics.RadarScreen.datablock(plan(i).id).String = [''];
%         
%         Graphics.RadarScreen.radarposition(flight(i).id).Visible = 'off';
%         Graphics.RadarScreen.radartrail(flight(i).id).Visible = 'off';
%         Graphics.RadarScreen.datablock(flight(i).id).Visible = 'off';
%         
%         set(Graphics.RadarScreen.datablock(plan(i).id), 'ButtonDownFcn', {@RadarDataBlockCallback, flight, RunTime});
%         
% %         Loc = cellfun(@(x) any(x==plan(i).id),GraphicsRadarScreen.Table.Object.Data(:,1));
%         Loc = Graphics.RadarScreen.Table.Lookup(plan(i).id);
%         Graphics.RadarScreen.Table.Object.Data{Loc,3} = '<html><body bgcolor="#408CE6">Arrived';
%         Graphics.RadarScreen.Table.Object.Data{Loc,6} = flight(plan(i).id).arrived;
%         Graphics.RadarScreen.Table.Object.Data{Loc,7} = Graphics.RadarScreen.Table.Object.Data{Loc,6} - Graphics.RadarScreen.Table.Object.Data{Loc,5};
%     end
%     


% 
% 
% for i = 1:length(plan)
%     
% %     if and(plan(i).gentime <= RunTime, flight(i).status == 1)
% %         % status 1:queued, 2:airbourne, 3:terminated, 4:deleted, 5:paused
% %         flight(i).status = 2;
% %         flight(i).gentime = RunTime;
% % %         Active = sort([Active ; plan(i).id]);
% %         Active = [Active ; [plan(i).id flight(i).status]];
% %         Graphics.RadarScreen.datablock(flight(i).id).Visible = 'on';
% %         Graphics.RadarScreen.radarposition(flight(i).id).Visible = 'on';
% %         if plan(i).id == Graphics.RadarScreen.Target.OldID
% %             Graphics.RadarScreen.radarposition(plan(i).id).MarkerEdgeColor = [0.9 0.55 0.25];
% %             Graphics.RadarScreen.datablock(plan(i).id).Color = [0.9 0.55 0.25];
% %         else
% %             Graphics.RadarScreen.radarposition(plan(i).id).MarkerEdgeColor = [0.25 0.9 0.55];
% %             Graphics.RadarScreen.datablock(plan(i).id).Color = [0.25 0.9 0.55];
% %         end
% % %         Graphics.RadarScreen.datablock(plan(i).id).String = ['\bf' sprintf('\t \t \t \t') '\bf' flight(i).callsign sprintf('\n\t \t \t \t') '\bf' num2str(round(flight(i).alt), '%i') ' ft'  sprintf('\t \t \t') '\bf' num2str(round(flight(i).Vtas), '%i') ' kt'];
% % %         Graphics.RadarScreen.datablock(plan(i).id).UserData = plan(i).id;
% % 
% %         set(Graphics.RadarScreen.datablock(plan(i).id), 'ButtonDownFcn', {@RadarDataBlockCallback, flight, RunTime});
% % %         set(Graphics.RadarScreen.Table.Object, 'CellSelectionCallback', {@RadarDataBlockCallback, flight, RunTime});
% % %         set(Graphics.RadarScreen.Plan.Strip, 'CellSelectionCallback', {@RadarDataBlockCallback, flight, RunTime});
% % %         set(Graphics.RadarScreen.Target.Object, 'Callback', {@RadarDataBlockCallback, flight, RunTime});
% %         
% % %         Loc = cellfun(@(x) any(x==plan(i).id),GraphicsRadarScreen.Table.Object.Data(:,1));
% % 
% %         Loc = Graphics.RadarScreen.Table.Lookup(plan(i).id);
% %         Graphics.RadarScreen.Table.Object.Data{Loc,3} = '<html><body bgcolor="#40E68C">Airborne';
% %         
% %         
% %         %             Graphics.RadarScreen.radarposition(plan(i).id).MarkerFaceColor = [0.25 0.9 0.55];
% %         %             if(isempty(log))
% % %         flightlog(i).id = plan(i).id;
% % %         flightlog(i).callsign = plan(i).callsign;
% % %         flightlog(i).history = [];
% %         %             else
% %         %                 log(end + 1).id = plan(i).id;
% %         %                 log(end).callsign = plan(i).callsign;
% %         %                 log(end).history = [];
% %         %             end
% %     end
%     
%     
%     
%     
%     
%     if and(flight(i).status == 2, flight(i).arrived ~= -1)
%         flight(i).status = 3;
%         index = (Active(:,1) == plan(i).id);
% 
%         Active(index,:) = [];
% 
%         flight(i).deltime = RunTime;
% %         Graphics.RadarScreen.radarposition(plan(i).id).MarkerEdgeColor = [0.3 0.3 0.3];
% %         Graphics.RadarScreen.radarposition(plan(i).id).MarkerFaceColor = 'none';
% %         Graphics.RadarScreen.radartrail(plan(i).id).LineStyle = 'none';
% %         Graphics.RadarScreen.datablock(plan(i).id).String = [''];
%         
%         Graphics.RadarScreen.radarposition(flight(i).id).Visible = 'off';
%         Graphics.RadarScreen.radartrail(flight(i).id).Visible = 'off';
%         Graphics.RadarScreen.datablock(flight(i).id).Visible = 'off';
%         
%         set(Graphics.RadarScreen.datablock(plan(i).id), 'ButtonDownFcn', {@RadarDataBlockCallback, flight, RunTime});
%         
% %         Loc = cellfun(@(x) any(x==plan(i).id),GraphicsRadarScreen.Table.Object.Data(:,1));
%         Loc = Graphics.RadarScreen.Table.Lookup(plan(i).id);
%         Graphics.RadarScreen.Table.Object.Data{Loc,3} = '<html><body bgcolor="#408CE6">Arrived';
%         Graphics.RadarScreen.Table.Object.Data{Loc,6} = flight(plan(i).id).arrived;
%         Graphics.RadarScreen.Table.Object.Data{Loc,7} = Graphics.RadarScreen.Table.Object.Data{Loc,6} - Graphics.RadarScreen.Table.Object.Data{Loc,5};
%     end
%     
% end
% 
