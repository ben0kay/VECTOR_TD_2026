/// @description Initializes the current level's mission-result runtime.

function scr_level_result_initialize()
{
    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;

    if (variable_struct_exists(global.vtd_level, "result"))
        return true;


    var _world_data =
        scr_world_data_get(
            global.vtd_level.identity.world_key
        );

    var _victory =
    {
        type: LevelVictoryType.NONE,
        required_waves: 0,
        survival_seconds: 0
    };

    var _progression =
    {
        next_world_key: "",
        menu_room: noone
    };


    if (
        is_struct(_world_data)
        && variable_struct_exists(_world_data, "victory")
        && is_struct(_world_data.victory)
    )
    {
        var _source = _world_data.victory;

        if (variable_struct_exists(_source, "type"))
            _victory.type = _source.type;

        if (variable_struct_exists(_source, "required_waves"))
            _victory.required_waves = max(0, _source.required_waves);

        if (variable_struct_exists(_source, "survival_seconds"))
            _victory.survival_seconds = max(0, _source.survival_seconds);
    }


    if (
        is_struct(_world_data)
        && variable_struct_exists(_world_data, "progression")
        && is_struct(_world_data.progression)
    )
    {
        var _source = _world_data.progression;

        if (variable_struct_exists(_source, "next_world_key"))
            _progression.next_world_key = _source.next_world_key;

        if (variable_struct_exists(_source, "menu_room"))
            _progression.menu_room = _source.menu_room;
    }


    if (!variable_struct_exists(global.vtd_level, "combat"))
    {
        global.vtd_level.combat =
        {
            kills: 0,
            credits_earned: 0
        };
    }

    if (!variable_struct_exists(global.vtd_level.combat, "credits_earned"))
        global.vtd_level.combat.credits_earned = 0;


    global.vtd_level.result =
    {
        active: false,
        victory: false,
        reason: "",

        config:
        {
            victory: _victory,
            progression: _progression
        },

        tracking:
        {
            structures_placed: 0,
            towers_placed: 0,

            player_kills: 0,
            tower_kills: 0,

            waves_reached: 0
        },

        snapshot:
        {
            world_name: "",
            mission_seconds: 0,
            wave_reached: 0,

            enemies_defeated: 0,
            structures_placed: 0,
            towers_placed: 0,
            structures_remaining: 0,

            player_kills: 0,
            tower_kills: 0,

            credits_earned: 0,
            credits_remaining: 0,

            cpu_integrity_percent: 0
        },

        animation:
        {
            delay_remaining: 1.15,
            progress: 0,
            opening_speed: 0.055,
            input_ready: false
        }
    };


    return true;
}


/// @description Records one successfully placed player structure.

function scr_level_result_building_placed(_building)
{
    if (!instance_exists(_building))
        return false;

    if (!scr_level_result_initialize())
        return false;


    var _tracking =
        global.vtd_level.result.tracking;

    _tracking.structures_placed++;


    if (_building.identity.type == BuildingType.TOWER)
        _tracking.towers_placed++;


    return true;
}


/// @description Records the source responsible for one enemy kill.

function scr_level_result_enemy_kill_record(_damage)
{
    if (!is_struct(_damage))
        return false;

    if (!scr_level_result_initialize())
        return false;


    var _tracking =
        global.vtd_level.result.tracking;


    switch (_damage.source_type)
    {
        case DamageSource.PLAYER:
            _tracking.player_kills++;
        break;

        case DamageSource.TOWER:
            _tracking.tower_kills++;
        break;
    }


    return true;
}

/// @description Records one authored major wave entering the battlefield.

function scr_level_result_wave_reached(_wave_number)
{
    if (!scr_level_result_initialize())
        return false;

    global.vtd_level.result.tracking.waves_reached =
        max(
            global.vtd_level.result.tracking.waves_reached,
            _wave_number
        );

    return true;
}


/// @description Captures final level statistics once.

