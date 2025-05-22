# Proxy EC2 Instances
resource "aws_instance" "proxy" {
  count                  = length(var.public_subnet_ids)
  ami                    = var.proxy_ami
  instance_type          = var.proxy_instance_type
  subnet_id              = var.public_subnet_ids[count.index]
  vpc_security_group_ids = [var.proxy_security_group_id]
  key_name               = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd mod_proxy_html -y
    systemctl start httpd
    systemctl enable httpd

    echo "LoadModule proxy_module modules/mod_proxy.so" >> /etc/httpd/conf.modules.d/00-proxy.conf
    echo "LoadModule proxy_http_module modules/mod_proxy_http.so" >> /etc/httpd/conf.modules.d/00-proxy.conf

    cat <<EOP > /etc/httpd/conf.d/reverse-proxy.conf
    <VirtualHost *:80>
      ServerAdmin webmaster@localhost
      DocumentRoot /var/www/html

      ProxyPreserveHost On
      ProxyPass / http://BACKEND_IP:80/
      ProxyPassReverse / http://BACKEND_IP:80/

      ErrorLog /var/log/httpd/error.log
      CustomLog /var/log/httpd/access.log combined
    </VirtualHost>
    EOP

    systemctl restart httpd
  EOF

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-proxy-${count.index + 1}"
    }
  )
}

# Backend EC2 Instances
resource "aws_instance" "backend" {
  count                  = length(var.private_subnet_ids)
  ami                    = var.backend_ami
  instance_type          = var.backend_instance_type
  subnet_id              = var.private_subnet_ids[count.index]
  vpc_security_group_ids = [var.backend_security_group_id]
  key_name               = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd -y
    systemctl start httpd
    systemctl enable httpd

    cat <<EOT > /var/www/html/index.html
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>NTI Backend Server</title>
          <style>
        body {
          background-image: url('https://images.unsplash.com/photo-1507525428034-b723cf961d3e');
          background-size: cover;
          background-position: center;
          background-repeat: no-repeat;
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          text-align: center;
          padding: 60px;
          color: #ffffff;
        }
        h1 {
          font-size: 56px;
          margin-bottom: 10px;
          color: #ffffff;
          text-shadow: 2px 2px 4px #000000;
        }
        h2 {
          font-size: 28px;
          margin-bottom: 10px;
          color: #ffffff;
          text-shadow: 1px 1px 2px #000000;
        }
        p {
          font-size: 18px;
          margin: 10px 0;
          text-shadow: 1px 1px 2px #000000;
        }
        .footer {
          margin-top: 40px;
          font-size: 16px;
          color: #e2e8f0;
          text-shadow: 1px 1px 2px #000000;
        }
      </style>
    </head>
    <body>
      <h1>NTI</h1>
      <h2>Welcome to Backend Server $(hostname)</h2>
      <p><strong> Yasmeen </strong></p>
      <p><strong>Supervised by Eng: Mohamed Swelam</strong></p>
      <div class="footer">Powered by AWS & Terraform</div>
    </body>
    </html>
    EOT
    systemctl restart httpd
  EOF

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-backend-${count.index + 1}"
    }
  )
}

# Null resource to configure reverse proxy after provisioning
resource "null_resource" "configure_proxy" {
  count = length(aws_instance.proxy)

  triggers = {
    proxy_instance_id   = aws_instance.proxy[count.index].id
    backend_instance_id = aws_instance.backend[count.index % length(aws_instance.backend)].id
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_path)
    host        = aws_instance.proxy[count.index].public_ip
  }

  provisioner "remote-exec" {
    inline = [
      # Wait for config file to exist
      "for i in {1..10}; do [ -f /etc/httpd/conf.d/reverse-proxy.conf ] && break || sleep 5; done",
      # Replace BACKEND_IP placeholder
      "sudo sed -i 's|BACKEND_IP|${aws_instance.backend[count.index % length(aws_instance.backend)].private_ip}|' /etc/httpd/conf.d/reverse-proxy.conf",
      # Restart Apache
      "sudo systemctl restart httpd"
    ]
  }

  depends_on = [
    aws_instance.proxy,
    aws_instance.backend
  ]
}

