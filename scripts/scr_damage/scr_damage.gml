/// @description Shared Vector TD damage packet functions.


/// @description Creates one damage packet.

function scr_damage_create(
    _amount,
    _source,
    _source_type
)
{
    return
    {
        amount:
            max(
                0,
                _amount
            ),

        source:
            _source,

        source_type:
            _source_type
    };
}