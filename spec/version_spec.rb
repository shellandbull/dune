require "spec_helper"

RSpec.describe Dune::VERSION do
  it "version to be correct" do
    expect(Dune::VERSION).to eq("0.0.1")
  end
end
