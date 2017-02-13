function HSL(hue, saturation, lightness, alpha)
    if hue < 0 or hue > 360 then
        return 0, 0, 0, alpha
    end
    if saturation < 0 or saturation > 1 then
        return 0, 0, 0, alpha
    end
    if lightness < 0 or lightness > 1 then
        return 0, 0, 0, alpha
    end
    local chroma = (1 - math.abs(2 * lightness - 1)) * saturation
    local h = hue/60
    local x =(1 - math.abs(h % 2 - 1)) * chroma
    local r, g, b = 0, 0, 0
    if h < 1 then
        r,g,b=chroma,x,0
    elseif h < 2 then
        r,g,b=x,chroma,0
    elseif h < 3 then
        r,g,b=0,chroma,x
    elseif h < 4 then
        r,g,b=0,x,chroma
    elseif h < 5 then
        r,g,b=x,0,chroma
    else
        r,g,b=chroma,0,x
    end
    local m = lightness - chroma/2
    return math.floor((r+m)*255),math.floor((g+m)*255),math.floor((b+m)*255),alpha
end


tmr.stop(0)

LEDCOUNT = 60

i = 0

function setcolor()
    r, g, b = HSL(i/LEDCOUNT*360, 1, 0.1)
   
    color = string.char(r,g,b)
    
    colors = color:rep(60)
    ws2812.writergb(4, colors)
    i=i+1
    if i>LEDCOUNT then i=0 end
    
end

tmr.alarm(0, 10, 1, setcolor)


