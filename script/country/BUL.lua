local P = {}
AI_BUL = P

function P.ForeignMinister_Alignment(voForeignMinisterData)
	if not(voForeignMinisterData.HasFaction) then
		-- If Bulgaria controls the border provinces with Romania assume it was due to German influence and align with them
		if CCurrentGameState.GetProvince(4058):GetOwner() == voForeignMinisterData.ministerTag then -- Cavarna
			return Support.AlignmentPush("axis", voForeignMinisterData, true, true)
		end
	end
	
	return true
end
return AI_BUL
