/// @description Initializes one enemy's reusable stealth runtime.

function scr_enemy_stealth_initialize(_enemy)
{
    if (!instance_exists(_enemy))
        return false;


    _enemy.stealth =
    {
        // Permanent stealth supplied by EnemyModifier.STEALTHED.

        modifier:
            scr_enemy_modifier_has(
                _enemy,
                EnemyModifier.STEALTHED
            ),

        // Temporary stealth supplied by a future cloaking field.

        field:
        {
            active: false,
            source: noone,
            remaining_seconds: 0
        },

        // Detection temporarily overrides every stealth source.

        reveal:
        {
            active: false,
            remaining_seconds: 0
        },

        reveal_range: 192,
        reveal_duration_seconds: 2,

        alpha:
        {
            cloaked: 0.18,
            current: 1
        }
    };


    return true;
}


/// @description Returns whether an enemy currently possesses stealth.

function scr_enemy_stealth_available(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (!variable_instance_exists(_enemy, "stealth"))
        return false;

    if (!is_struct(_enemy.stealth))
        return false;


    return (
        _enemy.stealth.modifier
        || _enemy.stealth.field.active
    );
}


/// @description Returns whether an enemy is currently concealed.

function scr_enemy_stealth_cloaked(_enemy)
{
    if (!scr_enemy_stealth_available(_enemy))
        return false;


    return !_enemy.stealth.reveal.active;
}


/// @description Temporarily reveals one cloaked enemy.

function scr_enemy_stealth_reveal(
    _enemy,
    _duration_seconds = 2
)
{
    if (!instance_exists(_enemy))
        return false;

    if (!scr_enemy_stealth_available(_enemy))
        return false;


    var _reveal =
        _enemy.stealth.reveal;


    _reveal.active = true;

    _reveal.remaining_seconds =
        max(
            _reveal.remaining_seconds,
            _duration_seconds
        );


    return true;
}


/// @description Temporarily grants stealth from an external cloaking source.

function scr_enemy_stealth_field_apply(
    _enemy,
    _source,
    _duration_seconds = 0.5
)
{
    if (!instance_exists(_enemy))
        return false;


    var _field =
        _enemy.stealth.field;


    _field.active = true;
    _field.source = _source;

    _field.remaining_seconds =
        max(
            _field.remaining_seconds,
            _duration_seconds
        );


    return true;
}


/// @description Updates one enemy's stealth, reveal and visual state.

function scr_enemy_stealth_update(_enemy)
{
    if (!instance_exists(_enemy))
        return false;

    if (!is_struct(_enemy.stealth))
        return false;


    var _stealth =
        _enemy.stealth;

    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );

    var _delta =
        1 / _fps;


    // ========================================================================
    // TEMPORARY CLOAKING FIELD
    // ========================================================================

    if (_stealth.field.active)
    {
        _stealth.field.remaining_seconds =
            max(
                0,
                _stealth.field.remaining_seconds
                - _delta
            );


        if (_stealth.field.remaining_seconds <= 0)
        {
            _stealth.field.active = false;
            _stealth.field.source = noone;
        }
    }


    // ========================================================================
    // TEMPORARY REVEAL
    // ========================================================================

    if (_stealth.reveal.active)
    {
        _stealth.reveal.remaining_seconds =
            max(
                0,
                _stealth.reveal.remaining_seconds
                - _delta
            );


        if (_stealth.reveal.remaining_seconds <= 0)
        {
            _stealth.reveal.active = false;
        }
    }


    // ========================================================================
    // PROXIMITY DETECTION
    // ========================================================================
    //
    // This expensive positional work is staggered.
    // Enemies without stealth skip it immediately.

    if (
        scr_enemy_stealth_available(_enemy)
        && IFRAMES_10
    )
    {
        var _reveal_range =
            _stealth.reveal_range;

        var _player =
            global.vtd_level.entities.player;

        var _cpu =
            global.vtd_level.entities.cpu;


        if (
            instance_exists(_player)
            && point_distance(
                _enemy.x,
                _enemy.y,
                _player.x,
                _player.y
            )
            <= _reveal_range
        )
        {
            scr_enemy_stealth_reveal(
                _enemy,
                _stealth.reveal_duration_seconds
            );
        }


        if (
            instance_exists(_cpu)
            && point_distance(
                _enemy.x,
                _enemy.y,
                _cpu.x,
                _cpu.y
            )
            <= _reveal_range
        )
        {
            scr_enemy_stealth_reveal(
                _enemy,
                _stealth.reveal_duration_seconds
            );
        }
    }


    // ========================================================================
    // VISUAL ALPHA
    // ========================================================================

    var _target_alpha =
        scr_enemy_stealth_cloaked(_enemy)
        ? _stealth.alpha.cloaked
        : 1;


    _stealth.alpha.current =
        lerp(
            _stealth.alpha.current,
            _target_alpha,
            0.12
        );


    return true;
}