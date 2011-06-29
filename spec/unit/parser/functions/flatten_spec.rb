#!/usr/bin/env rspec
require 'spec_helper'

describe "the flatten function" do
  before :all do
    Puppet::Parser::Functions.autoloader.loadall
  end

  before :each do
    @scope = Puppet::Parser::Scope.new
  end

  it "should exist" do
    Puppet::Parser::Functions.function("flatten").should == "function_flatten"
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    lambda { @scope.function_flatten([]) }.should( raise_error(Puppet::ParseError))
  end

  it "should flatten a complex data structure" do
    result = @scope.function_flatten([["a","b",["c",["d","e"],"f","g"]]])
    result.should(eq(["a","b","c","d","e","f","g"]))
  end

end
