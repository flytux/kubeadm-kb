variable "password" { default = "linux" }

variable "network_name" { default = "nat10710" }

variable "prefix_ip" { default = "10.71.0" }

variable "master_ip" { default = "10.71.0.101" }

variable "network_domain_name" { default = "kubeworks.net" }

variable "cloud_image_name" { default = "focal-server-cloudimg-amd64.img" }

variable "disk_pool" { default = "default" }

variable "qemu_connect" { default = "qemu:///system" }

variable "join_cmd" { default = "$(ssh -i $HOME/.ssh/id_rsa.key -o StrictHostKeyChecking=no 10.71.0.101 -- cat join_cmd)" }

variable "kubeadm_nodes" { 

  type = map(object({ role = string, octetIP = string , vcpu = number, memoryMB = number, incGB = number}))
  default = { 
              kb-master-1 = { role = "master-init",   octetIP = "101" , vcpu = 2, memoryMB = 1024 * 8, incGB = 30},
              kb-worker-1 = { role = "worker",        octetIP = "201" , vcpu = 2, memoryMB = 1024 * 8, incGB = 30}
              kb-master-2 = { role = "master-member", octetIP = "102" , vcpu = 2, memoryMB = 1024 * 8, incGB = 30}
  }
}
