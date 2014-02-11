require 'notifiable'
require 'grocer'

module Notifiable
  module Apns
    module Grocer
  		class Stream < Notifiable::NotifierBase
        
        attr_accessor :sandbox, :certificate, :passphrase
        
        def close
          super
          @grocer_pusher = nil        
          @grocer_feedback = nil
        end
      
  			protected      
  			def enqueue(notification, device_token)        				
          
          grocer_notification = ::Grocer::Notification.new(
            device_token: device_token.token, 
            alert: notification.message, 
            custom: notification.params
          )
            
  				grocer_pusher.push(grocer_notification) unless Notifiable.delivery_method == :test

          processed(notification, device_token)
  			end
      
        def flush
          process_feedback unless self.test_env?
        end

        private
          def gateway_config 
            {
              certificate: self.certificate,
              passphrase:  self.passphrase,
              gateway:     self.test_env? ? "localhost" : self.sandbox ? "gateway.sandbox.push.apple.com" : "gateway.push.apple.com",
              port:        2195,
              retries:     3
            }
          end
          
          def feedback_config
            {
              certificate: self.certificate,
              passphrase:  self.passphrase,
              gateway:     self.test_env? ? "feedback.sandbox.push.apple.com" : "feedback.push.apple.com",
              port:        2196,
              retries:     3
            }
          end
        
          def grocer_pusher
            @grocer_pusher ||= ::Grocer.pusher(gateway_config)
          end
      
          def grocer_feedback
    				@grocer_feedback ||= ::Grocer.feedback(feedback_config)
          end
      
          def process_feedback
    				grocer_feedback.each do |attempt|
    					token = attempt.device_token
    					device_token = DeviceToken.find_by_token(token)
    					if device_token
    						device_token.update_attribute("is_valid", false) if device_token.updated_at < attempt.timestamp
    						Rails.logger.info("Device #{token} (#{device_token.user_id}) failed at #{attempt.timestamp}")
    					end
    				end
          end
  		end
    end
	end
end