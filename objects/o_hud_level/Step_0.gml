/// @description Processes level HUD input and animation.

if (!variable_global_exists("vtd_level")) exit;
if (!is_struct(global.vtd_level)) exit;

scr_hud_alert_update(id);
scr_hud_notification_update(id);
scr_hud_resource_feedback_update(id);

if (
    variable_struct_exists(
        global.vtd_level,
        "result"
    )
    && global.vtd_level.result.active
)
{
    hud.selection.target =
        noone;

    hud.build_menu.open =
        false;

    hud.debug_menu.open =
        false;

    scr_level_result_hud_update(id);

    exit;
}

if (
    instance_exists(hud.selection.target)
    && hud.selection.target.BuildingState
    == BuildingState.DESTROYED
)
{
    hud.selection.target =
        noone;
}

scr_debug_menu_update(id);

if (!hud.debug_menu.open)
{
    scr_hud_minimap_update(id);

    scr_hud_build_menu_update(id);
    scr_hud_build_menu_hover_update(id);

    scr_hud_selection_panel_update(id);
    scr_hud_selection_update(id);
}

scr_hud_vector_window_update(id);