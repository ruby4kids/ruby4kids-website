require 'spec_helper'

describe LayoutHelper do

  describe "#layout_options" do
    before do
      helper.class_eval do
        attr_accessor :foo
        attr_accessor :bar
      end
    end

    it "should do nothing if no options are given" do
      helper.layout_options.should be_nil
    end

    it "should set options that have corresponding setters" do
      helper.layout_options(foo: 'foo_value', bar: 'bar_value')
      helper.instance_variable_get('@foo').should == 'foo_value'
      helper.instance_variable_get('@bar').should == 'bar_value'
    end

    it "should raise an error if an option is given that has no corresponding setter" do
      expect { helper.layout_options(nonexistent: 'value') }.to raise_error
    end
  end

  describe "#title" do
    before do
      helper.controller = double('controller')
      helper.controller.stub(:controller_name).and_return('foo')
      helper.controller.stub(:action_name).and_return('bar')
    end

    it "should be the controller name and action name when no title has been set" do
      helper.title.should == "#{I18n.t(:application)} - Foo - Bar"
    end

    it "should be the title if one has been set" do
      helper.title = "My View"
      helper.title.should == "#{I18n.t(:application)} - My View"
    end

    it "should be the title joined by the separator if the title is an array" do
      helper.title = ["Baz", "Bat"]
      helper.title.should == "#{I18n.t(:application)} - Baz - Bat"
    end

    it "should be the raw title without the application title if one has been set" do
      helper.raw_title = "Raw Title"
      helper.title.should == "Raw Title"
    end
  end

  describe "#active_section_class" do
    before(:each) do
      helper.active_section = 'dashboard'
    end

    it "should be 'active' if the specified section is the active one" do
      helper.active_section_class('dashboard').should == 'active'
    end

    it "should be nothing if the specified section is not the active one" do
      helper.active_section_class('not_selected').should be_nil
    end
  end

end
