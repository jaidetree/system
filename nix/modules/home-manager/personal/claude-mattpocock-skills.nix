{ inputs, pkgs, lib, ... }:
{
  home.activation.linkMattPocockSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.bash}/bin/bash ${inputs.mattpocock-skills}/scripts/link-skills.sh
  '';
}
