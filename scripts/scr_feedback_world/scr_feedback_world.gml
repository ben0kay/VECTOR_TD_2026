/// @description Reusable floating world-space feedback text.

/// @description Creates one floating feedback message.
function scr_feedback_world_text_create(
    _world_x,
    _world_y,
    _movement_layer,
    _text,
    _color,
    _options = undefined
)
{
    if (!scr_fog_position_visible(_world_x, _world_y))
        return noone;

    return instance_create_layer(
        _world_x,
        _world_y,
        scr_layer_effect_get(
            _movement_layer
        ),
        o_feedback_world,
        {
            feedback_text:
                string(_text),

            feedback_color:
                _color,

            feedback_options:
                _options
        }
    );
}


/// @description Initializes one floating feedback message.
function scr_feedback_world_initialize(_feedback)
{
    if (!instance_exists(_feedback))
        return false;

    if (
        !variable_instance_exists(
            _feedback,
            "feedback_text"
        )
    )
    {
        return false;
    }

    if (
        !variable_instance_exists(
            _feedback,
            "feedback_color"
        )
    )
    {
        return false;
    }


    var _duration_seconds = 0.7;
    var _rise_distance = 26;

    var _alpha_start = 1;
    var _alpha_end = 0;

    var _scale_start = 1;
    var _scale_end = 0.85;

    var _outline_color = c_black;
    var _outline_alpha = 0.85;


    if (
        is_struct(
            _feedback.feedback_options
        )
    )
    {
        var _options =
            _feedback.feedback_options;

        if (
            variable_struct_exists(
                _options,
                "duration_seconds"
            )
        )
        {
            _duration_seconds =
                max(
                    0.01,
                    _options.duration_seconds
                );
        }

        if (
            variable_struct_exists(
                _options,
                "rise_distance"
            )
        )
        {
            _rise_distance =
                max(
                    0,
                    _options.rise_distance
                );
        }

        if (
            variable_struct_exists(
                _options,
                "scale_start"
            )
        )
        {
            _scale_start =
                max(
                    0.01,
                    _options.scale_start
                );
        }

        if (
            variable_struct_exists(
                _options,
                "scale_end"
            )
        )
        {
            _scale_end =
                max(
                    0.01,
                    _options.scale_end
                );
        }

        if (
            variable_struct_exists(
                _options,
                "outline_color"
            )
        )
        {
            _outline_color =
                _options.outline_color;
        }
    }


    _feedback.feedback =
    {
        text:
            _feedback.feedback_text,

        color:
            _feedback.feedback_color,

        outline_color:
            _outline_color,

        outline_alpha:
            _outline_alpha,

        age: 0,

        duration_seconds:
            _duration_seconds,

        rise_distance:
            _rise_distance,

        alpha_start:
            _alpha_start,

        alpha_end:
            _alpha_end,

        scale_start:
            _scale_start,

        scale_end:
            _scale_end
    };

    return true;
}


/// @description Updates one floating feedback message.
function scr_feedback_world_update(_feedback)
{
    if (!instance_exists(_feedback))
        return false;

    var _fps =
        max(
            1,
            game_get_speed(gamespeed_fps)
        );

    _feedback.feedback.age +=
        1 / _fps;

    if (
        _feedback.feedback.age
        >= _feedback.feedback.duration_seconds
    )
    {
        instance_destroy(_feedback);
        return false;
    }

    return true;
}


/// @description Draws one floating feedback message.
function scr_feedback_world_draw(_feedback)
{
    if (!instance_exists(_feedback))
        return false;

    var _feedback_data =
        _feedback.feedback;

    var _progress =
        clamp(
            _feedback_data.age
            / _feedback_data.duration_seconds,
            0,
            1
        );

    var _rise_progress =
        1
        - power(
            1 - _progress,
            2
        );

    var _draw_y =
        _feedback.y
        - (
            _feedback_data.rise_distance
            * _rise_progress
        );

    var _alpha =
        lerp(
            _feedback_data.alpha_start,
            _feedback_data.alpha_end,
            _progress
        );

    var _scale =
        lerp(
            _feedback_data.scale_start,
            _feedback_data.scale_end,
            _progress
        );


    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);


    // Outline keeps feedback readable over bright combat effects.

    draw_set_alpha(
        _alpha
        * _feedback_data.outline_alpha
    );

    draw_set_color(
        _feedback_data.outline_color
    );

    draw_text_transformed(
        _feedback.x - 1,
        _draw_y,
        _feedback_data.text,
        _scale,
        _scale,
        0
    );

    draw_text_transformed(
        _feedback.x + 1,
        _draw_y,
        _feedback_data.text,
        _scale,
        _scale,
        0
    );

    draw_text_transformed(
        _feedback.x,
        _draw_y - 1,
        _feedback_data.text,
        _scale,
        _scale,
        0
    );

    draw_text_transformed(
        _feedback.x,
        _draw_y + 1,
        _feedback_data.text,
        _scale,
        _scale,
        0
    );


    draw_set_alpha(_alpha);
    draw_set_color(_feedback_data.color);

    draw_text_transformed(
        _feedback.x,
        _draw_y,
        _feedback_data.text,
        _scale,
        _scale,
        0
    );

    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    return true;
}