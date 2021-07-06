--[[
    GD50
    Breakout Remake
    -- LevelMaker Class --
    Author: Colton Ogden
    cogden@cs50.harvard.edu
    Creates randomized levels for our Breakout game. Returns a table of
    bricks that the game can render, based on the current level we're at
    in the game.
]]

--global patterns

NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

--per-row patterns

SOLID = 1 --all colors the same in this row
ALTERNATE = 2 -- alternate colors
SKIP = 3 	--skip every other block
NONE = 4	--no blocks this row

LevelMaker = Class{}

function LevelMaker.createMap(level)
	local bricks = {}

	local numRows = math.random(1, 5)

	local numCols = math.random(7, 13)
	numCols = numCols % 2 == 0 and (numCols + 1) or numCols

	--not to go above tier 3 for some reason
	local highestTier = math.min(3, math.floor(level / 5))

	-- highest color 
	local highestColor = math.min(5, level % 5 + 3)

	--decider if the level is going to have a locked brick in it or not
	local containsLock = true

	-- the position decider for the locked brick. It is random
	local randomRow = math.random(1, numRows)
	local randomCol = math.random(1, numCols)


	for y = 1, numRows do

		local skipPattern = math.random(1, 2) == 1

		local alternatePattern = math.random(1, 2) == 1

		local alternateColor1 = math.random(1, highestColor)
		local alternateColor2 = math.random(1, highestColor)

		local alternateTier1 = math.random(0, highestTier)
		local alternateTier2 = math.random(0, highestTier)

		-- used only when we have to skip a block, for skip pattern
		local skipFlag = math.random(1, 2) == 1

		--used only when we have to alternate the block, for alternate pattern
		local alternateFlag = math.random(1, 2) == 1

		--solid color we'll use if not alternating
		local solidColor = math.random(1, highestColor)
		local solidTier = math.random(0, highestTier)

		for x = 1, numCols do

			if x == randomRow and y == randomCol and containsLock then
				b = Brick((x - 1) * 32 + 8 + (13 - numCols) * 16, y * 16, true)
				b.tier = 1
				b.color = 6
				table.insert(bricks, b)
				goto continue
			end

			-- we don't want both active at the same time (skipFlag will keep on alternating itself)
			if skipPattern and skipFlag then
				
				skipFlag = not skipFlag

				--lua's continue statement's work around
				goto continue
			else
				skipFlag = not skipFlag
			end
			b = Brick(
				(x - 1)
				* 32
				+ 8
				+ (13 - numCols) * 16,

				y * 16,
				false)

			--alternateFlag will keep on alternating its boolean
			if alternateFlag and alternatePattern then
				b.color = alternateColor1
				b.tier = alternateTier1
				alternateFlag = not alternateFlag
			else
				b.color = alternateColor2
				b.tier = alternateTier2
				alternateFlag = not alternateFlag
			end

			if not alternatePattern then
				b.color = solidColor
				b.tier = solidTier
			end

			table.insert(bricks, b)

			::continue::
		end
	end
	
	if #bricks == 0 then
		return self.createMap(level)
	else
		return bricks
	end
end
