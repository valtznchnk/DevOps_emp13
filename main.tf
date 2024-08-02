terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = file("/root/key.json")
  cloud_id = "b1gu7174canjcro9e9l7"
  folder_id = "b1gl3iani8oqt0tp1rli"
  zone = "ru-central1-a"
}

resource "yandex_compute_disk" "boot-disk-1" {
  name     = "boot-disk-1"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "20"
  image_id = "fd8t2tl92i4i96khgg06"
}

resource "yandex_compute_disk" "boot-disk-2" {
  name     = "boot-disk-2"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "20"
  image_id = "fd8t2tl92i4i96khgg06"
}

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  network_interface {
    subnet_id = "e9bljefmp3smnc0tvact"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/root/.ssh/id_ed25519.pub")}"
    user-data = <<-EOF
      #cloud-config
      users:
        - name: ubuntu
          groups: [sudo]
          shell: /bin/bash
    EOF
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y maven git",
      "sudo wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.91/bin/apache-tomcat-9.0.91.tar.gz",
      "tar zxvf apache-tomcat-*.tar.gz -C /opt/tomcat --strip-components 1",
      "/opt/tomcat/bin/startup.sh",
      "mkdir -p ~/mywebapp1 && cd ~/mywebapp1 && sudo git pull https://github.com/valtznchnk/DevOps_emp_11_3.git",
      "mvn package",
      "scp -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519 ~/mywebapp/target/hello-1.0.war ubuntu@{yandex_compute_instance.vm-2.network_interface.0.nat_ip_address}}:'scp -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519 hello-1.0.war ubuntu@{yandex_compute_instance.vm-2.network_interface.0.nat_ip_address}}:/usr/local/tomcat/webapps/'",
      "/opt/tomcat/bin/shutdown.sh && /opt/tomcat/bin/startup.sh"

    ]

    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/root/.ssh/id_ed25519")
      host     = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
    }
  }
}

resource "yandex_compute_instance" "vm-2" {
  name = "terraform2"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-2.id
  }

  network_interface {
    subnet_id = "e9bljefmp3smnc0tvact"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("/root/.ssh/id_ed25519.pub")}"
    user-data = <<-EOF
      #cloud-config
      users:
        - name: ubuntu
          groups: [sudo]
          shell: /bin/bash
    EOF
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y maven git",
      "sudo wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.91/bin/apache-tomcat-9.0.91.tar.gz",
      "tar zxvf apache-tomcat-*.tar.gz -C /opt/tomcat --strip-components 1",
      "/opt/tomcat/bin/shutdown.sh && /opt/tomcat/bin/startup.sh",
    ]

    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/root/.ssh/id_ed25519")
      host     = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
    }
  }
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

output "external_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}
