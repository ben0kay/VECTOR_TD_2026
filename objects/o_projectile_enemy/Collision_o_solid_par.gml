var _world_solid =
    other.object_index == o_world_solid
    || object_is_ancestor(
        other.object_index,
        o_world_solid
    );

// Flying shots pass over dead/resource terrain.

if (
    movement.layer == EnemyMovementLayer.FLYING
    && _world_solid
)
{
    exit;
}

scr_projectile_enemy_impact(id, other);