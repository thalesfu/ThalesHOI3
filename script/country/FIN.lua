local P = {}
AI_FIN = P

function P.HandleMobilization( minister )
	local ministerTag = minister:GetCountryTag()
	local ministerCountry = ministerTag:GetCountry()
	local ai = minister:GetOwnerAI()

	-- mobilize before winter war
	local sovTag = CCountryDataBase.GetTag('SOV')
	local estTag = CCountryDataBase.GetTag('EST')
	
	--if (not sovTag:GetCountry():IsAtWar())
	--and
	if ((not estTag:GetCountry():Exists()) or estTag:GetCountry():IsGovernmentInExile())	     
	then
		local command = CToggleMobilizationCommand( ministerTag, true )
		ai:Post( command )
		return
	end
	
	
	local year = ai:GetCurrentDate():GetYear()
	local month = ai:GetCurrentDate():GetMonthOfYear()
	local gerTag = CCountryDataBase.GetTag('GER')
	
	local warTime = ( year >= 1940 ) or ( year == 1939 and month >= 6 )

	if warTime
	and ( not ministerCountry:HasFaction() )
	and ( not ministerCountry:IsFriend( sovTag, false ) )
	and ( not ministerCountry:IsFriend( gerTag, false ) )
	then
		local finnishBorder = { [0] = 377, 353, 329, 286, 268, 253, 237, 210, 183 }
		local troupCount = 0
		for tmpIndex, provID in pairs(finnishBorder) do
			local province = CCurrentGameState.GetProvince( provID )
			troupCount = troupCount + province:GetNumberOfUnits()
		end
				
		if troupCount > 5
		then
			local command = CToggleMobilizationCommand( ministerTag, true )
			ai:Post( command )
			return
		end
	end
	
	-- general check of neighbors
	for neighborCountry in ministerCountry:GetNeighbours() do
		local threat = ministerCountry:GetRelation(neighborCountry):GetThreat():Get()
		if  threat > 30 then 
			--Utils.LUA_DEBUGOUT( "MOBILIZE " .. tostring(ministerTag) .. " " .. tostring(threat) .. "towards" .. tostring(neighborCountry) )
			local warDesirability = CalculateWarDesirability( ai, neighborCountry:GetCountry(), ministerTag )
			if warDesirability > 70 then
				local command = CToggleMobilizationCommand( ministerTag, true )
				ai:Post( command )
				return
			end
		end
	end
end

function P.DiploScore_OfferTrade(voDiploScoreObj)
	local laTrade = {
		GER = {Score = 100},
		NOR = {Score = 20},
		SOV = {Score = -50},
		SWE = {Score = 100}}
	
	if laTrade[voDiploScoreObj.TagName] then
		return voDiploScoreObj.Score + laTrade[voDiploScoreObj.TagName].Score
	end
	
	return voDiploScoreObj.Score
end

--##########################
-- Foreign Minister Hooks

function P.ForeignMinister_Alignment(voForeignMinisterData)
	if not(voForeignMinisterData.HasFaction) and voForeignMinisterData.Year <= 1942 then
		local loSOVTag = CCountryDataBase.GetTag("SOV")
		
		-- Align with Germany if we go to war with the soviets
		if CCurrentGameState.GetProvince(698):GetOwner() == loSOVTag -- Viipuri
		or voForeignMinisterData.ministerCountry:GetRelation(loSOVTag):HasWar() then
			return Support.AlignmentPush("axis", voForeignMinisterData, true, true)
		end
	end
	
	return true
end

function P.ForeignMinister_EvaluateDecision(voDecision, voForeignMinisterData)
	-- Join the continuation war about 1 month later
	if voDecision.Name == "continuation_war" then
		local loGERTag = CCountryDataBase.GetTag("GER")
		local loGerSovDiplo = loGERTag:GetCountry():GetRelation(CCountryDataBase.GetTag("SOV"))
		
		if loGerSovDiplo:HasWar() then
			local loWar = loGerSovDiplo:GetWar()
			local liWarMonths = loWar:GetCurrentRunningTimeInMonths()
	
			if liWarMonths >= 1 then
				voDecision.Score = 100
			end
		end
		
		voDecision.Score = 0
	end
	
	return voDecision.Score
end

-- Finland has very highly trained forces
function P.CallLaw_training_laws(minister, voCurrentLaw)
	local _SPECIALIST_TRAINING_ = 30
	return CLawDataBase.GetLaw(_SPECIALIST_TRAINING_)
end

return AI_FIN
