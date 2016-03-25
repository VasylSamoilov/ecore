apply: 
	terraform apply -var "token=$$(curl https://discovery.etcd.io/new?size=1)" -var "admin_location=$$(curl -s ipinfo.io/ip)/32"

plan: 
	terraform plan -var "token=$$(curl https://discovery.etcd.io/new?size=1)" -var "admin_location=$$(curl -s ipinfo.io/ip)/32"

.PHONY: apply plan
