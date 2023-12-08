 /*
PROGRAMMER:     Brent Yelle
PROJECT #:      Project 3
DUE DATE:       Wednesday, 2023/11/08
INSTRUCTOR:     Dr. Cen Li
BONUS FEATURES ADDED:
    - pressing B will reset the scene
    - when the ghost is hit by the arrow, the arrow and ghost disappear
        * arrow will not reappear on the bow
        * unless B is pressed to reset the arrow, future ghosts cannot be shot (since you only had the 1 arrow)
*/


// for holding uniform variables for transformations
var modelViewMatrix     = mat4();
var modelViewMatrixLoc;
var projectionMatrix    = mat4();
var projectionMatrixLoc;
var modelViewStack=[];

// for holding list of all the points
var points=[];          // list of position points (2 floats per point)
var colors=[];          // list of color points (4 floats per point)

// for holding game details
var global_ShowGhost        = false;
var global_ShowArrow        = true;
var global_BowAngle         = 0.0;  // in degrees, 0 is up, + is right, - is left
var global_ArrowDistance    = 0.0;  // 0 is on bow, ~1.9 is out of sight
var global_GhostPosition_x  = -0.6;
var global_GhostPosition_y  = -0.2;
const ANIMATION_STEPS   = 100;
const MAXIMUM_ARROW_DIST = 2.5;
const DELTA_DIST = MAXIMUM_ARROW_DIST/ANIMATION_STEPS;
const MILLISECOND_DELAY = 1;
const ANGLE_TOLERANCE = 18;
const BOW_TILT_ON_KEYPRESS = 5;

// ratio of width to height
var RATIO               = 1.618;    // initial value is approximate and gets overridden when we load "canvas"

// constants for drawing
const POINTS_IN_SHAPES  = 100;              // number of points that make up each piece of the shape
const PLANET_TILT       = 50.0;             // degrees that planet tilts left
const PLANET_SCALEDOWN  = 0.25;             // post-calculation scaling-down of the planet
const PLANET_TRANSLATE  = [-0.9, 0.7, 0.0]; // post-calculation, post-scaling translation of the planet

// the globe shape of the planet
const GLOBE_RADIUS  = 0.4;                          // radius of globe
const COLOR_GLOBE   = vec4(0.8, 0.7, 0.0, 1.0);     // color of globe (yellowish)
const COLOR_GLOBE2  = vec4(0.9, 0.8, 0.7, 1.0);
const POINTS_IN_GLOBE = POINTS_IN_SHAPES+2;         // +2 for center point and loop-back point

// for the rings of the planet
const RING_RADIUS1      = 0.9;  // semimajor axis of outer ring
const RING_RADIUS2      = 0.8;  // semimajor axis of middle ring
const RING_RADIUS3      = 0.7;  // semimajor axis of inner ring
const COLOR_RING1       = vec4(1.0, 0.0, 0.0, 1.0); // color of outer ring (red)
const COLOR_RING2       = vec4(0.0, 0.9, 0.2, 1.0); // color of middle ring (green)
const COLOR_RING3       = vec4(0.2, 0.6, 1.0, 1.0); // color of inner ring (turquoise)
const RINGS_SQUISH      = 0.3;
const POINTS_IN_RING    = POINTS_IN_SHAPES+1;       // +1 for both endpoints

// for drawing the stars
const POINTS_IN_STAR = 7;
const NUMBER_OF_STARS = 25;
const STAR_RADIUS = 0.03;
const STAR_SKIP = 3;
const STAR_THETA = (360.0/POINTS_IN_STAR) * (Math.PI / 180.0);
const STAR_COLOR = vec4(1.0, 1.0, 0.5, 1);

// for drawing the bow and arrow
const BOW_WIDTH_SCALE   = 0.2;
const BOW_HEIGHT_SCALE  = 0.2;
const STRING_POINT      = (Math.PI/2) * BOW_WIDTH_SCALE;
const POINTS_IN_BOW     = 100;
const BOW_COLOR         = vec4(0.1, 0.6, 0.9, 1.0);
const BOWSTRING_COLOR   = vec4(0.9, 0.9, 0.9, 1.0);
const POINTS_IN_BOWSTRING = 2;
const BOWARROW_SHIFTDOWN_DIST = -0.8;
const BOWARROW_SHIFTDOWN = translate(0, BOWARROW_SHIFTDOWN_DIST, 0);
const ARROWHEAD_SIZER = 0.05;
const FLETCHING_SIZER = 0.05;
const ARROW_LENGTH    = 0.3;
const POINTS_IN_ARROWHEAD = 4;
const POINTS_IN_SHAFT     = 2;
const POINTS_IN_FLETCHING = 6;
const ARROWHEAD_COLOR     = vec4(0.1, 0.1, 0.1, 1);
const SHAFT_COLOR         = vec4(0.3, 0.2, 0.0, 1);
const FLETCHING_COLOR     = vec4(0.7, 0.8, 0.6, 1);

