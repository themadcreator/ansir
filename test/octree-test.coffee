{expect} = require 'chai'
Octree = require '../src/octree'

randomPoint = -> new Octree.Point(
  Math.random() * 100
  Math.random() * 100
  Math.random() * 100
)

nearestPointLinear = (points, test) ->
  min = Infinity
  val = null
  for p, i in points
    if (distance = p.distanceSq(test)) < min
      min = distance
      val = i
  return val

describe 'Octree', ->

  it 'Can insert points', ->
    tree   = new Octree()
    points = [0...1000].map randomPoint
    for p, i in points
      tree.insert(p, i)

  it 'Can locate exact match points', ->
    tree   = new Octree()
    points = [0...1000].map randomPoint
    for p, i in points
      tree.insert(p, i)

    for p, i in points
      nearest = tree.nearest(p)
      expect(nearest.value).to.equal(i)

  it 'Can find same nearest point as linear search', ->
    tree   = new Octree()
    points = [0...1000].map randomPoint
    for p, i in points
      tree.insert(p, i)

    for run in [0...1000]
      test = randomPoint()
      nt = tree.nearest(test).value
      nl = nearestPointLinear(points, test)
      expect(nt).to.equal(nl)

