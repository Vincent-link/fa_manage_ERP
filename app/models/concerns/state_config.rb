module StateConfig
  extend ActiveSupport::Concern

  module ClassMethods
    def state_config *args
      options = args.extract_options!

      config = options[:config] || {}
      args.each do |_arg|
        define_singleton_method "#{_arg}_array_with_option" do |select_options = {}|
          config.values.inject([]) do |result, element|
            if select_options.present? && !select_options.keys.map {|_key| element.has_key?(_key) && (select_options[_key].is_a?(Array) ? element[_key].in?(select_options[_key]) : element[_key] == select_options[_key])}.include?(false)
              result << [element[:desc], element[:value]]
            end
            result
          end
        end

        define_singleton_method "#{_arg}_hash" do
          config.values.inject({}) do |result, element|
            result[element[:value]] = element[:desc]
            result
          end
        end

        define_singleton_method "#{_arg}_id_name" do
          config.values.map do |element|
            {:id => element[:value],
             :name => element[:desc]}
          end
        end

        define_singleton_method "#{_arg}_id_name_with_option" do |select_options = {}|
          self.try("#{_arg}_array_with_option", select_options).map do |v, k|
            {:id => k,
             :name => v}
          end
        end

        define_singleton_method "#{_arg}_hash_with_option" do |select_options = {}|
          config.values.inject([]) do |result, element|
            if select_options.present? && !select_options.keys.map {|_key| element.has_key?(_key) && (select_options[_key].is_a?(Array) ? element[_key].in?(select_options[_key]) : element[_key] == select_options[_key])}.include?(false)
              result << element
            end
            result
          end
        end

        define_singleton_method "#{_arg}_key_with_option" do |select_options = {}|
          result = []
          config.each do |key, element|
            if select_options.present? && !select_options.keys.map {|_key| element.has_key?(_key) && (select_options[_key].is_a?(Array) ? element[_key].in?(select_options[_key]) : element[_key] == select_options[_key])}.include?(false)
              result << key
            end
          end
          result
        end

        define_singleton_method "#{_arg}_attr_with_option" do |return_attr, select_options = {}|
          config.each do |key, element|
            if select_options.present? && !select_options.keys.map {|_key| element.has_key?(_key) && (select_options[_key].is_a?(Array) ? element[_key].in?(select_options[_key]) : element[_key] == select_options[_key])}.include?(false)
              return element[return_attr]
            end
          end
          nil
        end

        define_singleton_method "#{_arg}_array" do
          config.values.inject([]) do |result, element|
            result << [element[:desc], element[:value]]
            result
          end
        end

        define_singleton_method "#{_arg}_desc_for_value" do |_val|
          if _val.is_a?(Array)
            _val.map {|ins| config.values.select {|_option| _option[:value] == ins}.first[:desc].to_s rescue nil}.compact.join(', ')
          else
            if config.values.select {|_option| _option[:value] == _val}.first
              config.values.select {|_option| _option[:value] == _val}.first[:desc].to_s
            else
              ''
            end
          end
        end

        define_singleton_method "#{_arg}_config" do
          config
        end

        define_singleton_method "#{_arg}_values" do
          config.values.map {|each_config| each_config[:value]}
        end

        define_singleton_method "#{_arg}_value" do |key|
          config[key.to_sym]&.fetch(:value, nil)
        end

        define_singleton_method "#{_arg}_filter" do |*filter_array|
          if filter_array.is_a?(Array)
            filter_array = filter_array.map(&:to_sym)
            config.slice(*filter_array).values.map {|c| c[:value]}
          else
            config.slice(filter_array).values.map {|c| c[:value]}.first
          end
        end

        define_singleton_method "#{_arg}_value_for_config" do |value|
          config.select {|k, v| v[:value] == value.to_i}
        end

        define_method "#{_arg}_desc" do
          if (field = self.send(_arg)).is_a?(Array)
            field.map do |ins|
              (config.select {|k, v| v[:value] == ins}.values.first || {}).fetch(:desc, nil)
            end.join(',')
          else
            (config.select {|k, v| v[:value] == field}.values.first || {}).fetch(:desc, nil)
          end
        end

        define_method "#{_arg}_key" do
          config.select {|k, v| v[:value] == self.send(_arg)}.keys.first.to_s
        end

        define_method "#{_arg}_config" do
          config.select {|k, v| v[:value] == self.send(_arg)}.values.first
        end

        config.keys.each do |_key|
          define_singleton_method "#{_arg}_#{_key}" do
            self.where("#{self.table_name}.#{_arg} = #{config[_key][:value]}")
          end

          define_singleton_method "#{_arg}_#{_key}_value" do
            config[_key][:value]
          end

          define_method "#{_arg}_#{_key}?" do
            self.send(_arg) == config[_key][:value]
          end
        end
      end
    end
  end
end
