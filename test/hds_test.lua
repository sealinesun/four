-- Geometry viewer

require 'lubyk'

local Hds = require 'hds'
local Geometry = four.Geometry


local should = test.Suite("four")

function should.planeHDS()
  -- N.B. these assertions depend on the index given by Plane and 
  -- the way hdsFromTriangles operates. 

  local p = Geometry.Plane(1,2)
  local hds = Hds.FromTriangles(p.index)
  assertEqual(hds.vertex[1], 1)  
  assertEqual(hds.vertex[2], 2)
  assertEqual(hds.vertex[3], 3)
  assertEqual(hds.vertex[4], 6)

  assertEqual(hds.face[1], 1)
  assertEqual(hds.face[2], 4)

  assertEqual(hds.halfedge[1].dest, 2)
  assertEqual(hds.halfedge[1].face, 1)
  assertEqual(hds.halfedge[1].next, 2)
  assertEqual(hds.halfedge[1].twin, nil)

  assertEqual(hds.halfedge[2].dest, 3)
  assertEqual(hds.halfedge[2].face, 1)
  assertEqual(hds.halfedge[2].next, 3)
  assertEqual(hds.halfedge[2].twin, nil)

  assertEqual(hds.halfedge[3].dest, 1)
  assertEqual(hds.halfedge[3].face, 1)
  assertEqual(hds.halfedge[3].next, 1)
  assertEqual(hds.halfedge[3].twin, 4)

  assertEqual(hds.halfedge[4].dest, 3)
  assertEqual(hds.halfedge[4].face, 2)
  assertEqual(hds.halfedge[4].next, 5)
  assertEqual(hds.halfedge[4].twin, 3)

  assertEqual(hds.halfedge[5].dest, 4)
  assertEqual(hds.halfedge[5].face, 2)
  assertEqual(hds.halfedge[5].next, 6)
  assertEqual(hds.halfedge[5].twin, nil)

  assertEqual(hds.halfedge[6].dest, 1)
  assertEqual(hds.halfedge[6].face, 2)
  assertEqual(hds.halfedge[6].next, 4)
  assertEqual(hds.halfedge[6].twin, nil)
end

function should.planeTrianglesAdjacency()
  local p = Geometry.Plane(1,2)
  local hds = Hds.FromTriangles(p.index)
  local i = Hds.trianglesAdjacencyIndex(hds)

  assertEqual(i:getScalar(1), 0)
  assertEqual(i:getScalar(2), 0)
  assertEqual(i:getScalar(3), 1)
  assertEqual(i:getScalar(4), 1)
  assertEqual(i:getScalar(5), 2)
  assertEqual(i:getScalar(6), 3)

  assertEqual(i:getScalar(7), 0)
  assertEqual(i:getScalar(8), 1)
  assertEqual(i:getScalar(9), 2)
  assertEqual(i:getScalar(10), 2)
  assertEqual(i:getScalar(11), 3)
  assertEqual(i:getScalar(12), 3)

  
end




