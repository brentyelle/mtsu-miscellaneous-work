var gl, program;
var user_color  =   0;  // choose color for display (0 or 1)
var user_fern   =   0;  // choose fern for display (0 or 1)
var pts_fern0   =   [];
var pts_fern1   =   [];
var points;

//                            Set1   Set2   Set3   Set4
const FERN_ARRAY0       =  [[ 0.00,  0.20, -0.15,  0.75],   //a 
                            [ 0.00, -0.26,  0.28,  0.04],   //b
                            [ 0.00,  0.23,  0.26, -0.04],   //c
                            [ 0.16,  0.22,  0.24,  0.85],   //d
                            [ 0.00,  0.00,  0.00,  0.00],   //e
                            [ 0.00,  1.60,  0.44,  1.60]];  //f
const PROB_ARRAY0   = [0.00,  0.10,  0.08,  0.08,  0.74];       // individual probabilities
const CUMUL_PROB0   = [0.00,  0.10,  0.18,  0.26,  1.00];       // cumulative probabilities over the list of sets

//                            Set1   Set2   Set3   Set4
const FERN_ARRAY1       =  [[ 0.00,  0.20, -0.15,  0.85],   //a 
                            [ 0.00, -0.26,  0.28,  0.04],   //b
                            [ 0.00,  0.23,  0.26, -0.04],   //c
                            [ 0.16,  0.22,  0.24,  0.85],   //d
                            [ 0.00,  0.00,  0.00,  0.00],   //e
                            [ 0.00,  1.60,  0.44,  1.60]];  //f
const PROB_ARRAY1   = [0.00,  0.01,  0.07,  0.07,  0.85];       // individual probabilities
const CUMUL_PROB1   = [0.00,  0.01,  0.08,  0.15,  1.00];       // cumulative probabilities over the list of sets


const NUM_ITERATIONS    =   100000;
const STARTPOINT        =   100;

// convert a 0 to 1, and a 0 to a 1
function toggle01(this_var) {
    let dmy = Boolean(this_var);    // convert to boolean
    dmy = !dmy;                     // toggle true <-> false
    dmy = +dmy;                     // convert true->1 and false->0
    return dmy;
}

// given a nested array "matrix", grabs the "columnnumber"-th column as an array
function grabcolumn(matrix, columnnumber) {
    var col = [];
    var num_rows = matrix.length;
    for (var i = 0; i < num_rows; i++) {
        col.push(matrix[i][columnnumber]);
    }
    return col;
}

// scale all points to be within [-1, 1] x [-1, 1]
function scaledown(fernpoints) {
    var n_points = fernpoints.length;   // to avoid recalculating all the time
    var max_x = 0.0, min_x = 0.0;
    var max_y = 0.0, min_y = 0.0;

    // for each point, find the extreme extents in each of the 4 directions
    for (var i=0; i<n_points; i++) {
        let thispoint = fernpoints[i];
        if (thispoint[0] > max_x)
            max_x = thispoint[0];
        if (thispoint[0] < min_x)
            min_x = thispoint[0];
        if (thispoint[1] > max_y)
            max_y = thispoint[1];
        if (thispoint[1] < min_y)
            min_y = thispoint[1];
    }

    // center of all the points drawn (before scaling)
    var center_x = (max_x + min_x)/2.0;
    var center_y = (max_y + min_y)/2.0;

    // would be 2.0, except I'm making the image less wide and less tall.
    // I'm using the reciprocal of the scale factor to increase efficiency, as doing division for every point would be more CPU-intensive.
    var reciprocal_scalefactor_x = 1.5/(max_x - min_x);
    var reciprocal_scalefactor_y = 1.8/(max_y - min_y);

    // for each (x,y) in the list of points, re-center and scale it properly
    for (var i=0; i<n_points; i++) {
        fernpoints[i][0] = (fernpoints[i][0] - center_x) * reciprocal_scalefactor_x;
        fernpoints[i][1] = (fernpoints[i][1] - center_y) * reciprocal_scalefactor_y;
    }

    return fernpoints;
}

