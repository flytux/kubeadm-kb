resource "local_file" "create_script" {
  depends_on = [terraform_data.init_master]
    content     = templatefile("${path.module}/artifacts/templates/install-registry.sh", {
		    master_ip = var.master_ip
		   })
    filename = "${path.module}/artifacts/kubeadm/scripts/install-registry.sh"
}

resource "terraform_data" "install_registry" {
  depends_on = [local_file.create_script]
  for_each = var.kubeadm_nodes

  connection {
    host        = "${var.prefix_ip}.${each.value.octetIP}"
    user        = "root"
    type        = "ssh"
    private_key = "${tls_private_key.generic-ssh-key.private_key_openssh}"
    timeout     = "2m"
  }

  provisioner "local-exec" {
    command = <<EOF
      openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout artifacts/kubeadm/certs/registry.key -out artifacts/kubeadm/certs/registry.crt \
      -subj "/CN=docker.kw01" -addext "subjectAltName=DNS:docker.kw01,DNS:*.kw01,IP:${var.master_ip}"
    EOF
  }

  provisioner "file" {
    source      = "artifacts/kubeadm/scripts/install-registry.sh"
    destination = "/root/kubeadm/scripts/install-registry.sh"
  }

  provisioner "file" {
    source      = "artifacts/kubeadm/certs"
    destination = "/root/kubeadm"
  }

  provisioner "remote-exec" {
    inline = [<<EOT
    
      sh kubeadm/scripts/install-registry.sh

    EOT
    ]
  }
}