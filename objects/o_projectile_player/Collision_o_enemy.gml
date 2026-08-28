/// @description Resolves native player-projectile collision with an enemy.

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


if (
    other.EnemyState
    == EnemyState.DEAD
)
{
    exit;
}


var _damage =
    scr_damage_create(
        combat.damage,
        combat.owner,
        DamageSource.PLAYER
    );


scr_enemy_damage(
    other,
    _damage
);


instance_destroy();