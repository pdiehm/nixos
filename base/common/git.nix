{
  home-manager.users.pascal.programs = {
    delta = {
      enable = true;
      enableGitIntegration = true;
    };

    git = {
      enable = true;

      settings = {
        init.defaultBranch = "main";
        pull.rebase = true;
        rebase.autoStash = true;
        submodule.recurse = true;

        alias = {
          a = "add";
          ae = "add --edit";
          af = "add --force";
          ap = "add --patch";
          au = "add --update";

          b = "branch";
          bc = "branch --copy";
          bd = "branch --delete";
          bdf = "branch --delete --force";
          bm = "branch --move";
          br = "branch --remotes";
          bu = "branch --set-upstream-to";

          bs = "bisect";
          bsb = "bisect bad";
          bsg = "bisect good";
          bsr = "bisect reset";
          bss = "bisect start";
          bsv = "bisect view";

          c = "commit";
          ca = "commit --all";
          cac = "commit --all --amend --no-edit";
          cace = "commit --all --amend";
          cacm = "commit --all --amend --message";
          cam = "commit --all --message";
          cc = "commit --amend --no-edit";
          cce = "commit --amend";
          ccm = "commit --amend --message";
          ce = "commit --allow-empty";
          cem = "commit --allow-empty --message";
          cm = "commit --message";

          cl = "clean -fdx";
          cli = "clean -fdX";

          cn = "clone";
          cns = "clone --depth 1";

          co = "checkout";
          cob = "checkout -b";

          cp = "cherry-pick";
          cpa = "cherry-pick --abort";
          cpc = "cherry-pick --continue";
          cpn = "cherry-pick --no-commit";

          d = "diff";
          dm = "diff main";
          ds = "diff --staged";
          du = "diff '@{u}'";

          dl = "rev-list --left-right --oneline";
          dlm = "rev-list --left-right --oneline '...main'";
          dlu = "rev-list --left-right --oneline '...@{u}'";

          f = "fetch";

          i = "init";

          l = "log --format='%C(yellow)%h %C(blue)%aN, %ah %C(reset)%s%C(dim white)%d'";
          ll = "log --format='%C(yellow)%h %C(white)%s%C(dim white)%d%n%C(blue)%aN <%aE>, %ah %C(reset)- %C(green)(%G?) %GS%n'";
          lll = "log --format='%C(yellow)Commit %H%C(dim white)%d%n%C(blue)Author:    %aN <%aE> on %aD%n%C(blue)Committer: %cN <%cE> on %cD%n%C(green)Signature: (%G?) %GS%n%n%B%n'";
          lp = "log --patch";

          m = "merge";
          ma = "merge --abort";
          mc = "merge --continue";
          mn = "merge --no-commit";

          pf = "push --force-with-lease";
          ps = "push";
          psa = "push --all";
          psd = "push --delete";

          pl = "pull";

          rb = "rebase";
          rba = "rebase --abort";
          rbc = "rebase --continue";
          rbi = "rebase --interactive";
          rbm = "rebase --interactive main";
          rbr = "rebase --interactive --root";
          rbu = "rebase --interactive '@{u}'";

          rl = "reflog";

          rs = "restore";
          rss = "restore --staged";

          rt = "reset";
          rth = "reset --hard";
          rtu = "reset --hard '@{u}'";

          rv = "revert";
          rva = "revert --abort";
          rvc = "revert --continue";
          rvn = "revert --no-commit";

          s = "status";
          ss = "status --short";

          st = "stash push --include-untracked";
          sta = "stash apply";
          stb = "stash branch";
          stc = "stash clear";
          std = "stash drop";
          stl = "stash list";
          stm = "stash push --include-untracked --message";
          stp = "stash pop";
          sts = "stash show --include-untracked --patch";

          sh = "show";

          t = "tag";
          td = "tag --delete";
          tm = "tag --message";
        };

        fetch = {
          prune = true;
          pruneTags = true;
        };

        push = {
          autoSetupRemote = true;
          followTags = true;
        };

        url = {
          "git@github.com:".insteadOf = "gh:";
          "git@github.com:pdiehm/".insteadOf = "gh:/";
        };

        user = {
          email = "pdiehm8@gmail.com";
          name = "Pascal Diehm";
        };
      };
    };
  };
}
