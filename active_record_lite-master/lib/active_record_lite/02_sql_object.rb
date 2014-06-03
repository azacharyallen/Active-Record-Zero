require_relative 'db_connection'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
   results.map { |result| self.new(result)}
  end
end

class SQLObject < MassObject
  def self.columns
    @columns ||= begin
      cols = DBConnection.execute2("SELECT * FROM #{ table_name }").first

      cols.each do |attribute|
       define_method(attribute) do
         self.attributes[attribute]
       end

       define_method("#{attribute}=") do |value|
         self.attributes[attribute] = value
       end
      end
      cols.map(&:to_sym)
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= "#{self.to_s.downcase.pluralize.underscore}"
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
                SELECT *
                FROM #{table_name}
              SQL
    parse_all(results)         
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
                SELECT *
                FROM #{ table_name }
                WHERE id = ?
              SQL
    parse_all(result).first
  end

  def attributes
    @attributes || begin
      @attributes = Hash.new
    end
    @attributes
  end

  def insert
    p col_names = self.attributes.keys.join(", ")
    p question_marks = Array.new(self.attributes.count) {"?"}.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name.to_sym)
      self.send("#{attr_name}=", value)
    end
  end

  def save
    self.id.nil? ? insert : update
  end

  def update
    set_line = self.attributes.keys.select { |key| key != "id"}.map { |key| "#{key} = ?" }.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values[1..-1])
      UPDATE
      #{self.class.table_name}
      SET
      #{set_line}
      WHERE
      id = #{self.id}
    SQL
  end

  def attribute_values
    attributes.to_a.map { |attribute| attribute.last}
  end
end
