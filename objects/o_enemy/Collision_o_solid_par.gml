if (
    attack.type != EnemyAttack.CONTACT
    || !movement.destroy_on_impact
)
{
    exit;
}

var _damageable =
    other.object_index == o_cpu|| object_is_ancestor(other.object_index, o_building_par);

if (_damageable)
{
    targeting.target = other;
    scr_enemy_attack(id);
}

if (instance_exists(id))
    instance_destroy();