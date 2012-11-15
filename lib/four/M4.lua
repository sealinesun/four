--[[--
  # four.M4
  4x4 float matrices 

  We write aij the element of a located at the ith one-based row
  and jth one-based column.
  
  Constructor specify matrix elements in row-major order so that
  matrix definition look mathematically natural if you indent your
  code properly. Elements are stored and iterated over in
  column-major order.
--]]--

-- Module definition  

local lib = { type = 'four.M4' }
lib.__index = lib
four.M4 = lib
setmetatable(
  lib, 
  { __call = function(lib, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, 
                      a13, a14, a15, a16) 
      return lib.M4(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, 
                      a13, a14, a15, a16) end 
})

local V3 = four.V3

-- ## Constructors and accessors

local meta = {} -- for operators

function lib.M4(e11, e12, e13, e14, -- row 1
                e21, e22, e23, e24, -- row 2
                e31, e32, e33, e34, -- row 3
                e41, e42, e43, e44) -- row 4
  local o =  { e11, e21, e31, e41,  -- col 1
               e12, e22, e32, e42,  -- col 2
               e13, e23, e33, e43,  -- col 3
               e14, e24, e34, e44 } -- col 4
  setmetatable(o, meta)
  return o
end

local M4 = lib.M4

function lib.row(m, i) return four.V4(m[i], m[4 + i], m[8 + i], m[12 + i]) end
function lib.col(m, i)
  local b = i * 4
  return four.V4(m[b + 1], m[b + 2], m[b + 3], m[b + 4])
end

-- ## Converters

function lib.ofRows(r1, r2, r3, r4) 
  return M4(r1[1], r1[2], r1[3], r1[4],
            r2[1], r2[2], r2[3], r2[4],
            r3[1], r3[2], r3[3], r3[4],
            r4[1], r4[2], r4[3], r4[4])
end

function lib.ofCols(c1, c2, c3, c4) 
  return M4(c1[1], c2[1], c3[1], c4[1],
            c1[2], c2[2], c3[2], c4[2],
            c1[3], c2[3], c3[3], c4[3],
            c1[4], c2[4], c3[4], c4[4])
end

function lib.tostring(m) 
  return string.format("(% g % g % g % g )\n(% g % g % g % g )\n(% g % g % g % g )\n(% g % g % g % g )",
                       m[1], m[5], m[ 9], m[13],
                       m[2], m[6], m[10], m[14],
                       m[3], m[7], m[11], m[15],
                       m[4], m[8], m[12], m[16])
end

-- ## Constants 

function lib.zero() 
  return M4(0, 0, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 0, 
            0, 0, 0, 0)
end

function lib.id()
  return M4(1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1)
end

-- ## Functions

function lib.neg(a)
  local r = {} for i in 1, 16 do r[i] = -a[i] end return r
end

function lib.add(a, b)
  local r = {} for i in 1, 16 do r[i] = a[i] + b[i] end return r
end

function lib.sub(a, b)
  local r = {} for i in 1, 16 do r[i] = a[i] - b[i] end return r
end

function lib.mul(a, b)
  return M4 (a[1] * b[1] + a[5] * b[2] + a[9] * b[3] + a[13] * b[4], -- row 1
             a[1] * b[5] + a[5] * b[6] + a[9] * b[7] + a[13] * b[8],
             a[1] * b[9] + a[5] * b[10] + a[9] * b[11] + a[13] * b[12],
             a[1] * b[13] + a[5] * b[14] + a[9] * b[15] + a[13] * b[16],
             a[2] * b[1] + a[6] * b[2] + a[10] * b[3] + a[14] * b[4], -- row 2
             a[2] * b[5] + a[6] * b[6] + a[10] * b[7] + a[14] * b[8],
             a[2] * b[9] + a[6] * b[10] + a[10] * b[11] + a[14] * b[12],
             a[2] * b[13] + a[6] * b[14] + a[10] * b[15] + a[14] * b[16],
             a[3] * b[1] + a[7] * b[2] + a[11] * b[3] + a[15] * b[4], -- row 3
             a[3] * b[5] + a[7] * b[6] + a[11] * b[7] + a[15] * b[8],
             a[3] * b[9] + a[7] * b[10] + a[11] * b[11] + a[15] * b[12],
             a[3] * b[13] + a[7] * b[14] + a[11] * b[15] + a[15] * b[16],
             a[4] * b[1] + a[8] * b[2] + a[12] * b[3] + a[16] * b[4], -- row 4
             a[4] * b[5] + a[8] * b[6] + a[12] * b[7] + a[16] * b[8],
             a[4] * b[9] + a[8] * b[10] + a[12] * b[11] + a[16] * b[12],
             a[4] * b[13] + a[8] * b[14] + a[12] * b[15] + a[16] * b[16])
