/// @description Resolves native tower-projectile collision with an enemy.

if (
    global.GameState
    != GameState.PLAYING
)
{
    exit;
}


if (
    global.LevelState
    != LevelState.PLAYING
)
{
    exit;
}


// Mortar-style projectiles deliberately pass through enemies.

if (
    movement.type
    == ProjectileMovement.TARGET_POSITION
)
{
    exit;
}


// Ignore enemies on the wrong movement layer.

if (
    other.movement.layer
    != combat.target_layer
)
{
    exit;
}


// Ignore enemies already being destroyed.

if (
    other.EnemyState
    == EnemyState.DEAD
)
{
    exit;
}


scr_projectile_tower_impact(
    id,
    other
);


instance_destroy();