apply: 
	terraform apply -var "token=$$(curl https://discovery.etcd.io/new?size=1)"

plan: 
	terraform plan -var "token=$$(curl https://discovery.etcd.io/new?size=1)"

.PHONY: apply plan
