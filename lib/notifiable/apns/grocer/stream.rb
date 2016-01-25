require 'notifiable'
require 'grocer'
require 'connection_pool'

module Notifiable
  module Apns
    module Grocer
  		class Stream < Notifiable::NotifierBase
        
        attr_accessor :certificate, :passphrase, :connection_pool_size, :connection_pool_timeout, :gateway_host, :gateway_port, :feedback_host, :feedback_port
           
        def gateway_host
          @gateway_host || "gateway.push.apple.com"
        end
      
        def gateway_port
          @gateway_port || 2195
        end
      
        def feedback_host
          @gateway_host || "feedback.push.apple.com"
        end
      
        def feedback_port
          @feedback_port || 2196
        end
        
        def connection_pool_size
          @connection_pool_size || 10
        end
        
        def connection_pool_timeout
          @connection_pool_timeout || 10
        end   
                
        def close
          super
          @grocer_pusher = nil        
          @grocer_feedback = nil
        end
      
  			protected      
    			def enqueue(device_token, localized_notification)        				
          
            raise "Certificate missing" if certificate.nil?
          
            grocer_notification = ::Grocer::Notification.new(
              device_token: device_token.token,
              alert: localized_notification.message, 
              custom: localized_notification.send_params,
              sound: "default"
            )
          
            pusher_pool.with do |pusher|
              pusher.push(grocer_notification)
            end
                      
            # assume processed. Errors will be receieved through a callback
            processed(device_token, 0)
    			end
      
          def flush
            process_feedback unless self.test_env?
          end

        private                 
        # logic     
          def gateway_config 
            {
              certificate: certificate,
              passphrase:  passphrase,
              gateway:     gateway_host,
              port:        gateway_port,
              retries:     3
            }
          end
          
          def feedback_config
            {
              certificate: certificate,
              passphrase:  self.passphrase,
              gateway:     self.feedback_host,
              port:        self.feedback_port,
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
