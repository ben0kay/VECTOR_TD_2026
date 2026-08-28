/// @description Draws one generic resource node.


// ============================================================================
// STAGGERED VISIBILITY
// ============================================================================
//
// Resource nodes are stationary.
//
// Instead of every node checking the camera every Draw frame,
// IFRAMES_5 spreads the checks across five frames.
//
// The previous visibility result remains cached between checks.

if (IFRAMES_5)
{
    visibility.on_screen =
        scr_culling_check_point_fast(
            x,
            y,
            64
        );
}


if (!visibility.on_screen)
    exit;


// ============================================================================
// DRAW
// ============================================================================

scr_resource_node_draw(id);