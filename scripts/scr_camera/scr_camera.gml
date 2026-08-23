/// @description Camera initialization, input, movement, zoom, and shake.


/// @description Initializes one level camera.

function scr_camera_initialize(_camera)
{
    if (!instance_exists(_camera))
        return false;

    if (!variable_global_exists("vtd"))
        return false;

    if (!is_struct(global.vtd))
        return false;

    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;


    var _view_width =
        global.vtd.settings.view_width;

    var _view_height =
        global.vtd.settings.view_height;


    var _player =
        global.vtd_level.entities.player;

    var _start_x =
        0;

    var _start_y =
        0;


    if (instance_exists(_player))
    {
        _start_x =
            _player.x
            - (_view_width * 0.5);

        _start_y =
            _player.y
            - (_view_height * 0.5);
    }


    // CameraState is a direct global, matching the original Vector style.

    global.CameraState =
        CameraState.FOLLOW_PLAYER;


    _camera.camera_runtime =
    {
        id:
            camera_create_view(
                _start_x,
                _start_y,
                _view_width,
                _view_height,
                0,
                noone,
                -1,
                -1,
                -1,
                -1
            ),

        base_view:
        {
            width:
                _view_width,

            height:
                _view_height
        },

        position:
        {
            x:
                _start_x,

            y:
                _start_y
        },

        zoom:
        {
            current:
                1,

            minimum:
                0.5,

            maximum:
                2.5,

            speed:
                0.1
        },

        roaming:
        {
            move_speed:
                12
        },

        shake:
        {
            magnitude:
                0,

            remaining:
                0,

            duration:
                0
        }
    };


    // ========================================================================
    // VIEWPORT
    // ========================================================================

    view_enabled =
        true;

    view_visible[0] =
        true;

    view_camera[0] =
        _camera.camera_runtime.id;

    view_xport[0] =
        0;

    view_yport[0] =
        0;

    view_wport[0] =
        _view_width;

    view_hport[0] =
        _view_height;


    global.vtd_level.entities.camera =
        _camera;


    show_debug_message(
        "VECTOR TD 2026 - CAMERA INITIALIZED"
    );


    return true;
}


/// @description Toggles between following the player and roaming freely.

function scr_camera_mode_toggle(_camera)
{
    if (!instance_exists(_camera))
        return false;

    if (!is_struct(_camera.camera_runtime))
        return false;


    switch (global.CameraState)
    {
        case CameraState.FOLLOW_PLAYER:
        {
            global.CameraState =
                CameraState.ROAMING;
        }
        break;


        case CameraState.ROAMING:
        {
            global.CameraState =
                CameraState.FOLLOW_PLAYER;
        }
        break;
    }


    return true;
}

/// @description Updates camera zoom outside HUD-owned areas.

function scr_camera_zoom_update(_camera)
{
    if (!instance_exists(_camera))
        return false;

    if (scr_hud_pointer_blocks_world())
        return true;


    var _zoom =
        _camera.camera_runtime.zoom;


    if (mouse_wheel_up())
        _zoom.current -= _zoom.speed;

    if (mouse_wheel_down())
        _zoom.current += _zoom.speed;


    _zoom.current = clamp(
        _zoom.current,
        _zoom.minimum,
        _zoom.maximum
    );


    return true;
}


/// @description Updates the camera's desired map position.

