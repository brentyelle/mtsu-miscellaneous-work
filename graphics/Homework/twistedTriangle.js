// Twisted Tritheta using Tessellation
// The Outer triangle is tessellated 5 timesa
// The points of the resulting triangle are twisted "THETA" degrees

const THETA_DEG   = 120.0;                       // angle by which the triangle will be twisted at d=1
const THETA       = THETA_DEG * (Math.PI/180.0)
const COS30       = Math.cos(Math.PI/6.0);  // cos(30°) = sqrt(3/4)
const SIN30       = 0.5                     // sin(30°) = 1/2
const RADIUS      = 0.6;                    // radius of circle circumscribed around original triangle (before twisting)
const SPLIT_LIMIT = 4;                      // number of iterations the triangle will be subdivided into a sub-lattice (4 sub-triangles per iteration)
var canvas;
var gl;
var points = [];

window.onload = function init()
{
    canvas = document.getElementById( "gl-canvas" );
    
    gl = WebGLUtils.setupWebGL( canvas );
    if ( !gl ) { alert( "WebGL isn't available" ); }
        
    //
    //  Initialize our data for the Sierpinski Gasket
    //

    // First, initialize the corners of an equilateral triangle with three points.
    // The points are 
    var vertices = [
        vec2(  0.0,  RADIUS),                       // top vertex
        vec2(  COS30 * RADIUS, -SIN30 * RADIUS),     // bottom-right vertex
        vec2( -COS30 * RADIUS, -SIN30 * RADIUS)      // bottom-left vertex
    ];

    split_triangle_into_lattice( vertices[0], vertices[1], vertices[2], SPLIT_LIMIT);

    //
    //  Configure WebGL
    //
    gl.viewport( 0, 0, canvas.width, canvas.height );
    gl.clearColor( 1.0, 1.0, 1.0, 1.0 );

    //  Load shaders and initialize attribute buffers
    
    var program = initShaders( gl, "vertex-shader", "fragment-shader" );
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
};

function add_triangle( a, b, c )
{
    var aa, bb, cc;

    // twist the three points "THETA" degrees 
    // according their distance to the origin 
    aa = twist(a);
    bb = twist(b);
    cc = twist(c);

    points.push( aa, bb, cc );
}

// rotate a vertex p by THETA degrees
function twist(p)
{
    let magnitude = Math.sqrt(p[0]*p[0] + p[1]*p[1]);                             // euclidean norm of the point, used in rotation function
    let x = p[0]*Math.cos(magnitude*THETA) - p[1]*Math.sin(magnitude*THETA);      // find twisted x coordinate
    let y = p[0]*Math.sin(magnitude*THETA) + p[1]*Math.cos(magnitude*THETA);      // find twisted y coordinate

    return (vec2(x, y));
}

function split_triangle_into_lattice( a, b, c, count )
{

    // check for end of recursion
    
    if ( count === 0 ) {
        add_triangle( a, b, c );
    }
    else {
    
        //bisect the sides
        
        let ab = mix( a, b, 0.5 );
        let ac = mix( a, c, 0.5 );
        let bc = mix( b, c, 0.5 );

        --count;

        // four new triangles
        
        split_triangle_into_lattice(  a, ab, ac, count );
        split_triangle_into_lattice(  c, ac, bc, count );
        split_triangle_into_lattice(  b, bc, ab, count );
        split_triangle_into_lattice( ab, bc, ac, count );
    }
}

function render()
{
    gl.clear( gl.COLOR_BUFFER_BIT );
    gl.drawArrays( gl.TRIANGLES, 0, points.length );
}