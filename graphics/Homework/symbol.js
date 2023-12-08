var gl, program;
var points = [];
// constants for drawing the circle
const CIRCLE_NUM_POINTS     = 100;                  // number of sides for the polygon that will approximate the circle (should be high)
const CIRCLE_CENTER         = vec2(0.0, 0.0);       // center of the circle
const CIRCLE_RADIUS         = 1.0;                  // radius of the circle
// constants for drawing the star
const STAR_NUM_POINTS       = 6;                    // number of convex points on the star (expected to be an integer)
const STAR_CENTER           = CIRCLE_CENTER;        // center of the star
const STAR_INNER_RADIUS     = 0.5;                  // radius of invisible circle inscribed in the star
const STAR_OUTER_RADIUS     = CIRCLE_RADIUS;        // radius of invisible circle that circumscribes the star
const STAR_ROTATION_PHASE   = 0.0;                  // clockwise rotation from default, in radians

function main() {
    var canvas = document.getElementById( "gl-canvas" );
    
    gl = WebGLUtils.setupWebGL( canvas );
    if ( !gl ) { console.log( "WebGL isn't available" ); return; }

    generate_circle_points(CIRCLE_CENTER, CIRCLE_RADIUS, CIRCLE_NUM_POINTS);
    generate_star_points(STAR_NUM_POINTS, STAR_CENTER, STAR_INNER_RADIUS, STAR_OUTER_RADIUS, STAR_ROTATION_PHASE);
    console.log("after generating points");

    //  Configure WebGL
    gl.viewport( 0, 0, canvas.width, canvas.height );
    gl.clearColor( 1.0, 1.0, 1.0, 1.0 );
    
    //  Load shaders and initialize attribute buffers
    program = initShaders( gl, "vertex-shader", "fragment-shader" );
    if (!program) { console.log("Failed to intialize shaders."); return; }
    gl.useProgram( program );
    
    // Load the data into the GPU
    var bufferId = gl.createBuffer();
    gl.bindBuffer( gl.ARRAY_BUFFER, bufferId );
    gl.bufferData( gl.ARRAY_BUFFER, flatten(points), gl.STATIC_DRAW );

    // Associate out shader variables with our data buffer
    var vPosition = gl.getAttribLocation( program, "vPosition" );
    gl.vertexAttribPointer( vPosition, 2, gl.FLOAT, false, 0, 0 );
    gl.enableVertexAttribArray( vPosition );

    render();
}

// PUSH POINTS TO MAKE A CIRCLE (really a regular n-gon) USING gl.LINE_LOOP
function generate_circle_points(center, radius, polygonal_sides) {
    // incremental angle between consecutive points
    let delta_theta  = (2.0 * Math.PI) / polygonal_sides;
    for  (var i=0; i < polygonal_sides; i++) {
        let theta   = i * delta_theta;                  // current angle
        points.push([
            center[0] + radius * Math.cos(theta),       // current x-coord
            center[1] + radius * Math.sin(theta)        // current y-coord
        ]);
    }
    return;
}

// PUSH POINTS TO MAKE A STAR USING gl.LINE_LOOP
function generate_star_points(num_points, center, radius_inner, radius_outer, phase) {
    // incremental angle between consecutive points
    let delta_theta    = Math.PI / num_points;
    for (var i=0; i < num_points*2; i++) {
        let theta   = (i * delta_theta) + phase;        // current angle
        let r       = radius_inner + (radius_outer - radius_inner) * (Math.cos(num_points * theta / 2.0) ** 2);     // current distance from center
        points.push([
            center[0] + r * Math.sin(theta),            // current x-coord
            center[1] + r * Math.cos(theta)             // current y-coord
        ]);
    }
    return;
}

function render() {
    gl.clear( gl.COLOR_BUFFER_BIT );
    // gl.uniform1i(gl.getUniformLocation(program, "colorIndex"), 1);
    gl.drawArrays( gl.LINE_LOOP, 0, CIRCLE_NUM_POINTS);
    gl.drawArrays( gl.LINE_LOOP, CIRCLE_NUM_POINTS, STAR_NUM_POINTS * 2);
}
