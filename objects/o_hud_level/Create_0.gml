/// @description Initializes the gameplay-level HUD.

if (instance_number(object_index) > 1)
{
    instance_destroy();
    exit;
}


hud =
{
    selection:
    {
        target: noone
    },

    top:
    {
        height: 44,
        color: c_aqua,
        background_alpha: 0.92
    },

    bottom:
    {
        height: 220,
        inspector_width: 400,
        color: c_aqua,
        background_alpha: 0.92
    },

    window:
    {
        width: 380,
        height: 220,

        color: c_aqua,
        background_alpha: 0.88,

        line_progress: 0,
        panel_progress: 0,

        line_speed: 0.14,
        panel_speed: 0.12
    }
};


show_debug_message(
    "VECTOR TD 2026 - LEVEL HUD INITIALIZED"
);