end

function lib.emul(a, b) -- element-wise multiplication
  local r = {} for i in 1, 16 do r[i] = a[i] * b[i] end return r
end

function lib.ediv(a, b) -- element-wise division
  local r = {} for i in 1, 16 do r[i] = a[i] / b[i] end return r
end

function lib.smul(s, b) -- scalar multiplication
  local r = {} for i in 1, 16 do r[i] = s * a[i] end return r
end

function lib.transpose(a) 
  return M4(m[1], m[5], m[ 9], m[13],
            m[2], m[6], m[10], m[14],
            m[3], m[7], m[11], m[15],
            m[4], m[8], m[12], m[16])
end

function lib.trace(a) return a[1] + a[6] + a[11] + a[16] end
function lib.det(a) 
  -- N.B. mij symbols for minors are written as zero-based row/column
  local d1 = (a[11] * a[16]) - (a[12] * a[15]) -- second minor
  local d2 = (a[7] * a[16]) - (a[8] * a[15])
  local d3 = (a[7] * a[12]) - (a[8] * a[11]) 
  local m00 = (a[6] * d1) - (a[10] * d2) + (a[14] * d3)   -- minor
  local m10 = (a[5] * d1) - (a[9] * d2) + (a[13] * d3)
  local d4 = (a[9] * a[14]) - (a[10] * a[13])
  local d5 = (a[5] * a[14]) - (a[6] * a[13]) 
  local d6 = (a[5] * a[10]) - (a[6] * a[9]) 
  local m20 = (a[8] * d4) - (a[12] * d5) + (a[16] * d6)
  local m30 = (a[7] * d4) - (a[11] * d5) + (a[15] * d6) 
  return (a[1] * m00) - (a[2] * m10) + (a[3] * m20) - (a[4] * m30) 
end

function lib.inv(a)
  -- N.B. mij symbols for minors are written as zero-based row/column
  local d1 = (a[11] * a[16]) - (a[12] * a[15]) -- second minor
  local d2 = (a[7] * a[16]) - (a[8] * a[15])  
  local d3 = (a[7] * a[12]) - (a[8] * a[11])  
  local m00 = (a[6] * d1) - (a[10] * d2) + (a[14] * d3)    -- minor
  local m10 = (a[5] * d1) - (a[9] * d2) + (a[13] * d3)  
  local d4 = (a[9] * a[14]) - (a[10] * a[13]) 
  local d5 = (a[5] * a[14]) - (a[6] * a[13]) 
  local d6 = (a[5] * a[10]) - (a[6] * a[9]) 
  local m20 = (a[8] * d4) - (a[12] * d5) + (a[16] * d6)  
  local m30 = (a[7] * d4) - (a[11] * d5) + (a[15] * d6) 
  local d7 = (a[3] * a[16]) - (a[4] * a[15]) 
  local d8 = (a[3] * a[12]) - (a[4] * a[11])  
  local m01 = (a[2] * d1) - (a[10] * d7) + (a[14] * d8)  
  local m11 = (a[1] * d1) - (a[9] * d7) + (a[13] * d8)  
  local d9 = (a[1] * a[14]) - (a[2] * a[13])  
  local d10 = (a[1] * a[10]) - (a[2] * a[9])  
  local m21 = (a[4] * d4) - (a[12] * d9) + (a[16] * d10)  
  local m31 = (a[3] * d4) - (a[11] * d9) + (a[15] * d10) 
  local d11 = (a[3] * a[8]) - (a[4] * a[7]) 
  local m02 = (a[2] * d2) - (a[6] * d7) + (a[14] * d11)  
  local m12 = (a[1] * d2) - (a[5] * d7) + (a[13] * d11)  
  local d12 = (a[1] * a[6]) - (a[2] * a[5])  
  local m22 = (a[4] * d5) - (a[8] * d9) + (a[16] * d12)  
  local m32  =(a[3] * d5) - (a[7] * d9) + (a[15] * d12)  
  local m03 = (a[2] * d3) - (a[6] * d8) + (a[10] * d11)  
  local m13 = (a[1] * d3) - (a[5] * d8) + (a[9] * d11)  
  local m23 = (a[4] * d6) - (a[8] * d10) + (a[12] * d12)  
  local m33 = (a[3] * d6) - (a[7] * d10) + (a[11] * d12)  
  local det = (a[1] * m00) - (a[2] * m10) + (a[3] * m20) - (a[4] * m30)
  return M4 ( m00 / det, -m10 / det,  m20 / det, -m30 / det,
             -m01 / det,  m11 / det, -m21 / det,  m31 / det,
              m02 / det, -m12 / det,  m22 / det, -m32 / det,
             -m03 / det,  m13 / det, -m23 / det,  m33 / det)
