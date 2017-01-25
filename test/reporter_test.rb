require 'test_helper'
require 'state_inspector/observers'
include StateInspector::Observers
class A; attr_writer :thing end
class B; attr_accessor :thing end
class C; attr_accessor :thing end
class D; attr_accessor :thing end
class F; attr_accessor :thing end
class G; def thing(one:); yield end end
StateInspector::Reporter[A] = InternalObserver
StateInspector::Reporter[D] = InternalObserver.new
StateInspector::Reporter[F] = InternalObserver.new
StateInspector::Reporter[G] = InternalObserver.new

D.toggle_informant
F.toggle_informant

class ReporterTest < Minitest::Test
  def observer; StateInspector::Reporter[A] end
  def teardown; observer.purge end

  def test_reports_get_made_from_setter_methods
    A.toggle_informant
    a = A.new
    a.thing = 4
    assert_equal [[a, "@thing", nil, 4]], observer.values
    a.thing = 5
    assert_equal [
        [a, "@thing", nil, 4],
        [a, "@thing", 4, 5]
      ],
      observer.values
    a.thing = nil
    assert_equal [
        [a, "@thing", nil, 4],
        [a, "@thing", 4, 5],
        [a, "@thing", 5, nil]
      ],
      observer.values
  ensure
    A.toggle_informant
  end

  def test_internal_observer_can_have_separate_observers
    d = D.new
    d.thing = 4
    assert_equal [[d, "@thing", nil, 4]], 
      StateInspector::Reporter[D].values

    f = F.new
    f.thing = 4
    assert_equal [[f, "@thing", nil, 4]], 
      StateInspector::Reporter[F].values

    assert_empty observer.values
  end

  def test_null_observer_for_no_obervers
    StateInspector::Reporter.default InternalObserver
    b = B.new
    b.toggle_informant
    b.thing = 42
    assert_equal [[b, "@thing", nil, 42]], StateInspector::Reporter[B].values
    StateInspector::Reporter.default NullObserver
    assert_equal NullObserver, StateInspector::Reporter[B]
  end

  def test_session_logger_observer
    StateInspector::Reporter[C] = SessionLoggerObserver
    c = C.new
    c.toggle_informant
    c.thing = 42
    assert_equal [[c.to_s, "@thing", nil, "42"]], StateInspector::Reporter[C].values
    c.thing = :aqua
    assert_equal [
        [c.to_s, "@thing", nil, "42"],
        [c.to_s, "@thing", "42", :aqua]
      ],
      StateInspector::Reporter[C].values
    file = StateInspector::Reporter[C].instance_variable_get(:@file)
    assert File.exist? file
    StateInspector::Reporter[C].purge
    refute File.exist? file
  end

  def test_good_behavior_for_kwargs_and_a_block
    g = G.new
    toggle_snoop_clean(g) do
      g.state_inspector.snoop_methods :thing
      g.thing(one: 4) { nil }
      assert_equal [[g, :thing, {:one => 4}]], 
        StateInspector::Reporter[G].values
    end
  end
end
