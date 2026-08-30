show_debug_message(
    "ENEMY COLLISION | other="
    + string(other)
    + " target="
    + string(targeting.target)
    + " contact="
    + string(attack.type == EnemyAttack.CONTACT)
    + " destroy="
    + string(movement.destroy_on_impact)
);

if (attack.type == EnemyAttack.CONTACT
    && movement.destroy_on_impact
    && other == targeting.target)
{
    scr_enemy_attack(id);

    if (instance_exists(id))
        instance_destroy();
}