require 'spec_helper'

describe Notifiable::Apns::Grocer::Stream do

  subject { Notifiable::Apns::Grocer::Stream.new(n1) }
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
      it { expect(@grocer_payload).to include(device_token: "abc123") }
      it { expect(@grocer_payload[:alert]).to include({body: "New deals!"}) } 
      it { expect(@grocer_payload).to include({sound: 'default'}) } 
      it { expect(@grocer_payload[:custom]).to include(n_id: n1.id) }                     
    end
    
    context "title and message" do
      let(:n1) { Notifiable::Notification.create! app: a1, title: 'Shopping', message: "New deals!" }
      it { expect(@grocer_payload[:alert]).to include({title: 'Shopping'}) } 
      it { expect(@grocer_payload[:alert]).to include({body: 'New deals!'}) }
      it { expect(@grocer_payload).to include({sound: 'default'}) } 
      it { expect(@grocer_payload).to include(device_token: "abc123") }
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
    
    context "thread id" do
      let(:thread_id) { "threadabc123" }
      let(:n1) { Notifiable::Notification.create! app: a1, thread_id: thread_id}
      it { expect(@grocer_payload).to include(device_token: "abc123") }
      it { expect(@grocer_payload).to include(thread_id: "threadabc123") }
      it { expect(@grocer_payload[:custom]).to include(n_id: n1.id) }
    end
    
    context "category" do
      let(:category) { "INVITATION" }
      let(:n1) { Notifiable::Notification.create! app: a1, category: category}
      it { expect(@grocer_payload).to include(device_token: "abc123") }
      it { expect(@grocer_payload).to include(category: "INVITATION") }
      it { expect(@grocer_payload[:custom]).to include(n_id: n1.id) }
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
    let!(:d1) { Notifiable::DeviceToken.create! app: a1, token: 'abc123', provider: 'apns' }
    before(:each) do
      feedback_double = double('Grocer::Feedback')
      attempt_double = double('Grocer::FailedDeliveryAttempt', device_token: 'abc123', timestamp: DateTime.now)
      allow(subject).to receive(:grocer_feedback) { [attempt_double].each } 
      subject.send(:process_feedback)
    end
    it { expect(Notifiable::DeviceToken.count).to eq 0 }
  end
  
end