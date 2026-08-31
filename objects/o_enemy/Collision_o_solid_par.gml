if (
    attack.type != EnemyAttack.CONTACT
    || !movement.destroy_on_impact
)
{
    exit;
}

var _damageable =
    other.object_index == o_cpu
    || other.object_index == o_building_par
    || object_is_ancestor(other.object_index, o_building_par);

// Brainless enemies impact whatever solid they touch.

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

// Regular enemies ignore solids that are not their chosen target.

var _target = targeting.target;

if (!instance_exists(_target) || other != _target)
    exit;

if (_damageable)
    scr_enemy_attack(id);

if (instance_exists(id))
    instance_destroy();