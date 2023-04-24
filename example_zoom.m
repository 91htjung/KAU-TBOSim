
function example_zoom
    %# some plot
    plot(1:10)
    hAx = gca;

    %# save original axis limits
    setappdata(hAx, 'limits',get(gca,{'XLim','YLim'}))

    %# create custom toolbar button
    [X,map] = imread(fullfile(toolboxdir('matlab'),'icons','view_zoom_out.gif'));
    icon = ind2rgb(X,map);
    uipushtool('CData',icon, 'ClickedCallback',{@click_cb,hAx});

    %# zoom
    uiwait(msgbox('Zooming now, click button to reset', 'modal'))
    set(gca, 'XLim',[3 7], 'YLim',[2 9])
    %zoom on
end

function click_cb(o,e, hAx)
    %# restore original axis limits
    limits = getappdata(hAx, 'limits');
    set(hAx, 'XLim',limits{1}, 'YLim',limits{2})
end