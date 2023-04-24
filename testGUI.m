function testGUI
g = figure('KeyPressFcn', @keyPress)
MyButton = uicontrol('Style', 'pushbutton','Callback',@task);

    function task(src, e)
        disp('button press');
    end

    function keyPress(src, e)
        e.Key
        switch e.Key
            
            case 'uparrow'
                task(MyButton, []);
        end
    end
end