// for drawing the pumpkin
const POINT_IN_PUMP_CURVE = 200;
const POINTS_IN_PUMPKIN = POINT_IN_PUMP_CURVE+1;
const PUMPKIN_ORANGE    = vec4(219/255, 152/255, 44/255, 1);
const PUMPKIN_BLACK     = vec4(0.05, 0.02, 0.0, 1);
const PUMPKIN_BROWN     = vec4(105/255, 101/255, 77/255, 1);

// create a 4x4 matrix to scale a point with reference to the origin
function scale4(a, b, c) {
    var result = mat4();    // start with I(4x4) matrix
    result[0][0] = a;       // x-axis factor
    result[1][1] = b;       // y-axis factor
    result[2][2] = c;       // z-axis factor
    return result;
}

/* functions in MV.js:
-----------------------------------------------------------
mult(matrix1, matrix2);     // matrix multiplication
translate(x, y, z);         // translate a point
rotate(angle, axis);        // rotate counterclockwise: "axis" should be 3 arguments or a vec3() array
*/

window.onload = function init()
{
    canvas  = document.getElementById( "gl-canvas" );
    RATIO   = canvas.width / canvas.height;

    gl = WebGLUtils.setupWebGL( canvas );
    if ( !gl ) { alert( "WebGL isn't available" ); }

    // Generate the points for the scene (ORDERING IS CRUCIAL)
    BuildBackground();
    BuildStar();
    BuildPlanet();
    BuildRocks();
    BuildPumpkin();
    BuildGhost();
    BuildBow();
    BuildArrow();

    //modelViewMatrix = mat4();
    projectionMatrix = ortho(-RATIO, RATIO, -1, 1, -1, 1);
    gl.viewport( 0, 0, canvas.width, canvas.height );
    gl.clearColor( 0.2, 0.2, 0.5, 1.0 );

    //  load shaders
    var program = initShaders( gl, "vertex-shader", "fragment-shader" );
    gl.useProgram( program );

    // make buffer for colors: each color-point consists of 4 floats (RGBA)
    var cBuffer = gl.createBuffer();
    gl.bindBuffer( gl.ARRAY_BUFFER, cBuffer );
    gl.bufferData( gl.ARRAY_BUFFER, flatten(colors), gl.STATIC_DRAW );
    // assign an attribute variable for the color buffer
    var vColor = gl.getAttribLocation( program, "vColor" );
    gl.vertexAttribPointer( vColor, 4, gl.FLOAT, false, 0, 0 );
    gl.enableVertexAttribArray( vColor );

    // make a buffer for positions: each position-point consists of 2 floats (x & y)
    var vBuffer = gl.createBuffer();
    gl.bindBuffer( gl.ARRAY_BUFFER, vBuffer );
    gl.bufferData( gl.ARRAY_BUFFER, flatten(points), gl.STATIC_DRAW );

    // assign an attribute variable for the position buffer
    var vPosition = gl.getAttribLocation( program, "vPosition" );
    gl.vertexAttribPointer( vPosition, 2, gl.FLOAT, false, 0, 0 );
    gl.enableVertexAttribArray( vPosition );

    // make uniform variable for the model-view and projection matrices
    modelViewMatrixLoc = gl.getUniformLocation(program, "modelViewMatrix");
    projectionMatrixLoc= gl.getUniformLocation(program, "projectionMatrix");

    // LISTENERS
    // pressing S will move the ghost to a new position
    window.addEventListener("keydown", function(event) {
        if (event.key == 'S' || event.key == 's') {
                move_ghost();
                render();
        }
    });

    // pressing L or LeftArrow will move the ghost to a new position
    window.addEventListener("keydown", function(event) {
        if (event.key == 'L' || event.key == 'l' || event.key == 'ArrowLeft') {
            global_BowAngle -= BOW_TILT_ON_KEYPRESS;
            render();
        }
    });

    // pressing R or right arrow will tilt the bow left
    window.addEventListener("keydown", function(event) {
        if (event.key == 'R' || event.key == 'r' || event.key == 'ArrowRight') {
            global_BowAngle += BOW_TILT_ON_KEYPRESS;
            render();
        }
    });

    // pressing B will reset the scene
    window.addEventListener("keydown", function(event) {
        if (event.key == 'B' || event.key == 'b') {
            reset_scene();
            render();
        }
    });

    // pressing F will shoot the arrow
    window.addEventListener("keydown", function(event) {
        if (event.key == 'F' || event.key == 'f') {
            // if arrow is not visible, do nothing (as we don't have an arrow); otherwise shoot the arrow
            if (!global_ShowArrow) return;

            // distance of ghost from arrow's starting position
            var ghost_dist = Math.sqrt(global_GhostPosition_y - BOWARROW_SHIFTDOWN_DIST)**2 + global_GhostPosition_x*global_GhostPosition_x;
            console.log("ghost distance is", ghost_dist);
            // angle of ghost from vertical
            var ghost_angle = Math.atan2(global_GhostPosition_x, global_GhostPosition_y - BOWARROW_SHIFTDOWN_DIST) * 180.0 / Math.PI;
            console.log("ghost angle is", ghost_angle);

            var dummy = setInterval(function() {
                // move the arrow ahead a little bit
                global_ArrowDistance += DELTA_DIST;
                render();
                // if at the right angle and distance, kill the ghost
                if (global_ArrowDistance > ghost_dist && Math.abs(ghost_angle - global_BowAngle) < ANGLE_TOLERANCE) {
                    kill_ghost();
                    render();
                }
                // if arrow has reached end of trajectory, return it to starting position (perhaps invisibly) and end animation loop
                if (global_ArrowDistance > MAXIMUM_ARROW_DIST) {
                    global_ArrowDistance = 0.0;
                    render();
                    clearInterval(dummy);
                }
                return;
                }, MILLISECOND_DELAY);
        }
    });



    // pass off rendering to other functions
    render();
}

