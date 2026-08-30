/// @description Core Vector TD enums and macros.


// ============================================================================
// GAME / LEVEL
// ============================================================================

enum GameState { BOOT, MENU, PLAYING, PAUSED, GAME_OVER }
enum LevelState { INITIALIZING, CHASSIS_SELECT, PLAYING, COMPLETE, FAILED, EXITING }
enum LevelVictoryType
{
    NONE,
    SURVIVE_TIME,
    COMPLETE_WAVES
}
enum CameraState { FOLLOW_PLAYER, ROAMING }


// ============================================================================
// WORLD / GENERATION
// ============================================================================

enum WorldCellType { EMPTY, DEAD, RESOURCE }
enum WorldGenerationStyle { NONE, CLUSTERS, CAVERNS }
enum WorldContentType { ENEMY, BUILDING, RESOURCE, DEPOSIT }
enum SpawnSide { TOP, RIGHT, BOTTOM, LEFT, RANDOM, INHERIT }


// ============================================================================
// PLAYER
// ============================================================================

enum PlayerState { ACTIVE, STUNNED, DEAD }
enum PlayerChassis
{
    NONE,
    ASSAULT,
    HEAVY,
    ENGINEER,
    SUPPORT
}

enum PlayerAlternateAbility
{
    NONE,
    COMBAT_BURST,
    ROCKET,
    REPAIR,
    COMMAND_PULSE
}

enum PlayerMainFire
{
    PULSE,
    AUTOCANNON,
    ARC,
    BEAM
}



// ============================================================================
// ENEMIES
// ============================================================================

enum EnemyState { SPAWNING, MOVING, ATTACKING, STUNNED, DEAD }
enum EnemyTarget { CPU, BUILDING, PLAYER }
enum EnemyMovementLayer { GROUND, FLYING, UNDERGROUND }

enum EnemyCombatMovement
{
    STATIONARY,
    ANCHOR_ROAM,
}

enum EnemyBlockedAction { WAIT, RETARGET, BREACH }
enum EnemyAttack
{
    CONTACT,
    PROJECTILE,
    CONTINUOUS_BEAM
}

enum EnemyAbility
{
    PHASING,
    EXPLODE_ON_DEATH,
    SPLIT_ON_DEATH,
    TRANSPORT_ENEMIES,
    REGENERATE,
    SHIELD_ALLIES
}
enum EnemyModifier { SHIELDED, STEALTHED }
enum EnemyBehavior
{
    STANDARD,
    BRAINLESS,
    ORBIT,
    STANDOFF,
    ANCHOR_BEAM,
    SUPPORT
}
enum EnemyOrder
{
    NONE,
    TARGET_PLAYER,
    TARGET_MINER,
    TARGET_TOWER
}


// ============================================================================
// ENEMY EFFECTS / STATUS
// ============================================================================

enum EnemyEffect { SLOW, STASIS, DAMAGE_OVER_TIME }


// ============================================================================
// COMBAT / DAMAGE
// ============================================================================

enum DamageSource { PLAYER, TOWER, ENEMY, ENVIRONMENT }
enum DamageType
{
    KINETIC,
    EXPLOSIVE,
    LASER,
    ELECTRICAL
}
enum AttackAreaShape { POINT, CIRCLE, LINE, CONE, CAPSULE }


// ============================================================================
// PROJECTILES
// ============================================================================

enum ProjectileImpact { DIRECT, EXPLOSIVE }
enum ProjectileMovement { STRAIGHT, TARGET_POSITION, HOMING }


// ============================================================================
// BUILDINGS / CONSTRUCTION
// ============================================================================

