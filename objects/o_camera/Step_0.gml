/// @description Processes camera behaviour.

if (
    !variable_global_exists(
        "vtd_level"
    )
)
{
    exit;
}

if (!is_struct(global.vtd_level))
    exit;

scr_camera_update(id);