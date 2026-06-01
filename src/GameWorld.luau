local GameWorld = {}
GameWorld.__index = GameWorld

function GameWorld.new(worldName: string)
	local self = setmetatable({}, GameWorld)
	self.name = worldName
	self.branches = {main = {}}
	self.currentBranch = "main"
	self.entities = {}
	self.commitHistory = {}
	self.tickCount = 0
	return self
end

-- Save entity (like git add)
function GameWorld:saveEntity(path: string, data: any)
	self.entities[path] = data
end

-- Load entity
function GameWorld:loadEntity(path: string): any?
	return self.entities[path]
end

-- Commit changes (like git commit)
function GameWorld:commit(message: string)
	self.tickCount += 1
	local snapshot = {}
	for path, data in pairs(self.entities) do
		snapshot[path] = data
	end
	table.insert(self.commitHistory, {
		branch = self.currentBranch,
		message = message,
		tick = self.tickCount,
		entities = snapshot,
	})
	if not self.branches[self.currentBranch] then
		self.branches[self.currentBranch] = {}
	end
	table.insert(self.branches[self.currentBranch], {
		message = message,
		tick = self.tickCount,
	})
	return self.tickCount
end

-- Create branch (like git branch)
function GameWorld:createBranch(name: string)
	if self.branches[name] then
		return false, "branch exists"
	end
	self.branches[name] = {}
	return true
end

-- Switch branch (like git checkout)
function GameWorld:checkout(branchName: string): boolean
	if not self.branches[branchName] then
		return false
	end
	self.currentBranch = branchName
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
		self.entities[path] = data
	end
	self:commit("Forked from " .. sourceWorld.name)
end

-- Merge branch into current (like git merge)
function GameWorld:merge(sourceBranch: string): {conflicts: {string}, merged: boolean}
	if not self.branches[sourceBranch] then
		return {conflicts = {}, merged = false}
	end
	self:commit("Merged " .. sourceBranch .. " into " .. self.currentBranch)
	return {conflicts = {}, merged = true}
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
