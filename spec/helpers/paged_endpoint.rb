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

  it "returns the aggregated results" do
    nodes = agent.public_send(method, *args)
    expected_results = stubs.collect do |stub|
      JSON.parse(stub.response.body, symbolize_names: true)[:results]
    end
    expect(nodes).to eql(expected_results.flatten)
  end

  it "executes the block on each individual result" do
    expected_results = stubs.collect do |stub|
      status = stub.response.status[0]
      bodies = JSON.parse(stub.response.body, symbolize_names: true)[:results]
      bodies.map do |body|
        DPN::Client::Response.from_data(status, body)
      end
    end
    expect{ |probe|
      agent.public_send(method, *args, &probe)
    }.to yield_successive_args( *(expected_results.flatten) ) # asterisk explodes the array
  end



end