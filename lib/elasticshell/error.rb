module Elasticshell

  Error               = Class.new(StandardError)
  ArgumentError       = Class.new(Error)
  NotImplementedError = Class.new(Error)
  ClientError         = Class.new(Error)

end
