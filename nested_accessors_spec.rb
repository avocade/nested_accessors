require 'minitest/autorun'
require 'minitest/spec'
require 'simple_mock'
require 'minitest-colorize'

require './nested_accessors'

# STUBBING OUT active_record "serialized" class method
class Person  #< ActiveRecord::Base  # must inherit from activerecord to get "serialize" class method
  # Stubs out the "serialize :name, Hash" method
  # So don't have to use activerecord
  # Creates eg a :info hash accessor and returns hash
  def self.serialize(name, klass)
    attr_accessor name
    define_method name do
      @serialized_hash = {} if @serialized_hash.nil?
      @serialized_hash
    end
  end

  # must include module after the serialize method has been defined (it's defined in the superclass when inherited from activerecord)
  include NestedAccessors

  # USAGE in active_record model:
  # nested_accessor :info, :phone, address: [ :street, :zipcode ]
end

# SPECS
describe NestedAccessors do
  describe 'init method for hash accessors' do
    it 'should init root object to Hash if blank or not a Hash' do
      Person.class_eval %q{ nested_accessor :info }
      Person.new.info.class.must_equal Hash
    end

    describe "with phone accessor" do
      before(:each) do
        Person.class_eval %q{ nested_accessor :info, :phone }
      end

      let(:person) { Person.new }

      it 'should use stringified keys' do
        person.phone = "12378"
        person.info.keys.must_include "phone"
      end

      it 'sets up accessors for first level of nesting' do
        person.phone = "123-2345"
        person.phone.must_equal "123-2345"
      end

      it 'read accessor should return value typed to String by default (to_s)' do
        person.phone = 123
        person.phone.must_equal "123"
      end

      it 'write accessor should save value typed to String' do
        person.phone = 234
        person.info["phone"].must_equal "234"
      end

      it 'each subvalue should be nil if regular value param' do
        person.info["phone"].must_be_nil
        person.info["address"].must_be_nil
      end

      it 'can set multiple properties if first param is Array type' do
        Person.class_eval %q{ nested_accessor :info, [:phone1, :phone2] }
        person = Person.new
        person.info["phone1"] = "2365"
        person.phone1.must_equal "2365"
        person.phone2 = "9090"
        person.info["phone2"].must_equal "9090"
      end
    end

    describe 'subhashes' do
      it 'should init as hash if gets Array with multiple params for a property name in Hash' do
        # Gives self.info["address"]["street"] and ["city"]
        Person.class_eval %q{ nested_accessor :info, address: [:street, :city] }
        person = Person.new
        person.address.must_be_kind_of Hash
        person.address["city"] = "Goteborg"
        person.address["city"].must_equal "Goteborg"
      end

      it 'should init with just one param in array' do
        Person.class_eval %q{ nested_accessor :info, snub: [:snub_id] }
        person = Person.new
        person.snub.must_be_kind_of Hash
        person.snub_id = "Achaplan"
        person.snub_id.must_equal "Achaplan"
      end

      it 'should init with just one param symbol in hash as well' do
        Person.class_eval %q{ nested_accessor :info, auth: :facebook }
        person = Person.new
        person.auth.must_be_kind_of Hash
        person.facebook = "Achaplan"
        person.facebook.must_equal "Achaplan"
      end

      it 'should create shallow accessor methods for each hash propname' do
        Person.class_eval %q{ nested_accessor :bank, branch: [:branch_id, :account_number] }
        person = Person.new
        person.branch.must_be_kind_of Hash
        person.branch_id = "123"
        person.branch_id.must_equal "123"
        person.account_number = "999"
        person.account_number.must_equal "999"
      end

      # it 'should perhaps create accessor methods on the subroot object, for each subparam in hash' do
      #   Person.class_eval %q{ nested_accessor :info, address: [:street, :city] }
      #   person = Person.new
      #   person.address.must_be_kind_of Hash
      #   # the subroot method must thus return an object and define attr_accessor methods on it for each propname
      #   person.address.street = "Storgatan"
      #   person.address.street.must_equal "Storgatan"
      #   person.address.city = "Bigtown"
      #   person.address.city.must_equal "Bigtown"
      # end
    end

    it 'should init subvalue with Array if type set to array for accessor' do
      # nested_accessor :info, balls: Array
      #=> self.info["Balls"] == []
      Person.class_eval %q{ nested_accessor :things, balls: Array }
      person = Person.new
      person.balls.must_be_kind_of Array
      person.balls << "bob"
      person.balls << "alice"
      person.balls.must_include "bob"
      person.balls.must_include "alice"
    end

    describe 'second level nesting' do
      it 'sets up accessors for two level deep hash' do
        # nested_accessor :info, subregion: { address: [:street, :city] }
        #=> foo.info[address][subregion] = {}
        # Person.class_eval %q{ nested_accessor :home, subregion: { address: [:street, :city] } }
        Person.class_eval %q{ nested_accessor :home, budget: { heating: [:high, :low] } }
        person = Person.new
        person.heating.must_be_kind_of Hash
        person.budget.must_be_kind_of Hash
        person.budget.has_key?("heating").must_equal true  # can only test that hash has the key after we've used the subregion command since that instantiates the nested hash
        person.high = "32 C"
        person.high.must_equal "32 C"
        person.low = "10 C"
        person.low.must_equal "10 C"
      end

      it 'should set deep hash values and not overwrite others in the same subhash' do
        # TODO: Must test so we don't just write a new hash when changing a value
      end
    end
  end
end

