/// @description Simple level camera.

function scr_camera_initialize(_camera)
{
    if (!instance_exists(_camera))
        return false;


    var _view_width =
        global.vtd.settings.view_width;

    var _view_height =
        global.vtd.settings.view_height;

    var _player =
        global.vtd_level.entities.player;


    _camera.camera_main =
        camera_create_view(
            0,
            0,
            _view_width,
            _view_height,
            0,
            noone,
            -1,
            -1,
            -1,
            -1
        );


    _camera.base_width =
        _view_width;

    _camera.base_height =
        _view_height;


    _camera.zoom_current =
        1;

    _camera.zoom_min =
        0.5;

    _camera.zoom_max =
        2.5;

    _camera.zoom_speed =
        0.1;


    _camera.cam_x =
        0;

    _camera.cam_y =
        0;


    if (instance_exists(_player))
    {
        _camera.cam_x =
            _player.x
            - (_view_width * 0.5);

        _camera.cam_y =
            _player.y
            - (_view_height * 0.5);
    }


    _camera.roam_speed =
        12;


    _camera.shake_magnitude =
        0;

    _camera.shake_remaining =
        0;


    global.CameraState =
        CameraState.FOLLOW_PLAYER;


    view_enabled =
        true;

    view_visible[0] =
        true;

    view_camera[0] =
        _camera.camera_main;

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


    return true;
}



function scr_camera_update(_camera)
{
    var _player =
        global.vtd_level.entities.player;


    // Toggle follow / roaming.

    if (keyboard_check_pressed(ord("C")))
    {
        if (
            global.CameraState
            == CameraState.FOLLOW_PLAYER
        )
        {
            global.CameraState =
                CameraState.ROAMING;
        }
        else
        {
            global.CameraState =
                CameraState.FOLLOW_PLAYER;
        }
    }


    // Zoom.

    if (!scr_hud_pointer_blocks_world())
    {
        if (mouse_wheel_up())
        {
            _camera.zoom_current -=
                _camera.zoom_speed;
        }

        if (mouse_wheel_down())
        {
            _camera.zoom_current +=
                _camera.zoom_speed;
        }

        _camera.zoom_current =
            clamp(
                _camera.zoom_current,
                _camera.zoom_min,
                _camera.zoom_max
            );
    }


    var _view_width =
        _camera.base_width
        * _camera.zoom_current;

    var _view_height =
        _camera.base_height
        * _camera.zoom_current;


    // Position.

    switch (global.CameraState)
    {
        case CameraState.FOLLOW_PLAYER:
        {
            if (instance_exists(_player))
            {
                _camera.cam_x =
                    _player.x
                    - (_view_width * 0.5);

                _camera.cam_y =
                    _player.y
                    - (_view_height * 0.5);
            }
        }
        break;


        case CameraState.ROAMING:
        {
            if (keyboard_check(vk_right))
                _camera.cam_x += _camera.roam_speed;

            if (keyboard_check(vk_left))
                _camera.cam_x -= _camera.roam_speed;

            if (keyboard_check(vk_down))
                _camera.cam_y += _camera.roam_speed;

            if (keyboard_check(vk_up))
                _camera.cam_y -= _camera.roam_speed;
        }
        break;
    }


    // Clamp.

    _camera.cam_x =
        clamp(
            _camera.cam_x,
            0,
            max(
                0,
                room_width - _view_width
            )
        );

    _camera.cam_y =
        clamp(
            _camera.cam_y,
            0,
            max(
                0,
                room_height - _view_height
            )
        );


    // Shake only does work while actually active.

    var _shake_x =
        0;

    var _shake_y =
        0;


    if (_camera.shake_remaining > 0)
    {
        _shake_x =
            random_range(
                -_camera.shake_magnitude,
                _camera.shake_magnitude
            );

        _shake_y =
            random_range(
                -_camera.shake_magnitude,
                _camera.shake_magnitude
            );


        _camera.shake_remaining--;


        if (_camera.shake_remaining <= 0)
        {
            _camera.shake_remaining =
                0;

            _camera.shake_magnitude =
                0;
        }
    }


    camera_set_view_size(
        _camera.camera_main,
        _view_width,
        _view_height
    );


    camera_set_view_pos(
        _camera.camera_main,
        _camera.cam_x + _shake_x,
        _camera.cam_y + _shake_y
    );


    return true;
}



function scr_camera_shake_start(
    _magnitude,
    _duration_frames
)
{
    var _camera =
        global.vtd_level.entities.camera;

    if (!instance_exists(_camera))
        return false;


    _camera.shake_magnitude =
        max(
            _camera.shake_magnitude,
            _magnitude
        );

    _camera.shake_remaining =
        max(
            _camera.shake_remaining,
            _duration_frames
        );


    return true;
}



function scr_camera_cleanup(_camera)
{
    if (!instance_exists(_camera))
        return false;


    if (_camera.camera_main >= 0)
    {
        camera_destroy(
            _camera.camera_main
        );

        _camera.camera_main =
            -1;
    }


    view_visible[0] =
        false;

    view_camera[0] =
        -1;


    return true;
}