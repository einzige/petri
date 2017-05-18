require 'minitest/autorun'
require 'petri'

class LoadFromFileTest < Minitest::Test
  def test_empty_net
    net = Petri::Net.from_file('test/empty_net.json')

    assert_equal [], net.places
    assert_equal [], net.transitions
    assert_equal [], net.arcs
  end

  def test_net
    net = Petri::Net.from_file('test/net.json')

    assert_place net.places.first
    assert_transition net.transitions.first
    assert_arc net.arcs.first
  end

  private

  def assert_place(place)
    assert_equal 1, place.identifier
    refute_nil place.guid
  end

  def assert_transition(transition)
    refute_nil transition.guid
    assert_equal 2, transition.identifier
    assert transition.automated?
  end

  def assert_arc(arc)
    refute_nil arc.guid
    assert arc.regular?
  end
end
