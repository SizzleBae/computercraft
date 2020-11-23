SelectableList = {}

function SelectableList:new(list)
    self.list = list
end

function SelectableList:draw(x, y, selected_index)
    for i, str_element in ipairs(self.list) do
        -- Draw selected suggetion with white background
        if i == selected_index then
            term.setBackgroundColor(colors.white)
            term.setTextColor(colors.black)
        else
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
        end
        term.setCursorPos(x, y + i - 1)
        term.write(str_element)
    end
    -- Reset colors
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

return SelectableList