require 'spec_helper'

describe Notifiable::Apns::Grocer::Stream do

  let(:a) { Notifiable::App.create }  
  let(:n1) { Notifiable::Notification.create(:message => "Test message", :app => a) }
  let(:n1_with_params) { Notifiable::Notification.create(:message => "Test message", :app => a, :params => {:flag => true}) }
  let(:d) { Notifiable::DeviceToken.create(:token => "ABC123", :provider => :apns, :app => a) }
  
  it "sends a single notification" do
    n1.batch do {|n| n.add_device_token(d)}
    
    Notifiable::NotificationStatus.count.should == 1
    Notifiable::NotificationStatus.first.status.should == 0
    
    Timeout.timeout(2) {
      notification = @grocer.notifications.pop
      notification.alert.should eql "Test message"
      notification.custom[:notification_id].should == n1.id
    }
  end 
  
  it "supports custom properties" do    
    n1_with_params.batch do {|n| n.add_device_token(d)}

    Notifiable::NotificationStatus.count.should == 1
    Notifiable::NotificationStatus.first.status.should == 0
    
    Timeout.timeout(2) {
      notification = @grocer.notifications.pop
      notification.custom[:notification_id].should == n1_with_params.id
      notification.custom[:flag].should == true
    }
  end
  
end