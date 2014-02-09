require 'spec_helper'

describe Notifiable::Apns::Grocer::Stream do
  
  let(:g) { Notifiable::Apns::Grocer::Stream.new }
  let(:n) { Notifiable::Notification.create(:message => "Test message") }
  let(:d) { Notifiable::DeviceToken.create(:token => "ABC123", :provider => :apns) }
  let(:u) { User.new(d) }
  
  it "sends a single grocer notification" do    
    g.env = "test"      
    g.send_notification(n, d)
    
    Timeout.timeout(2) {
      notification = @grocer.notifications.pop
      notification.alert.should eql "Test message"
    }
  end
  
  it "sends a single grocer notification in a batch" do    
    
    Notifiable.batch do |b|
      b.add(n, u)
    end
    Notifiable::NotificationDeviceToken.count.should == 1
    
    Timeout.timeout(2) {
      notification = @grocer.notifications.pop
      notification.alert.should eql "Test message"
    }
  end 
  
  it "supports custom properties" do
    n.payload = {:apns => {:custom => {:flag => true}}}
    
    Notifiable.batch do |b|
      b.add(n, u)
    end
    Notifiable::NotificationDeviceToken.count.should == 1
    
    Timeout.timeout(2) {
      notification = @grocer.notifications.pop
      notification.custom[:flag].should == true
    }
  end
  
end

User = Struct.new(:device_token) do
  def device_tokens
    [device_token]
  end
end