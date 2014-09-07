require 'notifiable'
require 'grocer'
require 'connection_pool'

module Notifiable
  module Apns
    module Grocer
  		class Stream < Notifiable::NotifierBase
        
        attr_accessor :sandbox, :certificate, :passphrase, :connection_pool_size, :connection_pool_timeout
                
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
          
            pusher_pool.with do |pusher|
              pusher.push(grocer_notification) unless Notifiable.delivery_method == :test
            end
                      
            # assume processed. Errors will be receieved through a callback
            processed(device_token, 0)
    			end
      
          def flush
            process_feedback unless self.test_env?
          end

        private
        # override getters with defaults
          def sandbox
            @sandbox || "0"
          end
          
          def connection_pool_size
            @connection_pool_size || 10
          end
          
          def connection_pool_timeout
            @connection_pool_timeout || 10
          end
         
          def sandbox?
            sandbox.eql? "1"
          end
        
        # logic     
          def gateway_config 
            {
              certificate: self.certificate,
              passphrase:  self.passphrase,
              gateway:     self.test_env? ? "localhost" : self.sandbox? ? "gateway.sandbox.push.apple.com" : "gateway.push.apple.com",
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
          
          def pusher_pool
            @pusher_pool ||= ConnectionPool.new(size: connection_pool_size, timeout: connection_pool_timeout) do
              ::Grocer.pusher(gateway_config)
            end
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