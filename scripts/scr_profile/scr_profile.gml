/// @description Commander profile creation, loading, saving, and slot summaries.


/// ============================================================================
/// CONFIGURATION
/// ============================================================================

function scr_profile_slot_count_get()
{
    return 3;
}


function scr_profile_filename_get(_slot)
{
    return
        "vector_td_profile_"
        + string(_slot)
        + ".sav";
}


/// ============================================================================
/// PROFILE DATA
/// ============================================================================

function scr_profile_create(
    _slot,
    _commander_name
)
{
    return
    {
        version: 1,

        slot:
            _slot,

        commander_name:
            string_upper(
                string_trim(
                    _commander_name
                )
            ),

        created_timestamp:
            date_current_datetime(),

        last_played_timestamp:
            date_current_datetime(),

        campaign:
        {
            levels_completed: [],
            highest_level_index: 0
        },

        statistics:
        {
            kills_total: 0,
            buildings_constructed_total: 0
        },

        upgrades:
        {
            owned: []
        }
    };
}


/// @description Ensures optional fields exist when loading an older profile.
function scr_profile_migrate(_profile)
{
    if (!is_struct(_profile))
        return false;

    if (!variable_struct_exists(_profile, "version"))
        _profile.version = 1;
	
	if (!variable_struct_exists(_profile, "created_timestamp"))
	{
	    _profile.created_timestamp =
	        date_current_datetime();
	}

	if (!variable_struct_exists(_profile, "last_played_timestamp"))
	{
	    _profile.last_played_timestamp =
	        date_current_datetime();
	}

    if (!variable_struct_exists(_profile, "campaign"))
    {
        _profile.campaign =
        {
            levels_completed: [],
            highest_level_index: 0
        };
    }

    if (!variable_struct_exists(_profile, "statistics"))
    {
        _profile.statistics =
        {
            kills_total: 0,
            buildings_constructed_total: 0
        };
    }

    if (!variable_struct_exists(_profile, "upgrades"))
    {
        _profile.upgrades =
        {
            owned: []
        };
    }

    if (
        !variable_struct_exists(
            _profile.upgrades,
            "owned"
        )
    )
    {
        _profile.upgrades.owned = [];
    }

    return true;
}


/// @description Validates essential profile fields.
function scr_profile_valid(_profile)
{
    if (!is_struct(_profile))
        return false;

    if (!variable_struct_exists(_profile, "version"))
        return false;

    if (!variable_struct_exists(_profile, "slot"))
        return false;

    if (!variable_struct_exists(_profile, "commander_name"))
        return false;

    if (
        string_length(
            string_trim(
                _profile.commander_name
            )
        )
        <= 0
    )
    {
        return false;
    }

    return true;
}


/// ============================================================================
/// DISK ACCESS
/// ============================================================================

/// @description Saves the currently loaded commander profile.
function scr_profile_save()
{
    if (!variable_global_exists("vtd"))
        return false;

    if (!is_struct(global.vtd))
        return false;

    if (!is_struct(global.vtd.profile))
        return false;

    if (!scr_profile_valid(global.vtd.profile))
        return false;


    global.vtd.profile.last_played_timestamp =
        date_current_datetime();

    var _json =
        json_stringify(
            global.vtd.profile
        );

    var _buffer =
        buffer_create(
            string_byte_length(_json) + 1,
            buffer_fixed,
            1
        );

    buffer_write(
        _buffer,
        buffer_string,
        _json
    );

    buffer_save(
        _buffer,
        scr_profile_filename_get(
            global.vtd.profile.slot
        )
    );

    buffer_delete(_buffer);

    show_debug_message(
        "PROFILE SAVED: "
        + global.vtd.profile.commander_name
    );

    return true;
}


/// @description Loads a saved commander profile into global.vtd.profile.
function scr_profile_load(_slot)
{
    var _filename =
        scr_profile_filename_get(
            _slot
        );

    if (!file_exists(_filename))
        return false;


    var _buffer =
        buffer_load(_filename);

    var _json =
        buffer_read(
            _buffer,
            buffer_string
        );

    buffer_delete(_buffer);

    var _profile =
        json_parse(_json);

    if (
    !scr_profile_migrate(
        _profile
    )
	)
	{
	    return false;
	}

	if (!scr_profile_valid(_profile))
	    return false;

    _profile.slot =
        _slot;

    global.vtd.profile =
        _profile;

    show_debug_message(
        "PROFILE LOADED: "
        + _profile.commander_name
    );

    return true;
}


/// @description Creates, activates, and saves one new commander profile.
function scr_profile_new(
    _slot,
    _commander_name
)
{
    var _name =
        string_trim(
            _commander_name
        );

    if (string_length(_name) <= 0)
        return false;

    global.vtd.profile =
        scr_profile_create(
            _slot,
            _name
        );

    return scr_profile_save();
}


/// @description Reads profile-card data without changing the active profile.
function scr_profile_slot_summary_get(_slot)
{
    var _filename =
        scr_profile_filename_get(
            _slot
        );

    if (!file_exists(_filename))
    {
        return
        {
            occupied: false,
            slot: _slot
        };
    }


    var _buffer =
        buffer_load(_filename);

    var _json =
        buffer_read(
            _buffer,
            buffer_string
        );

    buffer_delete(_buffer);

	    var _profile =
	    json_parse(_json);

	if (
	    !scr_profile_migrate(
	        _profile
	    )
	    || !scr_profile_valid(
	        _profile
	    )
	)
	{
	    return
	    {
	        occupied: false,
	        slot: _slot,
	        corrupted: true
	    };
	}

    return
    {
        occupied: true,
        slot: _slot,

        commander_name:
            _profile.commander_name,

        last_played_timestamp:
            _profile.last_played_timestamp
    };
}