/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$
DRAWING BACKGROUND STUFF
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */
function BuildBackground() {
    const sky_points  = [vec2(-RATIO, 1), vec2(RATIO, 1), vec2(-RATIO,  0), vec2(RATIO,  0)];
    const land_points = [vec2(-RATIO, 0), vec2(RATIO, 0), vec2(-RATIO, -1), vec2(RATIO, -1)];
    const color_sky_low       = vec4(77/255, 19/255, 105/255, 1);
    const color_sky_high      = vec4(18/255,  9/255,  56/255, 1);
    const color_land_low      = vec4(39/255, 84/255,   9/255, 1);
    const color_land_high     = vec4(77/255, 110/255,  0/255, 1);
    const sky_colors      = [color_sky_high, color_sky_high, color_sky_low, color_sky_low];
    const land_colors     = [color_land_high, color_land_high, color_land_low, color_land_low];
    
    points = points.concat(sky_points, land_points);
    colors = colors.concat(sky_colors, land_colors);
    return 8;
}
function DrawBackground(current_offset) {
    const POINTS_IN_RECTANGLE = 4;
    // push whatever the previous MVM was
    modelViewStack.push(modelViewMatrix);

    // use default as MVM
    modelViewMatrix = mat4();
    gl.uniformMatrix4fv(modelViewMatrixLoc, false, flatten(modelViewMatrix));

    //draw sky
    gl.drawArrays(gl.TRIANGLE_STRIP, current_offset, POINTS_IN_RECTANGLE);
    current_offset += POINTS_IN_RECTANGLE;
    //draw land
    gl.drawArrays(gl.TRIANGLE_STRIP, current_offset, POINTS_IN_RECTANGLE);
    current_offset += POINTS_IN_RECTANGLE;

    // restore the previous MVM
    modelViewMatrix = modelViewMatrix.pop();

    return current_offset;
}

/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$
DRAWING STARS IN THE SKY
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */
function BuildStar() {
    var xs = [];
    var ys = [];

    for (var i=0; i<POINTS_IN_STAR; i++) {
        xs.push(STAR_RADIUS * Math.sin(STAR_THETA*STAR_SKIP*i));
        ys.push(STAR_RADIUS * Math.cos(STAR_THETA*STAR_SKIP*i));
    }

    for (var j=0; j<POINTS_IN_STAR; j++) {
        points.push(vec2(xs[j], ys[j]));
        colors.push(STAR_COLOR);
    }

    return POINTS_IN_STAR;
}
function DrawStars(current_offset) {
    // push whatever the previous MVM was
    modelViewStack.push(modelViewMatrix);
    stararray = [
        vec2([0.045413936212970504, 0.6553252622682524]),
        vec2([-0.1228181736345805,  0.6669434750379251]),
        vec2([-0.23390339613962338, 0.395556501012407]),
        vec2([-0.3435022655971028,  0.6453442616661936]),
        vec2([-0.3616563481568868,  0.3571939446607385]),
        vec2([-0.4479374739242652,  0.9580147069216983]),
        vec2([-0.4932311822200559,  0.5335891471789095]),
        vec2([-0.7953964003782061,  0.7540858829781546]),
        vec2([-1.201055470892312,   0.6457879187193504]),
        vec2([-1.505436836916549,   0.8330308466769987]),
        vec2([-1.5979309033837008,  0.4684648667072049]),
        vec2([0.22221194259973173,  0.500077712736671]),
        vec2([0.24474346197783167,  0.7821087463740872]),
        vec2([0.24487935900292232,  0.9721944566257967]),
        vec2([0.32230840707002373,  0.6844295611783467]),
        vec2([0.5026759983272365,   0.6045187644506138]),
        vec2([0.723912743101556,    0.8879668385709363]),
        vec2([0.7689872258502933,   0.9973859868655671]),
        vec2([0.8681907846957072,   0.6393307720039425]),
        vec2([1.0115972426329387,   0.538341667211786]),
        vec2([1.042140909537043,    0.6985336435044256]),
        vec2([1.0433097291946103,   0.44126228334726936]),
        vec2([1.1574015502784725,   0.6599680527977818]),
        vec2([1.3796568155039723,   0.795292275665921]),
        vec2([1.5087209579217746,   0.3357933070987552])
    ];

    for (var i=0; i<NUMBER_OF_STARS; i++) {
        var star_x = stararray[i][0];
        var star_y = stararray[i][1];
        modelViewMatrix = translate(star_x, star_y, 0);
        gl.uniformMatrix4fv(modelViewMatrixLoc, false, flatten(modelViewMatrix));
        gl.drawArrays(gl.LINE_LOOP, current_offset, POINTS_IN_STAR);
    }
    current_offset += POINTS_IN_STAR;

    // restore the previous MVM
    modelViewMatrix = modelViewMatrix.pop();
    return current_offset;
}

