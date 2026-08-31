if (
    attack.type != EnemyAttack.CONTACT
    || !movement.destroy_on_impact
)
{
    exit;
}

// Flyers ignore unrelated solids and only impact their selected target.

if (
    movement.layer == EnemyMovementLayer.FLYING
    && other != targeting.target
)
{
    exit;
}

var _damageable =
    other.object_index == o_cpu
    || other.object_index == o_building_par
    || object_is_ancestor(other.object_index, o_building_par);

if (_damageable)
{
    targeting.target = other;
    scr_enemy_attack(id);
}

if (instance_exists(id))
    instance_destroy();