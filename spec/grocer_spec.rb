require 'spec_helper'

describe Notifiable::Apns::Grocer::Stream do
  
  it "sends a single grocer notification" do    
            
    g = Notifiable::Apns::Grocer::Stream.new
    g.send_notification(Notifiable::Notification.new("Test message", nil), Notifiable::DeviceToken.new("ABC123"))
    
    Timeout.timeout(2) {
      notification = @grocer.notifications.pop
      notification.alert.should eql "Test message"
    }
  end
  
end