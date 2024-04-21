import ./make-test-python.nix ({ pkgs, ... }: {
    name = "filebrowser";

    nodes = {
      machine = { ... }: {
        services.filebrowser.enable = true;
      };
    };

    testScript = ''
      start_all()

      machine.wait_for_unit("filebrowser.service")
      machine.succeed(
        'curl --fail --max-time 10 localhost:8080 | grep "File Browser"'
      )
    '';
  })