end

-- ## 3D space transforms

-- translates in 3D space according to `d`
function lib.move(d) 
  return M4(1, 0, 0, d[1],
            0, 1, 0, d[2],
            0, 0, 1, d[3],
            0, 0, 0, 1)
end

function lib.getMove(m) return V3(m[13], m[14], m[15]) end


-- rotates 3D space to map the *unit* vector `u` on the *unit* vector `v`
function lib.rotMap(u, v) 
  local n = V3.cross(u, v)
  local e = V3.dot(u, v)
  local h = 1 / (1 + e) 
  local x = n[1] 
  local y = n[2] 
  local z = n[3] 
  local xy = x * y 
  local xz = x * z 
  local yz = y * z
  return M4(e + h * x * x,    h * xy - z,     h * xz + y, 0,
               h * xy + z, e + h * y * y,     h * yz - x, 0,
               h * xz - y,    h * yz + x,  e + h * z * z, 0,
                        0,             0,              0, 1)
end

-- rotates 3D space by `theta` around the *unit* vector `v`
function lib.rotAxis(u, theta)
  local xy = u[1] * u[2] 
  local xz = u[1] * u[3] 
  local yz = u[2] * u[3] 
  local c = math.cos(theta) 
  local one_c = 1. - c 
  local s = math.sin(theta)
  return M4(u[1] * u[1] * one_c + c, -- row 1
            xy * one_c - u[3] * s,
            xz * one_c + u[2] * s,
            0,
            xy * one_c + u[3] * s,  -- row 2
            u[2] * u[2] * one_c + c,
            yz * one_c - u[1] * s, 
            0,
            xz * one_c - u[2] * s,  -- row 3
            yz * one_c + u[1] * s,
            u[3] * u[3] * one_c + c,
            0,
            0, 0, 0, 1)             -- row 4
end

-- `rot_zyx(V3(x, y, z))` rotates 3D space first by `x` around the x-axis,
-- then by `y` around the y-axis and finally by `z` around the z-axis
function lib.rotZYX(r)
  local cz = math.cos(r[3]) local sz = math.sin(r[3])
  local cy = math.cos(r[2]) local sy = math.sin(r[2])
  local cx = math.cos(r[1]) local sx = math.sin(r[1])
  return M4(cy * cz, sy * sx * cz - cx * sz, sy * cx * cz + sx * sz, 0,
            cy * sz, sy * sx * sz + cx * cz, sy * cx * sz - sx * cz, 0,
                -sy,                cy * sx,                cy * cx, 0,
                  0,                      0,                      0, 1)
end

-- scales 3D space in the x, y, and z dimensions according to `s`
function lib.scale(s)
  return M4(s[1], 0   , 0   , 0,
            0   , s[2], 0   , 0,
            0   , 0   , s[3], 0,
            0   , 0   , 0   , 1)
end

-- `rigid(d, axis, theta)` is the rigid body transformation of 3D space
-- that rotates by `axis`,`angle` and then translate by `d`
function lib.rigid(d, axis, theta) 
  local r = lib.rot_axis3D(axis, theta)
  r[13] = d[1]; -- set translation in col 4
  r[14] = d[2]; 
  r[15] = d[3];
  return r
