require_relative "nested_accessors/version"
require_relative "nested_accessors/railtie" if defined? Rails

module NestedAccessors
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    ##
    # Creates new method +nested_accessor+ for adding dynamic accessors to nested hashes, using:
    #   <tt>nested_accessor :pz_settings, confirmation_token: String, subsettings: { foo: String, bar: Integer }</tt>
    def nested_accessor(name, *args)
      self.class_eval do
        serialize name, Hash
      end

      args.each do |an_arg|
        if an_arg.is_a? Hash
          # nested_accessor :info, address: [:foo]
          an_arg.each do |subroot,propnames|
            if propnames.is_a? Array  # eg "address: [:city, :zipcode]"
              define_first_level_nesting_methods_for_subroot(name, subroot, Hash, propnames)
            elsif propnames == Array  # eg "address: Array"
              define_first_level_nesting_methods_for_subroot(name, subroot, Array)
            elsif propnames.is_a? Symbol  # eg "auth: :facebook"
              define_first_level_nesting_methods_for_subroot(name, subroot, Hash, [propnames])
            elsif propnames.is_a? Hash  # eg "subregion: { address: [:street, :city] }"
              propnames.each do |subsubroot,subpropnames|
                define_first_level_nesting_methods_for_subroot(name, subroot, Hash, [subsubroot])
                define_second_level_nesting_methods(subroot, subsubroot, subpropnames)
              end
            end
          end
        elsif an_arg.is_a? Array
          an_arg.each do |a_propname|
            define_first_level_nesting_methods_for_property(name, a_propname)
          end
        elsif an_arg.is_a? Symbol
          define_first_level_nesting_methods_for_property(name, an_arg)
        end
      end
    end
  end
end

# HELPER METHODS
def define_first_level_nesting_methods_for_property(root, propname)
  class_eval <<-RUBY, __FILE__, __LINE__+1
    def #{propname}=(val)
      #{root}.store("#{propname}", val.to_s)
    end

    def #{propname}
      #{root}.store("#{propname}", nil) unless (#{root}.has_key?("#{propname}"))
      #{root}.fetch "#{propname}"
    end
  RUBY
end

def define_first_level_nesting_methods_for_subroot(root, subroot, subroot_type, propnames=nil)
  subroot_value = case subroot_type.to_s
    when "Array" then []
    else {}
  end

  class_eval <<-RUBY, __FILE__, __LINE__+1
    def #{subroot}
      #{root}.store("#{subroot}", #{subroot_value}) unless (#{root}.has_key?("#{subroot}") and #{root}.fetch("#{subroot}").is_a?(#{subroot_value}.class))
      #{root}.fetch "#{subroot}"
    end
  RUBY

  if propnames
    propnames.each do |a_propname|
      self.class_eval <<-RUBY, __FILE__, __LINE__+1
        def #{subroot}_#{a_propname}=(val)
          #{subroot}.store("#{a_propname}".to_s, val.to_s)
        end

        def #{subroot}_#{a_propname}
          #{subroot}.store("#{a_propname}", nil) unless (#{subroot}.has_key?("#{a_propname}"))
          #{subroot}.fetch "#{a_propname}".to_s
        end
      RUBY
    end
  end
end

def define_second_level_nesting_methods(subroot, subsubroot, propnames)
  self.class_eval <<-RUBY, __FILE__, __LINE__+1
    def #{subroot}_#{subsubroot}
      #{subroot}.store("#{subsubroot}", {}) unless (#{subroot}.has_key?("#{subsubroot}") and #{subroot}.fetch("#{subsubroot}").is_a?(Hash))
      #{subroot}.fetch "#{subsubroot}"
    end
  RUBY

  if propnames
    propnames.each do |a_propname|
      self.class_eval <<-RUBY, __FILE__, __LINE__+1
        def #{subroot}_#{subsubroot}_#{a_propname}=(val)
          #{subroot}_#{subsubroot}.store("#{a_propname}", val.to_s)
        end

        def #{subroot}_#{subsubroot}_#{a_propname}
          #{subroot}_#{subsubroot}.store("#{a_propname}", nil) unless (#{subroot}_#{subsubroot}.has_key?("#{a_propname}"))
          #{subroot}_#{subsubroot}.fetch "#{a_propname}"
        end
      RUBY
    end
  end
end

