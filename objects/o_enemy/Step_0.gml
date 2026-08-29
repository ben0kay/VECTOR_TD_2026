/// @description Processes one generic enemy with optional unique events.

if (!GAMEPLAY_ACTIVE)
    exit;


// ============================================================================
// ENTERING MAP
// ============================================================================

if (EnemyState == EnemyState.SPAWNING)
{
    scr_enemy_entering_update(id);
    exit;
}


// ============================================================================
// PERFORMANCE
// ============================================================================

scr_enemy_performance_update(id);

var _visible = performance.visibility.visible;
var _decision_due = performance.decisions.due;


// ============================================================================
// ACTIVE EFFECTS
// ============================================================================

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
    movement.speed = movement.speed_base;
}


// ============================================================================
// STEALTH
// ============================================================================

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
// UNIQUE / NORMAL
// ============================================================================

if (has_unique)
{
    if (!scr_enemy_unique_step_event(id, _visible, _decision_due))
    {
        show_debug_message(
            "ENEMY UNIQUE ERROR - Step Event failed: "
            + identity.key
        );
    }

    exit;
}


scr_enemy_step_event_gameplay(id, _decision_due);

if (!instance_exists(id))
    exit;

scr_enemy_step_event_finish(id, _visible);