function scr_camera_position_update(
    _camera,
    _view_width,
    _view_height
)
{
    if (!instance_exists(_camera))
        return false;

    if (!is_struct(_camera.camera_runtime))
        return false;


    var _runtime =
        _camera.camera_runtime;

    var _position =
        _runtime.position;


    switch (global.CameraState)
    {
        case CameraState.FOLLOW_PLAYER:
        {
            var _player =
                global.vtd_level.entities.player;


            if (instance_exists(_player))
            {
                _position.x =
                    _player.x
                    - (_view_width * 0.5);

                _position.y =
                    _player.y
                    - (_view_height * 0.5);
            }
        }
        break;


        case CameraState.ROAMING:
        {
            var _move_x =
                keyboard_check(vk_right)
                - keyboard_check(vk_left);

            var _move_y =
                keyboard_check(vk_down)
                - keyboard_check(vk_up);


            if (
                _move_x != 0
                && _move_y != 0
            )
            {
                var _normalizer =
                    1 / sqrt(2);

                _move_x *=
                    _normalizer;

                _move_y *=
                    _normalizer;
            }


            // Roaming movement scales with zoom so it remains comfortable
            // when viewing a larger portion of the map.

            var _move_speed =
                _runtime.roaming.move_speed
                * _runtime.zoom.current;


            _position.x +=
                _move_x * _move_speed;

            _position.y +=
                _move_y * _move_speed;
        }
        break;
    }


    // ========================================================================
    // ROOM CLAMPING
    // ========================================================================

    var _maximum_x =
        max(
            0,
            room_width - _view_width
        );

    var _maximum_y =
        max(
            0,
            room_height - _view_height
        );


    _position.x =
        clamp(
            _position.x,
            0,
            _maximum_x
        );

    _position.y =
        clamp(
            _position.y,
            0,
            _maximum_y
        );


    return true;
}

/// @description Updates and returns the current camera-shake offset.

function scr_camera_shake_update(_camera)
{
    if (!instance_exists(_camera))
    {
        return
        {
            x: 0,
            y: 0
        };
    }


    var _shake =
        _camera.camera_runtime.shake;

    var _offset_x =
        0;

    var _offset_y =
        0;


    if (_shake.remaining > 0)
    {
        _offset_x =
            random_range(
                -_shake.magnitude,
                _shake.magnitude
            );

        _offset_y =
            random_range(
                -_shake.magnitude,
                _shake.magnitude
            );


        _shake.remaining--;


        if (_shake.remaining <= 0)
        {
            _shake.remaining =
                0;

            _shake.magnitude =
                0;

            _shake.duration =
                0;
        }
    }


    return
    {
        x:
            _offset_x,

        y:
            _offset_y
    };
}


/// @description Starts a camera-shake effect.

function scr_camera_shake_start(
    _magnitude,
    _duration_frames
)
{
    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;


    var _camera =
        global.vtd_level.entities.camera;

    if (!instance_exists(_camera))
        return false;


    var _shake =
        _camera.camera_runtime.shake;


    _shake.magnitude =
        max(
            _shake.magnitude,
            _magnitude
        );

    _shake.remaining =
        max(
            _shake.remaining,
            _duration_frames
        );

    _shake.duration =
        max(
            _shake.duration,
            _duration_frames
        );


    return true;
}


/// @description Processes the complete level-camera update.

function scr_camera_update(_camera)
{
    if (!instance_exists(_camera))
        return false;

    if (!is_struct(_camera.camera_runtime))
        return false;

    if (!variable_global_exists("vtd_level"))
        return false;

    if (!is_struct(global.vtd_level))
        return false;


    if (
        keyboard_check_pressed(
            ord("C")
        )
    )
    {
        scr_camera_mode_toggle(
            _camera
        );
    }


    scr_camera_zoom_update(
        _camera
    );


    var _runtime =
        _camera.camera_runtime;

    var _view_width =
        _runtime.base_view.width
        * _runtime.zoom.current;

    var _view_height =
        _runtime.base_view.height
        * _runtime.zoom.current;


    scr_camera_position_update(
        _camera,
        _view_width,
        _view_height
    );


    var _shake_offset =
        scr_camera_shake_update(
            _camera
        );


    camera_set_view_size(
        _runtime.id,
        _view_width,
        _view_height
    );

    camera_set_view_pos(
        _runtime.id,
        _runtime.position.x
            + _shake_offset.x,

        _runtime.position.y
            + _shake_offset.y
    );


    return true;
}


/// @description Releases resources owned by one camera.

function scr_camera_cleanup(_camera)
{
    if (!instance_exists(_camera))
        return false;


    if (
        variable_instance_exists(
            _camera,
            "camera_runtime"
        )
        && is_struct(
            _camera.camera_runtime
        )
    )
    {
        var _camera_id =
            _camera.camera_runtime.id;


        if (_camera_id >= 0)
        {
            camera_destroy(
                _camera_id
            );

            _camera.camera_runtime.id =
                -1;
        }
    }


    view_visible[0] =
        false;

    view_camera[0] =
        -1;


    return true;
}