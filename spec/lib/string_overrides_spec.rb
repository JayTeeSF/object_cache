require 'spec_helper'

describe StringOverrides do
  context "mixed-into some class" do
    let(:some_klass) {
      it = Class.new
      it.tap { |some_klass| some_klass.send(:include, StringOverrides) }
    }

    let(:test_details) do
      [{:string => "FooBarJaz-qaz", :expected_result => 'foo_bar_jaz_qaz'}]
    end

    it "should convert strings to snake_case" do
      test_details.all? do |t|
        t[:string].underscore == t[:expected_result]
      end.should == true
    end
  end
end
