require 'spec_helper'

describe Notifiable::Apns::Grocer::Stream do
  
  it "sends a single grocer notification" do    
            
    g = Notifiable::Apns::Grocer::Stream.new
    n = Notifiable::Notification.create(:message => "Test message")
    d = Notifiable::DeviceToken.create(:token => "ABC123")
    
    g.send_notification(n, d)
    
    Timeout.timeout(2) {
      notification = @grocer.notifications.pop
      notification.alert.should eql "Test message"
    }
  end
  
  it "sends a single grocer notification in a batch" do    
            
    g = Notifiable::Apns::Grocer::Stream.new
    n = Notifiable::Notification.create(:message => "Test message")
    d = Notifiable::DeviceToken.create(:token => "ABC123", :provider => :apns)
    u = User.new(d)
    
    Notifiable.batch do |b|
      b.add(n, u)
    end
    Notifiable::NotificationDeviceToken.count.should == 1
    
    Timeout.timeout(2) {
      notification = @grocer.notifications.pop
      notification.alert.should eql "Test message"
    }
  end 
  
end

User = Struct.new(:device_token) do
  def device_tokens
    [device_token]
  end
end