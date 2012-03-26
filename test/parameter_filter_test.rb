require "test_helper"

module ActionController

  class ParamterFilterTest < MiniTest::Unit::TestCase

    def test_class_with_parameter_filter
      klass = Class.new
      klass.expects(:before_filter).with(:remove_filtered_parameters).once
      klass.send :include, ParameterFilter
    end

    def test_allowing_core_parameters
      controller = self.filtered_controller
      controller.params = { controller: "users", action: "index", id: 123 }
      controller.remove_filtered_parameters
      assert_equal [ :controller, :action, :id ], controller.params.keys
    end

    def test_removing_noncore_parameters
      controller = self.filtered_controller
      controller.params = { foo: 999 }
      assert_equal 999, controller.params[:foo]
      controller.remove_filtered_parameters
      assert_equal nil, controller.params[:foo]
    end

    def test_allowing_nested_fields
      controller = self.filtered_controller fields: { user: "email" }
      controller.params = { "user" => { "email" => "joe@example.com" } }
      assert_equal "joe@example.com", controller.params["user"]["email"]
      controller.remove_filtered_parameters
      assert_equal "joe@example.com", controller.params["user"]["email"]
    end

    def test_removing_nested_fields
      controller = self.filtered_controller
      controller.params = { "user" => { "email" => "joe@example.com" } }
      assert_equal "joe@example.com", controller.params["user"]["email"]
      controller.remove_filtered_parameters
      assert_equal nil, controller.params["user"]
    end

    protected

    def filtered_controller options = {}
      klass = Class.new
      klass.stubs :before_filter
      klass.send :include, ParameterFilter
      klass.send :accepts, options

      klass.new.tap do |controller|
        def controller.action_name; "index"; end
        def controller.params; @params ||= {}; end
        def controller.params= p; @params = p; end
      end
    end

  end

end
