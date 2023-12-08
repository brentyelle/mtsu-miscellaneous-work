// coordinates of the "hook" used to draw all the stars
const HOOK_POINTS   =  [vec2( 0.0,  2.0),
                        vec2( 0.1,  1.0),
                        vec2( 0.4,  1.0),
                        vec2( 0.0,  4.0),
                        vec2(-1.0, -0.3),
                        vec2(-0.5, -0.5)]

const NUM_STAR_POINTS   =   5;      // number of points on one star == number of hooks to assemble into one star
const STAR_PHASE        =   0.0;    // optional phase angle by which to rotate all the stars individually

const ANIMATION_STEPS   =   200;    // total # of frames to use
var stepcount = 0;                  // the current frame we're on

var gl, program;
var points = make_star();       // make all the points for one star
var modelViewMatrix=mat4();     // identity
var modelViewMatrixLoc;         // referring to locations of variables on shader programs

function main() {
    console.log("after generating points");

    // set up HTML canvas
    var canvas = document.getElementById( "gl-canvas" );
    // open webgl
    gl = WebGLUtils.setupWebGL( canvas );
    if ( !gl ) {
        console.log( "WebGL isn't available" );
        return;
    }

    // set up WebGL - JavaScript - HTML connections
    initialize_buffers();

    render();
}

function initialize_buffers() {

    //  Configure WebGL
    gl.clearColor( 1.0, 1.0, 1.0, 1.0 );

    //  Load shaders and initialize attribute buffers
    program = initShaders( gl, "vertex-shader", "fragment-shader" );
    if (!program) { console.log("Failed to intialize shaders."); return; }
    gl.useProgram( program );

    // Load the data into the GPU
    var bufferId = gl.createBuffer();
    gl.bindBuffer( gl.ARRAY_BUFFER, bufferId );
    gl.bufferData( gl.ARRAY_BUFFER, flatten(points), gl.STATIC_DRAW );

    // Associate our shader variables with our data buffer
    var vPosition = gl.getAttribLocation( program, "vPosition" );
    gl.vertexAttribPointer( vPosition, 2, gl.FLOAT, false, 0, 0 );
    gl.enableVertexAttribArray( vPosition );

    // Prepare to send the model view matrix to the vertex shader
    modelViewMatrixLoc = gl.getUniformLocation(program, "modelViewMatrix");
}

// Form the 4x4 scale transformation matrix
function scale4(a, b, c) {
    var result = mat4();
    result[0][0] = a;
    result[1][1] = b;
    result[2][2] = c;
    return result;
 }

// draw a hook, but rotated by the chosen angle
function make_hook(chosen_angle) {
    var angle = chosen_angle+STAR_PHASE;
    var this_hook = [];
    for (var i=0; i < HOOK_POINTS.length; i++) {
        console.log("rotating by ", angle, " radians");
        var newpoint = vec2(    HOOK_POINTS[i][0] * Math.cos(angle) + HOOK_POINTS[i][1] * Math.sin(angle),
                                HOOK_POINTS[i][0] * Math.sin(-angle) + HOOK_POINTS[i][1] * Math.cos(angle));
        //console.log("newpoint: ", newpoint);
        this_hook.push(newpoint);
        console.log("just made point: ", this_hook[i][0], this_hook[i][1]);
    }
    return this_hook;
}

// make a big array of all the points in all the hooks in the star
function make_star() {
    var rotation_angle = 2.0 * Math.PI / NUM_STAR_POINTS;
    var this_star = [];
    for (var i=0; i<NUM_STAR_POINTS; i++) {
        var this_hook = make_hook(i*rotation_angle);
        for (var j=0; j<this_hook.length; j++) {
            this_star.push(this_hook[j]);
            console.log("just pushed: ", this_hook[j]);
        }
    }
    return this_star;
}

// based on a parameter t in range [0, 1], determine where the star's centroid should be.
// moves linearly from start point to middle point, then linearly from middle point to end point
function star_location(t) {
    var current_loc = vec2(0.00,  0.00);    // to hold return value
    var start_loc   = [-0.75, -0.75];       // where to start, t=0.0
    var mid_loc     = [ 0.00,  0.75];       // where to be, t=0.5
    var end_loc     = [ 0.75, -0.75];       // where to end, t=1.0

    // all of the *2.0 below are because the t is broken up into halves of [0, 0.5] to [0.5, 1]
    if (t <= 0.5) {
        current_loc[0] = ( mid_loc[0]*t + (0.5 - t)*start_loc[0] )*2.0;
        current_loc[1] = ( mid_loc[1]*t + (0.5 - t)*start_loc[1] )*2.0;
    } else {
        current_loc[0] = ( end_loc[0]*(t - 0.5) + (1.0 - t)*mid_loc[0] )*2.0;
        current_loc[1] = ( end_loc[1]*(t - 0.5) + (1.0 - t)*mid_loc[1] )*2.0;
    }

    return current_loc;
}

function render() {
    // clear previous frame
    gl.clear( gl.COLOR_BUFFER_BIT );

    // first, scale the star down to 1/10th of its original size
    var factor = 0.1;
    var s       = scale4(factor, factor, factor);
    
    // calculate the star's location, which will be calculated as a translation from the origin
    star_loc    = star_location(stepcount / ANIMATION_STEPS);   // our t is our fraction out of the total number of frames desired
    var t       = translate(star_loc[0], star_loc[1], 0);

    // first scale, then translate to current position
    modelViewMatrix = mult(t, s);
    gl.uniformMatrix4fv(modelViewMatrixLoc, false, flatten(modelViewMatrix));

    // draw all of the hooks to make the star
    for (var j=0; j<NUM_STAR_POINTS; j++) {
        console.log("generating hook ", j, " of star");
        gl.drawArrays(gl.LINE_LOOP, j * HOOK_POINTS.length, HOOK_POINTS.length);
    }
    
    // if stepcount is not yet at its limit (200 frames), then prep another frame to run in 20 ms; otherwise stop animation
    if (stepcount < ANIMATION_STEPS) {
        stepcount   += 1;
        setTimeout(function (){requestAnimFrame(render);}, 20);
    }
    
    return;
}
