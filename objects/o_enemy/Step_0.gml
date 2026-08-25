/// @description Processes one generic enemy.

if (!GAMEPLAY_ACTIVE)
    exit;


// Effects calculate the effective movement speed first.

scr_enemy_effects_update(id);

if (!instance_exists(id))
    exit;


scr_enemy_stealth_update(id);

if (!instance_exists(id))
    exit;


// Attached Centipede children use their recorded breadcrumb positions.

if (
    is_centipede_child
    && scr_enemy_centipede_child_update(id)
)
{
    if (!instance_exists(id))
        exit;

    scr_enemy_shield_update(id);
    scr_particles_enemy_update(id);

    exit;
}


// Temporary player aggro may override the active target.

scr_enemy_player_targeting_update(id);

if (!instance_exists(id))
    exit;


// Standard, brainless or advanced gameplay update.

scr_enemy_update(id);

if (!instance_exists(id))
    exit;


// Only Centipede heads record breadcrumbs.

if (is_centipede_head)
    scr_enemy_centipede_head_update(id);


// Visual feedback follows the completed gameplay update.

scr_enemy_visual_direction_update(id);
scr_enemy_shield_update(id);
scr_particles_enemy_update(id);