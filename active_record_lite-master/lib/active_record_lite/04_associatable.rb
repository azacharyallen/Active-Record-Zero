require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    model_class::table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    default_options = {:foreign_key => "#{name}_id".to_sym, :class_name => "#{name.to_s.camelcase}", :primary_key => :id}
    options = default_options.merge(options)

    self.foreign_key = options[:foreign_key]
    self.class_name = options[:class_name]
    self.primary_key = options[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
     default_options = {:foreign_key => "#{self_class_name.to_s.downcase}_id".to_sym, :class_name => "#{name.to_s.singularize.camelcase}", :primary_key => :id}
     options = default_options.merge(options)

    self.foreign_key = options[:foreign_key]
    self.class_name = options[:class_name]
    self.primary_key = options[:primary_key]
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    #options = BelongsToOptions.new(name, options)
    options = self.assoc_options[name]

    define_method(name) do
      model_class = options.model_class
      foreign_key = self.send(options.foreign_key)
      primary_key = self.send(options.primary_key)

      model_class.where(primary_key => foreign_key).first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)
    #options = HasManyOptions.new(name, self.name, options)
    options = self.assoc_options[name]

    define_method(name) do
      model_class = options.model_class
      foreign_key = options.foreign_key
      primary_key = self.send(options.primary_key)

      model_class.where(foreign_key => primary_key)      
    end
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end