FUNCTION CREATE_CIRC_NODE {

    // create maneuver node to circularize orbit after initial ascent

    PARAMETER targetOrbit.

    // calculate surface gravity
    // SurfaceGravity = GravitationalConstant * MassOfBody / RadiusOfBody^2
    // (GravitationalConstant * MassOfBody) is also known as the Gravitational Parameter - available in kOS as BODY:MU
    LOCAL srfcGravity IS ( BODY:MU/BODY:RADIUS^2 ).

    // calculate orbital speed for desired orbit
    // OrbitalSpeed = RadiusOfBody x SQRT ( Surface Gravity / ( Radius Of Body + Desired Orbit) )
    LOCAL orbitalSpeed IS ( BODY:RADIUS * SQRT(srfcGravity/(BODY:RADIUS+targetOrbit)) ).

    // calculate speed at current apoapsis
    // SpeedAtApoapsis = SQRT ( GravitationalConstant * MassOfBody * ( 2/RadiusOfShipsOrbit - 1/SemiMajorAxisOfShipsOrbit ) )
    // (GravitationalConstant * MassOfBody) is also known as the Gravitational Parameter - available in kOS as BODY:MU
    LOCAL speedAtApo IS SQRT ( BODY:MU * ( 2/(BODY:RADIUS+SHIP:APOAPSIS) - 1/SHIP:ORBIT:SEMIMAJORAXIS ) ).

    // calculate deltaV required to circularize
    // {deltaV to Circularize} = {Orbital Speed of Desired Orbit} - {Speed at Apoapsis of Current Orbit}
    LOCAL dvCirc IS orbitalSpeed-speedAtApo.

    // create maneuver node to circularize orbit
    LOCAL circNode IS NODE ( TIME:SECONDS+ETA:APOAPSIS, 0, 0, dvCirc).
    ADD circNode.

    PRINT "Circularization maneuver node created.".

    RETURN circNode.

}