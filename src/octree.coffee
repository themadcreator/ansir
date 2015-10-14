
class Octree

  internal : false

  constructor : (
    @_order  = 16
    @_center = new Octree.Point(0,0,0)
  ) ->

  get : (point) ->
    node = @
    while node.internal
      node = node._childAt(point)
    return node._dataValue

  insert : (point, value) ->
    node = @
    while node.internal
      node = node._childAt(point)
    node._insert(point,value)
    return

  nearest : (point, best = null) ->
    # Return if best is already better than anything in this node
    halfSize = Math.pow(2, @_order - 1)
    if best? and (
       point.x < @_center.x - halfSize - best.distance or
       point.x > @_center.x + halfSize + best.distance or
       point.y < @_center.y - halfSize - best.distance or
       point.y > @_center.y + halfSize + best.distance or
       point.z < @_center.z - halfSize - best.distance or
       point.z > @_center.z + halfSize + best.distance
      )
      return best

    # If we have a value, test ourselves
    if @_dataPoint?
      distance = @_dataPoint.distance(point)
      if not best?
        best = {
          distance : distance
          point    : @_dataPoint
          value    : @_dataValue
        }
      else if distance < best.distance
        best = {
          distance : distance
          point    : @_dataPoint
          value    : @_dataValue
        }

    # Finally, recurse children starting at most likely index
    if @_children?
      startIndex = @_toChildIndex(point)
      for i in [0...8]
        idx = (i + startIndex) % 8
        best = @_children[idx].nearest(point, best)

    return best

  _internalize : ->
    @internal = true
    quarterSize = Math.pow(2, @_order - 2)

    @_children = new Array(8)
    for i in [0...8]
      @_children[i] = new @constructor(
        (@_order - 1)
        @_toCenterPoint(i, quarterSize)
      )
    return

  _toCenterPoint : (index, quarterSize) ->
    x = if (index & 1) is 0 then @_center.x - quarterSize else @_center.x + quarterSize
    y = if (index & 2) is 0 then @_center.y - quarterSize else @_center.y + quarterSize
    z = if (index & 4) is 0 then @_center.z - quarterSize else @_center.z + quarterSize
    return new Octree.Point(x, y, z)

  _toChildIndex : (point) ->
    x = if point.x < @_center.x then 0 else 1
    y = if point.y < @_center.y then 0 else 1
    z = if point.z < @_center.z then 0 else 1
    return (z << 2 | y << 1 | x)

  _childAt : (point) ->
    return @_children[@_toChildIndex(point)]

  _insert : (point, value) ->
    # insert here if empty
    if not @_dataPoint?
      @_dataPoint = point
      @_dataValue = value
      return

    # detect direct collisions before attempting to subdivide
    if @_dataPoint.x is point.x and
       @_dataPoint.y is point.y and
       @_dataPoint.z is point.z
      return # throw new Error('Collision', @_dataValue)

    # otherwise we must split!
    # extract current data values
    currentPoint = @_dataPoint
    currentValue = @_dataValue
    delete @_dataPoint
    delete @_dataValue

    @_internalize()

    # re-insert both
    @_childAt(currentPoint).insert(currentPoint, currentValue)
    @_childAt(point).insert(point, value)
    return

class Octree.Point
  @centroid : (pts) ->
    c = new Octree.Point()
    for p in pts then c.add(p)
    return c.scale(1.0 / pts.length)

  constructor : (@x = 0, @y = 0, @z = 0) ->

  distanceSq : (p) ->
    dx = p.x - @x
    dy = p.y - @y
    dz = p.z - @z
    return (dx * dx) + (dy * dy) + (dz * dz)

  distance : (p) ->
    return Math.sqrt(@distanceSq(p))

  add : (p) ->
    @x += p.x
    @y += p.y
    @z += p.z
    return @

  scale : (s) ->
    @x *= s
    @y *= s
    @z *= s
    return @

  valueOf : ->
    "#{@x.toFixed(2)}, #{@y.toFixed(2)}, #{@z.toFixed(2)}"


module.exports = Octree