enum BuildingState { CONSTRUCTING, ACTIVE, DISABLED, DESTROYED }
enum BuildingType
{
    CPU, WALL, TOWER,
    MINER,
    REFINERY,
	FABRICATOR,
    STORAGE,
    POWER_GENERATOR,
    POWER_NODE,
    POWER_BATTERY,
    SUPPORT,
    FOUNDATION,
	UTILITY
}
enum BuildState { NONE, PLACING }
enum BuildLimitType
{
    NONE,
    TOWER,
    DEFENSE,
    ECONOMY,
    INFRASTRUCTURE,
	FOUNDATION
}
enum UtilityType
{
    CREDIT_MAGNET,
    REPAIRER,
    CREDIT_UPLINK,
	RADAR,
	SHIELD_GENERATOR
}
enum FoundationType
{
    ACCELERATOR,
    REINFORCED,
    SHOCK_GRID
}



// ============================================================================
// TOWERS / WEAPONS
// ============================================================================

enum TowerWeaponType { PROJECTILE, HITSCAN, BEAM, SHOCKWAVE }
enum TowerMuzzleMode { CENTER, ALTERNATING }


// ============================================================================
// TOWER TARGETING
// ============================================================================

enum TowerTargetMode { CLOSEST, FURTHEST, LOWEST_HP, HIGHEST_HP }
enum TowerTargetFilter { ANY, NOT_SLOWED, NOT_STASIS, NOT_DISRUPTED }


// ============================================================================
// LOGISTICS
// ============================================================================

enum CargoDroneState { WAITING_SOURCE, TO_SOURCE, TO_STORAGE, TO_REFINERY, WAITING_STORAGE, DESTROYED }
enum CargoDroneJob { MINER_DELIVERY, REFINERY_INPUT, REFINERY_OUTPUT }

enum ProductionState
{
    IDLE,
    REQUESTING_INPUT,
    AWAITING_INPUT,
    PROCESSING,
    OUTPUT_READY,
    BLOCKED_OUTPUT,
    PAUSED
}


// ============================================================================
// RESOURCES / ECONOMY
// ============================================================================

enum ResourceType { CURRENCY, RAW_MATERIAL, REFINED_MATERIAL, AMMUNITION }


// ============================================================================
// VISUAL EFFECTS
// ============================================================================

enum EffectType { SHOCKWAVE, IMPACT_FLASH, BEAM_IMPACT, ENEMY_DEATH, CONSTRUCTION_COMPLETE }


// ============================================================================
// HUD / UI
// ============================================================================

enum HudAlertType { INFO, WARNING, DANGER, MILESTONE, SUCCESS }
enum HudAlertState { OPENING, HOLDING, CLOSING }
enum BuildMenuCategory { TOWERS, DEFENSE, EXTRACTION, STORAGE, POWER, PRODUCTION, SUPPORT, FOUNDATION }


// ============================================================================
// ENERGY
// ============================================================================
enum EnergyRole { NONE, GENERATOR, NODE, BATTERY, CONSUMER }
enum EnergyPriority { CRITICAL, HIGH, NORMAL, LOW }
enum EnergyNetworkState { OFFLINE, DEFICIT, BATTERY, BALANCED, SURPLUS }
enum EnergyOverlayMode { OFF, NETWORKS, DETAILED }

enum UpgradeScope
{
    PROFILE,
    LEVEL
}

enum UpgradeTarget
{
    BUILDING,
    TOWER_COMBAT,
    PLAYER
}


enum MainMenuAction
{
    CAMPAIGN,
    SURVIVAL,
    SANDBOX,
    RESEARCH,
    OPTIONS,
    CHANGE_PROFILE,
    EXIT_GAME
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
	
#macro OUTSIDE_VIEW_64 \
    (!scr_culling_check_instance(id, 64))

#macro OUTSIDE_VIEW_128 \
    (!scr_culling_check_instance(id, 128))

#macro OUTSIDE_VIEW_256 \
    (!scr_culling_check_instance(id, 256))
	
#macro INSIDE_FOG \
	(!scr_fog_position_visible(x, y))
	
#macro GAMEPLAY_ACTIVE \
    (global.GameState == GameState.PLAYING \
    && global.LevelState == LevelState.PLAYING)
	
/// Whether the current building may perform its unique activity.

#macro BUILDING_CAN_OPERATE \
    (GAMEPLAY_ACTIVE \
    && BuildingState == BuildingState.ACTIVE \
    && (!energy.participates || energy.supplied))
