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

        define_singleton_method "#{_arg}_id_name" do |*extra_attr|
          config.map do |key, element|
            res = {:id => element[:value],
                   :name => element[:desc]}
            extra_attr.each do |attr|
              if attr == :key
                res[attr] = key.to_s
              else
                res[attr] = element[attr]
              end
            end
            res
          end
          # config.values.map do |element|
          #   res = {:id => element[:value],
          #          :name => element[:desc]}
          #   extra_attr.each do |attr|
          #     res[attr] = element[attr]
          #   end
          #   res
          # end
        end

        define_singleton_method "#{_arg}_id_name_unit" do |*extra_attr|
          config.map do |key, element|
            res = {:id => element[:value],
                   :name => element[:desc],
                   :unit => element[:unit],
                   :remarks => element[:remarks]
            }
            extra_attr.each do |attr|
              if attr == :key
                res[attr] = key.to_s
              else
                res[attr] = element[attr]
              end
            end
            res
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

        define_singleton_method "#{_arg}_op_for_value" do |_val|
          if _val.is_a?(Array)
            _val.map {|ins| config.values.select {|_option| _option[:value] == ins}.first[:op].to_s rescue nil}.compact.join(', ')
          else
            if config.values.select {|_option| _option[:value] == _val}.first
              config.values.select {|_option| _option[:value] == _val}.first[:op]
            else
              ''
            end
          end
        end

        define_singleton_method "#{_arg}_config_for_value" do |_val|
          if _val.is_a?(Array)
            _val.map {|ins| config.values.select {|_option| _option[:value] == ins}.first[:op].to_s rescue nil}.compact.join(', ')
          else
            if config.values.select {|_option| _option[:value] == _val}.first
              config.values.select {|_option| _option[:value] == _val}.first
            else
              ''
            end
          end
        end

        define_singleton_method "#{_arg}_config" do
          config
        end

        define_singleton_method "#{_arg}_type_values" do |type|
          config.values.select { |c| c[:type] == type }.map { |c| c[:value]  }
        end

        define_singleton_method "#{_arg}_values" do
          config.values.map {|each_config| each_config[:value]}
        end

        define_singleton_method "#{_arg}_value" do |key|
          config[key.to_sym]&.fetch(:value, nil)
        end

        define_singleton_method "#{_arg}_value_code" do |value, code|
          config.values.map {|each_config| each_config[code.to_sym] if each_config[:value] == value}.compact.flatten.uniq
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

        define_method "#{_arg}_rate" do
          config.select { |k, v| v[:value] == self.send(_arg) }.values.first.fetch(:rate, 0)
        end

        config.keys.each do |_key|
          define_singleton_method "#{_arg}_#{_key}" do
            self.where("#{self.table_name}.#{_arg} = #{config[_key][:value]}")
          end

          define_singleton_method "#{_arg}_#{_key}_value" do
            config[_key][:value]
          end

          define_singleton_method "#{_arg}_#{_key}_desc" do
            config[_key][:desc]
          end

          define_singleton_method "#{_arg}_#{_key}_op" do
            config[_key][:op]
          end

          define_method "#{_arg}_#{_key}?" do
            self.send(_arg) == config[_key][:value]
          end
        end
      end
    end
  end
end
