function Print(msg)
	if msg then return print(msg) end
end

function CapitalizeFirstLetter(str)
    if not str or str == "" then return str end
    return str:sub(1, 1):upper() .. str:sub(2)
end