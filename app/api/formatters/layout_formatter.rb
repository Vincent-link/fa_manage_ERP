module Formatters::LayoutFormatter
  def self.call(object, _env)
    return object.to_json if object.is_a?(Hash) && object.key?(:swagger)

    unless object.class.in? [String, TrueClass, FalseClass, NilClass, Symbol, Integer, Float]
      object = object.to_json
      object = JSON.parse(object) rescue []
    end
    result = {'data' => nil, 'meta' => {}}

    if object.is_a?(Hash) && object.has_key?('total_entries')
      result['data'] = object.delete 'data'
      result['meta']['total'] = object.delete 'total_entries'
      result['meta']['page'] = object.delete 'current_page'
      result['meta']['pageSize'] = object.delete('per_page') || object.delete('page_size')
    else
      result['data'] = object
    end

    if _env['rack.request.query_hash']['ack'].present?
      result['meta']['ack'] = _env['rack.request.query_hash']['ack']
    end
    result['meta']['ts'] = Time.now.to_i
    result['code'] = 200

    unless _env['no_camelize']
      result.deep_transform_keys! {|key| key.to_s.camelize(:lower)} if result.respond_to? :deep_transform_keys!
    end

    #after_deep_transform
    result['meta']['auth'] = page_auth(_env)
    result.to_json
  end

  def self.page_auth(env)
    if request['auth'].present?
      res = {}
      request = nil
      current_ability = nil
      request['auth'].each do |auth|
        request ||= env['rack.request.query_hash']
        current_ability ||= env['api.endpoint'].current_ability
        if (arr = auth.split('@')).size == 2
          action, model = arr
          res[auth] = current_ability.can?(action.to_sym, (model.constantize rescue model))
        else
          res[auth] = false
        end
      end
      res
    else
      {}
    end
  end
end
