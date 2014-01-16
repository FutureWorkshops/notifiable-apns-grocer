require 'notifiable'
require "notifiable/apns/grocer/version"
require "notifiable/apns/grocer/stream"

module Notifiable
  module Apns
    module Grocer
      
      def initialize
        Notifiable.notifier_classes[:apns] = Notifiable::Apns::Grocer::Stream
      end
      
    end
  end
end