/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$
DRAWING PLANET STUFF
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */
function GenerateGlobe() {
    var dtheta      = 2.0 * Math.PI / POINTS_IN_SHAPES;    // 360° divided up into incremental pieces 
    var this_globe  = [];
    // we need the initial point to be in the center to draw with the TRIANGLE_FAN mode
    this_globe.push(vec2(0.2, 0.0));
    // generate all the points (include endpoints, so POINTS_IN_SHAPES+1 points, plus the center point,
    // bringing us to a total of POINTS_IN_SHAPES+2)
    for (var i=0; i<=POINTS_IN_SHAPES; i++) {
        let x = GLOBE_RADIUS * Math.cos(i*dtheta);
        let y = GLOBE_RADIUS * Math.sin(i*dtheta);
        this_globe.push(vec2(x,y));
    }
    // return the globe rather than edit a global variable, since this is more functional
    return this_globe;
}
function GenerateHalfRing(radius, top_half = true) {
    var dtheta          = Math.PI / POINTS_IN_SHAPES;    // 180° divided up into incremental pieces
    var this_halfring   = [];
    // if drawing top half, go from 0° -> 180°, but if bottom half, 0° -> -180°.
    if (!top_half) {
        dtheta = -dtheta;
    }
    // generate all the points (include endpoints, so POINTS_IN_SHAPES+1 points total!)
    for (var i=0; i<=POINTS_IN_SHAPES; i++) {
        let x = radius * Math.cos(i*dtheta);
        let y = radius * Math.sin(i*dtheta) * RINGS_SQUISH;
        this_halfring.push(vec2(x,y));
    }
    // return the half-ring rather than edit a global variable, since this is more functional
    return this_halfring;
}
function BuildPlanet() {
    // generate all the position-points
    let ring_back1  = GenerateHalfRing(RING_RADIUS1, top_half = true);
    let ring_back2  = GenerateHalfRing(RING_RADIUS2, top_half = true);
    let ring_back3  = GenerateHalfRing(RING_RADIUS3, top_half = true);
    let globe       = GenerateGlobe();
    let ring_front1 = GenerateHalfRing(RING_RADIUS1, top_half = false);
    let ring_front2 = GenerateHalfRing(RING_RADIUS2, top_half = false);
    let ring_front3 = GenerateHalfRing(RING_RADIUS3, top_half = false);

    // combine all the position-points into the "points" array, re-initializing the "points" as well
    points = points.concat(ring_back1, ring_back2, ring_back3, globe, ring_front1, ring_front2, ring_front3);

    // add all the colors into the "colors" array, made to be parallel with "points"
    for (var i=0; i < POINTS_IN_RING; i++)    colors.push(COLOR_RING1);
    for (var i=0; i < POINTS_IN_RING; i++)    colors.push(COLOR_RING2);
    for (var i=0; i < POINTS_IN_RING; i++)    colors.push(COLOR_RING3);
    colors.push(COLOR_GLOBE2);
    for (var i=1; i < POINTS_IN_GLOBE; i++)   colors.push(COLOR_GLOBE);
    for (var i=0; i < POINTS_IN_RING; i++)    colors.push(COLOR_RING1);
    for (var i=0; i < POINTS_IN_RING; i++)    colors.push(COLOR_RING2);
    for (var i=0; i < POINTS_IN_RING; i++)    colors.push(COLOR_RING3);

    return 6*POINTS_IN_RING + POINTS_IN_GLOBE;
}
function DrawFullPlanet(current_offset)
{
    // push whatever the previous MVM was
    modelViewStack.push(modelViewMatrix);

    // calculate this individual MVM
    var s = scale4(PLANET_SCALEDOWN, PLANET_SCALEDOWN, PLANET_SCALEDOWN);
    var t = translate(PLANET_TRANSLATE[0], PLANET_TRANSLATE[1], PLANET_TRANSLATE[2]);
    var r = rotate(PLANET_TILT, 0, 0, 1);
    modelViewMatrix = mult(s, r);
    modelViewMatrix = mult(t, modelViewMatrix);

    // send MVM to WebGL
    gl.uniformMatrix4fv(modelViewMatrixLoc, false, flatten(modelViewMatrix));

    // to keep track of current offset in the arrays "points" and "colors"

    // draw back rings
    for (var i=0; i < 3; i++) {
        gl.drawArrays(gl.LINE_STRIP, current_offset, POINTS_IN_RING);
        current_offset += POINTS_IN_RING;
    }

    // draw planet
    gl.drawArrays(gl.TRIANGLE_FAN, current_offset, POINTS_IN_GLOBE);
    current_offset += POINTS_IN_GLOBE;
    
    // draw front rings
    for (var i=0; i < 3; i++) {
        gl.drawArrays(gl.LINE_STRIP, current_offset, POINTS_IN_RING);
        current_offset += POINTS_IN_RING;
    }
    
    // restore the previous MVM
    modelViewMatrix = modelViewMatrix.pop();
    return current_offset;
}

