#### NetApp volumes and NFS exports
# # # #
variable "test-host-iqn" {
  description = "Value from hosts /etc/iscsi/initiatorname.iscsi"
  type = string
  default = "iqn.1994-05.com.redhat:23c8adc14014"
}


resource "netapp-cloudmanager_volume" "cvo-nfs_vol1" {
  provider = netapp-cloudmanager
  volume_protocol = "nfs"
  name = "nfs_vol1"
  size = 10
  unit = "GB"
  aggregate_name = data.terraform_remote_state.cvo-1.outputs.cm_aggregate-name
  provider_volume_type = "gp2"

  export_policy_type = "custom"
  export_policy_ip = ["0.0.0.0/0"]
  export_policy_nfs_version = ["nfs4"]

  working_environment_id = data.terraform_remote_state.cvo-1.outputs.cm_cvo-aws-id
  client_id = data.terraform_remote_state.cvo-1.outputs.cm_connector-aws-id
}

resource "netapp-cloudmanager_volume" "cvo-iscsi_vol1" {
  provider = netapp-cloudmanager
  volume_protocol = "iscsi"
  name = "iscsi_vol1"
  size = 10
  unit = "GB"
  aggregate_name = data.terraform_remote_state.cvo-1.outputs.cm_aggregate-name
  provider_volume_type = "gp2"
  enable_compression = false
  enable_deduplication = false

  igroups = ["test-host-1"]
  initiator {
    alias = "test-host-1"
    iqn = var.test-host-iqn
  }
  os_name = "linux"

  working_environment_id = data.terraform_remote_state.cvo-1.outputs.cm_cvo-aws-id
  client_id = data.terraform_remote_state.cvo-1.outputs.cm_connector-aws-id
}

resource "netapp-cloudmanager_volume" "cvo-iscsi_vol2" {
  provider = netapp-cloudmanager
  volume_protocol = "iscsi"
  name = "iscsi_vol2"
  size = 10
  unit = "GB"
  aggregate_name = data.terraform_remote_state.cvo-1.outputs.cm_aggregate-name
  provider_volume_type = "gp2"
  enable_compression = false
  enable_deduplication = false

  igroups = ["test-host-1"]
  initiator {
    alias = "test-host-1"
    iqn = var.test-host-iqn
  }
  os_name = "linux"

  working_environment_id = data.terraform_remote_state.cvo-1.outputs.cm_cvo-aws-id
  client_id = data.terraform_remote_state.cvo-1.outputs.cm_connector-aws-id
}


output "nfs_vol1_name" {
  value = netapp-cloudmanager_volume.cvo-nfs_vol1.name
}
output "nfs_vol1_id" {
  value = netapp-cloudmanager_volume.cvo-nfs_vol1.id
}

output "iscsi_vol1_name" {
  value = netapp-cloudmanager_volume.cvo-iscsi_vol1.name
}
output "iscsi_vol1_id" {
  value = netapp-cloudmanager_volume.cvo-iscsi_vol1.id
}

output "iscsi_vol2_name" {
  value = netapp-cloudmanager_volume.cvo-iscsi_vol2.name
}
output "iscsi_vol2_id" {
  value = netapp-cloudmanager_volume.cvo-iscsi_vol2.id
}
