docker-tools() {
    if [ $# -lt 1 ]
    then
        echo -e "Usage : docker-tools clean image[s] <term>"
        echo -e "        docker-tools clean instance[s] <field> <term>"
        echo -e "        docker-tools net ip <instance>"
        echo -e "        docker-tools net ports <instance>"
        echo -e "        docker-tools net all <instance>"
        echo -e "clean:"
        echo -e "Remove containers/images"
        echo -e "\tterm: the term to search for."
        echo -e "\tImage terms are matched on name, instance terms are matched on the given field ex. name, status".
        echo -e "\tvalid fields are: id, image, command, created, status, ports, name[s]"
        echo -e "net:"
        echo -e "Retrieve network attributes for a conatiner"
        echo -e "\tinstance: the container to target"
        echo -e "\tip: get the IP for the given container"
        echo -e "\tports: get the forwarded ports for the given container"
        echo -e "\tall: get the IP and forwarded ports for the given container"
    fi
    subcommand=$1
    case "$subcommand" in
        clean)
            kind=$2
            case "$kind" in
                image|images)
                    term=$3
                    docker rmi $(docker images | grep $term | awk '{print $3}');;
                instance|instances)
                    user_field=$3
                    term=$4
                    case "$user_field" in
                        id) field='{print $1}';;
                        image) field='{print $2}';;
                        command) field='{print $3}';;
                        created) field='{print $4}';;
                        status) field='{print $5}';;
                        ports) field='{print $6}';;
                        name[s]) field='{print $7}';;
                    esac
                    docker ps -a | grep $term | awk $field |tail -n +1;;
            esac;;
        net)
            info=$2
            container=$3
            case "$info" in
                ip) docker inspect --format '{{ .NetworkSettings.IPAddress }}' $container;;
                ports) docker inspect --format '{{range $index, $value := .NetworkSettings.Ports}}{{$index}} :: {{range $index, $value := $value}}{{$value.HostIp}}:{{$value.HostPort}}{{end}}{{end}}' $container;;
                all) docker inspect --format '{{.NetworkSettings.IPAddress}} - {{range $index, $value := .NetworkSettings.Ports}}    {{$index}} :: {{range $index, $value := $value}}{{$value.HostIp}}:{{$value.HostPort}}{{end}}{{end}}' $container;;
            esac;;
    esac
}

dockersh () {
	# Drops to bash shell in container from anywhere in compose subdir
	container=$1
	: ${container:=1} # set default of 1 if null
	p="p"
	docker exec -it $(docker-compose ps -q|sed -n $container$p) /bin/bash;
}