/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$
DRAWING BOW
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */
function BowCurve(input) {  //input should be from 0 to 1
    var t = (input-0.5)*4
    var x = t * BOW_WIDTH_SCALE;            
    var y = Math.cos(t)**2 * BOW_HEIGHT_SCALE; // minimum at t=pi/2 and -pi/2
    return [x, y];
}
function BuildBow() {
    for (var i=0; i<POINTS_IN_BOW; i++) {
        var [x, y] = BowCurve(i/POINTS_IN_BOW);
        points.push(vec2(x, y));
        colors.push(BOW_COLOR);
    }
    points.push(vec2(-STRING_POINT, 0), vec2(STRING_POINT, 0));
    colors.push(BOWSTRING_COLOR, BOWSTRING_COLOR);

    return POINTS_IN_BOW + POINTS_IN_BOWSTRING;
}
function DrawBow(current_offset, angle=0) {
    // push whatever the previous MVM was
    modelViewStack.push(modelViewMatrix);

    // for future use in aiming, MVM also includes a rotation component (that currently does nothing)
    rotator = rotate(-angle, 0,0,1);
    modelViewMatrix = mult(BOWARROW_SHIFTDOWN, rotator);
    // send MVM to WebGL
    gl.uniformMatrix4fv(modelViewMatrixLoc, false, flatten(modelViewMatrix));

    //draw bow, then the string
    gl.drawArrays(gl.LINE_STRIP, current_offset, POINTS_IN_BOW);
    current_offset += POINTS_IN_BOW;
    gl.drawArrays(gl.LINE_STRIP, current_offset, POINTS_IN_BOWSTRING);
    current_offset += POINTS_IN_BOWSTRING;

    // restore the previous MVM
    modelViewMatrix = modelViewMatrix.pop();
    return current_offset;
}

/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$
DRAWING ARROW
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */
function BuildArrow() {

    arrowhead_points = [vec2(0, ARROW_LENGTH+ARROWHEAD_SIZER),
                        vec2(ARROWHEAD_SIZER/1.5, ARROW_LENGTH),
                        vec2(0, ARROW_LENGTH-ARROWHEAD_SIZER),
                        vec2(-ARROWHEAD_SIZER/1.5, ARROW_LENGTH)];
    shaft_points     = [vec2(0, ARROW_LENGTH),
                        vec2(0, 0)];
    fletching_points = [vec2(0,0),
                        vec2(FLETCHING_SIZER, -FLETCHING_SIZER),
                        vec2(FLETCHING_SIZER, -2*FLETCHING_SIZER),
                        vec2(0, -FLETCHING_SIZER),
                        vec2(-FLETCHING_SIZER, -2*FLETCHING_SIZER),
                        vec2(-FLETCHING_SIZER, -FLETCHING_SIZER)];

    points = points.concat(shaft_points, arrowhead_points, fletching_points);
    var i;
    for (i=0; i<POINTS_IN_SHAFT; i++)       {colors.push(SHAFT_COLOR);}
    for (i=0; i<POINTS_IN_ARROWHEAD; i++)   {colors.push(ARROWHEAD_COLOR);}
    for (i=0; i<POINTS_IN_FLETCHING; i++)   {colors.push(FLETCHING_COLOR);}

    return POINTS_IN_ARROWHEAD + POINTS_IN_SHAFT + POINTS_IN_FLETCHING;
}
function DrawArrow(current_offset, angle=0, arrow_dist=0) {
    // push whatever the previous MVM was
    modelViewStack.push(modelViewMatrix);

    rotator = rotate(-angle, 0,0,1);
    shooter = translate(0, arrow_dist, 0);
    modelViewMatrix = mult(BOWARROW_SHIFTDOWN, rotator);
    modelViewMatrix = mult(modelViewMatrix, shooter);
    gl.uniformMatrix4fv(modelViewMatrixLoc, false, flatten(modelViewMatrix));

    if (global_ShowArrow) gl.drawArrays(gl.LINE_STRIP, current_offset, POINTS_IN_SHAFT);
    current_offset += POINTS_IN_SHAFT;
    if (global_ShowArrow) gl.drawArrays(gl.TRIANGLE_FAN, current_offset, POINTS_IN_ARROWHEAD);
    current_offset += POINTS_IN_ARROWHEAD;
    if (global_ShowArrow) gl.drawArrays(gl.TRIANGLE_FAN, current_offset, POINTS_IN_FLETCHING);
    current_offset += POINTS_IN_FLETCHING;

    // restore the previous MVM
    modelViewMatrix = modelViewMatrix.pop();
    return current_offset;
}

