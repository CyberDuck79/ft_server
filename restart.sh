docker stop ft_server > /dev/null
docker rm ft_server > /dev/null
docker build -t ft_server .
docker run -d -it -P --name=ft_server ft_server
docker ps