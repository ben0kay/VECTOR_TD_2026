/// @description Processes one generic enemy with staggered optional updates.

if (!GAMEPLAY_ACTIVE)
    exit;


// Cache camera/fog visibility and stagger optional decisions.

scr_enemy_performance_update(id);


var _visible =
    performance.visibility.visible;

var _decision_due =
    performance.decisions.due;


// ============================================================================
// ACTIVE STATUS EFFECTS
// ============================================================================
//
// Inactive effects no longer enter the complete effects function every frame.

var _effects_active =
    effects.slow.active
    || effects.stasis.active
    || effects.damage_over_time.active;


if (_effects_active)
{
    scr_enemy_effects_update(id);

    if (!instance_exists(id))
        exit;
}
else
{
    movement.speed =
        movement.speed_base;
}


// ============================================================================
// STEALTH
// ============================================================================
//
// Ordinary enemies completely skip stealth processing. Stealth timers continue
// accurately every frame whenever stealth is genuinely relevant.

var _stealth_active =
    stealth.modifier
    || stealth.field.active
    || stealth.reveal.active
    || stealth.alpha.current < 0.999;


if (_stealth_active)
{
    scr_enemy_stealth_update(id);

    if (!instance_exists(id))
        exit;
}


// ============================================================================
// CENTIPEDE CHILD
// ============================================================================

if (
    is_centipede_child
    && scr_enemy_centipede_child_update(id)
)
{
    if (!instance_exists(id))
        exit;


    var _child_shield_active =
        vitals.shield.hit_flash > 0
        || (
            is_struct(vitals.shield.support)
            && vitals.shield.support.enabled
        );


    if (_child_shield_active)
        scr_enemy_shield_update(id);


    if (_visible)
        scr_particles_enemy_update(id);


    exit;
}


// ============================================================================
// PLAYER TARGETING AND STRATEGIC RETARGETING
// ============================================================================
//
// Active player pursuits remain responsive every frame.
// An enemy that is not pursuing the player only performs its player-acquisition
// roll on its staggered decision frame.
//
// Strategic building-retarget timers continue every frame so hunters can still
// notice a newly placed closer building at their configured interval.

var _player_target_active =
    variable_struct_exists(
        targeting,
        "player"
    )
    && targeting.player.active;


if (_player_target_active || _decision_due)
{
    scr_enemy_player_targeting_update(id);
}
else
{
    scr_enemy_strategic_retarget_update(id);
}


if (!instance_exists(id))
    exit;


// ============================================================================
// PRIMARY GAMEPLAY
// ============================================================================
//
// Movement, active attacks and behavior state continue every frame.

scr_enemy_update(id);

if (!instance_exists(id))
    exit;


// Only Centipede heads record breadcrumbs.

if (is_centipede_head)
    scr_enemy_centipede_head_update(id);


// ============================================================================
// OPTIONAL VISUAL WORK
// ============================================================================

if (_visible)
{
    scr_enemy_visual_direction_update(id);
    scr_particles_enemy_update(id);
}


// ============================================================================
// ACTIVE SHIELD TIMERS
// ============================================================================
//
// Shield timers remain accurate when active. Enemies without shield activity
// do not enter the full shield update function.

var _shield_active =
    vitals.shield.hit_flash > 0
    || (
        is_struct(vitals.shield.support)
        && vitals.shield.support.enabled
    );


if (_shield_active)
    scr_enemy_shield_update(id);