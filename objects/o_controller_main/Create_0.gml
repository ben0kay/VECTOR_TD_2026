/// @description Initializes persistent Vector TD state.

if (instance_number(object_index) > 1)
{
    instance_destroy();
    exit;
}

persistent =
    true;

scr_game_initialize();