/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$
DRAWING TREES
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */
function BuildRocks() {
    var TREECOLOR_A = vec4(128/255, 103/255,  54/255, 1);
    var TREECOLOR_B = vec4(105/255,  76/255,  19/255, 1);
    var TREECOLOR_C = vec4(84/255,   79/255,  64/255, 1);
    var object1 = [vec2(-1.8, -0.2), vec2(-1.5, 0.3), vec2(-1.4, 0.1), vec2(-1.2, 0.25), vec2(-1, -0.22)];
    var object2 = [vec2(0.3, -0.1), vec2(0.4, 0.1), vec2(0.6, 0.15), vec2(0.8, 0.12), vec2(0.85, -0.12)];
    var object3 = [vec2(-.5, -.1), vec2(-.45, .2), vec2(0, 0.1), vec2(0.05, -0.2), vec2(-0.2,-.2)];
    var object4 = [vec2(3-1.8, -0.25), vec2(3-1.5, 0.2), vec2(3-1.4, 0.15), vec2(3-1.2, 0.25), vec2(3-1, -0.22)];
    points = points.concat(object1, object2, object3, object4);
    colors.push(TREECOLOR_A, TREECOLOR_B, TREECOLOR_C, TREECOLOR_A, TREECOLOR_B);
    colors.push(TREECOLOR_B, TREECOLOR_C, TREECOLOR_A, TREECOLOR_B, TREECOLOR_C);
    colors.push(TREECOLOR_B, TREECOLOR_A, TREECOLOR_C, TREECOLOR_B, TREECOLOR_C);
    colors.push(TREECOLOR_B, TREECOLOR_A, TREECOLOR_B, TREECOLOR_C, TREECOLOR_A)

    return;
}
function DrawRocks(current_offset) {
    // push whatever the previous MVM was
    modelViewStack.push(modelViewMatrix);

    modelViewMatrix = mat4();
    gl.uniformMatrix4fv(modelViewMatrixLoc, false, flatten(modelViewMatrix));

    gl.drawArrays(gl.TRIANGLE_FAN, current_offset, 5);
    current_offset += 5;
    gl.drawArrays(gl.TRIANGLE_FAN, current_offset, 5);
    current_offset += 5;
    gl.drawArrays(gl.TRIANGLE_FAN, current_offset, 5);
    current_offset += 5;
    gl.drawArrays(gl.TRIANGLE_FAN, current_offset, 5);
    current_offset += 5;

    return current_offset;
}

