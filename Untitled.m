
    figure
    
    hold on
    grid on
    set(gca, 'color', [0.95 0.95 0.95])
    caxis([0 600])
    zlim([0 100000])
    daspect([1 1 40000])
    set(gca, 'ZLimMode', 'manual')
    % set(gca,'zlim',[0 100000]);
    
    xlim([125.5 127.5]);
    ylim([32.5 34.5]);

    
    % axis vis3d
    
    for Region = 1:length(config.Map)
        try
        for Segment = 1:length(Map.(config.Map{Region}).Segment)
            fill(Map.(config.Map{Region}).Segment(Segment).long(:), Map.(config.Map{Region}).Segment(Segment).lat(:), [0.15, 0.55, 0.25], 'LineStyle', 'none')
        end
        end
    end
    
    LongHist = 0;
    LatHist = 0;
    for ARMark = 1:length(Airspace.route)
%         plot3([Airspace.route(ARMark).trajectory.WP_long], [Airspace.route(ARMark).trajectory.WP_lat], [Airspace.route(ARMark).trajectory.highalt], 'Color', [0.3 0.3 0.6]);
        plot3([Airspace.route(ARMark).trajectory.WP_long], [Airspace.route(ARMark).trajectory.WP_lat], [Airspace.route(ARMark).trajectory.lowalt], 'Color', [0.204 0.533 0.6], 'LineWidth', 1.5);
        for TrajLen = 1:length(Airspace.route(ARMark).trajectory)
            TextLoc = 1;
            Loc = 1;
            if length(Airspace.route(ARMark).trajectory) < TextLoc + 3
                break
            else
                TextLoc = TextLoc + 2;
                Loc = [Loc TextLoc];
            end
        end
        for LocLen = 1:length(Loc)
            cor = 0;
            TextLong = Airspace.route(ARMark).trajectory(Loc(LocLen)).WP_long * (0.5 + cor) + Airspace.route(ARMark).trajectory(Loc(LocLen) + 1).WP_long * (0.5 - cor);
            TextLat = Airspace.route(ARMark).trajectory(Loc(LocLen)).WP_lat * (0.5 + cor) + Airspace.route(ARMark).trajectory(Loc(LocLen) + 1).WP_lat * (0.5 - cor);
            
            
            LongMatch = (LongHist == TextLong);
            LatMatch = (LatHist .* LongMatch == TextLat);
            
            if any(LatMatch)
                if cor >= 0.8
                    cor = cor - 0.8;
                else
                    cor = cor + 0.2;
                end
            else
                LongHist = [LongHist TextLong];
                LatHist = [LatHist TextLat];
            end
            
%             text(Airspace.route(ARMark).trajectory(Loc(LocLen)).WP_long * (0.5 + cor) + Airspace.route(ARMark).trajectory(Loc(LocLen) + 1).WP_long * (0.5 - cor), Airspace.route(ARMark).trajectory(Loc(LocLen)).WP_lat * (0.5 + cor) + Airspace.route(ARMark).trajectory(Loc(LocLen) + 1).WP_lat * (0.5 - cor), sprintf(['\n ' Airspace.route(ARMark).name]), 'Color', [0.3 0.3 0.6], 'FontSize', 6, 'HorizontalAlignment', 'center');
            
        end
    end
    
    
    
    for WPMark = 1:length(Airspace.Waypoint)
        switch Airspace.Waypoint(WPMark).Type
            case 'Waypoint'
                if Airspace.Waypoint(WPMark).display
                    plot3(Airspace.Waypoint(WPMark).Long(:), Airspace.Waypoint(WPMark).Lat(:), 1000, 'LineStyle', 'none', 'Marker', '^', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', 5)
                    text(Airspace.Waypoint(WPMark).Long(:), Airspace.Waypoint(WPMark).Lat(:),sprintf(['\n ' Airspace.Waypoint(WPMark).Name]), 'FontSize', 8, 'HorizontalAlignment', 'center');
                end
        end
    end
    
    for RWYMark = 1:length(Aerodrome(2).RWY)
        
        
        scatter(Aerodrome(2).Long, Aerodrome(2).Lat, 400, 'MarkerEdgeColor', [0.6 0.6 0.6])
        plot3([Aerodrome(2).RWY(RWYMark).THRlong Aerodrome(2).RWY(RWYMark).ENDlong], [Aerodrome(2).RWY(RWYMark).THRlat Aerodrome(2).RWY(RWYMark).ENDlat], [Aerodrome(2).RWY(RWYMark).elevation Aerodrome(2).RWY(RWYMark).elevation], 'Color', [0.3, 0.3, 0.3], 'LineStyle', '-', 'LineWidth', 2)
    end
    
    Lookup1 = [118 139 150]; % KAMIT
    Lookup2 = [119 140 151]; % MAKET
    Lookup3 = [122 143]; % TAMNA
    Lookup4 = [121 142]; % PANSI
    Lookup5 = [120 141]; % PALSA
    
for PROCMark = 1:length(Lookup1)
plot([Procedure(Lookup1(PROCMark)).trajectory.WP_long], [Procedure(Lookup1(PROCMark)).trajectory.WP_lat], 'LineStyle', 'none', 'Marker', '^', 'MarkerEdgeColor', 'b');
end

for PROCMark = 1:length(Lookup2)
plot([Procedure(Lookup2(PROCMark)).trajectory.WP_long], [Procedure(Lookup2(PROCMark)).trajectory.WP_lat], 'LineStyle', 'none', 'Marker', '^', 'MarkerEdgeColor', 'r');
end


for PROCMark = 1:length(Lookup3)
plot([Procedure(Lookup3(PROCMark)).trajectory.WP_long], [Procedure(Lookup3(PROCMark)).trajectory.WP_lat], 'LineStyle', 'none', 'Marker', '^', 'MarkerEdgeColor', 'g');
end


for PROCMark = 1:length(Lookup4)
plot([Procedure(Lookup4(PROCMark)).trajectory.WP_long], [Procedure(Lookup4(PROCMark)).trajectory.WP_lat], 'LineStyle', 'none', 'Marker', '^', 'MarkerEdgeColor', 'y');
end

for PROCMark = 1:length(Lookup5)
plot([Procedure(Lookup5(PROCMark)).trajectory.WP_long], [Procedure(Lookup5(PROCMark)).trajectory.WP_lat], 'LineStyle', 'none', 'Marker', '^', 'MarkerEdgeColor', 'k');
end