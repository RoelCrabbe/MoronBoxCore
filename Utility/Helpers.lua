
function FindInTable(table, string)
	if not table then
		return
	end

	for i, v in table do
		if v == string then
			return i
		end
	end
	return nil
end

function FindKeyInTable(table, string)
	if not table then
		return
	end

	for i, v in table do
		if i == string and v then
			return true
		end
	end
	return nil
end

function sPairs(t, order)
   local keys = {}
   local size
   
   for k in pairs(t) do
       size = TableLength(keys) 
       keys[size + 1] = k
   end
   
   if order then
       table.sort(keys, function(a, b)
           return order(t, a, b)
       end)
   else
       table.sort(keys)
   end
   
   local i = 0
   
   return function()
       i = i + 1
       if keys[i] then
           return keys[i], t[keys[i]]
       end
   end
end

function TableLength(tab)
    if not tab then
		return 0
	end

    local len = 0
    for _ in pairs(tab) do
		len = len + 1
	end
    return len
end

function IncrementIndex(tab, len)
	if tab == len then
		return 1
	end
	return tab + 1
end

function DecrementIndex(tab, len)
	if tab == 1 then
		return len
	end
	return tab - 1
end

function PrintTable(t)
	for k, v in pairs(t) do Print(k, v) end
end

function TableInvert(tbl)
	local rv = {}
	for key, val in pairs(tbl) do
		rv[ val ] = key
	end
	return rv
end