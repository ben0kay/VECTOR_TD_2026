if (attack.type == EnemyAttack.CONTACT
    && movement.destroy_on_impact
    && other == targeting.target)
{
    scr_enemy_attack(id);

    if (instance_exists(id))
        instance_destroy();
}