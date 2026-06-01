-- Test runner for luau-git-world
-- Run with: luau tests/run-tests.luau

local GameWorld = require(script.Parent.src.GameWorld)

local passed = 0
local failed = 0

local function assert_(condition: boolean, testName: string)
	if condition then
		passed += 1
		print("  ✅ " .. testName)
	else
		failed += 1
		print("  ❌ " .. testName)
	end
end

local function assertEqual(actual: any, expected: any, testName: string)
	if actual == expected then
		passed += 1
		print("  ✅ " .. testName)
	else
		failed += 1
		print("  ❌ " .. testName .. " (expected " .. tostring(expected) .. ", got " .. tostring(actual) .. ")")
	end
end

-- Test Group 1: World creation and basics
print("\n📦 World Creation")
do
	local world = GameWorld.new("TestWorld")
	assert_(world ~= nil, "World created successfully")
	assertEqual(world.name, "TestWorld", "World name is set")
	assertEqual(world:currentBranchName(), "main", "Default branch is main")
end

-- Test Group 2: Save and load entities
print("\n💾 Save & Load Entities")
do
	local world = GameWorld.new("EntityTest")
	world:saveEntity("trees/oak", {height = 10, type = "oak"})
	world:saveEntity("buildings/house", {floors = 2, color = "blue"})

	local oak = world:loadEntity("trees/oak")
	assertEqual(oak.height, 10, "Loaded entity has correct height")
	assertEqual(oak.type, "oak", "Loaded entity has correct type")

	local house = world:loadEntity("buildings/house")
	assertEqual(house.floors, 2, "Building has correct floors")

	local missing = world:loadEntity("nonexistent")
	assertEqual(missing, nil, "Missing entity returns nil")
end

