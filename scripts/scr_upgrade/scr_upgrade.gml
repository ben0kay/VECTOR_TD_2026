/// @description Upgrade runtime ownership for profile and current-level upgrades.


/// @description Creates one owned-upgrade collection.
function scr_upgrade_collection_create()
{
    return
    {
        keys: []
    };
}


/// @description Creates the permanent campaign/profile upgrade runtime.
function scr_upgrade_profile_runtime_create()
{
    return
    {
        owned:
            scr_upgrade_collection_create()
    };
}


/// @description Creates the current level's temporary upgrade runtime.
function scr_upgrade_level_runtime_create()
{
    return
    {
        owned:
            scr_upgrade_collection_create()
    };
}