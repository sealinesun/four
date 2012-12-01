--[[--
  h1. four.Effect

  An effect defines either a configuration of the graphics pipeline 
  or a list of Effects for rendering a Geometry object.
--]]--

local lib = { type = 'four.Effect' }
lib.__index = lib
four.Effect = lib
setmetatable(lib, { __call = function(lib, ...) return lib.new(...) end})

local Color = four.Color
local Effect = lib

-- h2. Render states

--[[--
h3. Face culling
In four, the convention is that faces with a counter clock-wise orientation
are front faces.
--]]--

lib.CULL_NONE = 1
lib.CULL_FRONT = 2
lib.CULL_BACK = 3

-- h2. Constructor

--[[-- 
  @Effect(def)@ is a new effect object. @def@ keys:
  * @version@, the GLSL version string (defaults to @"150"@).
  * @uniforms@, key/value table, defining values for the given 
    uniforms.
  * @vertex@, vertex shader source.
  * @geometry@, geometry shader source (optional).
  * @fragment@, fragment shader source.
  * @cull_face@, face culling (defaults to @CULL_BACK@).
  * @polygon_offset@, scale and unit used to calculate depth values
    (defaults to @{ factor = 0, units = 0 }@).
--]]--
function lib.new(def)
  local self = 
    { version = "150 core",
      uniforms = {},
      vertex = lib.Shader [[void main(void) {}]],
      geometry = nil, -- optional
      fragment = lib.Shader [[void main(void) {}]],
      cull_face = lib.CULL_BACK,
      polygon_offset = { factor = 0, units = 0 },}
  setmetatable(self, lib)
  if def then self:set(def) end
  return self
end

function lib:set(def) 
  if def.version then self.version = def.version end
  if def.uniforms then self.uniforms = def.uniforms end
  if def.vertex then self.vertex = def.vertex end
  if def.geometry then self.geometry = def.geometry end
  if def.fragment then self.fragment = def.fragment end
  if def.cull_face then self.cull_face = def.cull_face end
  if def.polygon_offset then self.polygon_offset = def.polygon_offset end
end

-- h2. Shader constructor

function lib.Shader(src) 
  local trace = lk.split(debug.traceback(),'\n\t')[3]
  local file, last_line = string.match(trace, '^([^:]+):([^:]+):')
  local src_line_count = #lk.split(src, '\n')
  return { file = file, line = last_line - src_line_count, src_fragment = src }
end

-- h2. Special Uniforms

lib.MODEL_TO_WORLD = { special_uniform = true } 
lib.MODEL_TO_CAMERA = { special_uniform = true } 
lib.MODEL_TO_CLIP = { special_uniform = true } 
lib.MODEL_NORMAL_TO_CAMERA = { special_uniform = true } 
lib.WORLD_TO_CAMERA = { special_uniform = true } 
lib.CAMERA_TO_CLIP = { special_uniform = true } 
lib.CAMERA_RESOLUTION = { special_uniform = true } 

local function glslVersion(v) return string.format("#version %s\n", v) end

function lib:glslPreamble(pretty)
  local decls = ""
  local nl = pretty and "\n" or ""
  if not pretty then decls = decls .. "\n" end
  return glslVersion(self.version) .. decls
end

-- h2. Effect shaders

function lib:vertexShaderSource(pretty) 
  local v = self.vertex
  local pre = self:glslPreamble(pretty)
  v.src =  pre .. v.src_fragment
  return  v
end

function lib:geometryShaderSource(pretty)
  local g = self.geometry
  if not g then return nil end
  local pre = self:glslPreamble(pretty)
  g.src =  pre .. g.src_fragment
  return g
end

function lib:fragmentShaderSource(pretty)
  local f = self.fragment
  local pre = self:glslPreamble(pretty)
  f.src =  pre .. f.src_fragment
  return f
end

-- h2. Predefined Effects

