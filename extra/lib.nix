lib: prev: {
  importCSV = file: let
    lines = lib.readFile file |> lib.splitString "\n" |> lib.filter (line: line != "");
    keys = lib.head lines |> lib.splitString ",";
    data = lib.tail lines |> lib.map (lib.splitString ",");
  in lib.map (line: lib.zipListsWith lib.nameValuePair keys line |> lib.listToAttrs) data;

  mkFirefoxBookmarks = lib.mapAttrsToList (
    name: value: if lib.isAttrs value then
      {
        inherit name;
        toolbar = name == "_toolbar";
        bookmarks = lib.mkFirefoxBookmarks value;
      }
    else
      {
        inherit name;
        url = value;
      }
  );

  mkFirefoxSearchEngines = lib.mapAttrs (
    name: url: if url == null then
      { metaData.hidden = true; }
    else
      {
        definedAliases = [ "@${name}" ];
        urls = [ { template = lib.replaceString "%s" "{searchTerms}" url; } ];
      }
  );

  mkMozillaExtensions = file: settings: lib.importJSON file
  |> lib.map (ext: {
    name = ext.id;

    value = {
      default_area = settings.${ext.name}.area or "menupanel";
      install_url = ext.source;
      installation_mode = "force_installed";
      private_browsing = settings.${ext.name}.private or false;
    };
  })
  |> lib.listToAttrs
  |> lib.mergeAttrs { "*".installation_mode = "blocked"; };

  mkNvimAutoCmds = cmds: lib.mapAttrsToList (
    event: command: if lib.isAttrs command then
      lib.mapAttrsToList (pattern: command: { inherit command event pattern; }) command
    else
      { inherit command event; }
  ) cmds
  |> lib.flatten;

  mkNvimFormatters = lib.mapAttrs (
    key: value: {
      command = lib.head value;
      prepend_args = lib.tail value;
    }
  );

  mkNvimKeymaps = maps: lib.mapAttrsToList (
    mode: keys: lib.mapAttrsToList (key: action: {
      inherit action key;
      mode = lib.stringToCharacters mode;
    }) keys
  ) maps
  |> lib.flatten;

  templateString = vars: let
    keys = lib.attrNames vars |> lib.map (key: "@${key}@");
    values = lib.attrValues vars |> lib.map toString;
  in lib.replaceStrings keys values;
}
