/// @description Returns the room layer used by one enemy movement layer.

function scr_layer_enemy_get(_movement_layer)
{
    switch (_movement_layer)
    {
        case EnemyMovementLayer.FLYING:
            return "Enemies_Flyer";

        case EnemyMovementLayer.GROUND:
            return "Enemies_Ground";

        case EnemyMovementLayer.UNDERGROUND:
        {
            // FUTURE:
            // Add Enemies_Underground if underground enemies require their
            // own visual depth or subterranean effects.

            return "Enemies_Ground";
        }
    }

    return "Enemies_Ground";
}


/// @description Returns the projectile layer for one target movement layer.

function scr_layer_projectile_get(_target_layer)
{
    switch (_target_layer)
    {
        case EnemyMovementLayer.FLYING:
            return "Projectiles_Flyer";

        case EnemyMovementLayer.GROUND:
        case EnemyMovementLayer.UNDERGROUND:
            return "Projectiles_Ground";
    }

    return "Projectiles_Ground";
}


/// @description Returns the effects layer for one movement layer.

function scr_layer_effect_get(_movement_layer)
{
    switch (_movement_layer)
    {
        case EnemyMovementLayer.FLYING:
            return "Effects_Flyer";

        case EnemyMovementLayer.GROUND:
        case EnemyMovementLayer.UNDERGROUND:
            return "Effects_Ground";
    }

    return "Effects_Ground";
}