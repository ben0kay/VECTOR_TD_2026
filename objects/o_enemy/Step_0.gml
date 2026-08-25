/// @description Processes one generic enemy.

if (global.GameState != GameState.PLAYING)
    exit;

if (global.LevelState != LevelState.PLAYING)
    exit;


// Effects calculate the effective movement speed first.

scr_enemy_effects_update(id);

if (!instance_exists(id))
    exit;


// Only actual Centipede children enter the breadcrumb function.
// Attached children skip targeting and MP-grid navigation.

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


// Only the Centipede head records breadcrumbs.

if (is_centipede_head)
    scr_enemy_centipede_head_update(id);


// Visual feedback follows the completed gameplay update.

scr_enemy_visual_direction_update(id);
scr_enemy_shield_update(id);
scr_particles_enemy_update(id);