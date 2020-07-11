
local P = {}
AI_ROM = P


-- Production Weights
--   1.0 = 100% the total needs to equal 1.0
function P.ProductionWeights(voProductionData)
	local laArray
	
	-- Check to see if manpower is to low
	-- More than 100 brigades build stuff that does not use manpower
	if (voProductionData.ManpowerTotal < 90 and voProductionData.LandCountTotal > 45)
	or voProductionData.ManpowerTotal < 45 then
		laArray = {
			0.0, -- Land
			0.60, -- Air
			0.40, -- Sea
			0.00}; -- Other	
	elseif voProductionData.Year <= 1938 and not(voProductionData.IsAtWar) then
		laArray = {
			0.00, -- Land
			0.65, -- Air
			0.35, -- Sea
			0.00}; -- Other
	elseif voProductionData.IsAtWar then
		if voProductionData.Year <= 1939 then
			laArray = {
				0.40, -- Land
				0.40, -- Air
				0.20, -- Sea
				0.00}; -- Other
		else
			laArray = {
				0.50, -- Land
				0.20, -- Air
				0.30, -- Sea
				0.00}; -- Other
		end
	else
		laArray = {
			0.30, -- Land
			0.35, -- Air
			0.35, -- Sea
			0.00}; -- Other
	end
	
	return laArray
end
-- Land ratio distribution
function P.LandRatio(voProductionData)
	local laArray = {
		garrison_brigade = 1,
		infantry_brigade = 8};

	return laArray
end

-- Special Forces ratio distribution
function P.SpecialForcesRatio(voProductionData)
	local laRatio = {
		5, -- Land
		1}; -- Special Force Unit

	local laUnits = { bergsjaeger_brigade = 1};
	
	return laRatio, laUnits	
end

-- Transport to Land unit distribution
function P.TransportLandRatio(voProductionData)
	local laArray = {
		0, -- Land
		0,  -- transport
		0}  -- invasion craft
  
	return laArray
end

function P.DiploScore_OfferTrade(voDiploScoreObj)
	local laTrade = {
		GER = {Score = 100},
		ITA = {Score = 100},
		TUR = {Score = 20},
		SOV = {Score = -50},
		ENG = {Score = -20},
		FRA = {Score = -20}}
	
	if laTrade[voDiploScoreObj.TagName] then
		return voDiploScoreObj.Score + laTrade[voDiploScoreObj.TagName].Score
	end
	
	return voDiploScoreObj.Score
end

function P.ForeignMinister_Alignment(voForeignMinisterData)
	if not(voForeignMinisterData.HasFaction) and not(voForeignMinisterData.IsAtWar) then
		local loSOVTag = CCountryDataBase.GetTag("SOV")
		
		-- If Russia controls Romania border align with Germany
		if CCurrentGameState.GetProvince(3377):GetOwner() == loSOVTag then
			return Support.AlignmentPush("axis", voForeignMinisterData, true, true)
		end
	end
	
	return true
end

return AI_ROM