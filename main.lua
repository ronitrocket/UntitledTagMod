UTM = {}

--Loads mod files
SMODS.load_file("util/main_util.lua")()
SMODS.load_file("util/cardDefs.lua")()
SMODS.load_file("modContent/atlas.lua")()

--Loads stuff added by the mod
UTM.load_cards(UTM.stickers, "modContent/stickers")
UTM.load_cards(UTM.enhancements, "modContent/enhancements")