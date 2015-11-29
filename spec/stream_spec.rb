require 'spec_helper'

describe Notifiable::Apns::Grocer::Stream do

  let(:a) { Notifiable::App.create }  
  let(:n1) { Notifiable::Notification.create(:app => a) }
  let!(:ln) { Notifiable::LocalizedNotification.create(:message => "Test message", :params => {:flag => true}, :notification => n1, :locale => :en) }
  let(:d) { Notifiable::DeviceToken.create(:token => "ABC123", :provider => :apns, :app => a, :locale => :en) }
  
  before(:each) do
    a.configuration = {:apns => {
          :gateway_host => "localhost", 
          :gateway_port => 2195, 
          :feedback_host => "localhost", 
          :feedback_port => 2196}}
  end
  
  it "sends a single notification" do
    n1.batch do |n| 
      n.add_device_token(d)
    end
    
    expect(Notifiable::NotificationStatus.count).to eql 1
    expect(Notifiable::NotificationStatus.first.status).to eql 0
    
    Timeout.timeout(2) {
      notification = @grocer.notifications.pop
      expect(notification.alert).to eql "Test message"
      expect(notification.custom[:localized_notification_id]).to eql ln.id
    }
  end 
  
  it "supports custom properties" do    
    n1.batch do |n| 
      n.add_device_token(d)
    end

    expect(Notifiable::NotificationStatus.count).to eql 1
    expect(Notifiable::NotificationStatus.first.status).to eql 0
    
    Timeout.timeout(2) {
      notification = @grocer.notifications.pop
      expect(notification.custom[:localized_notification_id]).to eql ln.id
      expect(notification.custom[:flag]).to eql true
    }
  end
  
  it "sets gateway and feedback properties" do
    g = Notifiable::Apns::Grocer::Stream.new(Rails.env, n1)
    a.configure(:apns, g)
    
    expect(g.send(:gateway_host)).to eql "localhost"
    expect(g.send(:gateway_port)).to eql 2195
    expect(g.send(:feedback_host)).to eql "localhost"
    expect(g.send(:feedback_port)).to eql 2196
    
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