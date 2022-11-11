require "spec_helper"

RSpec.describe Dune::VERSION do
  it "version to be correct" do
    expect(Dune::VERSION).to eq("0.1.0")
  end
end