/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$
DRAWING THE GHOST
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */
function BuildGhost() {
            // begin body  (87 points)
    points.push(vec2(3, 0));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(3.1, 1));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(3.5, 2));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(4, 3.6));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(4, 4));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(4.1, 3.3));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(4.5, 3));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(5.5, 3));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(6,3.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(6.5, 4));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(6.7, 4.2));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(6.8, 2.8));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(7, 2.4));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(7.5, 2));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(8, 2));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(8.5, 1.7));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(9, 1.2));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(10, 0.8));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(10, -2));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(10.4, -2.8));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(10.5, -3.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(10.7, -1.7));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(11, -1.4));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(11.2, -1.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(12, -2));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(12.5, -2.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(13, -3));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(13, -2));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(12.8, -0.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(12, 0));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(12.5, 0.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(11, 1));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(10.8, 1.4));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(10.2, 2.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(10, 4));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(9.8, 7.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(7.5, 9.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(6, 11));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(3, 12));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(.5, 15));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(0, 17));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-1.8, 17.4));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-4, 16.6));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-5, 14));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-6, 10.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-9, 10));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-10.5, 8.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-12, 7.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-12.5, 4.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-13, 3));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-13.5, -1));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-13, -2.3));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-12, 0));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-11.5, 1.8));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-11.5, -2));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-10.5, 0));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-10, 2));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-8.5, 4));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-8, 4.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-8.5, 7));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-8, 5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-6.5, 4.2));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-4.5, 6.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-4, 4));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-5.2, 2));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-5, 0));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-5.5, -2));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-6, -5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-7, -8));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-8, -10));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-9, -12.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-10, -14.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-10.5, -15.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-11, -17.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-5, -14));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-4, -11));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-5, -12.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-3, -12.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-2, -11.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(0, -11.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(1, -12));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(3, -12));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(3.5, -7));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(3, -4));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(4, -3.8));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(4.5, -2.5));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(3, 0));
    colors.push(vec4(1, 1, 1, 1));
    // end body

    // begin mouth (6 points)
    points.push(vec2(-1, 6));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-0.5, 7));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-0.2, 8));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-1, 8.6));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-2, 7));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-1.5, 5.8));
    colors.push(vec4(1, 1, 1, 1));
    // end mouth

    // begin nose (5 points)
    points.push(vec2(-1.8, 9.2));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-1, 9.8));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-1.1, 10.6));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-1.6, 10.8));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-1.9, 10));
    colors.push(vec4(1, 1, 1, 1));

    // begin left eye, translate (2.6, 0.2, 0) to draw the right eye
    // outer eye, draw line loop (9 points)
    points.push(vec2(-2.9, 10.8));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-2.2, 11));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-2, 12));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-2, 12.8));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-2.2, 13));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-2.5, 13));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-2.9, 12));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-3, 11));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-2.9, 10.5));
    colors.push(vec4(1, 1, 1, 1));

    // eye ball, draw triangle_fan (7 points)
    points.push(vec2(-2.5, 11.4));  // middle point
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-2.9, 10.8));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-2.2, 11));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-2, 12));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-2.9, 12));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-3, 11));
    colors.push(vec4(1, 1, 1, 1));
    points.push(vec2(-2.9, 10.5));
    colors.push(vec4(1, 1, 1, 1));
    // end left eye
    return;
}
function DrawGhost(current_offset, ghost_x=0, ghost_y=0) {
    const GHOST_SCALE = 0.03;
    // push whatever the previous MVM was
    modelViewStack.push(modelViewMatrix);

    modelViewMatrix = scale4(GHOST_SCALE, GHOST_SCALE/RATIO, 1);
    modelViewMatrix = mult(translate(ghost_x, ghost_y, 0), modelViewMatrix);
    gl.uniformMatrix4fv(modelViewMatrixLoc, false, flatten(modelViewMatrix));

    //ghost body
    if (global_ShowGhost) gl.drawArrays(gl.LINE_STRIP, current_offset, 87);
    current_offset += 87;
    //ghost mouth
    if (global_ShowGhost) gl.drawArrays(gl.LINE_STRIP, current_offset, 6);
    current_offset += 6;
    // ghost nose
    if (global_ShowGhost) gl.drawArrays(gl.LINE_STRIP, current_offset, 5);
    current_offset += 5;
    // ghost left eye
    if (global_ShowGhost) gl.drawArrays(gl.LINE_STRIP, current_offset, 9);
    current_offset += 9;
    if (global_ShowGhost) gl.drawArrays(gl.LINE_STRIP, current_offset, 7);
    current_offset += 7;

    // ghost right eye
    current_offset -= (7+9);
    modelViewMatrix = scale4(GHOST_SCALE, GHOST_SCALE/RATIO, 1);
    modelViewMatrix = mult(translate(ghost_x, ghost_y, 0), modelViewMatrix);
    modelViewMatrix = mult(modelViewMatrix, translate(2.6, 0.2, 0));
    gl.uniformMatrix4fv(modelViewMatrixLoc, false, flatten(modelViewMatrix));
    if (global_ShowGhost) gl.drawArrays(gl.LINE_STRIP, current_offset, 9);
    current_offset += 9;
    if (global_ShowGhost) gl.drawArrays(gl.LINE_STRIP, current_offset, 7);
    current_offset += 7;

    // restore the previous MVM
    modelViewMatrix = modelViewStack.pop();
    return current_offset;
}

