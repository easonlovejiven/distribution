class Array
  class_attribute :json_options
  attr_accessor :json_options

  def assign_options(options = {})
    self.json_options = options
    self
  end

  def to_json_with_options(options = {}, &block)
    options = options.merge(self.json_options || self.class.json_options || {}) if options.slice(:only, :except, :include, :methods, :object).blank?
    to_json_without_options(options.merge(:indent => 0), &block)
  end

  alias_method_chain :to_json, :options

  def as_json_with_options(options = {})
    self.json_options ||= self.class.json_options
    options = options.merge(self.json_options).except(:encoder) if self.json_options && options.slice(:only, :except, :include, :methods, :object).blank?
    as_json_without_options(options)
  end

  alias_method_chain :as_json, :options
end

class ActiveRecord::Base
  class_attribute :json_options
  attr_accessor :json_options

  def assign_options(options = {})
    self.json_options = options
    self
  end

  # def to_json_with_options(options = {}, &block)
  #   options = options.merge(self.json_options || self.class.json_options || {}) if options.slice(:only, :except, :include, :methods, :object).blank?
  #   to_json_without_options(options, &block)
  # end

  # alias_method_chain :to_json, :options

  def as_json_with_options(options = {})
    self.json_options ||= self.class.json_options
    options = options.merge(self.json_options).except(:encoder) if self.json_options && options.slice(:only, :except, :include, :methods, :object).blank?
    as_json_without_options(options)
  end

  alias_method_chain :as_json, :options
end


module ActiveModel
  module Serialization
    def serializable_hash_with_objects(options = {})
      options = options.deep_clone
      options[:include] = (options[:include] || {}).merge(options[:objects]) if options[:objects]
      serializable_hash_without_objects(options)
    end

    alias_method_chain :serializable_hash, :objects
  end
end


module ActiveRecord
  class Relation
    def serializable_hash(*args)
      map { |a| a.serializable_hash(*args) }
    end
  end
end

class NilClass
  def to_json(options = nil) #:nodoc:
    ""
  end
  def as_json(options = nil) #:nodoc:
    ""
  end
end

class ActiveSupport::TimeWithZone
  def as_json(options = {})
    self.to_i
  end
end


class TrueClass
  def as_json(options = nil) #:nodoc:
    1
  end
end

class FalseClass
  def as_json(options = nil) #:nodoc:
    0
  end
end