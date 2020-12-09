#### NetApp volumes and NFS exports
# # # #
resource "netapp-cloudmanager_volume" "cvo-nfs_vol1" {
  provider = netapp-cloudmanager
  volume_protocol = "nfs"
  name = "nfs_vol1"
  size = 10
  unit = "GB"
  aggregate_name = var.cloudmanager_aggregate_name
  provider_volume_type = "gp2"
  export_policy_type = "custom"
  export_policy_ip = ["0.0.0.0/0"]
  export_policy_nfs_version = ["nfs4"]
  working_environment_id = var.cloudmanager_working_environment_id
  client_id = var.cloudmanager_connector_client_id
}