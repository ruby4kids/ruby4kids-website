# Include hook code here
require "search_and_paginate"
require "account_monitor"
require "account_role_right"
require "select_column_names"
require "fiscal_quarter"
require "user_monitor"


ActiveRecord::Base.class_eval do include ActiveRecord::UserMonitor end