local GameWorld = {}
GameWorld.__index = GameWorld

-- Helper: deep copy a table
local function deepCopy(t: any): any
	if type(t) ~= "table" then return t end
	local copy = {}
	for k, v in pairs(t) do
		copy[k] = deepCopy(v)
	end
	return copy
end

function GameWorld.new(worldName: string)
	local self = setmetatable({}, GameWorld)
	self.name = worldName
	self.branches = {main = {entities = {}, commits = {}}}
	self.currentBranch = "main"
	self.entities = {} -- working copy for current branch
	self.commitHistory = {}
	self.tickCount = 0
	return self
end

-- Save entity (like git add)
function GameWorld:saveEntity(path: string, data: any)
	self.entities[path] = deepCopy(data)
end

-- Load entity
function GameWorld:loadEntity(path: string): any?
	return self.entities[path]
end

-- Commit changes (like git commit)
function GameWorld:commit(message: string)
	self.tickCount += 1
	
	-- Snapshot working entities
	local snapshot = deepCopy(self.entities)
	
	table.insert(self.commitHistory, {
		branch = self.currentBranch,
		message = message,
		tick = self.tickCount,
		entities = snapshot,
	})
	
	-- Update branch state
	local branch = self.branches[self.currentBranch]
	table.insert(branch.commits, {
		message = message,
		tick = self.tickCount,
	})
	-- Save branch entity snapshot
	branch.entities = deepCopy(self.entities)
	
	return self.tickCount
end

-- Create branch (like git branch)
function GameWorld:createBranch(name: string)
	if self.branches[name] then
		return false, "branch exists"
	end
	-- Branch starts with current entities as base
	self.branches[name] = {
		entities = deepCopy(self.entities),
		commits = {},
	}
	return true
end

-- Switch branch (like git checkout)
function GameWorld:checkout(branchName: string): boolean
	if not self.branches[branchName] then
		return false
	end
	-- Save current working state to current branch
	self.branches[self.currentBranch].entities = deepCopy(self.entities)
	-- Load target branch entities
	self.currentBranch = branchName
	self.entities = deepCopy(self.branches[branchName].entities)
	return true
end

-- Get adventure log (like git log)
function GameWorld:log(): {{branch: string, message: string, tick: number}}
	local result = {}
	for i = #self.commitHistory, 1, -1 do
		table.insert(result, {
			branch = self.commitHistory[i].branch,
			message = self.commitHistory[i].message,
			tick = self.commitHistory[i].tick,
		})
	end
	return result
end

-- Fork: copy another world (like git clone/fork)
function GameWorld:fork(sourceWorld: any, newBranch: string)
	for path, data in pairs(sourceWorld.entities) do
		self.entities[path] = deepCopy(data)
	end
	self:commit("Forked from " .. sourceWorld.name)
end

-- Merge branch into current (like git merge)
-- Simple merge: source branch entities overlay onto current, conflicts detected
function GameWorld:merge(sourceBranch: string): {conflicts: {string}, merged: boolean}
	if not self.branches[sourceBranch] then
		return {conflicts = {}, merged = false}
	end
	
	local sourceEntities = self.branches[sourceBranch].entities
	local conflicts = {}
	
	-- Overlay source entities onto current
	for path, data in pairs(sourceEntities) do
		if self.entities[path] ~= nil then
			-- Both branches modified this entity
			table.insert(conflicts, path)
		end
		self.entities[path] = deepCopy(data)
	end
	
	self:commit("Merged " .. sourceBranch .. " into " .. self.currentBranch)
	
	return {conflicts = conflicts, merged = true}
end

-- List all entities
function GameWorld:listEntities(): {string}
	local paths = {}
	for path, _ in pairs(self.entities) do
		table.insert(paths, path)
	end
	table.sort(paths)
	return paths
end

-- Delete entity
function GameWorld:deleteEntity(path: string)
	self.entities[path] = nil
end

-- Get current branch
function GameWorld:currentBranchName(): string
	return self.currentBranch
end

-- Get branch list
function GameWorld:listBranches(): {string}
	local names = {}
	for name, _ in pairs(self.branches) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

return GameWorld
