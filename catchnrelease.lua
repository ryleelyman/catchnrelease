-- Catch 'n' Release
--
-- v 0.1 @alanza

engine.name = 'PolyPerc'

local pattern_time = require 'pattern_time'

LastPitch = -1
OutPitch = -1

Keys = {0, 0, 0}

function init()
    Patterns = {}
    for i = 1,4 do
        Patterns[i] = pattern_time.new()
        Patterns[i].process = function(note)
            engine.hz(note)
            OutPitch = note
        end
    end
    Pattern = 1

    LeftPitch = poll.set("pitch_in_l")
    LeftPitch.callback = function(val)
        if val ~= -1 and val ~= LastPitch then
            Patterns[Pattern]:watch(val)
            LastPitch = val
        end
    end
    LeftPitch.time = 0.1
    LeftPitch:start()
end

function key(n, z)
    Keys[n] = z
    if n == 2 and Keys[3] == 0 then
        -- record
        if z == 0 then
            if Patterns[Pattern].rec == 1 then
                Patterns[Pattern]:rec_stop()
            else
                Patterns[Pattern]:rec_start()
            end
            redraw()
        end
    elseif n == 3 and Keys[2] == 0 then
        -- play
        if z == 0 then
            if Patterns[Pattern].play == 1 then
                Patterns[Pattern]:stop()
            else
                Patterns[Pattern]:start()
            end
            redraw()
        end
    elseif Keys[2] == 1 and Keys[3] == 1 then
        Patterns[Pattern]:clear()
    end
end

function enc(n, d)
    if n == 2 then
        local playflag = false
        local recflag = false
        -- change pattern
        if Patterns[Pattern].play == 1 then
            playflag = true
            Patterns[Pattern]:stop()
        end
        if Patterns[Pattern].rec == 1 then
            recflag = true
            Patterns[Pattern]:rec_stop()
        end
        Pattern = Pattern + d
        while Pattern > 4 do
            Pattern = Pattern - 4
        end
        while Pattern < 1 do
            Pattern = Pattern + 4
        end
        if playflag then
            Patterns[Pattern]:play()
        end
        if recflag then
            Patterns[Pattern]:rec_start()
        end
        redraw()
    end
end

function redraw()
    screen.clear()
    screen.level(15)
    screen.move(10, 16)
    screen.text("Pattern: " .. Pattern)
    screen.move(10, 22)
    screen.text(Patterns[Pattern].play == 1 and "Play" or "Stop")
    screen.move(10, 28)
    screen.text(Patterns[Pattern].rec == 1 and "Rec" or "Not Rec")
    screen.update()
end
