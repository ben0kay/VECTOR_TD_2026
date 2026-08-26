
/// @description Processes one enemy through its configured unique Step hooks.
function scr_enemy_unique_step_event(
    _enemy,
    _visible,
    _decision_due
)
{
    if (!instance_exists(_enemy)) return false;

    var _step_event =
        _enemy.unique.step_event;

    _step_event.handled =
        false;

    // ========================================================================
    // UNIQUE STEP START
    // ========================================================================

    if (_step_event.start != undefined)
    {
        if (!_step_event.start(_enemy))
        {
            show_debug_message(
                "ENEMY UNIQUE ERROR - Step Event Start failed: "
                + _enemy.identity.key
            );

            return false;
        }

        if (!instance_exists(_enemy)) return true;
    }

    // ========================================================================
    // NORMAL GAMEPLAY
    // ========================================================================
    //
    // Attached Centipede children set handled to true because their unique
    // function already moved them to their breadcrumb position.

    if (!_step_event.handled)
    {
        if (
            !scr_enemy_step_event_gameplay(
                _enemy,
                _decision_due
            )
        )
        {
            return false;
        }

        if (!instance_exists(_enemy)) return true;
    }

    // ========================================================================
    // UNIQUE STEP FINISH
    // ========================================================================

    if (_step_event.finish != undefined)
    {
        if (!_step_event.finish(_enemy))
        {
            show_debug_message(
                "ENEMY UNIQUE ERROR - Step Event Finish failed: "
                + _enemy.identity.key
            );

            return false;
        }

        if (!instance_exists(_enemy)) return true;
    }

    // ========================================================================
    // SHARED STEP FINISH
    // ========================================================================

    return scr_enemy_step_event_finish(
        _enemy,
        _visible
    );
}

/// @description Processes one enemy through its configured unique Draw hooks.

function scr_enemy_unique_draw_event(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    var _draw_event =
        _enemy.unique.draw_event;


    _draw_event.handled =
        false;


    // ========================================================================
    // UNIQUE DRAW START
    // ========================================================================

    if (_draw_event.start != undefined)
    {
        if (!_draw_event.start(_enemy))
        {
            show_debug_message(
                "ENEMY UNIQUE ERROR - Draw Event Start failed: "
                + _enemy.identity.key
            );

            draw_set_alpha(1);
            draw_set_color(c_white);

            return false;
        }


        if (!instance_exists(_enemy))
            return true;
    }


    // ========================================================================
    // NORMAL DRAW
    // ========================================================================

    if (!_draw_event.handled)
    {
        scr_enemy_draw(
            _enemy
        );
    }


    // ========================================================================
    // UNIQUE DRAW FINISH
    // ========================================================================

    if (_draw_event.finish != undefined)
    {
        if (!_draw_event.finish(_enemy))
        {
            show_debug_message(
                "ENEMY UNIQUE ERROR - Draw Event Finish failed: "
                + _enemy.identity.key
            );

            draw_set_alpha(1);
            draw_set_color(c_white);

            return false;
        }
    }


    draw_set_alpha(1);
    draw_set_color(c_white);


    return true;
}