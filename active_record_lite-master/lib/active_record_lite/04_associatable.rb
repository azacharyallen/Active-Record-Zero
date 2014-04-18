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
    # ...
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end

class Cat < SQLObject
end

m = HasManyOptions.new(:cats, :human, {})
p m.class_name
p m.foreign_key
p m.primary_key

p m.model_class
p m.table_name

