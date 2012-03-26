require "parameter_filter/version"

# When a controller has ParameterFilter included, it will by default remove
# everything from params. The way to receive parameters is to specifically
# allow them with accept_fields.

module ParameterFilter

  module ClassMethods

    def accept_fields_parser fields
      table = {}

      [fields].flatten.compact.uniq.each do |field|
        case field

        when Symbol, String
          table[field.to_s] = {}

        when Hash
          field.each do |key, value|
            table[key.to_s] = accept_fields_parser value
          end

        end
      end

      table
    end

    def accepts options = {}
      @_accepted_fields ||= { nil => { "controller" => {}, "action" => {}, "id" => {} } }
      fields = options[:fields] || options[:field] || {}

      case options[:on]
      when Array
        options[:on].each do |k|
          @_accepted_fields[k.to_s] = accept_fields_parser fields
        end

      when Symbol, String
        @_accepted_fields[options[:on].to_s] = accept_fields_parser fields

      else
        @_accepted_fields[nil] ||= {}
        @_accepted_fields[nil].merge! accept_fields_parser fields

      end
    end

  end

  module InstanceMethods

    def remove_filtered_parameters accepted_fields = nil, parameters = nil
      if !accepted_fields && !parameters
        accepted_fields = self.class.instance_variable_get("@_accepted_fields") || {}
        fields = (accepted_fields[nil] || {}).merge(accepted_fields[self.action_name] || {})
        remove_filtered_parameters fields, self.params
      elsif parameters
        accepted_keys = ParameterFilter.field_keys accepted_fields
        accepted_keys += [ :controller, :action, :id ] if parameters == params
        parameters.slice! *accepted_keys

        ParameterFilter.each_field accepted_fields do |k, v|
          remove_filtered_parameters v, parameters[k] if parameters[k].kind_of? Hash
        end
      end
    end

  end

  def self.each_field fields
    [ fields ].flatten.compact.uniq.each do |f|
      case f
      when Hash then f.each { |k, v| yield k, v }
      when String, Symbol then yield f
      end
    end
  end

  def self.field_keys fields
    fields.map do |field|
      case field
      when Array then field_keys field
      when Hash then field.keys
      else field
      end
    end.flatten.compact.uniq
  end

  def self.included base
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
    base.send :before_filter, :remove_filtered_parameters
  end

end
