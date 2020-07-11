
local P = {}
AI_DEN = P

-- Production Weights
--   1.0 = 100% the total needs to equal 1.0
function P.ProductionWeights(voProductionData)
	local laArray = {
			0.0, -- Land
			0.0, -- Air
			0.8, -- Sea
			0.2}; -- Other
	return laArray
end

function P.Build_CoastalFort(ic, voProductionData)
	return ic, false
end

function P.Build_AntiAir(ic, voProductionData)
	return ic, false
end

return AI_DEN

