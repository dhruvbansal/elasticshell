require 'spec_helper'

describe HasName do

  before do
    @obj = Class.new { include HasName }.new
  end

  it "will not allow setting a name with a space or a '/'" do
    expect { @obj.name = "I have spaces" }.to raise_error(Elasticshell::ArgumentError)
    expect { @obj.name = "I have /" }.to      raise_error(Elasticshell::ArgumentError)
  end

end

