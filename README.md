# 🎮 luau-git-world

**Learn version control through Roblox gameplay.**

`luau-git-world` turns git concepts into game mechanics so kids (and curious adults) learn version control by playing — not by reading man pages.

## 🗺️ Game Mechanics → Git Concepts

| Game Action | Git Concept | Real Skill You Learn |
|------------|-------------|---------------------|
| Copy friend's world | **Fork** | Open source collaboration |
| Try a risky exploration | **Branch** | Safe experimentation |
| Save your changes | **Commit** | Version tracking & snapshots |
| View your adventure log | **Git log** | Audit trails & history |
| Combine two adventures | **Merge** | Integrating work from others |
| Switch between worlds | **Checkout** | Context switching |
| Find a saved point | **Load entity** | Retrieving past state |

## 🚀 Quick Start

```luau
local GameWorld = require(path.to.GameWorld)

-- Create your world
local myWorld = GameWorld.new("MyAdventure")

-- Build something
myWorld:saveEntity("castle", {size = "huge", towers = 4})
myWorld:saveEntity("village", {population = 50})

-- Save your progress (commit!)
myWorld:commit("Built a kingdom")

-- Try something risky on a new branch
myWorld:createBranch("dragon-lair")
myWorld:checkout("dragon-lair")
myWorld:saveEntity("dragon", {color = "red", hp = 1000})
myWorld:commit("Added a dragon! 🐉")

-- Check your adventure log
local log = myWorld:log()
for _, entry in log do
    print(entry.tick, entry.branch, entry.message)
end

-- Go back to safety
myWorld:checkout("main")
```

## 🧪 Running Tests

```bash
luau tests/run-tests.luau
```

## 📖 API Reference

### `GameWorld.new(worldName: string)`
Create a new game world. Starts on the `main` branch.

### `world:saveEntity(path: string, data: any)`
Save an entity at a path (like `git add`).

### `world:loadEntity(path: string): any?`
Load an entity by path. Returns `nil` if not found.

### `world:deleteEntity(path: string)`
Remove an entity.

### `world:listEntities(): {string}`
List all entity paths, sorted alphabetically.

### `world:commit(message: string): number`
Save a snapshot of all current entities with a message. Returns the tick number.

### `world:createBranch(name: string): (boolean, string?)`
Create a new branch. Returns `false` if it already exists.

### `world:checkout(branchName: string): boolean`
Switch to a branch. Returns `false` if branch doesn't exist.

### `world:log(): {logEntry}`
Get the adventure log (commits) in reverse chronological order.

### `world:fork(sourceWorld, newBranch)`
Copy all entities from another world into this one.

### `world:merge(sourceBranch: string): {conflicts: {string}, merged: boolean}`
Merge another branch into the current branch.

### `world:currentBranchName(): string`
Get the name of the current branch.

### `world:listBranches(): {string}`
List all branch names, sorted alphabetically.

## 🎯 Why?

Because `git rebase` shouldn't be scarier than a dragon. This module lets Roblox game devs teach git concepts as gameplay — kids learn by doing, not by memorizing CLI flags.

Built for the [Roblox](https://roblox.com) ecosystem using [Luau](https://luau-lang.org/).

## 📦 Installation

Install via [Wally](https://wally.run):

```toml
[dependencies]
GitWorld = "superinstance/luau-git-world@0.1.0"
```

## License

MIT
