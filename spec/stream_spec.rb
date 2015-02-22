require 'spec_helper'

describe Notifiable::Apns::Grocer::Stream do

  let(:a) { Notifiable::App.create }  
  let(:n1) { Notifiable::Notification.create(:app => a) }
  let!(:ln) { Notifiable::LocalizedNotification.create(:message => "Test message", :params => {:flag => true}, :notification => n1, :locale => :en) }
  let(:d) { Notifiable::DeviceToken.create(:token => "ABC123", :provider => :apns, :app => a, :locale => :en) }
  
  it "sends a single notification" do
    
    n1.batch do |n| 
      n.add_device_token(d)
    end
    
    Notifiable::NotificationStatus.count.should == 1
    Notifiable::NotificationStatus.first.status.should == 0
    
    Timeout.timeout(2) {
      notification = @grocer.notifications.pop
      notification.alert.should eql "Test message"
      notification.custom[:localized_notification_id].should == ln.id
    }
  end 
  
  it "supports custom properties" do    
    n1.batch do |n| 
      n.add_device_token(d)
    end

    Notifiable::NotificationStatus.count.should == 1
    Notifiable::NotificationStatus.first.status.should == 0
    
    Timeout.timeout(2) {
      notification = @grocer.notifications.pop
      notification.custom[:localized_notification_id].should == ln.id
      notification.custom[:flag].should == true
    }
  end
  
  it "can use production gateway" do
    g = Notifiable::Apns::Grocer::Stream.new(Rails.env, n1)
    a.configuration = {:apns => {:sandbox => "0"}} # This is how production is configured
    a.configure(:apns, g)
    
    expect(g.send(:sandbox?)).to eq false
    
  end

  it "has default connection pool size" do
    g = Notifiable::Apns::Grocer::Stream.new(Rails.env, n1)
    
    expect(g.send(:connection_pool_size)).to eq 10 
  end
  
  it "has default connection pool timeout" do
    g = Notifiable::Apns::Grocer::Stream.new(Rails.env, n1)
    
    expect(g.send(:connection_pool_timeout)).to eq 10 
  end
  
end