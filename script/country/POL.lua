
local P = {}
AI_POL = P

function P.ProductionWeights(voProductionData)
	local laArray
	
	-- Check to see if manpower is to low
	-- More than 100 brigades build stuff that does not use manpower
	if (voProductionData.ManpowerTotal < 60 and voProductionData.LandCountTotal > 30)
	or voProductionData.ManpowerTotal < 30 then
		laArray = {
			0.00, -- Land
			0.80, -- Air
			0.20, -- Sea
			0.00}; -- Other	
	elseif voProductionData.Year <= 1939 and not(voProductionData.IsAtWar) then
		laArray = {
			0.10, -- Land
			0.85, -- Air
			0.05, -- Sea
			0.00}; -- Other
	elseif voProductionData.IsAtWar then
		if voProductionData.Year <= 1941 then
			laArray = {
				0.20, -- Land
				0.65, -- Air
				0.15, -- Sea
				0.00}; -- Other
		else
			laArray = {
				0.50, -- Land
				0.30, -- Air
				0.20, -- Sea
				0.00}; -- Other
		end
	else
		laArray = {
			0.30, -- Land
			0.50, -- Air
			0.20, -- Sea
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

-- Transport to Land unit distribution
function P.TransportLandRatio(voProductionData)
	local laArray = {
		0, -- Land
		0,  -- transport
		0}  -- invasion craft
  
	return laArray
end

function P.Build_Fort(ic, voProductionData)
	if voProductionData.Year <= 1939 then
		ic = Support.Build_Fort(ic, voProductionData, 1626, 10) -- Danzig
		ic = Support.Build_Fort(ic, voProductionData, 2040, 10) -- L�dz
		ic = Support.Build_Fort(ic, voProductionData, 4749, 10) -- Warsaw
		ic = Support.Build_Fort(ic, voProductionData, 2386, 3) -- Katowice
		ic = Support.Build_Fort(ic, voProductionData, 2158, 3) -- Lublin
		ic = Support.Build_Fort(ic, voProductionData, 1810, 2) -- Bialystok
		ic = Support.Build_Fort(ic, voProductionData, 2509, 2) -- Lw�w
		ic = Support.Build_Fort(ic, voProductionData, 2445, 2) -- Krak�w
	end
	
	return ic, false
end

function P.Build_AntiAir(ic, voProductionData)
	return ic, false
end
function P.Build_Infrastructure(ic, voProductionData)
	return ic, false
end
function P.Build_NavalBase(ic, voProductionData)
	return ic, false
end
function P.Build_CoastalFort(ic, voProductionData)
	return ic, false
end
function P.Build_AirBase(ic, voProductionData)
	return ic, false
end
function P.Build_Industry(ic, voProductionData)
	return ic, false
end
function P.Build_Radar(ic, voProductionData)
	return ic, false
end

function P.HandleMobilization(minister)
	local ai = minister:GetOwnerAI()
	local ministerTag =  minister:GetCountryTag()
	local gerTag = CCountryDataBase.GetTag("GER")

	-- If Germany Controls Czechoslovakia then
	if CCurrentGameState.GetProvince(2562):GetController() == gerTag then -- Praha check
		ai:Post(CToggleMobilizationCommand( ministerTag, true ))					
	else
		-- Check if a neighbor is starting to look threatening
		-- This code should be idential to the one in ai_politics_minsiter.lua
		local ministerCountry = ministerTag:GetCountry()
		local liTotalIC = ministerCountry:GetTotalIC()
		local liNeutrality = ministerCountry:GetNeutrality():Get() * 0.9
		
		for loCountryTag in ministerCountry:GetNeighbours() do
			local liThreat = ministerCountry:GetRelation(loCountryTag):GetThreat():Get()
			
			if (liNeutrality - liThreat) < 10 then
				local loCountry = loCountryTag:GetCountry()
				
				liThreat = liThreat * CalculateAlignmentFactor(ai, ministerCountry, loCountry)
				
				if liTotalIC > 50 and loCountry:GetTotalIC() < liTotalIC then
					liThreat = liThreat / 2 -- we can handle them if they descide to attack anyway
				end
				
				if liThreat > 30 then
					if CalculateWarDesirability(ai, loCountry, ministerTag) > 70 then
						ai:Post(CToggleMobilizationCommand( ministerTag, true ))
					end
				end
			end
		end
	end
end


return AI_POL