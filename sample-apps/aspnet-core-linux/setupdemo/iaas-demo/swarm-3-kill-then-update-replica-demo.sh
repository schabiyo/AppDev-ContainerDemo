#this demo is meant to run interactively.  Initially the docker-stack.yml file has just 1 REPLICA
# One show CURL http://{YOUR Load balanced IP here}:81
# we are going to kill that running containerby command

#service name = replica count.  To get service name run "docker service ls""
docker service scale aspnet_web=5