require File.dirname(__FILE__) + '/../test_helper'

class NotificationTest < ActionMailer::TestCase
  tests Notification
  def test_invitation
    @expected.subject = 'Notification#invitation'
    @expected.body    = read_fixture('invitation')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notification.create_invitation(@expected.date).encoded
  end

end
