module Resourcing
  extend ActiveSupport::Concern

  included do
    @groups = Set.new
    @current_group = nil
    @resources = []
    @parent = nil
    @object_group = {}
    @group_name_mapping = {}

    attr_accessor :name, :group, :block, :desc

    def name_without_xiegang
      self.name.gsub('/', '__')
    end
  end

  module ClassMethods

    # 为每个 resource 添加一个 group, 方便管理
    def group(name, desc=name, &block)
      #name = {name => nil} if name.is_a?(String) || name.is_a?(Symbol)
      #name, desc = name.map {|k, v| [k, v]}.first
      @groups << name
      @group_name_mapping[name] = desc
      @current_group = name
      @parent = nil
      block.call
    end

    def resource(name, desc=name, &block)
      raise "Need define group first" if @current_group.nil?
      res = Resource.new
      res.name = "#{@current_group}_#{name}"
      res.block = block
      res.group = @current_group
      res.desc = desc
      @resources << res
      @object_group[@current_group] ||= []
      @object_group[@current_group] << res
    end

    def object_group
      @object_group
    end

    def groups
      @groups
    end

    def group_name_mapping
      @group_name_mapping
    end

    def resources(group_name=nil)
      if group_name
        @resources.find_all {|r| r.group == group_name}
      else
        @resources
      end
    end

    # def tree_resource
    #   res = {}
    #   @groups.each do |group|
    #     group_resources = resources(group)
    #     res[group] = group_resources unless group_resources.blank?
    #   end
    #   res
    # end

    def find_by_name(name)
      res = @resources.find {|r| r.name == name}
      res
    end
  end
end