/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$
DRAWING SPECIAL OBJECT (PUMPKINS)
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */
function BuildPumpkin() {
    const PUMPKIN_SCALE = 0.05;

    points.push(vec2(0,0));
    colors.push(PUMPKIN_ORANGE);

    for (var i=0; i<POINT_IN_PUMP_CURVE; i++) {
        let t = (i/(POINT_IN_PUMP_CURVE-1))*2.0*Math.PI;
        let theta = t;
        let r = 4 + Math.sin(4*t)**2;
        let x = r * Math.cos(theta) * PUMPKIN_SCALE;
        let y = r * Math.sin(theta) * PUMPKIN_SCALE/RATIO;
        points.push(vec2(x,y));
        colors.push(PUMPKIN_ORANGE);
    }

    points.push(vec2(-0.1,0.06), vec2(-0.15,0), vec2(-0.05,0));
    colors.push(PUMPKIN_BLACK, PUMPKIN_BLACK, PUMPKIN_BLACK);
    points.push(vec2(+0.1,0.06), vec2(+0.15,0), vec2(+0.05,0));
    colors.push(PUMPKIN_BLACK, PUMPKIN_BLACK, PUMPKIN_BLACK);
    points.push(vec2(-0.1,-0.03), vec2(-0.05,-0.08), vec2(0,-0.04), vec2(0.05,-0.08), vec2(0.1,-0.03));
    colors.push(PUMPKIN_BLACK, PUMPKIN_BLACK, PUMPKIN_BLACK, PUMPKIN_BLACK, PUMPKIN_BLACK);

    points.push(vec2(-0.02, 0.1), vec2(-0.013, 0.2), vec2(0.04, 0.23), vec2(0.025, 0.21), vec2(0.025, 0.1));
    colors.push(PUMPKIN_BROWN, PUMPKIN_BROWN, PUMPKIN_BROWN, PUMPKIN_BROWN, PUMPKIN_BROWN)

    return;
}
function DrawPumpkins(current_offset) {

    var pumpkin_positions = [vec2(-1.2, -0.7), vec2(-0.5, -0.5), vec2(0.5, -0.2), vec2(1.3, -0.6)];
    var pumpkin_scales = [0.75, 0.45, 0.85, 0.55];
    
    // push whatever the previous MVM was
    modelViewStack.push(modelViewMatrix);

    modelViewMatrix = mat4();

    for (var i=0; i<4; i++) {
        modelViewMatrix = translate(pumpkin_positions[i][0], pumpkin_positions[i][1], 0);
        modelViewMatrix = mult(modelViewMatrix, scale4(pumpkin_scales[i], pumpkin_scales[i], pumpkin_scales[i]));
        gl.uniformMatrix4fv(modelViewMatrixLoc, false, flatten(modelViewMatrix));
        gl.drawArrays(gl.TRIANGLE_FAN, current_offset, POINTS_IN_PUMPKIN);
        current_offset += POINTS_IN_PUMPKIN;
        gl.drawArrays(gl.TRIANGLE_STRIP, current_offset, 3);
        current_offset += 3;
        gl.drawArrays(gl.TRIANGLE_STRIP, current_offset, 3);
        current_offset += 3;
        gl.drawArrays(gl.TRIANGLE_STRIP, current_offset, 5);
        current_offset += 5;
        gl.drawArrays(gl.TRIANGLE_FAN, current_offset, 5);
        current_offset += 5;
        current_offset -= (POINTS_IN_PUMPKIN + 3+3+5+5);
    }

    current_offset += (POINTS_IN_PUMPKIN + 3+3+5+5)

    // restore the previous MVM
    modelViewMatrix = modelViewStack.pop();
    return current_offset;
}

/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$
RENDERING
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */
function render()
{
    // offset counter for drawings
    var offset = 0;
    // current angle of the bow and position of the arrow off the bow

    // reset basic canvas
    modelViewMatrix = mat4();
    gl.clear( gl.COLOR_BUFFER_BIT );
    gl.uniformMatrix4fv(projectionMatrixLoc, false, flatten(projectionMatrix));

    // draw all picture elements (currently only the planet for Project 5)
    offset = DrawBackground(offset);
    offset = DrawStars(offset);
    offset = DrawFullPlanet(offset);
    offset = DrawRocks(offset);
    offset = DrawPumpkins(offset);
    offset = DrawGhost(offset, global_GhostPosition_x, global_GhostPosition_y);
    offset = DrawBow(offset, angle=global_BowAngle);
    offset = DrawArrow(offset, angle=global_BowAngle, arrow_dist=global_ArrowDistance);
}

/* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$
GAME STUFF
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */
function reset_scene() {
    global_ShowGhost        = false;
    global_ShowArrow        = true;
    global_BowAngle         = 0.0;  // in degrees, 0 is up, + is right, - is left
    global_ArrowDistance    = 0.0;  // 0 is on bow, ~1.9 is out of sight
    return;
}

function kill_ghost() {
    global_ShowGhost        = false;
    global_ShowArrow        = false;
    // global_ArrowDistance    = 0.0;
    return;
}

function move_ghost() {
    global_ShowGhost        = true;
    global_GhostPosition_x  = (2.0 * (Math.random() - 0.5) * RATIO) * 0.9;
    global_GhostPosition_y  = Math.random() - 0.2;
    return;
}