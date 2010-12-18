#!/bin/env ruby

require File.dirname(__FILE__) + "/../test_helper"

require "picture"

class PictureTest < Test::Unit::TestCase
  fixtures :divisions, :companies, :people, :accounts, :staff_details, :roles, :accounts_roles

  def test_foreign_keys
  end
  
  def test_associations
  end
end
