# grape_swagger_entities
#   documentation keys to camelize
GrapeSwagger::Entity::Parser.class_eval do
  def parse_grape_entity_params(params, parent_model = nil)
    return unless params

    parsed = params.each_with_object({}) do |(entity_name, entity_options), memo|
      documentation_options = entity_options.fetch(:documentation, {})
      in_option = documentation_options.fetch(:in, nil).to_s
      hidden_option = documentation_options.fetch(:hidden, nil)
      next if in_option == 'header' || hidden_option == true

      entity_name = entity_name.original if entity_name.is_a?(GrapeSwagger::Entity::Parser::Alias)
      final_entity_name = entity_options.fetch(:as, entity_name)
      documentation = entity_options[:documentation]
      # patch point
      final_entity_name = final_entity_name.to_s.camelize(:lower).to_sym
      memo[final_entity_name] = if entity_options[:nesting]
                                  parse_nested(entity_name, entity_options, parent_model)
                                else
                                  attribute_parser.call(entity_options)
                                end
      next unless documentation

      memo[final_entity_name][:readOnly] = documentation[:read_only].to_s == 'true' if documentation[:read_only]
      memo[final_entity_name][:description] = documentation[:desc] if documentation[:desc]
    end

    [parsed, required_params(params)]
  end
end

GrapeSwagger::DocMethods::TagNameDescription.class_eval do
  def self.build_memo(tag)
    {
        name: tag,
        description: I18n.t(tag.singularize, scope: [:grape_api, :resources], default: tag.pluralize)
    }
  end
end

Grape::Endpoint.class_eval do
  def summary_object(route)
    summary = route.options[:desc] if route.options.key?(:desc)
    summary = route.description if route.description.present?
    summary = route.options[:summary] if route.options.key?(:summary)

    summary
  end
end