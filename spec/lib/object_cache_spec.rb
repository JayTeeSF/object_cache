require 'spec_helper'

describe ObjectCache do
  context "mixed-into some class" do
    let(:some_klass) {
      it = Class.new
      it.tap { |some_klass| some_klass.send(:include, ObjectCache) }
    }

    subject { some_klass }
    it { should respond_to(:cache) }
    it { should respond_to(:lookup_all) }
    it { should respond_to(:lookup) }

    context "with cached objects" do
      let(:entry_ids) { [3,6,9] }
      before { entry_ids.each {|i| some_klass.cache[i] = some_klass.new } }
      its(:cache) { should have(entry_ids.size).entries }
      its(:lookup_all) { should have(entry_ids.size).entries }

      it "should return requested entries" do
        got = subject.lookup_all(entry_ids.take(2))
        got.should == subject.lookup(entry_ids.take(2))
        got.size.should == 2
      end

      it "should maintain its entries" do
        subject.lookup(entry_ids.first).should == subject.lookup(entry_ids.first)
      end

      it "should distinguish its entries" do
        subject.lookup(entry_ids.first).should_not == subject.lookup(entry_ids.last)
      end
    end
  end
end
