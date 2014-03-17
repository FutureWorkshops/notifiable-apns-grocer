require 'spec_helper'

describe Notifiable::Apns::Grocer::Stream do

  let(:a) { Notifiable::App.create }  
  let(:g) { Notifiable::Apns::Grocer::Stream.new }
  let(:n) { Notifiable::Notification.create(:message => "Test message", :app => a) }
  let(:d) { Notifiable::DeviceToken.create(:token => "ABC123", :provider => :apns, :app => a) }
  let(:u) { User.new(d) }
  
  it "sends a single grocer notification" do    
    g.env = "test"      
    g.send_notification(n, d)
    
    Timeout.timeout(2) {
      notification = @grocer.notifications.pop
      notification.alert.should eql "Test message"
      notification.custom[:notification_id].should == n.id
    }
  end
  
  it "sends a single grocer notification in a batch" do
    
    Notifiable.batch(a) do |b|
      b.add_notifiable(n, u)
    end
    Notifiable::NotificationStatus.count.should == 1
    Notifiable::NotificationStatus.first.status.should == 0
    
    Timeout.timeout(2) {
      notification = @grocer.notifications.pop
      notification.alert.should eql "Test message"
      notification.custom[:notification_id].should == n.id
    }
  end 
  
  it "supports custom properties" do
    n.params = {:flag => true}
    
    Notifiable.batch(a) do |b|
      b.add_notifiable(n, u)
    end
    Notifiable::NotificationStatus.count.should == 1
    Notifiable::NotificationStatus.first.status.should == 0
    
    Timeout.timeout(2) {
      notification = @grocer.notifications.pop
      notification.custom[:notification_id].should == n.id
      notification.custom[:flag].should == true
    }
  end
  
end

User = Struct.new(:device_token) do
  def device_tokens
    [device_token]
  end
end