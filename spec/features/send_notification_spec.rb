require 'spec_helper'

describe "Send notification" do

  let(:a1) { Notifiable::App.create }  
  let(:n1) { Notifiable::Notification.create(:app => a1, message: "Test message") }
  let(:d1) { Notifiable::DeviceToken.create(:token => "ABC123", :provider => :apns, :app => a1) }
  
  describe "#add_device_token" do
    
    before(:each) do
      a1.save_notification_statuses = true
      a1.apns_certificate = File.read(File.join(File.dirname(__FILE__), "..", "fixtures", "apns-development.pem"))
      allow_any_instance_of(Notifiable::Apns::Grocer::Stream).to receive(:gateway_host).and_return("localhost")
      
      n1.batch do |n| 
        n.add_device_token(d1)
      end
      
      Timeout.timeout(2) {
        @notification = @grocer.notifications.pop
      }
    end
    
    it { expect(Notifiable::NotificationStatus.count).to eql 1 }
    it { expect(Notifiable::NotificationStatus.first.status).to eql 0 }
    it { expect(@notification.alert).to eql "Test message" }
    it { expect(@notification.custom[:n_id]).to eql n1.id }
  end
end