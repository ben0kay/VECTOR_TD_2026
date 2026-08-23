/// @description Processes level HUD input and animation.

if (!variable_global_exists("vtd_level"))
    exit;

if (!is_struct(global.vtd_level))
    exit;


if (
    instance_exists(hud.selection.target)
    && hud.selection.target.BuildingState
        == BuildingState.DESTROYED
)
{
    hud.selection.target = noone;
}


scr_hud_selection_update(id);
scr_hud_vector_window_update(id);
scr_hud_alert_update(id);