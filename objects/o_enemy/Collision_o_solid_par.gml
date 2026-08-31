if (
    attack.type != EnemyAttack.CONTACT
    || !movement.destroy_on_impact
)
{
    exit;
}

var _damageable =
    other.object_index == o_cpu
    || object_is_ancestor(
        other.object_index,
        o_building_par
    );

// Flying impact enemies ignore unrelated buildings.

if (
    movement.layer == EnemyMovementLayer.FLYING
    && other != targeting.target
)
{
    exit;
}

// Brainless enemies die against any solid.
// Damageable buildings also receive the impact.

if (movement.brainless)
{
    if (_damageable)
    {
        targeting.target = other;
        scr_enemy_attack(id);
    }

    if (instance_exists(id))
        instance_destroy();

    exit;
}

// Regular contact enemies attack whichever building they physically hit.

if (_damageable)
{
    targeting.target = other;
    scr_enemy_attack(id);

    if (instance_exists(id))
        instance_destroy();
}