-- Test Group 3: Commit creates log entry
print("\n📝 Commit & Log")
do
	local world = GameWorld.new("CommitTest")
	world:saveEntity("item1", "sword")
	local tick = world:commit("Added sword to inventory")
	assertEqual(tick, 1, "First commit returns tick 1")

	local log = world:log()
	assertEqual(#log, 1, "Log has one entry")
	assertEqual(log[1].message, "Added sword to inventory", "Log message matches")
	assertEqual(log[1].branch, "main", "Log branch is main")
	assertEqual(log[1].tick, 1, "Log tick is 1")
end

-- Test Group 4: Multiple commits in order
print("\n📚 Multiple Commits")
do
	local world = GameWorld.new("MultiCommit")
	world:saveEntity("a", 1)
	world:commit("First commit")
	world:saveEntity("b", 2)
	world:commit("Second commit")
	world:saveEntity("c", 3)
	world:commit("Third commit")

	local log = world:log()
	assertEqual(#log, 3, "Log has three entries")
	-- Reverse order: newest first
	assertEqual(log[1].message, "Third commit", "First log entry is most recent")
	assertEqual(log[3].message, "First commit", "Last log entry is oldest")
end

-- Test Group 5: Branch creation
print("\n🌿 Branch Creation")
do
	local world = GameWorld.new("BranchTest")
	local ok, err = world:createBranch("adventure")
	assertEqual(ok, true, "Branch created successfully")

	local dup = world:createBranch("adventure")
	assertEqual(dup, false, "Duplicate branch rejected")

	local branches = world:listBranches()
	assertEqual(#branches, 2, "Has two branches (main + adventure)")
end

-- Test Group 6: Checkout / switch branches
print("\n🔀 Branch Checkout")
do
	local world = GameWorld.new("CheckoutTest")
	world:createBranch("experiment")
	assertEqual(world:currentBranchName(), "main", "Still on main after branch create")

	world:checkout("experiment")
	assertEqual(world:currentBranchName(), "experiment", "Switched to experiment")

	local badCheckout = world:checkout("nonexistent")
	assertEqual(badCheckout, false, "Cannot checkout nonexistent branch")

	world:checkout("main")
	assertEqual(world:currentBranchName(), "main", "Switched back to main")
end

-- Test Group 7: Fork copies entities from another world
print("\n🍴 Fork World")
do
	local source = GameWorld.new("OriginalWorld")
	source:saveEntity("castle", {size = "huge"})
	source:saveEntity("village", {population = 50})
	source:commit("Built the kingdom")

	local forked = GameWorld.new("ForkedWorld")
	forked:fork(source, "fork")

	local castle = forked:loadEntity("castle")
	assertEqual(castle.size, "huge", "Forked entity copied correctly")

	local village = forked:loadEntity("village")
	assertEqual(village.population, 50, "Forked second entity copied")

	local log = forked:log()
	assertEqual(#log, 1, "Fork creates one commit")
	assertEqual(log[1].message, "Forked from OriginalWorld", "Fork commit message correct")
end

-- Test Group 8: Merge branches
print("\n🔗 Merge Branches")
do
	local world = GameWorld.new("MergeTest")
	world:saveEntity("base", "foundation")
	world:commit("Base commit")

	world:createBranch("feature")
	world:checkout("feature")
	world:saveEntity("feature_item", "cool stuff")
	world:commit("Added feature")

	world:checkout("main")
	local result = world:merge("feature")
	assertEqual(result.merged, true, "Merge succeeded")

	local badMerge = world:merge("nonexistent")
	assertEqual(badMerge.merged, false, "Merge nonexistent branch fails")
end

-- Test Group 9: Multiple branches with separate commits
print("\n🌳 Multiple Branch Commits")
do
	local world = GameWorld.new("MultiBranch")
	world:saveEntity("shared", "initial")
	world:commit("Initial on main")

	world:createBranch("branch-a")
	world:createBranch("branch-b")

	world:checkout("branch-a")
	world:saveEntity("a_item", "alpha")
	world:commit("Commit on branch-a")

	world:checkout("branch-b")
	world:saveEntity("b_item", "beta")
	world:commit("Commit on branch-b")

	local log = world:log()
	assertEqual(#log, 3, "Three total commits across branches")
	assertEqual(log[1].branch, "branch-b", "Latest commit on branch-b")
end

-- Test Group 10: Delete entity
print("\n🗑️ Delete Entity")
do
	local world = GameWorld.new("DeleteTest")
	world:saveEntity("temporary", "gone soon")
	world:saveEntity("permanent", "stays")

	assertEqual(world:loadEntity("temporary"), "gone soon", "Entity exists before delete")

	world:deleteEntity("temporary")
	assertEqual(world:loadEntity("temporary"), nil, "Entity gone after delete")
	assertEqual(world:loadEntity("permanent"), "stays", "Other entity unaffected")
end

-- Test Group 11: List entities
print("\n📋 List Entities")
do
	local world = GameWorld.new("ListTest")
	world:saveEntity("banana", 1)
	world:saveEntity("apple", 2)
	world:saveEntity("cherry", 3)

	local list = world:listEntities()
	assertEqual(#list, 3, "Three entities listed")
	assertEqual(list[1], "apple", "Entities sorted alphabetically (first)")
	assertEqual(list[3], "cherry", "Entities sorted alphabetically (last)")
end

-- Test Group 12: Commit preserves snapshot
print("\n📸 Commit Snapshots")
do
	local world = GameWorld.new("SnapshotTest")
	world:saveEntity("hp", 100)
	world:commit("Full health")

	world:saveEntity("hp", 50)
	world:commit("Took damage")

	-- Commit history should have both snapshots
	assertEqual(world.commitHistory[1].entities.hp, 100, "First snapshot has hp=100")
	assertEqual(world.commitHistory[2].entities.hp, 50, "Second snapshot has hp=50")
end

-- Test Group 13: Branch list sorted
print("\n📊 Branch Listing")
do
	local world = GameWorld.new("BranchListTest")
	world:createBranch("zeta")
	world:createBranch("alpha")
	world:createBranch("mid")

	local branches = world:listBranches()
	assertEqual(branches[1], "alpha", "Branches sorted: alpha first")
	assertEqual(branches[2], "main", "Branches sorted: main middle")
	assertEqual(branches[3], "mid", "Branches sorted: mid")
	assertEqual(branches[4], "zeta", "Branches sorted: zeta last")
end

-- Test Group 14: Empty world operations
print("\n🕸️ Empty World Edge Cases")
do
	local world = GameWorld.new("EmptyWorld")
	local log = world:log()
	assertEqual(#log, 0, "Empty world has no log entries")

	local entities = world:listEntities()
	assertEqual(#entities, 0, "Empty world has no entities")

	local branches = world:listBranches()
	assertEqual(#branches, 1, "Empty world has main branch only")
end

-- Summary
print("\n" .. string.rep("=", 40))
print(string.format("Results: %d passed, %d failed, %d total", passed, failed, passed + failed))
if failed == 0 then
	print("🎉 All tests passed!")
else
	print("⚠️ Some tests failed.")
end

return {passed = passed, failed = failed}