function scr_level_result_snapshot_capture()
{
    if (!scr_level_result_initialize())
        return false;


    var _result = global.vtd_level.result;
    var _snapshot = _result.snapshot;

    var _world_data =
        scr_world_data_get(
            global.vtd_level.identity.world_key
        );


    if (
        is_struct(_world_data)
        && variable_struct_exists(_world_data, "identity")
    )
    {
        _snapshot.world_name =
            _world_data.identity.name;
    }
    else
    {
        _snapshot.world_name =
            global.vtd_level.identity.world_key;
    }


    _snapshot.mission_seconds =
        global.vtd_level.time.seconds;

    _snapshot.wave_reached =
        _result.tracking.waves_reached;

    _snapshot.enemies_defeated =
        global.vtd_level.combat.kills;

    _snapshot.structures_placed =
        _result.tracking.structures_placed;

    _snapshot.towers_placed =
        _result.tracking.towers_placed;

    _snapshot.structures_remaining =
        instance_number(o_building_par);

    _snapshot.player_kills =
        _result.tracking.player_kills;

    _snapshot.tower_kills =
        _result.tracking.tower_kills;

    _snapshot.credits_earned =
        global.vtd_level.combat.credits_earned;

    _snapshot.credits_remaining =
        scr_resource_amount_get(
            "resource_credits"
        );


    var _cpu =
        global.vtd_level.entities.cpu;

    _snapshot.cpu_integrity_percent = 0;


    if (instance_exists(_cpu))
    {
        _snapshot.cpu_integrity_percent =
            clamp(
                round(
                    100
                    * _cpu.vitals.hp.current
                    / max(1, _cpu.vitals.hp.maximum)
                ),
                0,
                100
            );
    }


    return true;
}


/// @description Resolves the current level as victory or defeat.

function scr_level_result_resolve(
    _victory,
    _reason
)
{
    if (!scr_level_result_initialize())
        return false;

    var _result =
        global.vtd_level.result;

    if (_result.active)
        return false;


    scr_level_result_snapshot_capture();


    _result.active = true;
    _result.victory = _victory;
    _result.reason = _reason;

    _result.animation.delay_remaining = 1.15;
    _result.animation.progress = 0;
    _result.animation.input_ready = false;


    global.BuildState =
        BuildState.NONE;

    global.LevelState =
        _victory
        ? LevelState.COMPLETE
        : LevelState.FAILED;


    var _type =
        _victory
        ? HudAlertType.SUCCESS
        : HudAlertType.DANGER;

    var _title =
        _victory
        ? "MISSION SUCCESS"
        : "MISSION FAILED";


    scr_hud_major_alert_push(
        _type,
        _title,
        _reason,
        2.75
    );


    show_debug_message(
        "LEVEL RESULT: "
        + _title
        + " // "
        + _reason
    );


    return true;
}

/// @description Updates victory conditions and result-panel animation.

function scr_level_result_update()
{
    if (!scr_level_result_initialize())
        return false;


    var _result =
        global.vtd_level.result;

    var _delta =
        1 / max(
            1,
            game_get_speed(gamespeed_fps)
        );


    if (_result.active)
    {
        _result.animation.delay_remaining =
            max(
                0,
                _result.animation.delay_remaining - _delta
            );

        if (_result.animation.delay_remaining <= 0)
        {
            _result.animation.progress =
                min(
                    1,
                    _result.animation.progress
                    + _result.animation.opening_speed
                );

            _result.animation.input_ready =
                _result.animation.progress >= 0.96;
        }

        return true;
    }


    // Resolve externally assigned states defensively.

    if (global.LevelState == LevelState.FAILED)
    {
        return scr_level_result_resolve(
            false,
            "CPU CORE DESTROYED"
        );
    }

    if (global.LevelState == LevelState.COMPLETE)
    {
        return scr_level_result_resolve(
            true,
            "PRIMARY OBJECTIVE COMPLETE"
        );
    }

    if (global.LevelState != LevelState.PLAYING)
        return true;


    var _victory =
        _result.config.victory;


    switch (_victory.type)
    {
        case LevelVictoryType.NONE:
        {
            // Endless or development world.
        }
        break;


        case LevelVictoryType.SURVIVE_TIME:
        {
            if (
                _victory.survival_seconds > 0
                && global.vtd_level.time.seconds
                    >= _victory.survival_seconds
            )
            {
                return scr_level_result_resolve(
                    true,
                    "SURVIVAL TIME COMPLETED"
                );
            }
        }
        break;


        case LevelVictoryType.COMPLETE_WAVES:
        {
            var _required_wave =
                _victory.required_waves;

            if (
                _required_wave <= 0
                || _result.tracking.waves_reached
                    < _required_wave
            )
            {
                break;
            }


            // Only inspect the final wave periodically.
            // This avoids scanning the enemy population every frame.

            if ((global.vtd.tick mod 10) != 0)
                break;


            if (
                scr_level_result_required_wave_clear(
                    _required_wave
                )
            )
            {
                return scr_level_result_resolve(
                    true,
                    "ALL REQUIRED WAVES DEFEATED"
                );
            }
        }
        break;
    }


    return true;
}


