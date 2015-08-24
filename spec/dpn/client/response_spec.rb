# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require "spec_helper"
require "yaml"

RESPONSE_FILE = "spec/dpn/client/response_file.yml"
httpclient_resp = YAML::load(File.read(RESPONSE_FILE))


describe DPN::Client::Response do
  before(:all) { WebMock.disable! }
  let(:response) { DPN::Client::Response.new(httpclient_resp) }
  let(:json) { httpclient_resp.body }

  http_success_codes = ([200, 201, 202, 203] +
      [204, 205, 206, 207, 208, 226]).freeze

  http_failure_codes = ([100, 101, 102] +
      [300, 301, 302, 303, 304, 305, 307, 308] +
      [400, 401, 402, 403, 404, 405, 406, 407] +
      [408, 409, 410, 411, 412, 413, 414, 415] +
      [416, 417, 421, 422, 423, 424, 426, 428] +
      [429, 431, 500, 501, 502, 503, 504, 505] +
      [506, 507, 508, 510, 511]).freeze


  describe "#status" do
    it "returns 200" do
      expect(response.status).to eql(200)
    end

    it "is immutable" do
      expect {
        response.status = 301
      }.to raise_error(NoMethodError)

    end
  end


  describe "#body" do
    it "is a hash with symbols as keys" do
      expect(response.body).to be_a(Hash)
      response.body.keys do |key|
        expect(key).to be_a(Symbol)
      end
    end

    it "is immutable" do
      expect {
        response.body = "new body"
      }.to raise_error(NoMethodError)
    end
  end


  describe "#json" do
    it "returns the body as json" do
      expect(response.json).to eql(json)
    end
  end

  describe "#to_json" do
    it "returns the body as json" do
      expect(response.to_json).to eql(json)
    end
  end

  describe "#to_s" do
    it "returns the body as json" do
      expect(response.to_s).to eql(json)
    end
  end

  describe "#ok?" do
    http_success_codes.each do |code|
      it "is true when status==#{code}" do
        response.instance_variable_set(:@status, code)
        expect(response.ok?).to be true
      end
    end

    http_failure_codes.each do |code|
      it "is false when status==#{code}" do
        response.instance_variable_set(:@status, code)
        expect(response.ok?).to be false
      end
    end
  end

  describe "#success?" do
    http_success_codes.each do |code|
      it "is true when status==#{code}" do
        response.instance_variable_set(:@status, code)
        expect(response.success?).to be true
      end
    end

    http_failure_codes.each do |code|
      it "is false when status==#{code}" do
        response.instance_variable_set(:@status, code)
        expect(response.success?).to be false
      end
    end

  end

  describe "#[]" do
    it "returns the correct value" do
      expect(response[:first_key]).to eql("first_value")
    end
  end

  describe "#keys" do
    it "returns all the keys" do
      expect(response.keys.sort).to eql([:first_key, :second_key].sort)
    end
  end



end