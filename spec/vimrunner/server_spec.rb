require "spec_helper"
require "vimrunner/server"
require "vimrunner/platform"

module Vimrunner
  describe Server do
    let(:server) { Server.new(Platform.vim) }

    describe "#start" do
      it "starts a vim server process" do
        begin
          server.start
          server.serverlist.should include(server.name)
        ensure
          server.kill
          server.serverlist.should_not include(server.name)
        end
      end

      it "can start more than one vim server process" do
        begin
          first = Server.new(Platform.vim)
          second = Server.new(Platform.vim)

          first.start
          second.start

          first.serverlist.should include(first.name, second.name)
        ensure
          first.kill
          second.kill
        end
      end

      it "can start a vim server process with a block" do
        server.start do |client|
          server.serverlist.should include(server.name)
        end

        server.serverlist.should_not include(server.name)
      end
    end

    describe "#new_client" do
      it "returns a client" do
        server.new_client.should be_a(Client)
      end

      it "is attached to the server" do
        server.new_client.server.should == server
      end
    end

    describe "#remote_expr" do
      it "uses the server's executable to send remote expressions" do
        server.should_receive(:execute).
          with([server.executable, "--servername", server.name,
               "--remote-expr", "version"])

        server.remote_expr("version")
      end
    end

    describe "#remote_send" do
      it "uses the server's executable to send remote keys" do
        server.should_receive(:execute).
          with([server.executable, "--servername", server.name,
               "--remote-send", "ihello"])

        server.remote_send("ihello")
      end
    end

    describe "#serverlist" do
      it "uses the server's executable to list servers" do
        server.should_receive(:execute).
          with([server.executable, "--serverlist"]).and_return("VIM")

        server.serverlist
      end

      it "splits the servers into an array" do
        server.stub(:execute => "VIM\nVIM2")

        server.serverlist.should == ["VIM", "VIM2"]
      end
    end
  end
end