/// @description Formats a mission duration as MM:SS.

function scr_level_result_time_text(_seconds)
{
    _seconds =
        max(
            0,
            floor(_seconds)
        );

    var _minutes =
        floor(_seconds / 60);

    var _remaining =
        _seconds mod 60;


    return
        string(_minutes)
        + ":"
        + (
            _remaining < 10
            ? "0"
            : ""
        )
        + string(_remaining);
}


/// @description Creates the result-window button runtime.

function scr_level_result_hud_create()
{
    var _restart =
        scr_hud_button_create(
            "restart",
            "RESTART MISSION"
        );

    var _next =
        scr_hud_button_create(
            "next",
            "NEXT MISSION",
            "CAMPAIGN REQUIRED"
        );

    var _menu =
        scr_hud_button_create(
            "menu",
            "EXIT TO MENU",
            "MENU REQUIRED"
        );

    var _exit =
        scr_hud_button_create(
            "exit",
            "EXIT GAME"
        );


    return
        exit
        restart: _restart,
        next: _next,
        menu: _menu,: _exit
    };
}


/// @description Processes mission-result buttons.

function scr_level_result_hud_update(_hud)
{
    if (!instance_exists(_hud))
        return false;

    if (!scr_level_result_initialize())
        return false;


    var _result =
        global.vtd_level.result;

    if (!_result.active)
        return false;


    var _buttons =
        _hud.hud.result_buttons;

    var _gui_width =
        display_get_gui_width();

    var _gui_height =
        display_get_gui_height();

    var _button_width = 230;
    var _button_height = 48;
    var _button_spacing = 12;

    var _button_x =
        _gui_width
        - _button_width
        - 54;

    var _button_y =
        _gui_height
        - 284;


    scr_hud_button_bounds_set(
        _buttons.restart,
        _button_x,
        _button_y,
        _button_width,
        _button_height
    );

    scr_hud_button_bounds_set(
        _buttons.next,
        _button_x,
        _button_y + (_button_height + _button_spacing),
        _button_width,
        _button_height
    );

    scr_hud_button_bounds_set(
        _buttons.menu,
        _button_x,
        _button_y + ((_button_height + _button_spacing) * 2),
        _button_width,
        _button_height
    );

    scr_hud_button_bounds_set(
        _buttons.exit,
        _button_x,
        _button_y + ((_button_height + _button_spacing) * 3),
        _button_width,
        _button_height
    );


    var _accent =
        _result.victory
        ? c_lime
        : c_red;


    _buttons.restart.accent_color = _accent;
    _buttons.next.accent_color = _accent;
    _buttons.menu.accent_color = _accent;
    _buttons.exit.accent_color = _accent;


    // Navigation buttons remain visible but disabled until their rooms
    // and campaign-loading behavior exist.

    _buttons.restart.enabled =
        _result.animation.input_ready;

    _buttons.next.enabled =
        false;

    _buttons.menu.enabled =
        false;

    _buttons.exit.enabled =
        _result.animation.input_ready;


    if (!_result.animation.input_ready)
        return true;


    if (scr_hud_button_update(_buttons.restart))
    {
        room_restart();
        return true;
    }


    if (scr_hud_button_update(_buttons.exit))
    {
        game_end();
        return true;
    }


    return true;
}


/// @description Draws one result statistic card.

function scr_level_result_stat_card_draw(
    _x,
    _y,
    _width,
    _height,
    _label,
    _value,
    _color,
    _progress
)
{
    draw_set_alpha(0.72 * _progress);
    draw_set_color(c_black);

    draw_rectangle(
        _x,
        _y,
        _x + _width,
        _y + _height,
        false
    );


    draw_set_alpha(_progress);
    draw_set_color(_color);

    draw_line(
        _x,
        _y,
        _x + _width - 10,
        _y
    );

    draw_line(
        _x + _width - 10,
        _y,
        _x + _width,
        _y + 10
    );

    draw_line(
        _x + _width,
        _y + 10,
        _x + _width,
        _y + _height
    );


    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    draw_set_color(c_gray);

    draw_text(
        _x + 14,
        _y + 12,
        string_upper(_label)
    );


    draw_set_color(c_white);

    draw_text(
        _x + 14,
        _y + 38,
        string(_value)
    );


    return true;
}


/// @description Draws the complete victory or defeat results interface.

