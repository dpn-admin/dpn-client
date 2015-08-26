require "rspec"


shared_examples "a single endpoint" do |method, *args|
  # expect stub to be defined with let!

  it "sends the right request" do
    agent.public_send(method, *args)
    expect(stub).to have_been_requested
  end

  it "returns a response" do
    response = agent.public_send(method, *args)
    expect(response).to be_a DPN::Client::Response
    expect(response.to_json).to eql(stub.response.body)
  end

  it "calls the block" do
    expect { |probe|
      agent.public_send(method, *args, &probe)
    }.to yield_with_args(be_a(DPN::Client::Response))
  end

  it "yields the response" do
    agent.public_send(method, *args) do |response|
      expect(response.status).to eql(stub.response.status[0])
      expect(response.to_json).to eql(stub.response.body)
    end
  end
end