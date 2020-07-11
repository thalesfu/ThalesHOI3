
local P = {}
AI_SWE = P


-- Production Weights
--   1.0 = 100% the total needs to equal 1.0
function P.ProductionWeights(voProductionData)
	local laArray
	
	-- Check to see if manpower is to low
	-- More than 100 brigades build stuff that does not use manpower
	if (voProductionData.ManpowerTotal < 60 and voProductionData.LandCountTotal > 30)
	or voProductionData.ManpowerTotal < 30 then
		laArray = {
			0.0, -- Land
			0.50, -- Air
			0.50, -- Sea
			0.00}; -- Other	
	elseif voProductionData.Year <= 1939 and not(voProductionData.IsAtWar) then
		laArray = {
			0.10, -- Land
			0.50, -- Air
			0.40, -- Sea
			0.00}; -- Other
	elseif voProductionData.IsAtWar then
		if voProductionData.Year <= 1941 then
			laArray = {
				0.40, -- Land
				0.35, -- Air
				0.25, -- Sea
				0.00}; -- Other
		else
			laArray = {
				0.60, -- Land
				0.20, -- Air
				0.20, -- Sea
				0.00}; -- Other
		end
	else
		laArray = {
			0.30, -- Land
			0.45, -- Air
			0.25, -- Sea
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

	local laUnits = {bergsjaeger_brigade = 1};
	
	return laRatio, laUnits	
end

-- Transport to Land unit distribution
function P.TransportLandRatio(voProductionData)
	local laArray = {
		12, -- Land
		1,  -- transport
		1}  -- invasion craft
  
	return laArray
end

function P.DiploScore_OfferTrade(voDiploScoreObj)
	local laTrade = {
		GER = {Score = 100},
		ITA = {Score = 20},
		FIN = {Score = 20},
		NOR = {Score = 20},
		DEN = {Score = 20},
		SOV = {Score = -20},
		ENG = {Score = -20},
		FRA = {Score = -20}}
	
	if laTrade[voDiploScoreObj.TagName] then
		return voDiploScoreObj.Score + laTrade[voDiploScoreObj.TagName].Score
	end
	
	return voDiploScoreObj.Score
end

function P.ForeignMinister_EvaluateDecision(voDecision, voForeignMinisterData)
	if voDecision.Name == 'finnish_winter_war_swedish_intervention' then
		return 100 	-- lets help
	elseif voDecision.Name == 'finnish_winter_war_swedish_direct_intervention' then
		return 0 -- but not too much
	end

	return voDecision.Score
end

function P.DiploScore_GiveMilitaryAccess(viScore, voAI, voCountryTag)
	local lsCountry = tostring(voCountryTag)

	-- Process a German request
	if lsCountry == "GER" then
		local finTag = CCountryDataBase.GetTag("FIN")
		local FinCountry = finTag:GetCountry()
		local GerCountry = voCountryTag:GetCountry()
		
		-- If Germany and Finland are allies then consider giving them access
		local norTag = CCountryDataBase.GetTag("NOR")
		local loGerNorRelation = GerCountry:GetRelation(norTag)
	
		-- If Norway is gone then give them access
		if GerCountry:GetFaction() == FinCountry:GetFaction()
		--or loGerNorRelation:HasWar() 
		or loGerNorRelation:HasAlliance()
		or (CCurrentGameState.GetProvince(812):GetController():GetCountry():GetFaction() == GerCountry:GetFaction()) -- axis Controls Oslo
		then 
			viScore = viScore + 200
		end		
	end
	
	return viScore
end

function P.ForeignMinister_Alignment(...)
	return Support.AlignmentNeutral(...)
end

return AI_SWE