// generate the points for the chosen fern (0 or 1)
function makefern(fern) {
    var this_array, this_cprob;
    var new_points = [];
    var x   = 0.0;
    var y   = 0.0;

    // decide which array to use
    if (fern == 0) {
        console.log("Generation fern 0...");
        this_array = FERN_ARRAY0;
        this_cprob = CUMUL_PROB0;
    } else if (fern == 1) {
        console.log("Generation fern 1...");
        this_array = FERN_ARRAY1;
        this_cprob = CUMUL_PROB1;
    } else {
        console.log("Tried to use undefined array and cumulative probability.");
        return [];
    }

    // push the starting point
    new_points.push(vec2(x, y));

    // generate NUM_ITERATIONS number of points
    for (var i=0; i < NUM_ITERATIONS; i++) {
        // "randy" will choose the set of coefficients we're using this round
        var randy = Math.random();
        // the set of coefficients: contains [a, b, c, d, e, f]
        var abcdef;

        if        (randy < this_cprob[1]) {
            abcdef = grabcolumn(this_array, 0);
        } else if (randy < this_cprob[2]) {
            abcdef = grabcolumn(this_array, 1);
        } else if (randy < this_cprob[3]) {
            abcdef = grabcolumn(this_array, 2);
        } else if (randy < this_cprob[4]) {
            abcdef = grabcolumn(this_array, 3);
        } else {
            console.log("Invalid probability!?");
            return [];
        }
        
        // generate the next point
        var new_x = abcdef[0]*x + abcdef[1]*y + abcdef[4];
        var new_y = abcdef[2]*x + abcdef[3]*y + abcdef[5];

        // push the new point, and prepare for the next iteration
        new_points.push(vec2(new_x, new_y));
        x = new_x;
        y = new_y;
    }

    console.log("Points generated. Rescaling points to frame...");
    new_points = scaledown(new_points);
    console.log("Points rescaled.");
    return new_points;
}


function main() {
    var canvas = document.getElementById( "gl-canvas" );

    gl = WebGLUtils.setupWebGL( canvas );
    if ( !gl ) { console.log( "WebGL isn't available" ); return; }

    points = [].concat(makefern(0), makefern(1));
    //pts_fern0 = makefern(0);
    //pts_fern1 = makefern(1);

    //  Configure WebGL
    gl.viewport( 0, 0, canvas.width, canvas.height );
    gl.clearColor( 1.0, 1.0, 1.0, 1.0 );

    //  Load shaders and initialize attribute buffers
    program = initShaders( gl, "vertex-shader", "fragment-shader" );
 	if (!program) { console.log('Failed to intialize shaders.'); return; }
	gl.useProgram( program );

    // Load the data into the GPU
    var bufferId = gl.createBuffer();
    gl.bindBuffer( gl.ARRAY_BUFFER, bufferId );
    gl.bufferData( gl.ARRAY_BUFFER, flatten(points), gl.STATIC_DRAW );

    // Associate out shader variables with our data buffer
    var vPosition = gl.getAttribLocation( program, "vPosition" );
    gl.vertexAttribPointer( vPosition, 2, gl.FLOAT, false, 0, 0 );
    gl.enableVertexAttribArray( vPosition );

    // listen for mouse clicks, toggling the "user_fern" variable if there's a click
    // (event is defined with a big lambda function)
    window.addEventListener("mousedown", function() {
        user_fern = toggle01(user_fern);
        render();
    });

    // listen for keyboard presses, toggling the "user_color" variable if user presses E (uppercase or lowercase)
    // (event is defined with a big lambda function)
    window.addEventListener("keydown", function(event) {
        // VSCode told me that "event.keyCode" was deprecated, so I switched to the recommended event.key
        if (event.key == 'e' || event.key == 'E') {
                user_color = toggle01(user_color);
                render();
        }
    });
    

    render();
}

function render() {
    // clear previous fern, if any
    gl.clear( gl.COLOR_BUFFER_BIT );
    // set color according to "user_color" variable's current status
    gl.uniform1i(gl.getUniformLocation(program, "colorIndex"), user_color);
    // if user_fern=0, then draw the 0th fern, starting from index STARTPOINT and drawing NUM_ITERATIONS-STARTPOINT points
    // if user_fern=1, then draw the 1st fern, starting from index NUM_ITERATIONS + STARTPOINT (right after the 0th fern, and skipping the first STARTPOINT points) and rawing NUM_ITERATIONS-STARTPOINT points
    gl.drawArrays( gl.POINTS, user_fern*NUM_ITERATIONS + STARTPOINT, NUM_ITERATIONS - STARTPOINT);
    return;
}
