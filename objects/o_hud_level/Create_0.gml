/// @description Initializes the gameplay-level HUD.

if (instance_number(object_index) > 1)
{
    instance_destroy();
    exit;
}

hud =
{
	debug: 
	{
		hide: false
	},
	
    selection:
    {
        target: noone
    },

    top:
    {
        height: 104,
        row_height: 52,
        color: c_aqua,
        background_alpha: 0.92
    },

    bottom:
    {
        height: 220,
        inspector_height: 300,
        inspector_width: 500,
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
    },

    notifications:
    {
        active: [],
        start_x: 24,
        target_x: 24,
        start_y: 386,
        width: 390,
        height: 44,
        spacing: 50,
        maximum_visible: 5,
        opening_speed: 0.14,
        closing_speed: 0.16,
        vertical_speed: 0.14,
        background_alpha: 0.82
    },

    resource_feedback:
    {
        resource_key: "",
        amount: 0,
        remaining: 0,
        duration: 1.25
    }
};

hud.minimap =
    scr_hud_minimap_create();
	
hud.chassis_select =
    scr_hud_chassis_select_create();

hud.build_menu =
    scr_hud_build_menu_create();

hud.build_menu.hovered_key =
    "";

hud.selection_panel =
    scr_hud_selection_panel_create();

hud.refinery_controls =
    scr_hud_refinery_controls_create();

hud.fabricator_controls =
    scr_hud_fabricator_controls_create();

hud.debug_menu =
    scr_debug_menu_create();

hud.result_buttons =
    scr_level_result_hud_create();

scr_hud_build_menu_cards_rebuild(id);
scr_level_result_initialize();

global.vtd_level.entities.hud =
    id;

show_debug_message(
    "VECTOR TD 2026 - LEVEL HUD INITIALIZED"
);