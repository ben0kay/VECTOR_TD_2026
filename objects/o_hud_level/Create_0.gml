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
    },

    alerts:
    {
        queue: [],
        active: undefined,

        width: 580,
        height: 78,

        opening_speed: 0.09,
        closing_speed: 0.11
    }
};


hud.build_menu =
    scr_hud_build_menu_create();

scr_hud_build_menu_cards_rebuild(id);

global.vtd_level.entities.hud = id;


show_debug_message(
    "VECTOR TD 2026 - LEVEL HUD INITIALIZED"
);