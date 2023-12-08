var gl, points;

function main() {
    // grab the canvas that was set up in the HTML file with:
    // <canvas id="gl-canvas" width="512" height="512">
    var canvas = document.getElementById( "gl-canvas" );
    
    // Load webGL using the aforementioned canvas, exit if failed
    gl = WebGLUtils.setupWebGL( canvas );
    if ( !gl ) { alert( "WebGL isn't available" ); }

    // Load shaders and initialize attribute buffers
    // These are grabbed by name from HTML file by their <script id=[name] ...> tags
    var program = initShaders( gl, "vertex-shader", "fragment-shader" );
    // Load/Compile the "program", which is the combination of the two shaders. This is used implicitly in the gl.drawArrays(...) function later
    gl.useProgram( program );
    
    // create an array consisting of four vertices.
    // vec2 creates (x,y) relative coordinates from -1.0 to 1.0, normalized to the edges of the canvas
    var vertices = [
        // top-left square
        vec2(-0.5,  0.5),       //0
        vec2(-0.5,  0.0),
        vec2( 0.0,  0.0),
        vec2( 0.0,  0.5),
        // top-right triangle
        vec2( 0.0,  0.0),       //4
        vec2( 0.25, 0.5),
        vec2( 0.5,  0.0),
        // bottom-right square
        vec2( 0.0,  0.0),       //7
        vec2( 0.5,  0.0),
        vec2( 0.5, -0.5),
        vec2( 0.0, -0.5),
        // bottom-left triangle
        vec2(-0.25, 0.0),       //11
        vec2(-0.5, -0.5),
        vec2( 0.0, -0.5)
    ];

    // Load the data into the GPU
    var bufferId = gl.createBuffer();                                       // declare & initialize the buffer object
    gl.bindBuffer( gl.ARRAY_BUFFER, bufferId );                             // make the buffer interpretable as an array of points
    gl.bufferData( gl.ARRAY_BUFFER, flatten(vertices), gl.STATIC_DRAW );    // put the data from 'vertices' into the array, mark as single-use

    // set up the colors to be used
    var fColor = gl.getUniformLocation(program, "fColor");

    // Associate out shader variables with our data buffer
    var vPosition = gl.getAttribLocation( program, "vPosition" );           // grab memory address of attribute variable 'vPosition' in the vertex shader
    gl.vertexAttribPointer( vPosition, 2, gl.FLOAT, false, 0, 0 );          // binds current gl.ARRAY_BUFFER to the 'vPosition' memory address
        // vPosition    : indicates pointer of where the array of vertex vectors is stored
        // 2            : indicates number of components per vertex vector (2 for vec2)
        // gl.FLOAT     : enum to indicate type of components in the vertex vector (float)
        // false        : whether the vectors are normalized or not
        // 0            : spacing between the elements (0 = tightly-packed normal array)
        // 0            : which offset in the array to start at
    gl.enableVertexAttribArray( vPosition );                                // all attribute variables are disabled by default, so this enables it

    render(fColor);
};

function setColorRed(fColor) {
    let redColor  = vec4(1.0, 0.0, 0.0, 1.0);    // r,g,b=1,0,0 and alpha=opaque
    gl.uniform4fv(fColor, redColor);
};

function setColorBlue(fColor) {
    let blueColor  = vec4(0.0, 0.0, 1.0, 1.0);    // r,g,b=0,0,1 and alpha=opaque
    gl.uniform4fv(fColor, blueColor);
};

function render(fColor) {
    gl.clearColor( 0.0, 0.0, 0.0, 1.0 );                                    // prepare background color (sets the gl.COLOR_BUFFER_BIT)
    gl.clear( gl.COLOR_BUFFER_BIT );                                        // set background color based on gl.COLOR_BUFFER_BIT
    setColorBlue(fColor);
    gl.drawArrays( gl.TRIANGLE_FAN, 0, 4 );                                 // draw using the TRIANGLE_FAN mode, implicitly invoking the 'program'
        // gl.TRIANGLE_FAN      : drawing method
        // 0                    : which point in the array to use as start
        // 4                    : how many points total to draw in the array
    setColorRed(fColor);
    gl.drawArrays( gl.TRIANGLE_FAN, 4, 3 );                                 // draw using the TRIANGLE_FAN mode, implicitly invoking the 'program'
        // gl.TRIANGLE_FAN      : drawing method
        // 0                    : which point in the array to use as start
        // 4                    : how many points total to draw in the array
    setColorBlue(fColor);
    gl.drawArrays( gl.TRIANGLE_FAN, 7, 4 );                                 // draw using the TRIANGLE_FAN mode, implicitly invoking the 'program'
        // gl.TRIANGLE_FAN      : drawing method
        // 0                    : which point in the array to use as start
        // 4                    : how many points total to draw in the array
    setColorRed(fColor);
    gl.drawArrays( gl.TRIANGLE_FAN, 11, 3 );                                 // draw using the TRIANGLE_FAN mode, implicitly invoking the 'program'
        // gl.TRIANGLE_FAN      : drawing method
        // 0                    : which point in the array to use as start
        // 4                    : how many points total to draw in the array
}
