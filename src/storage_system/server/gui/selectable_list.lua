function draw(x, y, height, selected_index, length, string_supplier)

    local draw_start = 1

    if selected_index > length - (height / 2) then
        draw_start = length - height
    elseif selected_index > height / 2 then
        draw_start = math.floor(selected_index - height / 2)
    end

    if draw_start < 1 then draw_start = 1 end

    for i = draw_start, length do
        if i - draw_start <= height then
            -- Draw selected suggetion with white background
            if i == selected_index then
                term.setBackgroundColor(colors.white)
                term.setTextColor(colors.black)
            else
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
            end
            term.setCursorPos(x, y + i - draw_start)
            term.write(string_supplier(i))
        end
    end

    -- Reset colors
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

return {
    draw = draw
}