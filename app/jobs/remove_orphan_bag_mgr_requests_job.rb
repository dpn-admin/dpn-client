class RemoveOrphanBagMgrRequestsJob < ActiveJob::Base
  queue_as :default

  def perform(local_namespace = Rails.configuration.local_namespace)
    local_node = Node.find_by_namespace!(local_namespace)
    client = FrequentApple.client(local_node.api_root, local_node.auth_credential)

    wayne_transfers = ReplicationTransfer
        .joins(:replication_status)
        .where(to_node: local_node)
        .where(replication_statuses: {name: [:cancelled, :stored, :rejected]})
        .where.not(bag_mgr_request_id: nil)

    wayne_transfers.each do |parent|
      response = client.delete("/bag_mgr/requests/#{parent.bag_mgr_request_id}")
      if response.ok? || response.status == 404 # 404 could indicate it's already been deleted
        parent.bag_mgr_request_id = nil
        parent.save!
      end
    end
  end
end
