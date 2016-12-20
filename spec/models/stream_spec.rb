require 'spec_helper'

describe Notifiable::Apns::Grocer::Stream do

  subject { Notifiable::Apns::Grocer::Stream.new(Rails.env, n1) }
  let(:a1) { Notifiable::App.create! name: "Drum Cussac" }
  let(:n1) { Notifiable::Notification.create! app: a1 }
  
  describe "#sandbox?" do
    before(:each) { subject.instance_variable_set("@sandbox", "1") }
    it { expect(subject.send(:sandbox?)).to eql true }
  end
  
  describe "#grocer_payload?" do
    let(:d1) { Notifiable::DeviceToken.create! app: a1, token: "abc123", provider: 'apns' }
    before(:each) { @grocer_payload = subject.send("grocer_payload", d1, n1) }
    
    context "message" do
      let(:n1) { Notifiable::Notification.create! app: a1, message: "New deals!" }
      it { expect(@grocer_payload).to include(alert: "New deals!") } 
      it { expect(@grocer_payload).to include(device_token: "abc123") }
      it { expect(@grocer_payload).to_not include(:sound) }                      
      it { expect(@grocer_payload[:custom]).to include(n_id: n1.id) }                     
    end
    
    context "sound" do
      let(:n1) { Notifiable::Notification.create! app: a1, sound: "buzzer" }
      it { expect(@grocer_payload).to include(sound: "buzzer") } 
      it { expect(@grocer_payload).to include(device_token: "abc123") } 
      it { expect(@grocer_payload[:custom]).to include(n_id: n1.id) }                     
    end
    
    context "badge count" do
      let(:n1) { Notifiable::Notification.create! app: a1, badge_count: 1 }
      it { expect(@grocer_payload).to include(badge: 1) } 
      it { expect(@grocer_payload).to include(device_token: "abc123") } 
      it { expect(@grocer_payload[:custom]).to include(n_id: n1.id) }                     
    end
    
    context "parameters" do
      let(:n1) { Notifiable::Notification.create! app: a1, parameters: {screen: "leaderboard"}}
      it { expect(@grocer_payload).to include(device_token: "abc123") } 
      it { expect(@grocer_payload[:custom]).to include(n_id: n1.id) }  
      it { expect(@grocer_payload[:custom]).to include(screen: "leaderboard") }                     
    end
    
    context "identifier" do
      let(:n1) { Notifiable::Notification.create! app: a1, identifier: "23508241"}
      it { expect(@grocer_payload).to include(device_token: "abc123") } 
      it { expect(@grocer_payload[:custom]).to include(n_id: n1.id) }  
      it { expect(@grocer_payload).to include(identifier: "23508241") }                     
    end
    
    context "content_available" do
      let(:n1) { Notifiable::Notification.create! app: a1, content_available: true}
      it { expect(@grocer_payload).to include(device_token: "abc123") } 
      it { expect(@grocer_payload[:custom]).to include(n_id: n1.id) }  
      it { expect(@grocer_payload).to include(content_available: true) }                     
    end
    
    context "mutable_content" do
      let(:n1) { Notifiable::Notification.create! app: a1, mutable_content: true}
      it { expect(@grocer_payload).to include(device_token: "abc123") } 
      it { expect(@grocer_payload[:custom]).to include(n_id: n1.id) }  
      it { expect(@grocer_payload).to include(mutable_content: true) }                     
    end
    
    context "expiry" do
      let(:expiry) { Time.now + 60*60 }
      let(:n1) { Notifiable::Notification.create! app: a1, expiry: expiry}
      it { expect(@grocer_payload).to include(device_token: "abc123") } 
      it { expect(@grocer_payload[:custom]).to include(n_id: n1.id) }  
      it { expect(@grocer_payload).to include(expiry: expiry) }                     
    end
  end
  
  describe "#gateway_host" do
    context "sandbox" do
      before(:each) { allow(subject).to receive(:sandbox?) { true } }
      it { expect(subject.send(:gateway_host)).to eql "gateway.sandbox.push.apple.com" }
    end
    
    context "production" do
      before(:each) { allow(subject).to receive(:sandbox?) { false } }
      it { expect(subject.send(:gateway_host)).to eql "gateway.push.apple.com" }
    end
  end
  
  describe "#feedback" do
    xit "Remove tokens"
  end
  
end