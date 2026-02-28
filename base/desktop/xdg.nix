{
  home-manager.users.pascal.xdg = {
    enable = true;

    mimeApps = {
      enable = true;

      defaultApplications = {
        "application/gzip" = "org.kde.ark.desktop";
        "application/json" = "firefox.desktop";
        "application/pdf" = "firefox.desktop";
        "application/vnd.efi.iso" = "org.kde.ark.desktop";
        "application/x-compressed-tar" = "org.kde.ark.desktop";
        "application/x-cpio" = "org.kde.ark.desktop";
        "application/x-tar" = "org.kde.ark.desktop";
        "application/xml" = "firefox.desktop";
        "application/zip" = "org.kde.ark.desktop";
        "audio/aac" = "mpv.desktop";
        "audio/flac" = "mpv.desktop";
        "audio/mp4" = "mpv.desktop";
        "audio/mpeg" = "mpv.desktop";
        "audio/vnd.wav" = "mpv.desktop";
        "audio/webm" = "mpv.desktop";
        "audio/x-matroska" = "mpv.desktop";
        "image/bmp" = "org.kde.gwenview.desktop";
        "image/gif" = "org.kde.gwenview.desktop";
        "image/jpeg" = "org.kde.gwenview.desktop";
        "image/png" = "org.kde.gwenview.desktop";
        "image/svg+xml" = "org.kde.gwenview.desktop";
        "image/vnd.microsoft.icon" = "org.kde.gwenview.desktop";
        "image/webp" = "org.kde.gwenview.desktop";
        "inode/directory" = "org.kde.dolphin.desktop";
        "inode/mount-point" = "org.kde.dolphin.desktop";
        "text/calendar" = "thunderbird.desktop";
        "text/html" = "firefox.desktop";
        "text/markdown" = "firefox.desktop";
        "text/plain" = "firefox.desktop";
        "video/mp4" = "mpv.desktop";
        "video/quicktime" = "mpv.desktop";
        "video/vnd.avi" = "mpv.desktop";
        "video/webm" = "mpv.desktop";
        "video/x-flv" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/mailto" = "thunderbird.desktop";
      };
    };

    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = null;
      documents = null;
      music = null;
      pictures = null;
      publicShare = null;
      templates = null;
      videos = null;
    };
  };
}
