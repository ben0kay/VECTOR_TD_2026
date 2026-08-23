/// @description Initializes one generic temporary effect.

if (!scr_effect_initialize(id))
{
    instance_destroy();
    exit;
}