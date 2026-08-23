/// @description Core Vector TD enums and macros.

enum GameState
{
    BOOT,
    MENU,
    PLAYING,
    PAUSED,
    GAME_OVER
}

enum LevelState
{
    INITIALIZING,
    PLAYING,
    COMPLETE,
    FAILED,
    EXITING
}

enum CameraState
{
    FOLLOW_PLAYER,
    ROAMING
}

/// @description Defines the player's current gameplay state.
enum PlayerState
{
    ACTIVE,
    STUNNED,
    DEAD
}

enum EnemyState
{
    SPAWNING,
    MOVING,
    ATTACKING,
    STUNNED,
    DEAD
}

enum EnemyTarget
{
    CPU,
    BUILDING,
    PLAYER
}

enum EnemyMovementLayer
{
    GROUND,
    FLYING,
    UNDERGROUND
}

enum EnemyBlockedAction
{
    WAIT,
    RETARGET,
    BREACH
}

enum EnemyAttack
{
    CONTACT,
    PROJECTILE
}

enum EnemyAbility
{
    PHASING,
    EXPLODE_ON_DEATH,
    SPLIT_ON_DEATH,
    TRANSPORT_ENEMIES,
    REGENERATE
}

/// @description Identifies the original source of damage.
enum DamageSource
{
    PLAYER,
    TOWER,
    ENEMY,
    ENVIRONMENT
}

/// @description Defines the current runtime state of a building.
enum BuildingState
{
    CONSTRUCTING,
    ACTIVE,
    DISABLED,
    DESTROYED
}

/// @description Defines the player's current build-mode state.
enum BuildState
{
    NONE,
    PLACING
}

/// @description Identifies broad building categories.
enum BuildingType
{
    CPU,
    WALL,
    TOWER,
    MINER,
    REFINERY,
    STORAGE,
    POWER_GENERATOR,
    POWER_NODE,
    SUPPORT
}

/// @description Determines how a tower chooses an enemy.
enum TowerTargetMode
{
    CLOSEST,
    FURTHEST,
    LOWEST_HP,
    HIGHEST_HP
}

/// @description Determines how projectile damage is applied.
enum ProjectileImpact
{
    DIRECT,
    EXPLOSIVE
}

/// @description Identifies the permanent contents of a world cell.
enum WorldCellType
{
    EMPTY,
    DEAD,
    RESOURCE
}


/// @description Selects the broad world-generation algorithm.
enum WorldGenerationStyle
{
    NONE,
    CLUSTERS,
    CAVERNS
}

/// @description Defines the current job stage of a cargo drone.
enum CargoDroneState
{
    WAITING_SOURCE,
    TO_SOURCE,
    TO_STORAGE,
    WAITING_STORAGE,
    DESTROYED
}

/// @description Identifies one map edge used for enemy spawning.
enum SpawnSide
{
    TOP,
    RIGHT,
    BOTTOM,
    LEFT,
    RANDOM
}

// Staggered update helpers.
//
// FUTURE:
// Add more intervals only when profiling shows a real need.

#macro VTD_TICK global.vtd.tick

#macro IFRAMES_2 \
    (((VTD_TICK + real(id)) mod 2) == 0)

#macro IFRAMES_5 \
    (((VTD_TICK + real(id)) mod 5) == 0)

#macro IFRAMES_10 \
    (((VTD_TICK + real(id)) mod 10) == 0)

#macro IFRAMES_30 \
    (((VTD_TICK + real(id)) mod 30) == 0)

#macro IFRAMES_60 \
    (((VTD_TICK + real(id)) mod 60) == 0)