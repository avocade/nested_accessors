# IMPLEMENTATION
module NestedAccessors
  def self.included(base)
    base.extend ClassMethods
  end

  # LATER: Decorate with rdoc:
  #  recommended to be a <tt>t.text :info</tt> in migration, to accommodate growing hashes"

  # LATER: Do test with including this module in new class
  #  and setting up nested_accessor for :info, address: [:city, :street]
  # Then setup methods directly for accessing :info_fast serialized hash
  #  and add straight methods for getting at the [address][city], etc
  # Then see if nested_accessor is much slower due to using lots of "send" or
  #  if it's not critical

  # LATER: add nesting with arrays as well
  # nested_accessor :cellar,
  #   name: "My Cellar",  # specifies default value (set in "init hash" method)
  #   pincode: nil,  # nil default value
  #   location: { lat: nil, lon: nil },  # specifies a nested Hash with nil as default values
  #   # specify an array type, can only take one param (since we can only have one type of object in the array)
  #   # OBS: all this breaks old syntax just taking an array of symbols to specify hash key accessors
  #   wines: [
  #     {
  #       :year => Integer,
  #       :country => String,
  #       :price => Float
  #     }
  #   ]

  module ClassMethods
    # Creates new method +nested_accessor+ for adding dynamic accessors to nested hashes, using:
    #   <tt>nested_accessor :pz_settings, confirmation_token: String, subsettings: { foo: String, bar: Integer }</tt>
    def nested_accessor(name, *args)
      # SETUP ROOT HASH
      self.class_eval do
        serialize name, Hash
      end

      # SETUP SUBROOT PROPERTIES OR HASHES
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
def define_second_level_nesting_methods(subroot, subsubroot, propnames)
  self.send :define_method, subsubroot do
    self.send(subroot).send("store", subsubroot.to_s, {}) unless (self.send(subroot).has_key?(subsubroot.to_s) and self.send(subroot).send("fetch", subsubroot.to_s).send("is_a?", Hash))
    self.send(subroot).send("fetch", subsubroot.to_s)
  end

  if propnames
    propnames.each do |a_propname|
      self.send :define_method, "#{a_propname}=" do |val|
        self.send(subsubroot).send("store", a_propname.to_s, val.to_s)
      end
      self.send :define_method, a_propname do
        self.send(subsubroot).send("fetch", a_propname.to_s)
      end
    end
  end
end

def define_first_level_nesting_methods_for_subroot(root, subroot, subroot_type, propnames=nil)
  self.send :define_method, subroot do
    subroot_value = case subroot_type.to_s
      when "Array" then []
      else {}
    end
    self.send(root).send("store", subroot.to_s, subroot_value) unless (self.send(root).has_key?(subroot.to_s) and self.send(root).send("fetch", subroot.to_s).send("is_a?", subroot_value.class))
    self.send(root).send("fetch", subroot.to_s)
  end

  if propnames
    propnames.each do |a_propname|
      self.send :define_method, "#{a_propname}=" do |val|
        self.send(subroot).send("store", a_propname.to_s, val.to_s)
      end
      self.send :define_method, a_propname do
        self.send(subroot).send("fetch", a_propname.to_s)
      end
    end
  end
end

def define_first_level_nesting_methods_for_property(root, propname)
  self.send :define_method, propname do
    # 4. and return the correct value specified in the declaration, eg Integer
    # self.send "init_nested_accessor_#{root}"  # on root object name
    self.send(root).send("fetch", propname.to_s)
  end

  self.send :define_method, "#{propname}=" do |val|
    # self.send "init_nested_accessor_#{root}"  # on root object name
    self.send(root).send("store", propname.to_s, val.to_s)
  end
end