function scr_level_result_hud_draw(_hud)
{
    if (!instance_exists(_hud))
        return false;

    if (!scr_level_result_initialize())
        return false;


    var _result =
        global.vtd_level.result;

    if (!_result.active)
        return false;


    var _progress =
        _result.animation.progress;

    var _ease =
        1
        - power(
            1 - _progress,
            3
        );

    var _gui_width =
        display_get_gui_width();

    var _gui_height =
        display_get_gui_height();

    var _color =
        _result.victory
        ? c_lime
        : c_red;

    var _heading =
        _result.victory
        ? "VICTORY"
        : "DEFEAT";

    var _status =
        _result.victory
        ? "MISSION SUCCESS"
        : "MISSION FAILED";


    // ========================================================================
    // BACKGROUND
    // ========================================================================

    draw_set_alpha(0.94 * _ease);
    draw_set_color(c_black);

    draw_rectangle(
        0,
        0,
        _gui_width,
        _gui_height,
        false
    );


    if (_progress <= 0)
    {
        draw_set_alpha(1);
        draw_set_color(c_white);
        return true;
    }


    // ========================================================================
    // OPENING VECTOR SHELL
    // ========================================================================

    var _margin = 24;

    var _panel_width =
        (_gui_width - (_margin * 2))
        * _ease;

    var _left =
        (_gui_width - _panel_width)
        * 0.5;

    var _right =
        _left + _panel_width;

    var _top = _margin;
    var _bottom = _gui_height - _margin;


    draw_set_alpha(_ease);
    draw_set_color(_color);

    draw_line_width(
        _left + 18,
        _top,
        _right - 18,
        _top,
        2
    );

    draw_line_width(
        _left + 18,
        _bottom,
        _right - 18,
        _bottom,
        2
    );

    draw_line(_left, _top + 18, _left + 18, _top);
    draw_line(_left, _top + 18, _left, _bottom - 18);
    draw_line(_left, _bottom - 18, _left + 18, _bottom);

    draw_line(_right - 18, _top, _right, _top + 18);
    draw_line(_right, _top + 18, _right, _bottom - 18);
    draw_line(_right, _bottom - 18, _right - 18, _bottom);


    if (_progress < 0.35)
    {
        draw_set_alpha(1);
        draw_set_color(c_white);
        return true;
    }


    var _snapshot =
        _result.snapshot;


    // ========================================================================
    // HEADER
    // ========================================================================

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_set_color(_color);

    draw_text(
        _gui_width * 0.5,
        50,
        _status
    );


    draw_line(
        380,
        76,
        _gui_width - 380,
        76
    );


    // ========================================================================
    // LEFT SUMMARY
    // ========================================================================

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    draw_set_color(_color);

    draw_text(
        54,
        100,
        _heading
    );


    draw_set_color(c_aqua);

    draw_text(
        54,
        138,
        string_upper(_snapshot.world_name)
    );


    draw_set_color(c_gray);

    draw_text(54, 190, "MISSION TIME");
    draw_text(54, 226, "WAVE REACHED");
    draw_text(54, 262, "CPU INTEGRITY");


    draw_set_color(c_white);

    draw_text(
        190,
        190,
        scr_level_result_time_text(
            _snapshot.mission_seconds
        )
    );

    draw_text(
        190,
        226,
        string(_snapshot.wave_reached)
    );

    draw_text(
        190,
        262,
        string(_snapshot.cpu_integrity_percent)
        + "%"
    );


    draw_set_color(_color);

    draw_line(
        54,
        310,
        310,
        310
    );


    draw_set_color(c_gray);

    draw_text(
        54,
        330,
        "RESULT"
    );


    draw_set_color(c_white);

    draw_text_ext(
        54,
        356,
        _result.reason,
        18,
        256
    );


    // ========================================================================
    // PERFORMANCE SUMMARY
    // ========================================================================

    var _summary_x = 360;
    var _summary_y = 112;
    var _card_gap = 12;

    var _summary_right =
        _gui_width - 330;

    var _card_width =
        (
            _summary_right
            - _summary_x
            - (_card_gap * 2)
        )
        / 3;

    var _card_height = 90;


    draw_set_color(c_aqua);

    draw_text(
        _summary_x,
        88,
        "PERFORMANCE SUMMARY"
    );


    scr_level_result_stat_card_draw(
        _summary_x,
        _summary_y,
        _card_width,
        _card_height,
        "Enemies Defeated",
        _snapshot.enemies_defeated,
        _color,
        _ease
    );

    scr_level_result_stat_card_draw(
        _summary_x + _card_width + _card_gap,
        _summary_y,
        _card_width,
        _card_height,
        "Towers Placed",
        _snapshot.towers_placed,
        c_aqua,
        _ease
    );

    scr_level_result_stat_card_draw(
        _summary_x + ((_card_width + _card_gap) * 2),
        _summary_y,
        _card_width,
        _card_height,
        "Structures Built",
        _snapshot.structures_placed,
        c_aqua,
        _ease
    );


    scr_level_result_stat_card_draw(
        _summary_x,
        _summary_y + _card_height + _card_gap,
        _card_width,
        _card_height,
        "Player Kills",
        _snapshot.player_kills,
        c_yellow,
        _ease
    );

    scr_level_result_stat_card_draw(
        _summary_x + _card_width + _card_gap,
        _summary_y + _card_height + _card_gap,
        _card_width,
        _card_height,
        "Tower Kills",
        _snapshot.tower_kills,
        c_yellow,
        _ease
    );

    scr_level_result_stat_card_draw(
        _summary_x + ((_card_width + _card_gap) * 2),
        _summary_y + _card_height + _card_gap,
        _card_width,
        _card_height,
        "Structures Remaining",
        _snapshot.structures_remaining,
        c_lime,
        _ease
    );


    // ========================================================================
    // ECONOMY SUMMARY
    // ========================================================================

    var _economy_y =
        _summary_y
        + ((_card_height + _card_gap) * 2)
        + 30;


    draw_set_color(c_aqua);

    draw_text(
        _summary_x,
        _economy_y,
        "ECONOMY"
    );


    draw_set_color(c_gray);

    draw_text(
        _summary_x,
        _economy_y + 42,
        "CREDITS EARNED"
    );

    draw_text(
        _summary_x,
        _economy_y + 78,
        "CREDITS REMAINING"
    );


    draw_set_color(c_white);

    draw_text(
        _summary_x + 190,
        _economy_y + 42,
        string(_snapshot.credits_earned)
    );

    draw_text(
        _summary_x + 190,
        _economy_y + 78,
        string(_snapshot.credits_remaining)
    );


    draw_set_color(_color);

    draw_line(
        _summary_x,
        _economy_y + 116,
        _summary_right,
        _economy_y + 116
    );


    draw_set_color(c_gray);

    draw_text(
        _summary_x,
        _economy_y + 138,
        "FUTURE ANALYTICS"
    );


    draw_set_color(c_white);

    draw_text_ext(
        _summary_x,
        _economy_y + 166,
        "DAMAGE, RESOURCE LOGISTICS, TOP TOWER, ENEMY BREAKDOWN AND CAMPAIGN REWARDS",
        18,
        _summary_right - _summary_x
    );


    // ========================================================================
    // ACTIONS
    // ========================================================================

    draw_set_color(_color);

    draw_text(
        _gui_width - 284,
        _gui_height - 326,
        "MISSION ACTIONS"
    );


    var _buttons =
        _hud.hud.result_buttons;


    scr_hud_button_draw(_buttons.restart);
    scr_hud_button_draw(_buttons.next);
    scr_hud_button_draw(_buttons.menu);
    scr_hud_button_draw(_buttons.exit);


    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    return true;
}

/// @description Returns whether the required authored wave has been completely defeated.

function scr_level_result_required_wave_clear(_required_wave)
{
    if (_required_wave <= 0)
        return false;


    // Check enemies from the required wave that have not spawned yet.

    var _spawner =
        global.vtd_level.entities.spawner;

    if (instance_exists(_spawner))
    {
        var _queue =
            _spawner.spawner.queue;

        for (var i = 0; i < array_length(_queue); ++i)
        {
            var _entry = _queue[i];

            if (
                variable_struct_exists(_entry, "major_wave_number")
                && _entry.major_wave_number == _required_wave
            )
            {
                return false;
            }
        }
    }


    // Check living enemies belonging to the required wave.

    var _enemy_count =
        instance_number(o_enemy);

    for (var i = 0; i < _enemy_count; ++i)
    {
        var _enemy =
            instance_find(o_enemy, i);

        if (
            instance_exists(_enemy)
            && variable_instance_exists(_enemy, "major_wave_number")
            && _enemy.major_wave_number == _required_wave
            && _enemy.EnemyState != EnemyState.DEAD
        )
        {
            return false;
        }
    }


    return true;
}