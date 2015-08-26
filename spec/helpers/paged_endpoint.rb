require "rspec"

shared_examples "a paged endpoint" do |method, *args|
  # expects stubs, which is the stubs
  # expects agent, which is the agent
  # best comments ever

  it "requests the correct endpoints" do
    agent.public_send(method, *args) {}
    stubs.each do |stub|
      expect(stub).to have_been_requested
    end
  end

  it "returns the aggregated nodes" do
    nodes = agent.public_send(method, *args) {}
    expected_results = stubs.collect do |stub|
      JSON.parse(stub.response.body, symbolize_names: true)[:results]
    end
    expect(nodes).to eql(expected_results.flatten)
  end

  it "executes the block on each node" do
    expected_results = stubs.collect do |stub|
      JSON.parse(stub.response.body, symbolize_names: true)[:results]
    end
    expect{ |probe|
      agent.public_send(method, *args, &probe)
    }.to yield_successive_args( *(expected_results.flatten) ) # asterisk explodes the array
  end



end