docker build -t ft_server .
docker run -d -it -P --name=ft_server ft_server
docker ps