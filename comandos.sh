##### KAFKA CONNECT #####

# entrar no container
docker exec -it kafka-connect bash



##### KAFKA BROKER #####

# entrar no container
docker exec -it broker bash
cd /bin
./kafka-topics --create --topic quickstart-events --bootstrap-server localhost:9092


##### KAFKACAT #####

