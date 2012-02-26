require 'spec_helper'

describe ObjectCache do
  context "mixed-into some class" do
    before(:each) do
      ObjectCache.flush
    end

    let(:some_class) do
      it = Class.new
      it.tap do |_some_class|
        _some_class.send(:include, ObjectCache)
        _some_class.class_eval do
          attr_accessor :id
        end
      end
    end

    it "should respond_to #cache" do
      some_class.should respond_to(:cache)
    end
    it "should respond_to #cache" do
      some_class.should respond_to(:lookup_all)
    end
    it "should respond_to #cache" do
      some_class.should respond_to(:lookup)
    end

    context "given a registerable object" do
      let(:registration_key) { :reg_key }
      let(:obj) { mock() }

      it "should register" do
        ObjectCache.registered.should_not include(registration_key)

        obj.should_receive(:register).with(registration_key).and_return([obj, registration_key])
        ObjectCache.register(obj, registration_key)

        ObjectCache.registered?(registration_key).should be_true
      end

      it "should flush cache but maintain defaults" do
        originally_registered = ObjectCache.registered.dup
        ObjectCache.registered.should_not include(registration_key)

        obj.should_receive(:register).with(registration_key).and_return([obj, registration_key])
        ObjectCache.register(obj, registration_key)

        ObjectCache.registered?(registration_key).should be_true
        ObjectCache.flush
        ObjectCache.registered?(registration_key).should be_false
        ObjectCache.registered.should == originally_registered
      end

      it "should create key from subclass" do
        with_subclass = :with_subclass
        key_with_subclass = "some_string/#{with_subclass}"
        ObjectCache.key_for(key_with_subclass).should == with_subclass
      end

      it "should provide idempotent key_for" do
        got_key = ObjectCache.key_for(registration_key)
        got_key.should == registration_key
        got_key.should == ObjectCache.key_for(got_key)
      end

      it "should detect unregistered keys" do
        ObjectCache.registered.should_not include(registration_key)
        ObjectCache.registered?(registration_key).should be_false
      end

      context "instance with save_location specified" do
        let(:some_instance) do
          obj.should_receive(:register).with(registration_key).and_return([obj, registration_key])
          ObjectCache.register(obj, registration_key)
          ObjectCache.registered?(registration_key).should be_true
          some_class.class_eval do
            cache :in => :reg_key
          end
          some_class.new
        end

        it "should save in specified location" do
          some_instance.id = :some_id
          obj.should_receive(:store).with(some_instance.id, some_instance)
          some_instance.save
        end
      end
    end

    context "with cached objects" do
      let(:entry_ids) { [3,6,9] }
      before { entry_ids.each {|i| some_class.cache.store(i, some_class.new) } }

      it "should return the full cache" do
        some_class.cache.size.should == entry_ids.size
      end

      it "should lookup all the entries" do
        some_class.lookup_all.size.should == entry_ids.size
      end

      it "should return requested entries" do
        got = some_class.lookup_all(entry_ids.take(2))
        got.should == some_class.lookup(entry_ids.take(2))
        got.size.should == 2

        some_class.lookup_all(entry_ids.take(entry_ids.size)).should == some_class.lookup_all
      end

      it "should maintain its entries" do
        some_class.lookup(entry_ids.first).should be_instance_of some_class
        some_class.lookup(entry_ids.first).should == some_class.lookup(entry_ids.first)
      end

      it "should distinguish its entries" do
        some_class.lookup(entry_ids.first).should_not == some_class.lookup(entry_ids.last)
      end
    end
  end
end
