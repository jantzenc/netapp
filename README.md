###POC Rig 1
Apply the modules ending in "-1" in order. Destroy them in reverse order
0. aws-1
0. cvo-1 (has dependency on aws-1 outputs)
0. devops-1 (dependencies on aws-1 and cvo-1 outputs)

### Manual iscsi mount steps (awslinux2)
```
yum -y update
yum -y install iscsi-initiator-utils  
service iscsid status
service iscsid start
# Get the new initiator name and then go update the 
# LUN initiator group in Terraform or in CM GUI before moving on
cat /etc/iscsi/initiatorname.iscsi
# Discover. [GATEWAY_IP] from CM Working Environment Information
/sbin/iscsiadm --mode discovery --type sendtargets --portal [GATEWAY_IP]:3260
# Connect. [ISCSI_TARGET]:[ISCSI_TARGET_NAME] from last command
iscsiadm --mode node -l all
# or:
sudo /sbin/iscsiadm --mode node --targetname [ISCSI_TARGET]:[ISCSI_TARGET_NAME] --portal [GATEWAY_IP]:3260,1 --login
# Rescan (maybe)
iscsiadm -m session --rescan
# Find devs
ls -l /dev/disk/by-path
```
### Manual format and mount steps
```
fdisk -l
echo 'type=83' |sfdisk /dev/sda
echo 'type=83' |sfdisk /dev/sdb
mkfs.xfs /dev/sda1
mkfs.xfs /dev/sdb1
mkdir /mnt/lun0
mkdir /mnt/lun1
mount /dev/sda1 /mnt/lun0
mount /dev/sdb1 /mnt/lun1
```

#### dd performance tests
##### Write throughput: 1G using 512K block size
`dd if=/dev/zero of=/mnt/yyz/test.img 
bs=512k count=2048 oflag=dsync`
##### Read throughput: 1G using 512K block size
`sysctl -w vm.drop_caches=3 && 
dd if=/mnt/yyz/test.img of=/dev/zero 
bs=512k count=2048 oflag=dsync`

##### Write latency: reported time / 1000 = ms
`dd if=/dev/zero of=/mnt/yyz/test.img 
bs=512 count=1000 oflag=dsync`
##### Read latency: reported time / 1000 = ms
`sysctl -w vm.drop_caches=3 && 
dd if=/mnt/yyz/test.img of=/dev/zero 
bs=512 count=1000 oflag=dsync`

### Annoyances / Questions
0. /cvo-1: Can we apply tags to the netapp-cloudmanager_connector_aws resource and its volumes?
0. /cvo-1: S3://fabric-pool-f8238a2b-3fae-11eb-91c8-db3687e95786
    + What creates this bucket? What is it for?  
    I have set capacity_tier = "NONE" for both the netapp-cloudmanager_cvo_aws and the 
    netapp-cloudmanager_aggregate
    + Can it be configured for encryption?
    + Can it be configured for access logging?
0. /devops-1: Bad behavior of resources created by TF
    + Missing Aggregate
    + Missing/disappearing LUNs and Volumes
