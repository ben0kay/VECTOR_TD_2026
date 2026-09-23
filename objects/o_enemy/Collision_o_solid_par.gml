if (
    attack.type != EnemyAttack.CONTACT
    || !movement.destroy_on_impact
)
{
    exit;
}

var _is_cpu =
    other.object_index == o_cpu;

var _is_building =
    object_is_ancestor(
        other.object_index,
        o_building_par
    );

var _damageable =
    _is_cpu || _is_building;


// ========================================================================
// FLYING IMPACT ENEMIES
// ========================================================================
//
// Current contact flyers pass over buildings and impact only the CPU.

if (movement.layer == EnemyMovementLayer.FLYING)
{
    if (!_is_cpu)
        exit;

    targeting.target = other;
    scr_enemy_attack(id);

    if (instance_exists(id))
        instance_destroy();

    exit;
}


// ========================================================================
// BRAINLESS GROUND ENEMIES
// ========================================================================

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


// ========================================================================
// ORDINARY GROUND IMPACT ENEMIES
// ========================================================================

if (_damageable)
{
    targeting.target = other;
    scr_enemy_attack(id);

    if (instance_exists(id))
        instance_destroy();
}