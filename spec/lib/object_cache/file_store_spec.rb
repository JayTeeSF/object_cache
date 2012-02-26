require 'spec_helper'

describe ObjectCache::FileStore do
  let(:store_class) { ObjectCache::FileStore }

  context "class methods" do
    it "should have expected registration_key" do
      store_class.should respond_to(:registration_key)
      store_class.registration_key.should == ObjectCache.key_for(ObjectCache::FileStore)
    end

    it "should be registerable" do
      store_class.should respond_to(:register)
      got = store_class.register
      got.should be_instance_of Array
      got.last.should == store_class.registration_key
      got.first.should be_instance_of store_class
    end
  end

  context "instance methods" do
    let(:mock_storage_object) { mock() }
    let(:mock_storage_class) do
      mock().tap do |m|
        m.stub(:new).and_return(mock_storage_object)
      end
    end
    let(:transactor) do
      Class.new.tap do |cl|
        cl.class_eval do
          def transaction(&block)
            block.call
          end
        end
      end.new
    end
    let(:store_obj) { store_class.new({:storage_class => mock_storage_class, :transactor => transactor}) }
    let(:key) { :key }
    let(:value) { :value }
    let(:missing_key) { nil }

    it "should store a value for a key" do
      store_obj.should respond_to(:store)
      mock_storage_object.should_receive(:[]=).with(key, value)
      store_obj.store(key, value)
    end

    it "should fetch a value for a key" do
      store_obj.should respond_to(:fetch)
      mock_storage_object.should_receive(:fetch).with(key, missing_key)
      store_obj.fetch(key)
    end

    it "should fetch all values" do
      store_obj.should respond_to(:values)
      keys = [1,2,3]
      expected_fetches = keys.zip(keys.size.times.collect{missing_key})
      mock_storage_object.should_receive(:roots).and_return(keys)
      for expected_fetch in expected_fetches
        mock_storage_object.should_receive(:fetch).with(*expected_fetch)
      end
      store_obj.values
    end
  end
end