--[[--
  @Wireframe(def)@ renders triangle geometry as wireframe. @def@ keys:
  * @fill@, a Color defining the triangle fill color (defaults 
    to Color.white ()).
  * @wire@, a Color defining the wireframe color (default to Color.red().

  Effect adapted from http://cgg-journal.com/2008-2/06/index.html.
--]]--
function lib.Wireframe(def)
  return Effect
  {
    uniforms = 
      { 
        model_to_clip = Effect.modelToClip,
        resolution = Effect.cameraResolution,
        fill = def and def.fill or Color.white (),
        wire = def and def.wire or Color.red (),
        hidden_surface = true
      },
      
    vertex = Effect.Shader [[
      in vec4 vertex;
      void main() { gl_Position = model_to_clip * vertex; }
    ]],  

    geometry = Effect.Shader [[
      layout(triangles) in;
      layout(triangle_strip, max_vertices=3) out;
      noperspective out vec3 dist;
      void main(void)
      {
        vec2 p0 = resolution * gl_in[0].gl_Position.xy/gl_in[0].gl_Position.w;
        vec2 p1 = resolution * gl_in[1].gl_Position.xy/gl_in[1].gl_Position.w;
        vec2 p2 = resolution * gl_in[2].gl_Position.xy/gl_in[2].gl_Position.w;
  
        vec2 v0 = p2 - p1;
        vec2 v1 = p2 - p0;
        vec2 v2 = p1 - p0;
        float area = abs(v1.x * v2.y - v1.y * v2.x);

        dist = vec3(area / length(v0), 0, 0);
        gl_Position = gl_in[0].gl_Position;
        EmitVertex();
	
        dist = vec3(0, area/length(v1), 0);
        gl_Position = gl_in[1].gl_Position;
        EmitVertex();

        dist = vec3(0, 0, area/length(v2));
        gl_Position = gl_in[2].gl_Position;
        EmitVertex();

        EndPrimitive();
      }  
 ]],

  fragment = Effect.Shader [[
    noperspective in vec3 dist;
    out vec4 color;
    void main(void)
    {
      float d = min(dist[0],min(dist[1],dist[2]));
      float I = exp2(-2*d*d);
      if (!hidden_surface && I < 0.01) { discard; }
      color = mix(fill, wire, I); // I*wire + (1.0 - I)*fill;
    }
  ]]
}
end


--[[--
  @Normals(def)@ renders the normals of geometry.
  * @normal_scale@, a scale factor to apply to the normals.
  * @normal_color_start@, color at the starting point of the vector.
  * @normal_color_end@, color at the end of vector. 
--]]--
function lib.Normals(def)
return Effect
{
  uniforms = 
    { model_to_cam = Effect.modelToCamera,
      normal_to_cam = Effect.normalModelToCamera,
      cam_to_clip = Effect.cameraToClip,
      normal_scale = def and def.normal_scale or 0.1,
      normal_color_start = def and def.normal_color_start or Color.black(),
      normal_color_end = def and def.normal_color_end or Color.white() },
    
  vertex = Effect.Shader [[
      in vec3 vertex;
      in vec3 normal;
      out vec4 v_position;
      out vec3 v_snormal;

      void main() 
      { 
         v_position = model_to_cam * vec4(vertex, 1.0);
         v_snormal = normal_scale * normalize(normal_to_cam * normal);
      }
    ]],  
  
  geometry = Effect.Shader [[
    layout(triangles) in;
    layout(line_strip, max_vertices = 6) out;

    in vec4 v_position[3];
    in vec3 v_snormal[3];
    out vec4 g_color;

    void main()
    {
       for (int i = 0; i < 3; i++)
       {
         gl_Position = cam_to_clip * v_position[i];
         g_color = normal_color_start;
         EmitVertex();

         gl_Position = cam_to_clip * (v_position[i] + vec4(v_snormal[i], 0.0));
         g_color = normal_color_end;
         EmitVertex();

         EndPrimitive();
       }
    }
  ]],
  
  fragment = Effect.Shader [[
    in vec4 g_color;
    out vec4 f_color;
    void main(void) { f_color = g_color; }
  ]]
}
end

