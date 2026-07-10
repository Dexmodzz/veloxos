# VeloxOS — tema fish in stile DankMaterialShell (gnomeAdwaita / slate)
# Colori coerenti col tema kitty dank-material.conf.
# È uno snippet conf.d: applicato in automatico a ogni sessione interattiva.
# Per modificarlo, edita questo file (o sovrascrivi in ~/.config/fish/config.fish).

if status is-interactive
    # --- niente messaggio di benvenuto ---
    set -g fish_greeting ""

    # --- evidenziazione sintassi ---
    set -g fish_color_normal        e0e2e8
    set -g fish_color_command       98ccf9
    set -g fish_color_keyword       98ccf9
    set -g fish_color_quote         8de698
    set -g fish_color_redirection   7bdff4
    set -g fish_color_end           fba7ff
    set -g fish_color_error         ff888c
    set -g fish_color_param         c2c7ce
    set -g fish_color_option        c2c7ce
    set -g fish_color_comment       8c9198
    set -g fish_color_operator      7bdff4
    set -g fish_color_escape        fba7ff
    set -g fish_color_autosuggestion 6e6a86
    set -g fish_color_selection     --background=36363a
    set -g fish_color_search_match  --background=36363a
    set -g fish_color_valid_path    --underline

    # --- prompt di default fish ---
    set -g fish_color_cwd           ffc057
    set -g fish_color_user          8de698
    set -g fish_color_host          98ccf9

    # --- pager dei completamenti ---
    set -g fish_pager_color_prefix            98ccf9 --bold
    set -g fish_pager_color_completion        e0e2e8
    set -g fish_pager_color_description        8c9198
    set -g fish_pager_color_selected_background --background=36363a
end
