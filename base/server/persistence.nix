{
  environment.persistence."/perm".users.pascal.directories = [ "docker" ];

  services.backup = {
    postScript = "systemctl start docker.service docker.socket";
    preScript = "systemctl stop docker.service docker.socket";

    targets = {
      "/home/pascal/docker".include = [ "**/.env" ];

      "/var/lib/docker/volumes" = {
        excludeRegex = [ "[0-9a-f]{64}" ];
        include = [ "*/" ];
      };
    };
  };
}
