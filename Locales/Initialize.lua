-------------------------------------------------------------------------------
-- Localization {{{
-------------------------------------------------------------------------------

MBC.L = {}

-----------------------------------------

function MBC:PickLocalizationTable(Locale)
	local localizationFunctionName = _G["Localization_"..Locale]

    if type(self[localizationFunctionName]) == "function" then
        self[localizationFunctionName](self)
    else
		self:Localization_enUS()
	end

end

-----------------------------------------

MBC:PickLocalizationTable(GetLocale())

-----------------------------------------

function MBC:SL(Text, ...)

	if not Text or Text == "" then
		return Text
	end
	
	if self.L then
		local Result = self.L[Text]

		if Result and Result ~= "" then		
			return string.format(Result, ...)
		end
	end

	return Text
end
