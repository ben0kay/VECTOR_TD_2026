/// @description Core Vector TD enums and macros.


// ============================================================================
// GAME / LEVEL
// ============================================================================

enum GameState { BOOT, MENU, PLAYING, PAUSED, GAME_OVER }
enum LevelState { INITIALIZING, PLAYING, COMPLETE, FAILED, EXITING }
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


// ============================================================================
// ENEMIES
// ============================================================================

enum EnemyState { SPAWNING, MOVING, ATTACKING, STUNNED, DEAD }
enum EnemyTarget { CPU, BUILDING, PLAYER }
enum EnemyMovementLayer { GROUND, FLYING, UNDERGROUND }
enum EnemyBlockedAction { WAIT, RETARGET, BREACH }
enum EnemyAttack { CONTACT, PROJECTILE }
enum EnemyAbility { PHASING, EXPLODE_ON_DEATH, SPLIT_ON_DEATH, TRANSPORT_ENEMIES, REGENERATE, ORBIT_TARGET, SHIELD_ALLIES }
enum EnemyModifier { SHIELDED }


// ============================================================================
// ENEMY EFFECTS / STATUS
// ============================================================================

enum EnemyEffect { SLOW, STASIS, DAMAGE_OVER_TIME }


// ============================================================================
// COMBAT / DAMAGE
// ============================================================================

enum DamageSource { PLAYER, TOWER, ENEMY, ENVIRONMENT }
enum DamageType { KINETIC, EXPLOSIVE, LASER }
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
    STORAGE,
    POWER_GENERATOR,
    POWER_NODE,
    POWER_BATTERY,
    SUPPORT,
    FOUNDATION
}
enum BuildState { NONE, PLACING }


// ============================================================================
// TOWERS / WEAPONS
// ============================================================================

enum TowerWeaponType { PROJECTILE, HITSCAN, BEAM }
enum TowerMuzzleMode { CENTER, ALTERNATING }


// ============================================================================
// TOWER TARGETING
// ============================================================================

enum TowerTargetMode { CLOSEST, FURTHEST, LOWEST_HP, HIGHEST_HP }
enum TowerTargetFilter { ANY, NOT_SLOWED, NOT_STASIS, NOT_DISRUPTED }


// ============================================================================
// LOGISTICS
// ============================================================================

enum CargoDroneState { WAITING_SOURCE, TO_SOURCE, TO_STORAGE, WAITING_STORAGE, DESTROYED }


// ============================================================================
// RESOURCES / ECONOMY
// ============================================================================

enum ResourceType { CURRENCY, RAW_MATERIAL }


// ============================================================================
// VISUAL EFFECTS
// ============================================================================

enum EffectType { SHOCKWAVE, IMPACT_FLASH, BEAM_IMPACT }


// ============================================================================
// HUD / UI
// ============================================================================

enum HudAlertType { INFO, WARNING, DANGER, MILESTONE, SUCCESS }
enum HudAlertState { OPENING, HOLDING, CLOSING }
enum BuildMenuCategory { DEFENSE, EXTRACTION, STORAGE, POWER, PRODUCTION, SUPPORT, AUXILIARY }


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
	
#macro GAMEPLAY_ACTIVE \
    (global.GameState == GameState.PLAYING \
    && global.LevelState == LevelState.PLAYING)
	
#macro BUILDING_CAN_OPERATE \
    (GAMEPLAY_ACTIVE \
    && BuildingState == BuildingState.ACTIVE)