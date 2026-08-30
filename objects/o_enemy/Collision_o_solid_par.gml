var _target = targeting.target;

if (attack.type == EnemyAttack.CONTACT
    && movement.destroy_on_impact
    && instance_exists(_target)
    && place_meeting(x, y, _target))
{
    scr_enemy_attack(id);

    if (instance_exists(id))
        instance_destroy();
}