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

ActsAsTaggableOn::Tag.class_eval do
  send(:acts_as_taggable_on, :sub_tags)
  def validates_name_uniqueness?
    false
  end

  def self.find_or_create_all_with_like_by_name(*list)
    list = Array(list).flatten

    return [] if list.empty?
    existing_tags = named_any(list)
    list.map do |tag_name|
      begin
        tries ||= 3
        create(name: tag_name)
      rescue ActiveRecord::RecordNotUnique
        if (tries -= 1).positive?
          ActiveRecord::Base.connection.execute 'ROLLBACK'
          existing_tags = named_any(list)
          retry
        end

        raise DuplicateTagError.new("'#{tag_name}' has already been taken")
      end
    end
  end
end

ActsAsTaggableOn::Taggable::Core.module_eval do
  def tagging_contexts
    self.class.tag_types.map(&:to_s) | custom_contexts
  end

  def save_tags
    tagging_contexts.each do |context|
      next unless tag_list_cache_set_on(context)
      # List of currently assigned tag names
      tag_list = tag_list_cache_on(context).uniq

      # Find existing tags or create non-existing tags:
      tags = find_or_create_tags_from_list_with_context(tag_list, context)

      # Tag objects for currently assigned tags
      current_tags = tags_on(context)

      # Tag maintenance based on whether preserving the created order of tags
      if self.class.preserve_tag_order?
        old_tags, new_tags = current_tags - tags, tags - current_tags

        shared_tags = current_tags & tags

        if shared_tags.any? && tags[0...shared_tags.size] != shared_tags
          index = shared_tags.each_with_index { |_, i| break i unless shared_tags[i] == tags[i] }

          # Update arrays of tag objects
          old_tags |= current_tags[index...current_tags.size]
          new_tags |= current_tags[index...current_tags.size] & shared_tags

          # Order the array of tag objects to match the tag list
          new_tags = tags.map do |t|
            new_tags.find { |n| n.name.downcase == t.name.downcase }
          end.compact
        end
      else
        # Delete discarded tags and create new tags
        old_tags = current_tags - tags
        new_tags = tags - current_tags
      end

      # # Destroy old taggings:
      # if old_tags.present?
      #   taggings.not_owned.by_context(context).where(tag_id: old_tags).destroy_all
      # end

      
      # Create new taggings:
      new_tags.each do |tag|
        taggings.create!(tag_id: tag.id, context: context.to_s, taggable: self)
      end
    end

    true
  end
end

ActsAsTaggableOn::TagList.class_eval do
  def initialize(*args)
    @parser = ActsAsTaggableOn.default_parser
    # add(*args)
  end
end

# ActiveStorage::Blob.class_eval do
#
# end