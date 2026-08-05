# VeloxOS: guard against bare `bootc upgrade`. See
# /etc/profile.d/velox-bootc-upgrade-guard.sh for the rationale (kept in
# sync manually — this is the fish equivalent of that bash guard).

function _velox_bootc_upgrade_blocked
    test "$argv[1]" = upgrade; or return 1
    if contains -- --check $argv
        return 1
    end
    echo "VeloxOS: 'bootc upgrade' won't find newer builds — each build ships under its own image tag." >&2
    echo "Use 'sudo velox upgrade' to check for and apply the latest VeloxOS build." >&2
    echo "(Run 'command sudo bootc upgrade' to bypass this.)" >&2
    return 0
end

function bootc
    if _velox_bootc_upgrade_blocked $argv
        return 1
    end
    command bootc $argv
end

function sudo
    if test "$argv[1]" = bootc
        if _velox_bootc_upgrade_blocked $argv[2..-1]
            return 1
        end
        command sudo bootc $argv[2..-1]
        return
    end
    command sudo $argv
end
