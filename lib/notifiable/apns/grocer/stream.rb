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
  			def enqueue(device_token)        				
          
          grocer_notification = ::Grocer::Notification.new(
            device_token: device_token.token, 
            alert: notification.message, 
            custom: notification.send_params
          )
            
  				grocer_pusher.push(grocer_notification) unless Notifiable.delivery_method == :test
          
          # TODO - add errors via enhanced interface
          #0   - No errors encountered
          #1   - Processing error
          #2   - Missing device token
          #3   - Missing topic
          #4   - Missing payload
          #5   - Invalid token size
          #6   - Invalid topic size
          #7   - Invalid payload size
          #8   - Invalid token
          #255 - None (unknown)

          processed(device_token, 0)
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
    					device_token = DeviceToken.find_by_token(attempt.device_token)
    					device_token.destroy if device_token
    				end
          end
  		end
    end
	end
end