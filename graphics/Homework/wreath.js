// coordinates of the "hook" used to draw all the stars
const HOOK_POINTS   =  [vec2( 0.0,  2.0),
                        vec2( 0.1,  1.0),
                        vec2( 0.4,  1.0),
                        vec2( 0.0,  4.0),
                        vec2(-1.0, -0.3),
                        vec2(-0.5, -0.5)]

const NUM_STAR_POINTS   =   5;      // number of points on one star == number of hooks to assemble into one star
const STAR_PHASE        =   0.0;    // optional phase angle by which to rotate all the stars individually
const NUM_STARS         =   12;     // total number of stars to draw in the wreath

var gl, program;
var points = make_star();           // make all the points for one star
var modelViewMatrix=mat4();         // identity
var modelViewMatrixLoc;             // referring to locations of variables on shader programs

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

function render() {
    // clear previous frame
    gl.clear( gl.COLOR_BUFFER_BIT );

    // first, scale the star down
    var scalefactor = 0.075;
    var s       = scale4(scalefactor, scalefactor, scalefactor);

    // then, translate 0.70 units right
    var t       = translate(0.70, 0, 0);

    // finally, each copy of the star will be rotated 360/12 = 30° from the previous one
    var r_wheel = rotate(360.0/NUM_STARS, 0, 0, 1);

    // start with the first star (unrotated)
    modelViewMatrix = mult(t, s);

    // for each of the 12 stars
    for (var i=0; i<NUM_STARS; i++) {
        // send uniform matrix to shader
        gl.uniformMatrix4fv(modelViewMatrixLoc, false, flatten(modelViewMatrix));
        // draw each of the 5 hooks in the star
        for (var j=0; j<NUM_STAR_POINTS; j++) {
            gl.drawArrays(gl.LINE_LOOP, j * HOOK_POINTS.length, HOOK_POINTS.length);
        }
        // then rotate 30° from origin to draw the next star
        modelViewMatrix = mult(r_wheel, modelViewMatrix);
    }
    
    return;
}
