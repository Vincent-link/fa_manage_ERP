module GrapeLogging
  module Loggers
    class SessionInfo < GrapeLogging::Loggers::Base
      def parameters(request, response)
        request.session
      end
    end
  end
end