end

-- `rigidq(d, q)` is the rigid body transform of 3D space
-- that rotates by the quaternion `q` and then translates by `d`
function lib.rigidq(d, q)
  local r = four.Quat.toM4(q)
  r[13] = d[1]; -- set translation in col 4
  r[14] = d[2];
  r[15] = d[3];
  return r
end

-- `rigidScale(d, axis, theta, scale)` is like `rigid(d, axis, theta)` but 
-- it starts by scaling according to `scale`
function lib.rigidScale(d, axis, theta, scale)
  local r = lib.rigid(d, axis, theta)
  r[1] = r[1] * s[1] -- scale col 1
  r[2] = r[2] * s[1]  
  r[3] = r[3] * s[1]  
  r[5] = r[5] * s[2] -- scale col 2
  r[6] = r[6] * s[2]
  r[7] = r[7] * s[2]
  r[9] = r[9] * s[3] -- scale col 3
  r[10] = r[10] * s[3]
  r[11] = r[11] * s[3]
  return r
end

function lib.rigidqScale(d, q, scale)
  local r = lib.rigidq(d, q) 
  r[1] = r[1] * s[1] -- scale col 1
  r[2] = r[2] * s[1]  
  r[3] = r[3] * s[1]  
  r[5] = r[5] * s[2] -- scale col 2
  r[6] = r[6] * s[2]
  r[7] = r[7] * s[2]
  r[9] = r[9] * s[3] -- scale col 3
  r[10] = r[10] * s[3]
  r[11] = r[11] * s[3]
  return r
end

-- ## 4D space transformation

-- scales 4D space in the x, y, z and w dimensions according to `s`
function lib.scale4D(s)
  return M4(s[1],    0,    0,    0,
            0   , s[2],    0,    0,
            0   ,    0, s[3],    0,
            0   ,    0,    0,  s[4])
end

-- ## Traversal

function lib.map(f, m)
  local r = {} 
  for c = 1, 4 do
    local b = (c - 1) * 4 
    for r = 1, 4 do r[b + r] = f(m[b + r]) end
  end
  return r
end

function lib.mapi(f, m)
  local r = {} 
  for c = 1, 4 do
    local b = (c - 1) * 4 
    for r = 1, 4 do r[b + r] = f(r, c, m[b + r]) end
  end
  return r
end

function lib.fold(f, acc, m)
  local acc = acc 
  for c = 1, 4 do
    local b = (c - 1) * 4
    for r = 1, 4 do acc = f(acc, m[b + r]) end
  end
  return acc  
end

function lib.foldi(f, acc, m)
  local acc = acc 
  for c = 1, 4 do
    local b = (c - 1) * 4
    for r = 1, 4 do acc = f(acc, r, c, m[b + r]) end
  end
  return acc  
end

function lib.iter(f, m)
  for c = 1, 4 do
    local b = (c - 1) * 4
    for r = 1, 4 do acc = f(r, m[b + r]) end
  end
end

function lib.iter(f, m)
  for c = 1, 4 do
    local b = (c - 1) * 4
    for r = 1, 4 do acc = f(r, c, m[b + r]) end
  end
end

-- ## Predicates

function lib.forAll(p, m)
  local r = true 
  for i in 1, 16 do 
    if not p(m[i]) then r = false break end 
  end
  return r
end

function lib.exists(p, v) 
  local r = false
  for i in 1, 16 do 
    if p(m[i]) then r = true break end 
  end
  return r
end

function lib.equal(a, b)
  local r = true
  for i in 1, 16 do 
    if a[i] ~= b[i] then r = false break end
  end
  return r
end

function lib.equalF(f, u, v)
  local r = true
  for i in 1, 16 do 
    if not f(a[i],b[i]) then r = false break end
  end
  return r
end

function lib.compare(u, v) error ("TODO") end
function lib.compareF(f, u, v) error ("TODO") end

-- ## Operators

meta.__unm = lib.neg
meta.__add = lib.add
meta.__sub = lib.sub
meta.__mul = lib.mul
meta.__tostring = lib.tostring






