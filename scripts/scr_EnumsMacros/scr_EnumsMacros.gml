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